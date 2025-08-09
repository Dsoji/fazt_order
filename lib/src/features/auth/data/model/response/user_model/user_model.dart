import 'dart:convert';

import 'user.dart';

class UserModel {
  User? user;

  UserModel({this.user});

  @override
  String toString() => 'UserModel(user: $user)';

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        user: data['user'] == null
            ? null
            : User.fromMap(data['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'user': user?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [UserModel].
  factory UserModel.fromJson(String data) {
    return UserModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [UserModel] to a JSON string.
  String toJson() => json.encode(toMap());

  UserModel copyWith({
    User? user,
  }) {
    return UserModel(
      user: user ?? this.user,
    );
  }
}
