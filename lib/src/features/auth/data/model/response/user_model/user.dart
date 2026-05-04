import 'dart:convert';

import 'location.dart';
import 'promotion_state.dart';

class User {
  Location? location;
  PromotionState? promotionState;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? role;
  bool? verified;
  String? photo;
  bool? disabled;
  bool? appNotification;
  bool? emailNotification;
  List<dynamic>? favoriteShops;
  bool? hasUploadedStoreCredentials;
  bool? hasUploadedStoreDetails;
  bool? hasUploadedStoreOperations;
  bool? hasUploadedMenu;
  List<dynamic>? paymentInformation;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? passwordChangedAt;
  String? wallet;
  bool? isAvailable;
  bool? isDeleted;
  String? id;
  String? referralCode;

  User({
    this.location,
    this.promotionState,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.role,
    this.verified,
    this.photo,
    this.disabled,
    this.appNotification,
    this.emailNotification,
    this.favoriteShops,
    this.hasUploadedStoreCredentials,
    this.hasUploadedStoreDetails,
    this.hasUploadedStoreOperations,
    this.hasUploadedMenu,
    this.paymentInformation,
    this.createdAt,
    this.updatedAt,
    this.passwordChangedAt,
    this.wallet,
    this.isAvailable,
    this.isDeleted,
    this.id,
    this.referralCode,
  });

  @override
  String toString() {
    return 'User(location: $location, promotionState: $promotionState, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, role: $role, verified: $verified, photo: $photo, disabled: $disabled, appNotification: $appNotification, emailNotification: $emailNotification, favoriteShops: $favoriteShops, hasUploadedStoreCredentials: $hasUploadedStoreCredentials, hasUploadedStoreDetails: $hasUploadedStoreDetails, hasUploadedStoreOperations: $hasUploadedStoreOperations, hasUploadedMenu: $hasUploadedMenu, paymentInformation: $paymentInformation, createdAt: $createdAt, updatedAt: $updatedAt, passwordChangedAt: $passwordChangedAt, wallet: $wallet, isAvailable: $isAvailable, isDeleted: $isDeleted, id: $id)';
  }

  factory User.fromMap(Map<String, dynamic> data) => User(
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        promotionState: data['promotionState'] == null
            ? null
            : PromotionState.fromMap(
                data['promotionState'] as Map<String, dynamic>),
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        role: data['role'] as String?,
        verified: data['verified'] as bool?,
        photo: data['photo'] as String?,
        disabled: data['disabled'] as bool?,
        appNotification: data['appNotification'] as bool?,
        emailNotification: data['emailNotification'] as bool?,
        favoriteShops: data['favoriteShops'] as List<dynamic>?,
        hasUploadedStoreCredentials:
            data['hasUploadedStoreCredentials'] as bool?,
        hasUploadedStoreDetails: data['hasUploadedStoreDetails'] as bool?,
        hasUploadedStoreOperations: data['hasUploadedStoreOperations'] as bool?,
        hasUploadedMenu: data['hasUploadedMenu'] as bool?,
        paymentInformation: data['paymentInformation'] as List<dynamic>?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        passwordChangedAt: data['passwordChangedAt'] == null
            ? null
            : DateTime.parse(data['passwordChangedAt'] as String),
        wallet: data['wallet'] as String?,
        isAvailable: data['isAvailable'] as bool?,
        isDeleted: data['isDeleted'] as bool?,
        id: data['id'] as String?,
        referralCode: data['referralCode'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'location': location?.toMap(),
        'promotionState': promotionState?.toMap(),
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': role,
        'verified': verified,
        'photo': photo,
        'disabled': disabled,
        'appNotification': appNotification,
        'emailNotification': emailNotification,
        'favoriteShops': favoriteShops,
        'hasUploadedStoreCredentials': hasUploadedStoreCredentials,
        'hasUploadedStoreDetails': hasUploadedStoreDetails,
        'hasUploadedStoreOperations': hasUploadedStoreOperations,
        'hasUploadedMenu': hasUploadedMenu,
        'paymentInformation': paymentInformation,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'passwordChangedAt': passwordChangedAt?.toIso8601String(),
        'wallet': wallet,
        'isAvailable': isAvailable,
        'isDeleted': isDeleted,
        'id': id,
        'referralCode': referralCode,
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
    Location? location,
    PromotionState? promotionState,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
    bool? verified,
    String? photo,
    bool? disabled,
    bool? appNotification,
    bool? emailNotification,
    List<dynamic>? favoriteShops,
    bool? hasUploadedStoreCredentials,
    bool? hasUploadedStoreDetails,
    bool? hasUploadedStoreOperations,
    bool? hasUploadedMenu,
    List<dynamic>? paymentInformation,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? passwordChangedAt,
    String? wallet,
    bool? isAvailable,
    bool? isDeleted,
    String? id,
    String? referralCode,
  }) {
    return User(
      location: location ?? this.location,
      promotionState: promotionState ?? this.promotionState,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      verified: verified ?? this.verified,
      photo: photo ?? this.photo,
      disabled: disabled ?? this.disabled,
      appNotification: appNotification ?? this.appNotification,
      emailNotification: emailNotification ?? this.emailNotification,
      favoriteShops: favoriteShops ?? this.favoriteShops,
      hasUploadedStoreCredentials:
          hasUploadedStoreCredentials ?? this.hasUploadedStoreCredentials,
      hasUploadedStoreDetails:
          hasUploadedStoreDetails ?? this.hasUploadedStoreDetails,
      hasUploadedStoreOperations:
          hasUploadedStoreOperations ?? this.hasUploadedStoreOperations,
      hasUploadedMenu: hasUploadedMenu ?? this.hasUploadedMenu,
      paymentInformation: paymentInformation ?? this.paymentInformation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      wallet: wallet ?? this.wallet,
      isAvailable: isAvailable ?? this.isAvailable,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}
