import 'dart:async';
import 'dart:convert';

import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../common/res/app_colors.dart';
import '../../common/widgets/custom_textfield.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../auth/data/controller/authentication_controller.dart';
import '../profile/data/controller/profile_controller.dart';

class EditAddressBottomSheet extends HookConsumerWidget {
  final Function(String) onUpdate;

  const EditAddressBottomSheet({
    super.key,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState =
        ref.watch(profileControllerProvider).userDetails.valueOrNull;
    final phoneController =
        useTextEditingController(text: profileState?.user?.phone ?? "");
    final addressController =
        useTextEditingController(text: profileState?.user?.phone ?? "");

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

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16).copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: kcWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Information",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kcPrimaryNeutral100),
            ),
            verticalSpaceMedium,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Phone Number ",
                  style: TextStyle(color: kcPrimaryNeutral200, fontSize: 12),
                ),
                verticalSpaceSmall,
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: "e.g 08122345670",
                    filled: true,
                    fillColor: kcPrimaryNeutral900,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimaryNeutral800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimaryNeutral800),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimaryNeutral800),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            verticalSpaceMedium,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery Address ",
                  style: TextStyle(color: kcPrimaryNeutral200, fontSize: 12),
                ),
                verticalSpaceSmall,
                CustomFormTextField(
                  controller: addressController,
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
                        return ListTile(
                          title: Text(place['description']),
                          onTap: () async {
                            await getPlaceDetails(
                              place['place_id'],
                              place['description'],
                            );
                            places.value = [];
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            verticalSpaceMedium,
            FullButton(
              text: "Update",
              width: double.infinity,
              height: 48,
              color: AppColors.brand400,
              textColor: Colors.white,
              onPressed: () {
                onUpdate(addressController.text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
