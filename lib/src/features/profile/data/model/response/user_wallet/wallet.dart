import 'dart:convert';

import 'bank_transfer.dart';

class Wallet {
  BankTransfer? bankTransfer;
  String? id;
  String? userId;
  double? balance;
  double? availableBalance;
  String? currency;
  String? status;
  bool? isDefault;
  int? verificationLevel;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastTransactionAt;
  int? v;
  int? pendingBalance;
  String? formattedBalance;
  int? walletAge;

  Wallet({
    this.bankTransfer,
    this.id,
    this.userId,
    this.balance,
    this.availableBalance,
    this.currency,
    this.status,
    this.isDefault,
    this.verificationLevel,
    this.isDeleted,
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
    return 'Wallet(bankTransfer: $bankTransfer, id: $id, userId: $userId, balance: $balance, availableBalance: $availableBalance, currency: $currency, status: $status, isDefault: $isDefault, verificationLevel: $verificationLevel, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, lastTransactionAt: $lastTransactionAt, v: $v, pendingBalance: $pendingBalance, formattedBalance: $formattedBalance, walletAge: $walletAge, id: $id)';
  }

  factory Wallet.fromMap(Map<String, dynamic> data) => Wallet(
        bankTransfer: data['bankTransfer'] == null
            ? null
            : BankTransfer.fromMap(
                data['bankTransfer'] as Map<String, dynamic>),
        id: data['_id'] as String?,
        userId: data['userId'] as String?,
        balance: (data['balance'] as num?)?.toDouble(),
        availableBalance: (data['availableBalance'] as num?)?.toDouble(),
        currency: data['currency'] as String?,
        status: data['status'] as String?,
        isDefault: data['isDefault'] as bool?,
        verificationLevel: data['verificationLevel'] as int?,
        isDeleted: data['isDeleted'] as bool?,
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
        'bankTransfer': bankTransfer?.toMap(),
        '_id': id,
        'userId': userId,
        'balance': balance,
        'availableBalance': availableBalance,
        'currency': currency,
        'status': status,
        'isDefault': isDefault,
        'verificationLevel': verificationLevel,
        'isDeleted': isDeleted,
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
    BankTransfer? bankTransfer,
    String? id,
    String? userId,
    double? balance,
    double? availableBalance,
    String? currency,
    String? status,
    bool? isDefault,
    int? verificationLevel,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTransactionAt,
    int? v,
    int? pendingBalance,
    String? formattedBalance,
    int? walletAge,
  }) {
    return Wallet(
      bankTransfer: bankTransfer ?? this.bankTransfer,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      isDeleted: isDeleted ?? this.isDeleted,
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
