import 'dart:convert';

import 'category.dart';
import 'payment_information.dart';
import 'sales_operation.dart';

class StoreDetails {
  String? businessName;
  String? registrationNumber;
  String? proofOfRegistration;
  List<dynamic>? shops;
  List<dynamic>? menu;
  String? vendor;
  List<PaymentInformation>? paymentInformation;
  List<Category>? category;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? officialEmail;
  String? officialPhone;
  String? storeAddress;
  String? storeDescription;
  String? storeDisplayImage;
  String? storeName;
  SalesOperation? salesOperation;
  String? id;

  StoreDetails({
    this.businessName,
    this.registrationNumber,
    this.proofOfRegistration,
    this.shops,
    this.menu,
    this.vendor,
    this.paymentInformation,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.officialEmail,
    this.officialPhone,
    this.storeAddress,
    this.storeDescription,
    this.storeDisplayImage,
    this.storeName,
    this.salesOperation,
    this.id,
  });

  @override
  String toString() {
    return 'StoreDetails(businessName: $businessName, registrationNumber: $registrationNumber, proofOfRegistration: $proofOfRegistration, shops: $shops, menu: $menu, vendor: $vendor, paymentInformation: $paymentInformation, category: $category, createdAt: $createdAt, updatedAt: $updatedAt, officialEmail: $officialEmail, officialPhone: $officialPhone, storeAddress: $storeAddress, storeDescription: $storeDescription, storeDisplayImage: $storeDisplayImage, storeName: $storeName, salesOperation: $salesOperation, id: $id)';
  }

  factory StoreDetails.fromMap(Map<String, dynamic> data) => StoreDetails(
        businessName: data['businessName'] as String?,
        registrationNumber: data['registrationNumber'] as String?,
        proofOfRegistration: data['proofOfRegistration'] as String?,
        shops: data['shops'] as List<dynamic>?,
        menu: data['menu'] as List<dynamic>?,
        vendor: data['vendor'] as String?,
        paymentInformation: (data['paymentInformation'] as List<dynamic>?)
            ?.map((e) => PaymentInformation.fromMap(e as Map<String, dynamic>))
            .toList(),
        category: (data['category'] as List<dynamic>?)
            ?.map((e) => Category.fromMap(e as Map<String, dynamic>))
            .toList(),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        officialEmail: data['officialEmail'] as String?,
        officialPhone: data['officialPhone'] as String?,
        storeAddress: data['storeAddress'] as String?,
        storeDescription: data['storeDescription'] as String?,
        storeDisplayImage: data['storeDisplayImage'] as String?,
        storeName: data['storeName'] as String?,
        salesOperation: data['salesOperation'] == null
            ? null
            : SalesOperation.fromMap(
                data['salesOperation'] as Map<String, dynamic>),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'registrationNumber': registrationNumber,
        'proofOfRegistration': proofOfRegistration,
        'shops': shops,
        'menu': menu,
        'vendor': vendor,
        'paymentInformation':
            paymentInformation?.map((e) => e.toMap()).toList(),
        'category': category?.map((e) => e.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'officialEmail': officialEmail,
        'officialPhone': officialPhone,
        'storeAddress': storeAddress,
        'storeDescription': storeDescription,
        'storeDisplayImage': storeDisplayImage,
        'storeName': storeName,
        'salesOperation': salesOperation?.toMap(),
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [StoreDetails].
  factory StoreDetails.fromJson(String data) {
    return StoreDetails.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [StoreDetails] to a JSON string.
  String toJson() => json.encode(toMap());

  StoreDetails copyWith({
    String? businessName,
    String? registrationNumber,
    String? proofOfRegistration,
    List<dynamic>? shops,
    List<dynamic>? menu,
    String? vendor,
    List<PaymentInformation>? paymentInformation,
    List<Category>? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? officialEmail,
    String? officialPhone,
    String? storeAddress,
    String? storeDescription,
    String? storeDisplayImage,
    String? storeName,
    SalesOperation? salesOperation,
    String? id,
  }) {
    return StoreDetails(
      businessName: businessName ?? this.businessName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      proofOfRegistration: proofOfRegistration ?? this.proofOfRegistration,
      shops: shops ?? this.shops,
      menu: menu ?? this.menu,
      vendor: vendor ?? this.vendor,
      paymentInformation: paymentInformation ?? this.paymentInformation,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      officialEmail: officialEmail ?? this.officialEmail,
      officialPhone: officialPhone ?? this.officialPhone,
      storeAddress: storeAddress ?? this.storeAddress,
      storeDescription: storeDescription ?? this.storeDescription,
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
      storeName: storeName ?? this.storeName,
      salesOperation: salesOperation ?? this.salesOperation,
      id: id ?? this.id,
    );
  }
}
