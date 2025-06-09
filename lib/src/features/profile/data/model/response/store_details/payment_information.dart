import 'dart:convert';

class PaymentInformation {
  String? bankName;
  int? accountNumber;
  String? accountName;
  String? id;

  PaymentInformation({
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.id,
  });

  @override
  String toString() {
    return 'PaymentInformation(bankName: $bankName, accountNumber: $accountNumber, accountName: $accountName, id: $id)';
  }

  factory PaymentInformation.fromMap(Map<String, dynamic> data) {
    return PaymentInformation(
      bankName: data['bankName'] as String?,
      accountNumber: data['accountNumber'] as int?,
      accountName: data['accountName'] as String?,
      id: data['_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountName': accountName,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PaymentInformation].
  factory PaymentInformation.fromJson(String data) {
    return PaymentInformation.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PaymentInformation] to a JSON string.
  String toJson() => json.encode(toMap());

  PaymentInformation copyWith({
    String? bankName,
    int? accountNumber,
    String? accountName,
    String? id,
  }) {
    return PaymentInformation(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      id: id ?? this.id,
    );
  }
}
