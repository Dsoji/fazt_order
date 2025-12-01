import 'dart:convert';

import 'wallet.dart';

class Data {
  Wallet? wallet;

  Data({this.wallet});

  @override
  String toString() => 'Data(wallet: $wallet)';

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        wallet: data['wallet'] == null
            ? null
            : Wallet.fromMap(data['wallet'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'wallet': wallet?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Data].
  factory Data.fromJson(String data) {
    return Data.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Data] to a JSON string.
  String toJson() => json.encode(toMap());

  Data copyWith({
    Wallet? wallet,
  }) {
    return Data(
      wallet: wallet ?? this.wallet,
    );
  }
}
