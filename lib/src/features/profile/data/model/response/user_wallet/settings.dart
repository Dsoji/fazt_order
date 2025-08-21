import 'dart:convert';

class Settings {
  bool? autoTopUpEnabled;
  int? autoTopUpThreshold;
  int? autoTopUpAmount;
  bool? pinEnabled;
  bool? biometricEnabled;
  bool? notificationsEnabled;
  bool? lowBalanceAlert;
  int? lowBalanceThreshold;
  String? id;

  Settings({
    this.autoTopUpEnabled,
    this.autoTopUpThreshold,
    this.autoTopUpAmount,
    this.pinEnabled,
    this.biometricEnabled,
    this.notificationsEnabled,
    this.lowBalanceAlert,
    this.lowBalanceThreshold,
    this.id,
  });

  @override
  String toString() {
    return 'Settings(autoTopUpEnabled: $autoTopUpEnabled, autoTopUpThreshold: $autoTopUpThreshold, autoTopUpAmount: $autoTopUpAmount, pinEnabled: $pinEnabled, biometricEnabled: $biometricEnabled, notificationsEnabled: $notificationsEnabled, lowBalanceAlert: $lowBalanceAlert, lowBalanceThreshold: $lowBalanceThreshold, id: $id)';
  }

  factory Settings.fromMap(Map<String, dynamic> data) => Settings(
        autoTopUpEnabled: data['autoTopUpEnabled'] as bool?,
        autoTopUpThreshold: data['autoTopUpThreshold'] as int?,
        autoTopUpAmount: data['autoTopUpAmount'] as int?,
        pinEnabled: data['pinEnabled'] as bool?,
        biometricEnabled: data['biometricEnabled'] as bool?,
        notificationsEnabled: data['notificationsEnabled'] as bool?,
        lowBalanceAlert: data['lowBalanceAlert'] as bool?,
        lowBalanceThreshold: data['lowBalanceThreshold'] as int?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'autoTopUpEnabled': autoTopUpEnabled,
        'autoTopUpThreshold': autoTopUpThreshold,
        'autoTopUpAmount': autoTopUpAmount,
        'pinEnabled': pinEnabled,
        'biometricEnabled': biometricEnabled,
        'notificationsEnabled': notificationsEnabled,
        'lowBalanceAlert': lowBalanceAlert,
        'lowBalanceThreshold': lowBalanceThreshold,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Settings].
  factory Settings.fromJson(String data) {
    return Settings.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Settings] to a JSON string.
  String toJson() => json.encode(toMap());

  Settings copyWith({
    bool? autoTopUpEnabled,
    int? autoTopUpThreshold,
    int? autoTopUpAmount,
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? lowBalanceAlert,
    int? lowBalanceThreshold,
    String? id,
  }) {
    return Settings(
      autoTopUpEnabled: autoTopUpEnabled ?? this.autoTopUpEnabled,
      autoTopUpThreshold: autoTopUpThreshold ?? this.autoTopUpThreshold,
      autoTopUpAmount: autoTopUpAmount ?? this.autoTopUpAmount,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lowBalanceAlert: lowBalanceAlert ?? this.lowBalanceAlert,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      id: id ?? this.id,
    );
  }
}
