import 'dart:async';
import 'dart:convert';

import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/auth/data/controller/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
// import 'package:geocoding/geocoding.dart'; // Removed
// import 'package:geolocator/geolocator.dart'; // Removed
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../common/res/app_assets.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../dashboard_view.dart';
import '../data/model/payload/address_payload.dart';

class MapLocationScreen extends HookConsumerWidget {
  const MapLocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final places = useState<List<dynamic>>([]);
    final isLoading = useState(false);
    final selectedAddress = useState<Map<String, String>?>(null);

    // Place Details
    final lat = useState('');
    final long = useState('');
    final city = useState('');
    final state = useState('');

    // For debouncing search input
    final debounceTimer = useRef<Timer?>(null);

    final String? apiKey = dotenv.env['MAP_KEY'];
    print(apiKey);

    Future<void> searchPlaces(String query) async {
      if (query.isEmpty) {
        places.value = [];
        return;
      }

      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&types=geocode';
      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          places.value = json['predictions'];
        } else {
          print('Error fetching places: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getPlaceDetails(String placeId, String description) async {
      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          final result = json['result'];
          final location = result['geometry']['location'];

          String? foundCity;
          String? foundState;
          String? streetNumber;
          String? route;

          for (var component in result['address_components']) {
            final List types = component['types'];
            if (types.contains('locality')) {
              foundCity = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'];
            }
            if (types.contains('street_number')) {
              streetNumber = component['long_name'];
            }
            if (types.contains('route')) {
              route = component['long_name'];
            }
          }

          lat.value = location['lat'].toString();
          long.value = location['lng'].toString();
          city.value = foundCity ?? '';
          state.value = foundState ?? '';

          // Save selected address
          selectedAddress.value = {
            'title': description.split(',').first,
            'address': result['formatted_address'] ?? description,
            'lat': lat.value,
            'lng': long.value,
            'city': city.value,
            'state': state.value,
          };
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageAssets.mapBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Bottom-aligned container overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: selectedAddress.value == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grant current location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This let us show nearby restaurants, stores you can order from and address to deliver to.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          controller: controller,
                          hintText: 'e.g Lagos, Nigeria',
                          fieldName: '',
                          keyboardType: TextInputType.text,
                          onChanged: (text) {
                            debounceTimer.value?.cancel();
                            debounceTimer.value =
                                Timer(const Duration(milliseconds: 400), () {
                              searchPlaces(text!);
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            // Removed geolocator and geocoding logic
                            // You can add your own logic here if needed
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.my_location,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Use your current location',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        if (places.value.isNotEmpty)
                          SizedBox(
                            height: 350,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: places.value.length,
                              itemBuilder: (context, index) {
                                final place = places.value[index];
                                return ListTile(
                                    title: Text(place['description']),
                                    onTap: () {
                                      getPlaceDetails(place['place_id'],
                                          place['description']);
                                      places.value = [];
                                    });
                              },
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(IconsaxPlusLinear.location,
                                color: AppColors.neutral200),
                            const SizedBox(width: 8),
                            Text(
                              selectedAddress.value!['title'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.neutral200),
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () {
                                selectedAddress.value = null;
                                controller.clear();
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: AppColors.brand400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(color: AppColors.brand400),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedAddress.value!['address'] ?? '',
                          style: const TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FullButton(
                          text: 'Verify',
                          isLoading: ref
                              .watch(authenticationControllerProvider)
                              .addressUpdate
                              .isLoading,
                          width: double.infinity,
                          height: 50,
                          onPressed: () async {
                            final result = await ref
                                .read(authenticationControllerProvider.notifier)
                                .updateAddress(
                                  AddressPayload(
                                    address: selectedAddress.value!['address'],
                                    city: selectedAddress.value!['city'],
                                    state: selectedAddress.value!['state'],
                                    lat: selectedAddress.value!['lat'],
                                    long: selectedAddress.value!['lng'],
                                  ),
                                );
                            if (result == true) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DashboardView()));
                            }
                          },
                          color: AppColors.brand400,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
