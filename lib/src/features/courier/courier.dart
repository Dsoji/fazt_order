import 'dart:async'; // Add this import for Timer
import 'dart:convert';

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:fazt_order/src/common/widgets/custom_textfield.dart';
import 'package:fazt_order/src/common/widgets/reusbale_dropdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:timelines_plus/timelines_plus.dart';

import '../../common/res/app_colors.dart';
import '../../common/utils/validator.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/payload/courier_payload.dart';

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

    // For debouncing search input
    // For debouncing search input
    final debounceTimer = useRef<Timer?>(null);

    // For safer dotenv access
    String getApiKey() {
      try {
        return dotenv.env['MAP_KEY'] ?? '';
      } catch (e) {
        print('Error accessing MAP_KEY: $e');
        return '';
      }
    }

    final String apiKey = getApiKey();

    Future<void> searchPickUpPlaces(String query) async {
      if (query.isEmpty) {
        pickUpPlaces.value = [];
        return;
      }

      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyCZfDAROgHIb5FhQP863pKus-bJ3pKCgvo&types=geocode';
      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          pickUpPlaces.value = json['predictions'];
        } else {
          print('Error fetching places: ${json['status']}');
          pickUpPlaces.value = [];
        }
      } catch (e) {
        print('Error: $e');
        pickUpPlaces.value = [];
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

      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyCZfDAROgHIb5FhQP863pKus-bJ3pKCgvo&types=geocode';
      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          deliveryPlaces.value = json['predictions'];
        } else {
          print('Error fetching places: ${json['status']}');
          deliveryPlaces.value = [];
        }
      } catch (e) {
        print('Error: $e');
        deliveryPlaces.value = [];
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getPickUpPlaceDetails(String placeId) async {
      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyCZfDAROgHIb5FhQP863pKus-bJ3pKCgvo';

      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          final result = json['result'];
          final location = result['geometry']['location'];

          String? foundCity;
          String? foundState;

          for (var component in result['address_components']) {
            final List types = component['types'];
            if (types.contains('locality')) {
              foundCity = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'];
            }
          }

          pickUpLat.value = location['lat'].toString();
          pickUpLong.value = location['lng'].toString();
          pickUpCity.value = foundCity ?? '';
          pickUpState.value = foundState ?? '';

          print('Latitude: ${pickUpLat.value}');
          print('Longitude: ${pickUpLong.value}');
          print('City: ${pickUpCity.value}');
          print('State: ${pickUpState.value}');
        } else {
          print('Error fetching place details: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getDeliveryPlaceDetails(String placeId) async {
      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyCZfDAROgHIb5FhQP863pKus-bJ3pKCgvo';

      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          final result = json['result'];
          final location = result['geometry']['location'];

          String? foundCity;
          String? foundState;

          for (var component in result['address_components']) {
            final List types = component['types'];
            if (types.contains('locality')) {
              foundCity = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'];
            }
          }

          deliveryLat.value = location['lat'].toString();
          deliveryLong.value = location['lng'].toString();
          deliveryCity.value = foundCity ?? '';
          deliveryState.value = foundState ?? '';

          print('Latitude: ${deliveryLat.value}');
          print('Longitude: ${deliveryLong.value}');
          print('City: ${deliveryCity.value}');
          print('State: ${deliveryState.value}');
        } else {
          print('Error fetching place details: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

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
                          validator: (val) =>
                              Validators.requiredField(val, 'pickup_address'),
                        ),
                        if (pickUpPlaces.value.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                  return ListTile(
                                    title: Text(place['description']),
                                    onTap: () {
                                      getPickUpPlaceDetails(place['place_id']);
                                      pickUpController.text =
                                          place['description'];
                                      pickUpPlaces.value = [];
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
                          validator: (val) =>
                              Validators.requiredField(val, 'delivery_address'),
                        ),
                        if (deliveryPlaces.value.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                  return ListTile(
                                    title: Text(place['description']),
                                    onTap: () {
                                      getDeliveryPlaceDetails(
                                          place['place_id']);
                                      deliveryController.text =
                                          place['description'];
                                      deliveryPlaces.value = [];
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
              hintText: 'Parcel Type',
              items: const ['Parcel', 'Box', 'Envelope'],
              onChanged: (value) {}),
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
          const Gap(24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.brand950, // Light lime green background
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Delivery Fee",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF424242), // Dark grey text
                  ),
                ),
                Text(
                  "₦ 1,000",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242), // Dark grey text
                  ),
                ),
              ],
            ),
          ),
          const Gap(40),
          FullButton(
            text: 'Continue',
            width: double.infinity,
            height: 48,
            isLoading: ref.watch(shopControllerProvider).bookCourier.isLoading,
            onPressed: () async {
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
