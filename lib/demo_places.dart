import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

class PlaceSearchPage extends HookWidget {
  const PlaceSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
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

    final String? apiKey = dotenv.env['MAP_KEY'];

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

    return Scaffold(
      appBar: AppBar(title: const Text('Place Search (Typing + Debounce)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Search Place',
                suffixIcon: isLoading.value
                    ? const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
              ),
              onChanged: (text) {
                // Cancel the previous timer
                debounceTimer.value?.cancel();
                // Start a new timer
                debounceTimer.value =
                    Timer(const Duration(milliseconds: 400), () {
                  searchPlaces(text);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Place Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Latitude: ${lat.value}'),
                Text('Longitude: ${long.value}'),
                Text('City: ${city.value}'),
                Text('State: ${state.value}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
