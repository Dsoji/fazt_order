import 'dart:convert';

import '../../../../../app_update/data/model/app_update.dart';
import 'new_customer_promotion.dart';
import 'user.dart';

class UserModel {
  User? user;

  /// The update-popup decision, attached to a login response when the request
  /// sent `appVersion`, `platform` and `appType` together. Absent — not an
  /// error — when any of the three is missing.
  final AppUpdate? appUpdate;

  /// The new-customer promo outcome, on `role: user` signups only. `granted:
  /// false` still means the account was created.
  final NewCustomerPromotion? newCustomerPromotion;

  UserModel({this.user, this.appUpdate, this.newCustomerPromotion});

  @override
  String toString() => 'UserModel(user: $user, appUpdate: $appUpdate, '
      'newCustomerPromotion: $newCustomerPromotion)';

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        user: data['user'] == null
            ? null
            : User.fromMap(data['user'] as Map<String, dynamic>),
        appUpdate: data['appUpdate'] is Map<String, dynamic>
            ? AppUpdate.fromMap(data['appUpdate'] as Map<String, dynamic>)
            : null,
        newCustomerPromotion:
            data['newCustomerPromotion'] is Map<String, dynamic>
                ? NewCustomerPromotion.fromMap(
                    data['newCustomerPromotion'] as Map<String, dynamic>)
                : null,
      );

  Map<String, dynamic> toMap() => {
        'user': user?.toMap(),
        'appUpdate': appUpdate?.toMap(),
        'newCustomerPromotion': newCustomerPromotion?.toMap(),
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
    AppUpdate? appUpdate,
    NewCustomerPromotion? newCustomerPromotion,
  }) {
    return UserModel(
      user: user ?? this.user,
      appUpdate: appUpdate ?? this.appUpdate,
      newCustomerPromotion: newCustomerPromotion ?? this.newCustomerPromotion,
    );
  }
}
