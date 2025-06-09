import 'dart:convert';

class Time {
  DateTime? startTime;
  DateTime? endTime;
  String? id;

  Time({this.startTime, this.endTime, this.id});

  @override
  String toString() {
    return 'Time(startTime: $startTime, endTime: $endTime, id: $id)';
  }

  factory Time.fromMap(Map<String, dynamic> data) => Time(
        startTime: data['startTime'] == null
            ? null
            : DateTime.parse(data['startTime'] as String),
        endTime: data['endTime'] == null
            ? null
            : DateTime.parse(data['endTime'] as String),
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Time].
  factory Time.fromJson(String data) {
    return Time.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Time] to a JSON string.
  String toJson() => json.encode(toMap());

  Time copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? id,
  }) {
    return Time(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
    );
  }
}
