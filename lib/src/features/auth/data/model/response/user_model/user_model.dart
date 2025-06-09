import 'dart:convert';

import 'user.dart';

class UserModel {
  User? user;
  String? accessToken;
  String? refreshToken;

  UserModel({this.user, this.accessToken, this.refreshToken});

  @override
  String toString() {
    return 'UserModel(user: $user, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        user: data['user'] == null
            ? null
            : User.fromMap(data['user'] as Map<String, dynamic>),
        accessToken: data['accessToken'] as String?,
        refreshToken: data['refreshToken'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'user': user?.toMap(),
        'accessToken': accessToken,
        'refreshToken': refreshToken,
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
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
