import 'dart:convert';

class BankTransfer {
  String? bankName;
  String? bankCode;
  bool? isActive;
  String? accountNumber;
  String? accountName;
  String? paystackCustomerCode;
  String? paystackVirtualAccountId;

  BankTransfer(
      {this.bankName,
      this.bankCode,
      this.isActive,
      this.accountNumber,
      this.accountName,
      this.paystackCustomerCode,
      this.paystackVirtualAccountId});

  @override
  String toString() {
    return 'BankTransfer(bankName: $bankName, bankCode: $bankCode, isActive: $isActive, accountNumber: $accountNumber, accountName: $accountName, paystackCustomerCode: $paystackCustomerCode, paystackVirtualAccountId: $paystackVirtualAccountId)';
  }

  factory BankTransfer.fromMap(Map<String, dynamic> data) => BankTransfer(
        bankName: data['bankName'] as String?,
        bankCode: data['bankCode'] as String?,
        isActive: data['isActive'] as bool?,
        accountNumber: data['accountNumber'] as String?,
        accountName: data['accountName'] as String?,
        paystackCustomerCode: data['paystackCustomerCode'] as String?,
        paystackVirtualAccountId: data['paystackVirtualAccountId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'bankName': bankName,
        'bankCode': bankCode,
        'isActive': isActive,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'paystackCustomerCode': paystackCustomerCode,
        'paystackVirtualAccountId': paystackVirtualAccountId,
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
    String? bankName,
    String? bankCode,
    bool? isActive,
    String? accountNumber,
    String? accountName,
    String? paystackCustomerCode,
    String? paystackVirtualAccountId,
  }) {
    return BankTransfer(
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      isActive: isActive ?? this.isActive,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      paystackCustomerCode: paystackCustomerCode ?? this.paystackCustomerCode,
      paystackVirtualAccountId:
          paystackVirtualAccountId ?? this.paystackVirtualAccountId,
    );
  }
}
