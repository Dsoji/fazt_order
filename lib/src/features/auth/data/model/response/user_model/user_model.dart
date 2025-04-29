import 'dart:convert';

import 'data.dart';

class UserModel {
  Data? data;
  String? token;

  UserModel({this.data, this.token});

  @override
  String toString() => 'UserModel(data: $data, token: $token)';

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        data: data['data'] == null
            ? null
            : Data.fromMap(data['data'] as Map<String, dynamic>),
        token: data['token'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'data': data?.toMap(),
        'token': token,
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
    Data? data,
    String? token,
  }) {
    return UserModel(
      data: data ?? this.data,
      token: token ?? this.token,
    );
  }
}
