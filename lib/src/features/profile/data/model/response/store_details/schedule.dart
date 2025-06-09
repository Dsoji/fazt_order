import 'dart:convert';

import 'friday.dart';
import 'monday.dart';
import 'saturday.dart';
import 'sunday.dart';
import 'thursday.dart';
import 'tuesday.dart';
import 'wednesday.dart';

class Schedule {
  Monday? monday;
  Tuesday? tuesday;
  Wednesday? wednesday;
  Thursday? thursday;
  Friday? friday;
  Saturday? saturday;
  Sunday? sunday;
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
            : Monday.fromMap(data['Monday'] as Map<String, dynamic>),
        tuesday: data['Tuesday'] == null
            ? null
            : Tuesday.fromMap(data['Tuesday'] as Map<String, dynamic>),
        wednesday: data['Wednesday'] == null
            ? null
            : Wednesday.fromMap(data['Wednesday'] as Map<String, dynamic>),
        thursday: data['Thursday'] == null
            ? null
            : Thursday.fromMap(data['Thursday'] as Map<String, dynamic>),
        friday: data['Friday'] == null
            ? null
            : Friday.fromMap(data['Friday'] as Map<String, dynamic>),
        saturday: data['Saturday'] == null
            ? null
            : Saturday.fromMap(data['Saturday'] as Map<String, dynamic>),
        sunday: data['Sunday'] == null
            ? null
            : Sunday.fromMap(data['Sunday'] as Map<String, dynamic>),
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

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Schedule].
  factory Schedule.fromJson(String data) {
    return Schedule.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Schedule] to a JSON string.
  String toJson() => json.encode(toMap());

  Schedule copyWith({
    Monday? monday,
    Tuesday? tuesday,
    Wednesday? wednesday,
    Thursday? thursday,
    Friday? friday,
    Saturday? saturday,
    Sunday? sunday,
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
