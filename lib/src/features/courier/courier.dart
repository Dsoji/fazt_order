import 'dart:async'; // Add this import for Timer
import 'dart:convert';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:fazt_order/src/common/widgets/custom_textfield.dart';
import 'package:fazt_order/src/common/widgets/reusbale_dropdown_widget.dart';
import 'package:fazt_order/src/features/courier/parcel_confirm_details.dart';
import 'package:fazt_order/src/features/order/parcel_order_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../common/app_colors.dart' as app_theme;
import '../../common/res/app_colors.dart';
import '../../common/utils/validator.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/payload/courier_payload.dart';
import 'widgets/parcel_quote_card.dart';

final logger = Logger();

class CourierView extends HookConsumerWidget {
  const CourierView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final isSending = useState(true);

    // Add this effect to update isSending when tab changes
    useEffect(() {
      tabController.addListener(() {
        isSending.value = tabController.index == 0;
      });
      return null;
    }, [tabController]);

    final pickUpController = useTextEditingController();
    final deliveryController = useTextEditingController();
    final pickUpFocus = useFocusNode();
    final deliveryFocus = useFocusNode();
    final pickUpPlaces = useState<List<dynamic>>([]);
    final deliveryPlaces = useState<List<dynamic>>([]);
    // The address a suggestion put in the field. Writing to the controller
    // makes FormBuilderTextField fire onChanged again, which would search for
    // the address the user just picked and re-open the list under their
    // finger; holding on to the chosen text lets that echo be ignored. Cleared
    // the moment the user types something else, so the field searches again as
    // soon as it is genuinely active.
    final pickUpSelected = useState<String?>(null);
    final deliverySelected = useState<String?>(null);
    final isLoading = useState(false);
    final instructionsController = useTextEditingController();
    final promoCodeController = useTextEditingController();
    final promoCodeMessage = useState<String?>(null);
    final promoCodeIsError = useState(false);
    final nameController = useTextEditingController();
    final phoneNumberController = useTextEditingController();
    final emailController = useTextEditingController();
    final nameController2 = useTextEditingController();
    final phoneNumberController2 = useTextEditingController();
    final emailController2 = useTextEditingController();

    // Place Details
    final pickUpLat = useState('');
    final pickUpLong = useState('');
    final pickUpCity = useState('');
    final pickUpState = useState('');

    final deliveryLat = useState('');
    final deliveryLong = useState('');
    final deliveryCity = useState('');
    final deliveryState = useState('');

    // For debouncing search input - improved approach
    final debounceTimer = useRef<Timer?>(null);

    // Improved API key access
    final String? apiKey = dotenv.env['MAP_KEY'];

    // Add null check for API key
    if (apiKey == null) {
      print('Error: MAP_KEY not found in environment variables');
    }

    // The Courier badge is fetched once per visit. It is decoration — a failed
    // fetch just means no badge, which is indistinguishable from none being
    // configured.
    useEffect(() {
      Future.microtask(
        () => ref.read(shopControllerProvider.notifier).fetchParcelPromotion(),
      );
      return null;
    }, const []);

    // Re-price whenever both ends of the journey are known. Quoting here rather
    // than only on the confirm screen is the point of the endpoint: the user
    // sees what the delivery costs before committing to it, promotion included.
    useEffect(() {
      final pLat = num.tryParse(pickUpLat.value);
      final pLong = num.tryParse(pickUpLong.value);
      final dLat = num.tryParse(deliveryLat.value);
      final dLong = num.tryParse(deliveryLong.value);
      if (pLat == null || pLong == null || dLat == null || dLong == null) {
        return null;
      }
      Future.microtask(
        () => ref.read(shopControllerProvider.notifier).quoteParcel(
              pickUpAddress: pickUpController.text,
              pickUpLat: pLat,
              pickUpLong: pLong,
              deliveryAddress: deliveryController.text,
              deliveryLat: dLat,
              deliveryLong: dLong,
              promoCode: promoCodeController.text.trim().isEmpty
                  ? null
                  : promoCodeController.text.trim(),
            ),
      );
      return null;
    }, [
      pickUpLat.value,
      pickUpLong.value,
      deliveryLat.value,
      deliveryLong.value,
      promoCodeController.text,
    ]);

