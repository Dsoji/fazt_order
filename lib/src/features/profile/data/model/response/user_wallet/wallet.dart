import 'dart:convert';

import 'bank_transfer.dart';
import 'limits.dart';
import 'settings.dart';

class Wallet {
  String? userId;
  int? balance;
  int? availableBalance;
  String? currency;
  String? status;
  bool? isDefault;
  Limits? limits;
  Settings? settings;
  int? verificationLevel;
  BankTransfer? bankTransfer;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastTransactionAt;
  int? v;
  int? pendingBalance;
  String? formattedBalance;
  int? walletAge;

  Wallet({
    this.userId,
    this.balance,
    this.availableBalance,
    this.currency,
    this.status,
    this.isDefault,
    this.limits,
    this.settings,
    this.verificationLevel,
    this.bankTransfer,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.lastTransactionAt,
    this.v,
    this.pendingBalance,
    this.formattedBalance,
    this.walletAge,
  });

  @override
  String toString() {
    return 'Wallet(userId: $userId, balance: $balance, availableBalance: $availableBalance, currency: $currency, status: $status, isDefault: $isDefault, limits: $limits, settings: $settings, verificationLevel: $verificationLevel, bankTransfer: $bankTransfer, id: $id, createdAt: $createdAt, updatedAt: $updatedAt, lastTransactionAt: $lastTransactionAt, v: $v, pendingBalance: $pendingBalance, formattedBalance: $formattedBalance, walletAge: $walletAge, id: $id)';
  }

  factory Wallet.fromMap(Map<String, dynamic> data) => Wallet(
        userId: data['userId'] as String?,
        balance: data['balance'] as int?,
        availableBalance: data['availableBalance'] as int?,
        currency: data['currency'] as String?,
        status: data['status'] as String?,
        isDefault: data['isDefault'] as bool?,
        limits: data['limits'] == null
            ? null
            : Limits.fromMap(data['limits'] as Map<String, dynamic>),
        settings: data['settings'] == null
            ? null
            : Settings.fromMap(data['settings'] as Map<String, dynamic>),
        verificationLevel: data['verificationLevel'] as int?,
        bankTransfer: data['bankTransfer'] == null
            ? null
            : BankTransfer.fromMap(
                data['bankTransfer'] as Map<String, dynamic>),
        id: data['_id'] as String?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        lastTransactionAt: data['lastTransactionAt'] == null
            ? null
            : DateTime.parse(data['lastTransactionAt'] as String),
        v: data['__v'] as int?,
        pendingBalance: data['pendingBalance'] as int?,
        formattedBalance: data['formattedBalance'] as String?,
        walletAge: data['walletAge'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'balance': balance,
        'availableBalance': availableBalance,
        'currency': currency,
        'status': status,
        'isDefault': isDefault,
        'limits': limits?.toMap(),
        'settings': settings?.toMap(),
        'verificationLevel': verificationLevel,
        'bankTransfer': bankTransfer?.toMap(),
        '_id': id,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'lastTransactionAt': lastTransactionAt?.toIso8601String(),
        '__v': v,
        'pendingBalance': pendingBalance,
        'formattedBalance': formattedBalance,
        'walletAge': walletAge,
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Wallet].
  factory Wallet.fromJson(String data) {
    return Wallet.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Wallet] to a JSON string.
  String toJson() => json.encode(toMap());

  Wallet copyWith({
    String? userId,
    int? balance,
    int? availableBalance,
    String? currency,
    String? status,
    bool? isDefault,
    Limits? limits,
    Settings? settings,
    int? verificationLevel,
    BankTransfer? bankTransfer,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTransactionAt,
    int? v,
    int? pendingBalance,
    String? formattedBalance,
    int? walletAge,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      limits: limits ?? this.limits,
      settings: settings ?? this.settings,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      bankTransfer: bankTransfer ?? this.bankTransfer,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      v: v ?? this.v,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      formattedBalance: formattedBalance ?? this.formattedBalance,
      walletAge: walletAge ?? this.walletAge,
    );
  }
}
