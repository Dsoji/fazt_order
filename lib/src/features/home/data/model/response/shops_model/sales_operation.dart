import 'dart:convert';

import 'schedule.dart';

class SalesOperation {
  Schedule? schedule;

  SalesOperation({this.schedule});

  @override
  String toString() {
    return 'SalesOperation(schedule: $schedule)';
  }

  factory SalesOperation.fromMap(Map<String, dynamic> data) => SalesOperation(
        schedule: data['schedule'] == null
            ? null
            : Schedule.fromMap(data['schedule'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'schedule': schedule?.toMap(),
      };

  factory SalesOperation.fromJson(String data) {
    return SalesOperation.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  SalesOperation copyWith({
    Schedule? schedule,
  }) {
    return SalesOperation(
      schedule: schedule ?? this.schedule,
    );
  }
}

