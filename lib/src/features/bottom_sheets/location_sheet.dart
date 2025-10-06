import 'dart:async';
import 'dart:convert';

import 'package:fazt_order/src/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
// import 'package:geocoding/geocoding.dart'; // Removed
// import 'package:geolocator/geolocator.dart'; // Removed
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

import '../../common/res/app_colors.dart';
import '../../common/widgets/custom_textfield.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../auth/data/controller/authentication_controller.dart';
import '../auth/data/model/payload/address_payload.dart';
import '../profile/data/controller/profile_controller.dart';

class LocationBottomSheet extends HookConsumerWidget {
  const LocationBottomSheet({super.key});

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

    Future<void> getPlaceDetails(String placeId, String description) async {
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

          lat.value = (location?['latitude'] ?? '').toString();
          long.value = (location?['longitude'] ?? '').toString();
          city.value = foundCity ?? '';
          state.value = foundState ?? '';

          selectedAddress.value = {
            'title': description.split(',').first,
            'address': result['formattedAddress'] ?? description,
            'lat': lat.value,
            'lng': long.value,
            'city': city.value,
            'state': state.value,
          };
        } else {
          print(
              'Error fetching place details: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Change current location",
                    style: TextStyle(
                      color: kcPrimaryNeutral100,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Iconsax.close_circle,
                        size: 24,
                        color: kcPrimaryNeutral100,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ),
                ],
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
                          await getPlaceDetails(
                            pp?['placeId'],
                            pp?['text']?['text'] ?? '',
                          );
                          places.value = [];
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
                  text: 'Update address',
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
                    if (ok && context.mounted) {
                      ref
                          .read(profileControllerProvider.notifier)
                          .fetchProfile();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
              const Gap(50),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;

  const LocationTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.green : Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
