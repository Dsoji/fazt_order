import 'dart:convert';

import 'day_schedule.dart';

class Schedule {
  DaySchedule? monday;
  DaySchedule? tuesday;
  DaySchedule? wednesday;
  DaySchedule? thursday;
  DaySchedule? friday;
  DaySchedule? saturday;
  DaySchedule? sunday;
  String? id;

  Schedule({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.id,
  });

  @override
  String toString() {
    return 'Schedule(monday: $monday, tuesday: $tuesday, wednesday: $wednesday, thursday: $thursday, friday: $friday, saturday: $saturday, sunday: $sunday, id: $id)';
  }

  factory Schedule.fromMap(Map<String, dynamic> data) => Schedule(
        monday: data['Monday'] == null
            ? null
            : DaySchedule.fromMap(data['Monday'] as Map<String, dynamic>),
        tuesday: data['Tuesday'] == null
            ? null
            : DaySchedule.fromMap(data['Tuesday'] as Map<String, dynamic>),
        wednesday: data['Wednesday'] == null
            ? null
            : DaySchedule.fromMap(data['Wednesday'] as Map<String, dynamic>),
        thursday: data['Thursday'] == null
            ? null
            : DaySchedule.fromMap(data['Thursday'] as Map<String, dynamic>),
        friday: data['Friday'] == null
            ? null
            : DaySchedule.fromMap(data['Friday'] as Map<String, dynamic>),
        saturday: data['Saturday'] == null
            ? null
            : DaySchedule.fromMap(data['Saturday'] as Map<String, dynamic>),
        sunday: data['Sunday'] == null
            ? null
            : DaySchedule.fromMap(data['Sunday'] as Map<String, dynamic>),
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'Monday': monday?.toMap(),
        'Tuesday': tuesday?.toMap(),
        'Wednesday': wednesday?.toMap(),
        'Thursday': thursday?.toMap(),
        'Friday': friday?.toMap(),
        'Saturday': saturday?.toMap(),
        'Sunday': sunday?.toMap(),
        '_id': id,
      };

  factory Schedule.fromJson(String data) {
    return Schedule.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  Schedule copyWith({
    DaySchedule? monday,
    DaySchedule? tuesday,
    DaySchedule? wednesday,
    DaySchedule? thursday,
    DaySchedule? friday,
    DaySchedule? saturday,
    DaySchedule? sunday,
    String? id,
  }) {
    return Schedule(
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
      id: id ?? this.id,
    );
  }
}

