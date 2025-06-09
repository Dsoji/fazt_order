import 'dart:convert';

import 'schedule.dart';

class SalesOperation {
  Schedule? schedule;
  String? id;

  SalesOperation({this.schedule, this.id});

  @override
  String toString() => 'SalesOperation(schedule: $schedule, id: $id)';

  factory SalesOperation.fromMap(Map<String, dynamic> data) {
    return SalesOperation(
      schedule: data['schedule'] == null
          ? null
          : Schedule.fromMap(data['schedule'] as Map<String, dynamic>),
      id: data['_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'schedule': schedule?.toMap(),
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [SalesOperation].
  factory SalesOperation.fromJson(String data) {
    return SalesOperation.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [SalesOperation] to a JSON string.
  String toJson() => json.encode(toMap());

  SalesOperation copyWith({
    Schedule? schedule,
    String? id,
  }) {
    return SalesOperation(
      schedule: schedule ?? this.schedule,
      id: id ?? this.id,
    );
  }
}
