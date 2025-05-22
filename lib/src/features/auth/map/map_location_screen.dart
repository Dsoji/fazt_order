import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../common/res/app_assets.dart';
import '../../../common/widgets/custom_textfield.dart';

class MapLocationScreen extends HookConsumerWidget {
  const MapLocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final places = useState<List<dynamic>>([]);
    final isLoading = useState(false);

    // Place Details
    final lat = useState('');
    final long = useState('');
    final city = useState('');
    final state = useState('');

    // For debouncing search input
    final debounceTimer = useRef<Timer?>(null);

    const String apiKey = 'AIzaSyCZfDAROgHIb5FhQP863pKus-bJ3pKCgvo';

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

    Future<void> getPlaceDetails(String placeId) async {
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

          for (var component in result['address_components']) {
            final List types = component['types'];
            if (types.contains('locality')) {
              foundCity = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'];
            }
          }

          lat.value = location['lat'].toString();
          long.value = location['lng'].toString();
          city.value = foundCity ?? '';
          state.value = foundState ?? '';

          print('Latitude: ${lat.value}');
          print('Longitude: ${long.value}');
          print('City: ${city.value}');
          print('State: ${state.value}');
        } else {
          print('Error fetching place details: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      Future.microtask(() {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => const LocationBottomSheetContent(),
        );
      });
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              ImageAssets.mapBackground,
            ),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class LocationBottomSheetContent extends HookConsumerWidget {
  const LocationBottomSheetContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final places = useState<List<dynamic>>([]);
    final isLoading = useState(false);

    // Place Details
    final lat = useState('');
    final long = useState('');
    final city = useState('');
    final state = useState('');

    // For debouncing search input
    final debounceTimer = useRef<Timer?>(null);

    const String apiKey = 'AIzaSyCZfDAROgHIb5FhQP863pKus-bJ3pKCgvo';

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

    Future<void> getPlaceDetails(String placeId) async {
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

          for (var component in result['address_components']) {
            final List types = component['types'];
            if (types.contains('locality')) {
              foundCity = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'];
            }
          }

          lat.value = location['lat'].toString();
          long.value = location['lng'].toString();
          city.value = foundCity ?? '';
          state.value = foundState ?? '';

          print('Latitude: ${lat.value}');
          print('Longitude: ${long.value}');
          print('City: ${city.value}');
          print('State: ${state.value}');
        } else {
          print('Error fetching place details: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
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
              // Cancel the previous timer
              debounceTimer.value?.cancel();
              // Start a new timer
              debounceTimer.value =
                  Timer(const Duration(milliseconds: 400), () {
                searchPlaces(text!);
              });
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // TODO: Implement location permission logic
            },
            child: const Row(
              children: [
                Icon(Icons.my_location, color: Colors.green, size: 20),
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
          const Gap(24),
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
                        getPlaceDetails(place['place_id']);
                        places.value = [];
                      });
                },
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
