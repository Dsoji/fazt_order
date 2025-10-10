import 'dart:async'; // Add this import for Timer
import 'dart:convert';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:fazt_order/src/common/widgets/custom_textfield.dart';
import 'package:fazt_order/src/common/widgets/reusbale_dropdown_widget.dart';
import 'package:fazt_order/src/features/courier/parcel_confirm_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../common/res/app_colors.dart';
import '../../common/utils/validator.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/payload/courier_payload.dart';

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
    final pickUpPlaces = useState<List<dynamic>>([]);
    final deliveryPlaces = useState<List<dynamic>>([]);
    final isLoading = useState(false);
    final instructionsController = useTextEditingController();
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Parcel Delivery",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3E2723), // Dark brown
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC), // Light cream
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3E2723), // Dark brown outline
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      size: 30,
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
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          OutlinButton(
            text: "Order History",
            width: double.infinity,
            height: 50,
            onPressed: () {},
            color: AppColors.brand400,
            bgColor: Colors.transparent,
          ),
          const Gap(24),
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
          const Gap(24),
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
                          onChanged: (text) {
                            debounceTimer.value?.cancel();
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
                                        getPickUpPlaceDetails(placeId);
                                        pickUpController.text = displayText;
                                        pickUpPlaces.value = [];
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
                          onChanged: (text) {
                            debounceTimer.value?.cancel();
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
                                        getDeliveryPlaceDetails(placeId);
                                        deliveryController.text = displayText;
                                        deliveryPlaces.value = [];
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
          const Gap(16), // Reduced gap after timeline
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
          const Gap(24),
          Text(
            isSending.value ? 'Sender Information' : 'Receiver Information',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.neutral200,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(16),
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
            validator: (val) => Validators.requiredField(val, 'phone_number'),
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
          const Gap(24),
          Text(
            !isSending.value ? 'Sender Information' : 'Receiver Information',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.neutral200,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(16),
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
            validator: (val) => Validators.requiredField(val, 'phone_number'),
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

          const Gap(40),
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParcelConfirmDetails(),
                  ),
                );
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