    final parcelQuote =
        ref.watch(shopControllerProvider).parcelQuote.valueOrNull?.quote;
    useEffect(() {
      final enteredCode = promoCodeController.text.trim();
      if (enteredCode.isEmpty) {
        promoCodeMessage.value = null;
        promoCodeIsError.value = false;
        return null;
      }

      final error = (parcelQuote?.promoCodeError ?? '').trim();
      if (error.isNotEmpty) {
        promoCodeIsError.value = true;
        promoCodeMessage.value = error;
        return null;
      }

      final applied = (parcelQuote?.appliedPromoCode ?? '').trim();
      if (applied.isNotEmpty) {
        promoCodeIsError.value = false;
        promoCodeMessage.value = 'Promo code applied successfully.';
        return null;
      }

      final status = (parcelQuote?.promoCodeStatus ?? '').trim();
      if (status.isNotEmpty &&
          (status.toLowerCase() == 'valid_but_not_winning' ||
              status.toLowerCase() == 'valid_but_lost')) {
        promoCodeIsError.value = false;
        promoCodeMessage.value =
            'This promo code is valid, but a better discount is already active on your order.';
        return null;
      }

      return null;
    }, [
      parcelQuote?.promoCodeError,
      parcelQuote?.promoCodeStatus,
      parcelQuote?.appliedPromoCode,
      promoCodeController.text,
    ]);

