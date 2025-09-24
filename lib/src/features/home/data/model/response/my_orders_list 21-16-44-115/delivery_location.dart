import 'dart:convert';

class DeliveryLocation {
  String? type;
  List<dynamic>? coordinates;
  String? address;
  String? state;
  String? city;

  DeliveryLocation({
    this.type,
    this.coordinates,
    this.address,
    this.state,
    this.city,
  });

  @override
  String toString() {
    return 'DeliveryLocation(type: $type, coordinates: $coordinates, address: $address, state: $state, city: $city)';
  }

  factory DeliveryLocation.fromMap(Map<String, dynamic> data) {
    return DeliveryLocation(
      type: data['type'] as String?,
      coordinates: data['coordinates'] as List<dynamic>?,
      address: data['address'] as String?,
      state: data['state'] as String?,
      city: data['city'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'coordinates': coordinates,
        'address': address,
        'state': state,
        'city': city,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [DeliveryLocation].
  factory DeliveryLocation.fromJson(String data) {
    return DeliveryLocation.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [DeliveryLocation] to a JSON string.
  String toJson() => json.encode(toMap());

  DeliveryLocation copyWith({
    String? type,
    List<dynamic>? coordinates,
    String? address,
    String? state,
    String? city,
  }) {
    return DeliveryLocation(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
    );
  }
}
