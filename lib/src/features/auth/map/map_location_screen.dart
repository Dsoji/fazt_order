import 'dart:async';
import 'dart:convert';

import 'package:fazt_order/src/common/app_colors.dart';
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
import 'package:logger/logger.dart';

import '../../../common/location_service.dart';
import '../../../common/res/app_assets.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/widgets/custom_textfield.dart';
import '../../dashboard_view.dart';
import '../data/model/payload/address_payload.dart';

final logger = Logger();

class MapLocationScreen extends HookConsumerWidget {
  const MapLocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final places = useState<List<dynamic>>([]);
    final isLoading = useState(false);
    final selectedAddress = useState<Map<String, String>?>(null);
    final debounceTimer = useRef<Timer?>(null);

    // Place Details
    final lat = useState('');
    final long = useState('');
    final city = useState('');
    final state = useState('');

    // For debouncing search input
    final String? apiKey = dotenv.env['MAP_KEY'];
    print(apiKey);

    // Watch update state
    final addrUpdate = ref.watch(
      authenticationControllerProvider.select((s) => s.addressUpdate),
    );
    final isUpdating = addrUpdate.isLoading;

    Future<void> searchPlaces(String query) async {
      if (query.isEmpty) {
        places.value = [];
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
          places.value = List<dynamic>.from(json['suggestions']);
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

    Future<void> getCurrentPosition(BuildContext context) async {
      isLoading.value = true;
      try {
        final addressData =
            await LocationService.getCurrentLocationWithAddress(context);
        if (addressData != null) {
          // Update the state with the address data
          lat.value = addressData.lat;
          long.value = addressData.lng;
          city.value = addressData.city;
          state.value = addressData.state;
          selectedAddress.value = addressData.toMap();
        }
      } catch (e) {
        logger.e('Error getting current location: $e');
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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.brand950,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
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
                color: AppColors.brand980,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Set current location",
                    style: TextStyle(
                      color: kcPrimaryNeutral100,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This let us show nearby restaurants, stores you can order from and address to deliver to.",
                    style: TextStyle(
                      fontSize: 14,
                      color: kcPrimaryNeutral300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      getCurrentPosition(context);
                    },
                    child: const Text(
                      'Use Current Location',
                      style: TextStyle(color: AppColors.brand300),
                    ),
                  ),
                  CustomFormTextField(
                    controller: controller,
                    hintText: 'Full Address',
                    fieldName: '',
                    keyboardType: TextInputType.text,
                    suffixIcon: IconButton(
                      onPressed: () {
                        debounceTimer.value?.cancel();
                        debounceTimer.value =
                            Timer(const Duration(milliseconds: 400), () {
                          searchPlaces(controller.text);
                        });
                      },
                      icon: const Icon(IconsaxPlusLinear.search_normal),
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
                          final pp = place['placePrediction'];
                          return ListTile(
                            title: Text(pp?['text']?['text'] ?? ''),
                            onTap: () async {
                              isLoading.value = true;
                              try {
                                final addressData =
                                    await LocationService.getPlaceDetails(
                                  pp?['placeId'],
                                  pp?['text']?['text'] ?? '',
                                );
                                if (addressData != null) {
                                  lat.value = addressData.lat;
                                  long.value = addressData.lng;
                                  city.value = addressData.city;
                                  state.value = addressData.state;
                                  selectedAddress.value = addressData.toMap();
                                }
                                places.value = [];
                              } catch (e) {
                                logger.e('Error getting place details: $e');
                              } finally {
                                isLoading.value = false;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  if (selectedAddress.value != null) ...[
                    const Gap(12),
                    Card(
                      color: kcPrimary980,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: kcPrimary400, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedAddress.value!['title'] ?? '',
                              style: const TextStyle(
                                color: kcPrimaryNeutral100,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              selectedAddress.value!['address'] ?? '',
                              style: const TextStyle(
                                color: kcPrimaryNeutral300,
                                fontSize: 14,
                              ),
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'City: ${selectedAddress.value!['city'] ?? ''}',
                                    style: const TextStyle(
                                      color: kcPrimaryNeutral400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'State: ${selectedAddress.value!['state'] ?? ''}',
                                    style: const TextStyle(
                                      color: kcPrimaryNeutral400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Lat: ${selectedAddress.value!['lat'] ?? ''}',
                                    style: const TextStyle(
                                      color: kcPrimaryNeutral500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Lng: ${selectedAddress.value!['lng'] ?? ''}',
                                    style: const TextStyle(
                                      color: kcPrimaryNeutral500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    FullButton(
                      text: 'Verify',
                      width: double.infinity,
                      height: 48,
                      color: AppColors.brand400,
                      textColor: Colors.white,
                      onPressed: () async {
                        final addr = selectedAddress.value!;
                        final ok = await ref
                            .read(authenticationControllerProvider.notifier)
                            .updateAddress(
                              AddressPayload(
                                address: addr['address'],
                                city: addr['city'],
                                state: addr['state'],
                                long: addr['lng'],
                                lat: addr['lat'],
                              ),
                            );
                        if (ok == true && context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DashboardView()));
                        }
                      },
                    ),
                  ],
                  const Gap(50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