    // Cleanup timer on dispose
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    Future<void> searchPickUpPlaces(String query) async {
      if (query.isEmpty) {
        pickUpPlaces.value = [];
        return;
      }

      isLoading.value = true;

      const url = 'https://places.googleapis.com/v1/places:autocomplete';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey ?? '',
            'X-Goog-FieldMask':
                'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
          },
          body: jsonEncode({
            'input': query,
            'regionCode': 'NG',
            'languageCode': 'en',
          }),
        );

        final json = jsonDecode(response.body);
        if (response.statusCode == 200 && json['suggestions'] != null) {
          // A reply that lands after the user has picked an address or left
          // the field must not re-open the list.
          if (pickUpSelected.value != null || !pickUpFocus.hasFocus) {
            pickUpPlaces.value = [];
            return;
          }
          pickUpPlaces.value = List<dynamic>.from(json['suggestions']);
        } else {
          print(
              'Error fetching places: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> searchDeliveryPlaces(String query) async {
      if (query.isEmpty) {
        deliveryPlaces.value = [];
        return;
      }

      isLoading.value = true;

      const url = 'https://places.googleapis.com/v1/places:autocomplete';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey ?? '',
            'X-Goog-FieldMask':
                'suggestions.placePrediction.placeId,suggestions.placePrediction.text',
          },
          body: jsonEncode({
            'input': query,
            'regionCode': 'NG',
            'languageCode': 'en',
          }),
        );

        final json = jsonDecode(response.body);
        if (response.statusCode == 200 && json['suggestions'] != null) {
          // A reply that lands after the user has picked an address or left
          // the field must not re-open the list.
          if (deliverySelected.value != null || !deliveryFocus.hasFocus) {
            deliveryPlaces.value = [];
            return;
          }
          deliveryPlaces.value = List<dynamic>.from(json['suggestions']);
        } else {
          print(
              'Error fetching places: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getPickUpPlaceDetails(String placeId) async {
      isLoading.value = true;

      final url =
          'https://places.googleapis.com/v1/places/$placeId?languageCode=en&regionCode=NG';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'X-Goog-Api-Key': apiKey ?? '',
            'X-Goog-FieldMask':
                'id,displayName,formattedAddress,location,addressComponents',
          },
        );

        final json = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final result = json;
          final location = result['location'];
          String? foundCity;
          String? foundState;

          if (result['addressComponents'] is List) {
            for (var component in result['addressComponents']) {
              final List types = (component['types'] ?? []) as List;
              if (types.contains('locality')) {
                foundCity = component['longText'] ?? component['shortText'];
              }
              if (types.contains('administrative_area_level_1')) {
                foundState = component['longText'] ?? component['shortText'];
              }
            }
          }

          pickUpLat.value = (location?['latitude'] ?? '').toString();
          pickUpLong.value = (location?['longitude'] ?? '').toString();
          pickUpCity.value = foundCity ?? '';
          pickUpState.value = foundState ?? '';

          logger.i('Pickup - Latitude: ${pickUpLat.value}');
          logger.i('Pickup - Longitude: ${pickUpLong.value}');
          logger.i('Pickup - City: ${pickUpCity.value}');
          logger.i('Pickup - State: ${pickUpState.value}');
        } else {
          print(
              'Error fetching pickup place details: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('Error fetching pickup place details: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getDeliveryPlaceDetails(String placeId) async {
      isLoading.value = true;

      final url =
          'https://places.googleapis.com/v1/places/$placeId?languageCode=en&regionCode=NG';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'X-Goog-Api-Key': apiKey ?? '',
            'X-Goog-FieldMask':
                'id,displayName,formattedAddress,location,addressComponents',
          },
        );

        final json = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final result = json;
          final location = result['location'];
          String? foundCity;
          String? foundState;

          if (result['addressComponents'] is List) {
            for (var component in result['addressComponents']) {
              final List types = (component['types'] ?? []) as List;
              if (types.contains('locality')) {
                foundCity = component['longText'] ?? component['shortText'];
              }
              if (types.contains('administrative_area_level_1')) {
                foundState = component['longText'] ?? component['shortText'];
              }
            }
          }

          deliveryLat.value = (location?['latitude'] ?? '').toString();
          deliveryLong.value = (location?['longitude'] ?? '').toString();
          deliveryCity.value = foundCity ?? '';
          deliveryState.value = foundState ?? '';

          logger.i('Delivery - Latitude: ${deliveryLat.value}');
          logger.i('Delivery - Longitude: ${deliveryLong.value}');
          logger.i('Delivery - City: ${deliveryCity.value}');
          logger.i('Delivery - State: ${deliveryState.value}');
        } else {
          print(
              'Error fetching delivery place details: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('Error fetching delivery place details: $e');
      } finally {
        isLoading.value = false;
      }
    }

    final selectedPackageType = useState<String?>(null);

    /// Wipes the journey — both addresses, everything resolved from them, and
    /// the price quoted for them.
    ///
    /// Called on the way off this screen: an address left in the field after
    /// the user has gone elsewhere is stale by the time they come back, and a
    /// half-filled form is easy to submit without noticing.
    void clearAddressFields() {
      debounceTimer.value?.cancel();
      pickUpController.clear();
      deliveryController.clear();
      pickUpPlaces.value = [];
      deliveryPlaces.value = [];
      pickUpSelected.value = null;
      deliverySelected.value = null;
      pickUpLat.value = '';
      pickUpLong.value = '';
      pickUpCity.value = '';
      pickUpState.value = '';
      deliveryLat.value = '';
      deliveryLong.value = '';
      deliveryCity.value = '';
      deliveryState.value = '';
      ref.read(shopControllerProvider.notifier).clearParcelQuote();
    }

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFED9900),
        statusBarIconBrightness: Brightness.light,
      ));
      return () {
        // Optional: Reset on dispose if needed
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      };
    }, []);
    // ---- Reusable UI helpers (presentation only) ----
    Widget sectionCard({
      required Widget child,
      EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    }) {
      return Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral900),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
    }

    Widget sectionHeader(IconData icon, String title, {String? subtitle}) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.brand980,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.brand400),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral200,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral950,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(96),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFDDB7), // Light orange
                Color(0xFFED9900), // Darker orange
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Parcel Delivery",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3E2723), // Dark brown
                            height: 1.1,
                          ),
                        ),
                        Gap(4),
                        Text(
                          "Send and receive packages with ease",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6D4C41), // Muted brown
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC), // Light cream
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3E2723), // Dark brown outline
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      size: 26,
                      color: Color(0xFF3E2723), // Dark brown
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(children: [
          ParcelPromotionBanner(
            promotion: ref
                .watch(shopControllerProvider)
                .parcelPromotion
                .valueOrNull,
          ),
          if (ref
                  .watch(shopControllerProvider)
                  .parcelPromotion
                  .valueOrNull
                  ?.hasBadge ==
              true)
            const Gap(16),
          OutlinButton(
            text: "Order History",
            width: double.infinity,
            height: 50,
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParcelOrderHistory()));
              if (!context.mounted) return;
              clearAddressFields();
            },
            color: AppColors.brand400,
            bgColor: Colors.white,
          ),
          const Gap(20),
          SegmentedTabControl(
            tabPadding: const EdgeInsets.all(0),
            controller: tabController,
            tabTextColor: AppColors.neutral500,
            selectedTabTextColor: Colors.black,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral500,
            ),
            barDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorDecoration: BoxDecoration(
              color: AppColors.brand900,
              borderRadius: BorderRadius.circular(30),
            ),
            tabs: const [
              SegmentTab(label: "Sending"),
              SegmentTab(label: "Receiving"),
            ],
          ),
          const Gap(20),
          sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionHeader(
                  Icons.route_outlined,
                  'Delivery Route',
                  subtitle: 'Where should we pick up and drop off?',
                ),
                const Gap(20),
                FixedTimeline.tileBuilder(
            theme: TimelineThemeData(
              nodePosition: 0,
              indicatorTheme: const IndicatorThemeData(
                position: 0,
                size: 20.0,
              ),
              connectorTheme: const ConnectorThemeData(
                thickness: 2.0,
                color: AppColors.green400,
              ),
            ),
            builder: TimelineTileBuilder.connected(
              itemCount: 2,
              connectorBuilder: (context, index, type) {
                return const DashedLineConnector(
                  color: AppColors.green400,
                  gap: 2.0,
                  dash: 4.0,
                );
              },
              indicatorBuilder: (context, index) {
                return index == 0
                    ? const DotIndicator(
                        color: AppColors.green400,
                        child: Icon(Icons.check, color: Colors.white, size: 12),
                      )
                    : const OutlinedDotIndicator(
                        borderWidth: 2.0,
                        color: AppColors.orange800,
                      );
              },
              contentsBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 16.0), // Reduced bottom padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Pick Up Address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const Gap(16),
                        CustomFormTextField(
                          hintText: 'Enter pick up address',
                          fieldName: 'pickup_address',
                          keyboardType: TextInputType.text,
                          controller: pickUpController,
                          focus: pickUpFocus,
                          onChanged: (text) {
                            debounceTimer.value?.cancel();
                            // The echo of our own write after a suggestion was
                            // tapped — nothing to search for.
                            if (text != null && text == pickUpSelected.value) {
                              return;
                            }
                            pickUpSelected.value = null;
                            debounceTimer.value =
                                Timer(const Duration(milliseconds: 400), () {
                              if (text != null) {
                                searchPickUpPlaces(text);
                              }
                            });
                          },
                          validator: (val) {
                            if (val is String) {
                              return Validators.requiredField(
                                  val, 'pickup_address');
                            }
                            return 'Please enter a valid address';
                          },
                        ),
                        if (pickUpPlaces.value.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              maxHeight:
                                  200, // Use maxHeight instead of fixed height
                              minHeight: 50,
                            ),
                            child: SingleChildScrollView(
                              // Add scroll for overflow
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: pickUpPlaces.value.map((place) {
                                  final pp = place['placePrediction'];
                                  final displayText =
                                      pp?['text']?['text'] ?? '';
                                  final placeId = pp?['placeId'] ?? '';

                                  return ListTile(
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    title: Text(
                                      displayText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      if (placeId.isNotEmpty) {
                                        debounceTimer.value?.cancel();
                                        pickUpSelected.value = displayText;
                                        getPickUpPlaceDetails(placeId);
                                        pickUpController.text = displayText;
                                        pickUpPlaces.value = [];
                                        // Close the list and give the keyboard
                                        // back; typing in the field again is
                                        // what re-opens it.
                                        pickUpFocus.unfocus();
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 16.0), // Reduced bottom padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Delivery Address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const Gap(16),
                        CustomFormTextField(
                          hintText: 'Enter delivery address',
                          fieldName: 'delivery_address',
                          keyboardType: TextInputType.text,
                          controller: deliveryController,
                          focus: deliveryFocus,
                          onChanged: (text) {
                            debounceTimer.value?.cancel();
                            // The echo of our own write after a suggestion was
                            // tapped — nothing to search for.
                            if (text != null &&
                                text == deliverySelected.value) {
                              return;
                            }
                            deliverySelected.value = null;
                            debounceTimer.value =
                                Timer(const Duration(milliseconds: 400), () {
                              if (text != null) {
                                searchDeliveryPlaces(text);
                              }
                            });
                          },
                          validator: (val) {
                            if (val is String) {
                              return Validators.requiredField(
                                  val, 'delivery_address');
                            }
                            return 'Please enter a valid address';
                          },
                        ),
                        if (deliveryPlaces.value.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              maxHeight:
                                  200, // Use maxHeight instead of fixed height
                              minHeight: 50,
                            ),
                            child: SingleChildScrollView(
                              // Add scroll for overflow
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: deliveryPlaces.value.map((place) {
                                  final pp = place['placePrediction'];
                                  final displayText =
                                      pp?['text']?['text'] ?? '';
                                  final placeId = pp?['placeId'] ?? '';

                                  return ListTile(
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    title: Text(
                                      displayText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      if (placeId.isNotEmpty) {
                                        debounceTimer.value?.cancel();
                                        deliverySelected.value = displayText;
                                        getDeliveryPlaceDetails(placeId);
                                        deliveryController.text = displayText;
                                        deliveryPlaces.value = [];
                                        // Close the list and give the keyboard
                                        // back; typing in the field again is
                                        // what re-opens it.
                                        deliveryFocus.unfocus();
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },
                ),
                ),
              ],
            ),
          ),
          const Gap(20),
          sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionHeader(
                  Icons.inventory_2_outlined,
                  'Parcel Details',
                  subtitle: 'Tell us what you are sending',
                ),
                const Gap(20),
                ReusableDropdown(
                    label: 'Parcel Type',
                    hintText: 'Standard Package',
                    selectedValue: selectedPackageType.value,
                    items: const [
                      'Standard Package',
                      'Fragile Package',
                    ],
                    onChanged: (value) {
                      selectedPackageType.value = value;
                    }),
                const Gap(16),
                CustomFormTextField(
                  hintText: 'Instructions',
                  labelText: 'Instructions',
                  fieldName: 'instructions',
                  keyboardType: TextInputType.text,
                  controller: instructionsController,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          const Gap(20),
          sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionHeader(
                  Icons.person_outline,
                  isSending.value
                      ? 'Sender Information'
                      : 'Receiver Information',
                ),
                const Gap(20),
                CustomFormTextField(
                  labelText: 'Name',
                  hintText: 'Name',
                  fieldName: 'name',
                  keyboardType: TextInputType.text,
                  controller: nameController,
                  onChanged: (value) {},
                  validator: (val) => Validators.requiredField(val, 'name'),
                ),
                const Gap(16),
                CustomFormTextField(
                  labelText: 'Phone Number',
                  hintText: 'Phone Number',
                  fieldName: 'phone_number',
                  keyboardType: TextInputType.phone,
                  controller: phoneNumberController,
                  onChanged: (value) {},
                  validator: (val) =>
                      Validators.requiredField(val, 'phone_number'),
                ),
                const Gap(16),
                CustomFormTextField(
                  labelText: 'Email',
                  hintText: 'Email',
                  fieldName: 'email',
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  onChanged: (value) {},
                  validator: (val) => Validators.requiredField(val, 'email'),
                ),
              ],
            ),
          ),
          const Gap(20),
          sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionHeader(
                  Icons.person_pin_circle_outlined,
                  !isSending.value
                      ? 'Sender Information'
                      : 'Receiver Information',
                ),
                const Gap(20),
                CustomFormTextField(
                  labelText: 'Name',
                  hintText: 'Name',
                  fieldName: 'name',
                  keyboardType: TextInputType.text,
                  controller: nameController2,
                  onChanged: (value) {},
                  validator: (val) => Validators.requiredField(val, 'name'),
                ),
                const Gap(16),
                CustomFormTextField(
                  labelText: 'Phone Number',
                  hintText: 'Phone Number',
                  fieldName: 'phone_number',
                  keyboardType: TextInputType.phone,
                  controller: phoneNumberController2,
                  onChanged: (value) {},
                  validator: (val) =>
                      Validators.requiredField(val, 'phone_number'),
                ),
                const Gap(16),
                CustomFormTextField(
                  labelText: 'Email',
                  hintText: 'Email',
                  fieldName: 'email',
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController2,
                  onChanged: (value) {},
                  validator: (val) => Validators.requiredField(val, 'email'),
                ),
              ],
            ),
          ),
          const Gap(24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neutral900),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.discount_shape,
                        size: 16, color: app_theme.kcPrimary400),
                    const Gap(8),
                    const Expanded(
                      child: Text(
                        'Promo code',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (promoCodeController.text.trim().isNotEmpty)
                      TextButton(
                        onPressed: () {
                          promoCodeController.clear();
                          promoCodeMessage.value = null;
                          promoCodeIsError.value = false;
                        },
                        child: const Text('Remove'),
                      ),
                  ],
                ),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: promoCodeController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Enter code',
                          hintStyle: const TextStyle(
                            color: app_theme.kcPrimaryNeutral600,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: app_theme.kcPrimary500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    FilledButton(
                      onPressed: () async {
                        final code = promoCodeController.text.trim();
                        if (code.isEmpty) return;

                        final pLat = num.tryParse(pickUpLat.value);
                        final pLong = num.tryParse(pickUpLong.value);
                        final dLat = num.tryParse(deliveryLat.value);
                        final dLong = num.tryParse(deliveryLong.value);
                        if (pLat == null || pLong == null || dLat == null || dLong == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select valid addresses before applying a promo code',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await ref.read(shopControllerProvider.notifier).quoteParcel(
                              pickUpAddress: pickUpController.text,
                              pickUpLat: pLat,
                              pickUpLong: pLong,
                              deliveryAddress: deliveryController.text,
                              deliveryLat: dLat,
                              deliveryLong: dLong,
                              promoCode: code,
                            );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: app_theme.kcPrimary300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                if ((promoCodeMessage.value ?? '').isNotEmpty) ...[
                  const Gap(10),
                  Text(
                    promoCodeMessage.value!,
                    style: TextStyle(
                      color: promoCodeIsError.value
                          ? app_theme.kcPrimaryRed400
                          : app_theme.kcPrimaryGreen500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(24),
          ParcelQuoteCard(
            quote: ref
                .watch(shopControllerProvider)
                .parcelQuote
                .valueOrNull
                ?.quote,
            isLoading:
                ref.watch(shopControllerProvider).parcelQuote.isLoading,
          ),
          const Gap(24),
          FullButton(
            text: 'Continue',
            width: double.infinity,
            height: 48,
            isLoading: ref.watch(shopControllerProvider).bookCourier.isLoading,
            onPressed: () async {
              // Add this validation before the form submission
              if (pickUpController.text.isEmpty ||
                  deliveryController.text.isEmpty ||
                  nameController.text.isEmpty ||
                  phoneNumberController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  nameController2.text.isEmpty ||
                  phoneNumberController2.text.isEmpty ||
                  emailController2.text.isEmpty ||
                  pickUpLat.value.isEmpty ||
                  pickUpLong.value.isEmpty ||
                  pickUpCity.value.isEmpty ||
                  pickUpState.value.isEmpty ||
                  deliveryLat.value.isEmpty ||
                  deliveryLong.value.isEmpty ||
                  deliveryCity.value.isEmpty ||
                  deliveryState.value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Please select valid addresses with complete location data'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Remove the form validation since you removed FormBuilder
              // if (formKey.currentState!.saveAndValidate()) {
              //   final formData = formKey.currentState!.value;
              //   print(formData);
              // }

              // Add basic validation
              if (pickUpController.text.isEmpty ||
                  deliveryController.text.isEmpty ||
                  nameController.text.isEmpty ||
                  phoneNumberController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  nameController2.text.isEmpty ||
                  phoneNumberController2.text.isEmpty ||
                  emailController2.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final request = ref.read(shopControllerProvider.notifier);
              final response = await request.bookCourier(
                CourierPayload(
                  deliveryAddressCity: deliveryCity.value,
                  deliveryAddressState: deliveryState.value,
                  deliveryAddressLong: deliveryLong.value,
                  deliveryAddressLat: deliveryLat.value,
                  pickUpAddressCity: pickUpCity.value,
                  pickUpAddressState: pickUpState.value,
                  deliveryAddress: deliveryController.text,
                  pickUpAddress: pickUpController.text,
                  pickUpAddressLong: pickUpLong.value,
                  pickUpAddressLat: pickUpLat.value,
                  parcelType: 'Parcel',
                  instructions: instructionsController.text,
                  dispatchType: 'swift',
                  deliveryType: 'Standard',
                  receiverName: nameController2.text,
                  receiverPhone: phoneNumberController2.text,
                  receiverEmail: emailController2.text,
                  senderName: nameController.text,
                  senderPhone: phoneNumberController.text,
                  senderEmail: emailController.text,
                ),
              );

              // Clear form if successful
              if (response == true) {
                pickUpController.clear();
                deliveryController.clear();
                nameController.clear();
                phoneNumberController.clear();
                emailController.clear();
                nameController2.clear();
                phoneNumberController2.clear();
                emailController2.clear();
                instructionsController.clear();
                pickUpLat.value = '';
                pickUpLong.value = '';
                deliveryLat.value = '';
                deliveryLong.value = '';
                pickUpCity.value = '';
                pickUpState.value = '';
                deliveryCity.value = '';
                deliveryState.value = '';

                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParcelConfirmDetails(),
                  ),
                );
                if (!context.mounted) return;
                clearAddressFields();
              }
            },
            color: AppColors.brand400,
            textColor: Colors.white,
          ),
          const Gap(150),
        ]),
      ),
    );
  }
}
