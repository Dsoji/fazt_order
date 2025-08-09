import 'dart:convert';

class User {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? id;

  User({this.firstName, this.lastName, this.email, this.phone, this.id});

  @override
  String toString() {
    return 'User(firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, id: $id)';
  }

  factory User.fromMap(Map<String, dynamic> data) => User(
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [User].
  factory User.fromJson(String data) {
    return User.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [User] to a JSON string.
  String toJson() => json.encode(toMap());

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? id,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      id: id ?? this.id,
    );
  }
}
