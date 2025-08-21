import 'dart:convert';

class Limits {
  int? dailyTopUpLimit;
  int? monthlyTopUpLimit;
  int? dailySpendLimit;
  int? monthlySpendLimit;
  int? maxBalance;
  int? minBalance;
  int? singleTransactionLimit;
  String? id;

  Limits({
    this.dailyTopUpLimit,
    this.monthlyTopUpLimit,
    this.dailySpendLimit,
    this.monthlySpendLimit,
    this.maxBalance,
    this.minBalance,
    this.singleTransactionLimit,
    this.id,
  });

  @override
  String toString() {
    return 'Limits(dailyTopUpLimit: $dailyTopUpLimit, monthlyTopUpLimit: $monthlyTopUpLimit, dailySpendLimit: $dailySpendLimit, monthlySpendLimit: $monthlySpendLimit, maxBalance: $maxBalance, minBalance: $minBalance, singleTransactionLimit: $singleTransactionLimit, id: $id)';
  }

  factory Limits.fromMap(Map<String, dynamic> data) => Limits(
        dailyTopUpLimit: data['dailyTopUpLimit'] as int?,
        monthlyTopUpLimit: data['monthlyTopUpLimit'] as int?,
        dailySpendLimit: data['dailySpendLimit'] as int?,
        monthlySpendLimit: data['monthlySpendLimit'] as int?,
        maxBalance: data['maxBalance'] as int?,
        minBalance: data['minBalance'] as int?,
        singleTransactionLimit: data['singleTransactionLimit'] as int?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'dailyTopUpLimit': dailyTopUpLimit,
        'monthlyTopUpLimit': monthlyTopUpLimit,
        'dailySpendLimit': dailySpendLimit,
        'monthlySpendLimit': monthlySpendLimit,
        'maxBalance': maxBalance,
        'minBalance': minBalance,
        'singleTransactionLimit': singleTransactionLimit,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Limits].
  factory Limits.fromJson(String data) {
    return Limits.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Limits] to a JSON string.
  String toJson() => json.encode(toMap());

  Limits copyWith({
    int? dailyTopUpLimit,
    int? monthlyTopUpLimit,
    int? dailySpendLimit,
    int? monthlySpendLimit,
    int? maxBalance,
    int? minBalance,
    int? singleTransactionLimit,
    String? id,
  }) {
    return Limits(
      dailyTopUpLimit: dailyTopUpLimit ?? this.dailyTopUpLimit,
      monthlyTopUpLimit: monthlyTopUpLimit ?? this.monthlyTopUpLimit,
      dailySpendLimit: dailySpendLimit ?? this.dailySpendLimit,
      monthlySpendLimit: monthlySpendLimit ?? this.monthlySpendLimit,
      maxBalance: maxBalance ?? this.maxBalance,
      minBalance: minBalance ?? this.minBalance,
      singleTransactionLimit:
          singleTransactionLimit ?? this.singleTransactionLimit,
      id: id ?? this.id,
    );
  }
}
