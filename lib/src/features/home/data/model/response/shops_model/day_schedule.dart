import 'dart:convert';

import 'time_slot.dart';

class DaySchedule {
  bool? open;
  List<TimeSlot>? time;
  String? id;

  DaySchedule({this.open, this.time, this.id});

  @override
  String toString() {
    return 'DaySchedule(open: $open, time: $time, id: $id)';
  }

  factory DaySchedule.fromMap(Map<String, dynamic> data) => DaySchedule(
        open: data['open'] as bool?,
        time: (data['time'] as List<dynamic>?)
            ?.map((e) => TimeSlot.fromMap(e as Map<String, dynamic>))
            .toList(),
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'open': open,
        'time': time?.map((e) => e.toMap()).toList(),
        '_id': id,
      };

  factory DaySchedule.fromJson(String data) {
    return DaySchedule.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  DaySchedule copyWith({
    bool? open,
    List<TimeSlot>? time,
    String? id,
  }) {
    return DaySchedule(
      open: open ?? this.open,
      time: time ?? this.time,
      id: id ?? this.id,
    );
  }
}
