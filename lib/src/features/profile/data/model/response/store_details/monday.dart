import 'dart:convert';

import 'time.dart';

class Monday {
  bool? open;
  List<Time>? time;
  String? id;

  Monday({this.open, this.time, this.id});

  @override
  String toString() => 'Monday(open: $open, time: $time, id: $id)';

  factory Monday.fromMap(Map<String, dynamic> data) => Monday(
        open: data['open'] as bool?,
        time: (data['time'] as List<dynamic>?)
            ?.map((e) => Time.fromMap(e as Map<String, dynamic>))
            .toList(),
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'open': open,
        'time': time?.map((e) => e.toMap()).toList(),
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Monday].
  factory Monday.fromJson(String data) {
    return Monday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Monday] to a JSON string.
  String toJson() => json.encode(toMap());

  Monday copyWith({
    bool? open,
    List<Time>? time,
    String? id,
  }) {
    return Monday(
      open: open ?? this.open,
      time: time ?? this.time,
      id: id ?? this.id,
    );
  }
}
