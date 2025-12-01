import 'dart:convert';

class BankTransfer {
  String? accountNumber;
  String? accountName;
  String? bankName;
  String? bankCode;
  String? paystackCustomerCode;
  String? paystackVirtualAccountId;
  String? status;
  DateTime? lastSyncedAt;
  DateTime? createdAt;
  bool? isActive;

  BankTransfer({
    this.accountNumber,
    this.accountName,
    this.bankName,
    this.bankCode,
    this.paystackCustomerCode,
    this.paystackVirtualAccountId,
    this.status,
    this.lastSyncedAt,
    this.createdAt,
    this.isActive,
  });

  @override
  String toString() {
    return 'BankTransfer(accountNumber: $accountNumber, accountName: $accountName, bankName: $bankName, bankCode: $bankCode, paystackCustomerCode: $paystackCustomerCode, paystackVirtualAccountId: $paystackVirtualAccountId, status: $status, lastSyncedAt: $lastSyncedAt, createdAt: $createdAt, isActive: $isActive)';
  }

  factory BankTransfer.fromMap(Map<String, dynamic> data) => BankTransfer(
        accountNumber: data['accountNumber'] as String?,
        accountName: data['accountName'] as String?,
        bankName: data['bankName'] as String?,
        bankCode: data['bankCode'] as String?,
        paystackCustomerCode: data['paystackCustomerCode'] as String?,
        paystackVirtualAccountId: data['paystackVirtualAccountId'] as String?,
        status: data['status'] as String?,
        lastSyncedAt: data['lastSyncedAt'] == null
            ? null
            : DateTime.parse(data['lastSyncedAt'] as String),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        isActive: data['isActive'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'accountNumber': accountNumber,
        'accountName': accountName,
        'bankName': bankName,
        'bankCode': bankCode,
        'paystackCustomerCode': paystackCustomerCode,
        'paystackVirtualAccountId': paystackVirtualAccountId,
        'status': status,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'isActive': isActive,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [BankTransfer].
  factory BankTransfer.fromJson(String data) {
    return BankTransfer.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [BankTransfer] to a JSON string.
  String toJson() => json.encode(toMap());

  BankTransfer copyWith({
    String? accountNumber,
    String? accountName,
    String? bankName,
    String? bankCode,
    String? paystackCustomerCode,
    String? paystackVirtualAccountId,
    String? status,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return BankTransfer(
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      paystackCustomerCode: paystackCustomerCode ?? this.paystackCustomerCode,
      paystackVirtualAccountId:
          paystackVirtualAccountId ?? this.paystackVirtualAccountId,
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
