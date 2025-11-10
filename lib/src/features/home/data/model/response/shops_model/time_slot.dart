import 'dart:convert';

class TimeSlot {
  String? startTime;
  String? endTime;
  String? id;

  TimeSlot({this.startTime, this.endTime, this.id});

  @override
  String toString() {
    return 'TimeSlot(startTime: $startTime, endTime: $endTime, id: $id)';
  }

  factory TimeSlot.fromMap(Map<String, dynamic> data) => TimeSlot(
        startTime: data['startTime'] as String?,
        endTime: data['endTime'] as String?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'startTime': startTime,
        'endTime': endTime,
        '_id': id,
      };

  factory TimeSlot.fromJson(String data) {
    return TimeSlot.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  TimeSlot copyWith({
    String? startTime,
    String? endTime,
    String? id,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
    );
  }
}

