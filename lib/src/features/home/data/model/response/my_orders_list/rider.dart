import 'dart:convert';

/// The rider attached to an order once one accepts the delivery.
///
/// The order payload carries the rider under a handful of keys and sometimes
/// wraps the person inside a nested `user` object, so parsing stays permissive:
/// anything that cannot be read comes back null and the UI simply hides the
/// rider section until real details arrive.
class Rider {
  String? firstName;
  String? lastName;
  String? phone;
  String? photo;
  String? vehicleType;
  String? plateNumber;
  String? id;

  Rider({
    this.firstName,
    this.lastName,
    this.phone,
    this.photo,
    this.vehicleType,
    this.plateNumber,
    this.id,
  });

  /// Keys the order payload has used for the assigned rider.
  static const _orderKeys = [
    'rider',
    'assignedRider',
    'riderDetails',
    'deliveryRider',
    'courier',
  ];

  /// Pulls the rider out of a raw order map, whichever key it arrived under.
  ///
  /// Returns null when the rider is absent, is only an id string, or holds no
  /// detail worth showing.
  static Rider? fromOrderMap(Map<String, dynamic> data) {
    for (final key in _orderKeys) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        final rider = Rider.fromMap(value);
        if (rider.hasDetails) return rider;
      }
    }
    return null;
  }

  factory Rider.fromMap(Map<String, dynamic> data) {
    // Some responses nest the person under `user` and keep vehicle data on the
    // outer object.
    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final vehicle = data['vehicle'] is Map<String, dynamic>
        ? data['vehicle'] as Map<String, dynamic>
        : const <String, dynamic>{};

    String? pick(String key) {
      final value = data[key] ?? user[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    String? pickVehicle(String key) {
      final value = data[key] ?? vehicle[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    return Rider(
      firstName: pick('firstName'),
      lastName: pick('lastName'),
      phone: pick('phone') ?? pick('phoneNumber'),
      photo: pick('photo') ?? pick('profileImage'),
      vehicleType: pickVehicle('vehicleType') ?? pickVehicle('type'),
      plateNumber: pickVehicle('plateNumber') ?? pickVehicle('licensePlate'),
      id: pick('id') ?? pick('_id'),
    );
  }

  /// The rider's display name, or null when the payload carried no name.
  String? get fullName {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isEmpty ? null : name;
  }

  /// Whether there is enough here to show the customer.
  bool get hasDetails => fullName != null || phone != null;

  /// Whether the customer can place a call to this rider.
  bool get isCallable => phone != null && phone!.isNotEmpty;

  @override
  String toString() {
    return 'Rider(firstName: $firstName, lastName: $lastName, phone: $phone, photo: $photo, vehicleType: $vehicleType, plateNumber: $plateNumber, id: $id)';
  }

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'photo': photo,
        'vehicleType': vehicleType,
        'plateNumber': plateNumber,
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Rider].
  factory Rider.fromJson(String data) {
    return Rider.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Rider] to a JSON string.
  String toJson() => json.encode(toMap());

  Rider copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? photo,
    String? vehicleType,
    String? plateNumber,
    String? id,
  }) {
    return Rider(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      id: id ?? this.id,
    );
  }
}
