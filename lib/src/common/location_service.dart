import 'dart:convert';

import 'package:fazt_order/src/common/models/address_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Define AddressData class at the top of the file

class LocationService {
  static final _logger = Logger();
  static String? get _apiKey => dotenv.env['MAP_KEY'];

  /// Request location permission and check if location services are enabled
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return false;
    }
    return true;
  }

  /// Get current device position
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
      _logger.d('Current position: $position');
      return position;
    } catch (e) {
      _logger.e('Error getting current position: $e');
      return null;
    }
  }

  /// Get address details from coordinates using reverse geocoding
  static Future<AddressData?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${_apiKey ?? ''}';

    try {
      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          json['status'] == 'OK' &&
          json['results'] != null &&
          (json['results'] as List).isNotEmpty) {
        final result = (json['results'] as List)[0];
        final formattedAddress = result['formatted_address'] ?? '';

        String? foundCity;
        String? foundState;

        if (result['address_components'] is List) {
          for (var component in result['address_components']) {
            final List types = (component['types'] ?? []) as List;
            if (types.contains('locality')) {
              foundCity = component['long_name'] ?? component['short_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'] ?? component['short_name'];
            }
          }
        }

        return AddressData(
          title: formattedAddress.split(',').first,
          address: formattedAddress,
          lat: latitude.toString(),
          lng: longitude.toString(),
          city: foundCity ?? '',
          state: foundState ?? '',
        );
      } else {
        _logger.e(
            'Error reverse geocoding: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get place details from a Google Places placeId
  static Future<AddressData?> getPlaceDetails(
    String placeId,
    String description,
  ) async {
    final url =
        'https://places.googleapis.com/v1/places/$placeId?languageCode=en&regionCode=NG';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Goog-Api-Key': _apiKey ?? '',
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

        return AddressData(
          title: description.split(',').first,
          address: result['formattedAddress'] ?? description,
          lat: (location?['latitude'] ?? '').toString(),
          lng: (location?['longitude'] ?? '').toString(),
          city: foundCity ?? '',
          state: foundState ?? '',
        );
      } else {
        _logger.e(
            'Error fetching place details: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Error getting place details: $e');
      return null;
    }
  }

  /// Get place details from coordinates (tries nearby search first, then falls back to reverse geocoding)
  static Future<AddressData?> getPlaceDetailsFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Try to find a nearby place first
    const url = 'https://places.googleapis.com/v1/places:searchNearby';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey ?? '',
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.formattedAddress,places.location,places.addressComponents',
        },
        body: jsonEncode({
          'includedTypes': ['establishment', 'point_of_interest'],
          'maxResultCount': 1,
          'locationRestriction': {
            'circle': {
              'center': {
                'latitude': latitude,
                'longitude': longitude,
              },
              'radius': 50.0, // 50 meters radius
            },
          },
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          json['places'] != null &&
          (json['places'] as List).isNotEmpty) {
        final place = (json['places'] as List)[0];
        final placeId = place['id'];
        final displayName = place['displayName']?['text'] ?? 'Current Location';

        // Use the place details function
        return await getPlaceDetails(placeId, displayName);
      } else {
        // Fallback: Use reverse geocoding if nearby search doesn't work
        return await getAddressFromCoordinates(latitude, longitude);
      }
    } catch (e) {
      _logger.e('Error fetching place from coordinates: $e');
      // Fallback to reverse geocoding
      return await getAddressFromCoordinates(latitude, longitude);
    }
  }

  /// Get current position and address details in one call
  static Future<AddressData?> getCurrentLocationWithAddress(
    BuildContext context,
  ) async {
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return null;

    final position = await getCurrentPosition();
    if (position == null) return null;

    return await getPlaceDetailsFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }
}
