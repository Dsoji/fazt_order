import 'dart:convert';

import 'wallet.dart';

class UserWallet {
  Wallet? wallet;

  UserWallet({this.wallet});

  @override
  String toString() => 'UserWallet(wallet: $wallet)';

  factory UserWallet.fromMap(Map<String, dynamic> data) => UserWallet(
        wallet: data['wallet'] == null
            ? null
            : Wallet.fromMap(data['wallet'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'wallet': wallet?.toMap(),
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
    Wallet? wallet,
  }) {
    return UserWallet(
      wallet: wallet ?? this.wallet,
    );
  }
}
