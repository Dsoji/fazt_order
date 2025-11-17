class AddressData {
  final String title;
  final String address;
  final String lat;
  final String lng;
  final String city;
  final String state;

  AddressData({
    required this.title,
    required this.address,
    required this.lat,
    required this.lng,
    required this.city,
    required this.state,
  });

  Map<String, String> toMap() {
    return {
      'title': title,
      'address': address,
      'lat': lat,
      'lng': lng,
      'city': city,
      'state': state,
    };
  }

  factory AddressData.fromMap(Map<String, String> map) {
    return AddressData(
      title: map['title'] ?? '',
      address: map['address'] ?? '',
      lat: map['lat'] ?? '',
      lng: map['lng'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
    );
  }
}
