import 'dart:convert';

class Location {
  String? address;
  String? city;
  String? state;
  List<double>? coordinates;
  String? type;

  Location({
    this.address,
    this.city,
    this.state,
    this.coordinates,
    this.type,
  });

  @override
  String toString() {
    return 'Location(address: $address, city: $city, state: $state, coordinates: $coordinates, type: $type)';
  }

  factory Location.fromMap(Map<String, dynamic> data) => Location(
        address: data['address'] as String?,
        city: data['city'] as String?,
        state: data['state'] as String?,
        coordinates: (data['coordinates'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList(),
        type: data['type'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'address': address,
        'city': city,
        'state': state,
        'coordinates': coordinates,
        'type': type,
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
    String? address,
    String? city,
    String? state,
    List<double>? coordinates,
    String? type,
  }) {
    return Location(
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      coordinates: coordinates ?? this.coordinates,
      type: type ?? this.type,
    );
  }
}
