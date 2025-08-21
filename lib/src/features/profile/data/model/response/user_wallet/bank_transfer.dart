import 'dart:convert';

class BankTransfer {
  String? bankName;
  String? bankCode;
  bool? isActive;

  BankTransfer({this.bankName, this.bankCode, this.isActive});

  @override
  String toString() {
    return 'BankTransfer(bankName: $bankName, bankCode: $bankCode, isActive: $isActive)';
  }

  factory BankTransfer.fromMap(Map<String, dynamic> data) => BankTransfer(
        bankName: data['bankName'] as String?,
        bankCode: data['bankCode'] as String?,
        isActive: data['isActive'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'bankName': bankName,
        'bankCode': bankCode,
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
    String? bankName,
    String? bankCode,
    bool? isActive,
  }) {
    return BankTransfer(
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      isActive: isActive ?? this.isActive,
    );
  }
}
