import 'dart:convert';

import 'data.dart';

class UserWallet {
  bool? status;
  String? message;
  Data? data;

  UserWallet({this.status, this.message, this.data});

  @override
  String toString() {
    return 'UserWallet(status: $status, message: $message, data: $data)';
  }

  factory UserWallet.fromMap(Map<String, dynamic> map) => UserWallet(
        status: map['status'] as bool?,
        message: map['message'] as String?,
        data: map['data'] != null
            ? Data.fromMap(map['data'] as Map<String, dynamic>)
            : map['wallet'] != null
                ? Data.fromMap({'wallet': map['wallet']})
                : null,
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'message': message,
        'data': data?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [UserWallet].
  factory UserWallet.fromJson(String data) {
    return UserWallet.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [UserWallet] to a JSON string.
  String toJson() => json.encode(toMap());

  UserWallet copyWith({
    bool? status,
    String? message,
    Data? data,
  }) {
    return UserWallet(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
