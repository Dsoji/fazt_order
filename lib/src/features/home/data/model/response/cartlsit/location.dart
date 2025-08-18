import 'dart:convert';

class Location {
  String? type;
  List<double>? coordinates;
  String? address;
  String? state;
  String? city;

  Location({
    this.type,
    this.coordinates,
    this.address,
    this.state,
    this.city,
  });

  @override
  String toString() {
    return 'Location(type: $type, coordinates: $coordinates, address: $address, state: $state, city: $city)';
  }

  factory Location.fromMap(Map<String, dynamic> data) => Location(
        type: data['type'] as String?,
        coordinates: data['coordinates'] as List<double>?,
        address: data['address'] as String?,
        state: data['state'] as String?,
        city: data['city'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'coordinates': coordinates,
        'address': address,
        'state': state,
        'city': city,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Location].
  factory Location.fromJson(String data) {
    return Location.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Location] to a JSON string.
  String toJson() => json.encode(toMap());

  Location copyWith({
    String? type,
    List<double>? coordinates,
    String? address,
    String? state,
    String? city,
  }) {
    return Location(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
    );
  }
}
