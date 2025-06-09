import 'dart:convert';

import 'time.dart';

class Wednesday {
  bool? open;
  List<Time>? time;
  String? id;

  Wednesday({this.open, this.time, this.id});

  @override
  String toString() => 'Wednesday(open: $open, time: $time, id: $id)';

  factory Wednesday.fromMap(Map<String, dynamic> data) => Wednesday(
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
  /// Parses the string and returns the resulting Json object as [Wednesday].
  factory Wednesday.fromJson(String data) {
    return Wednesday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Wednesday] to a JSON string.
  String toJson() => json.encode(toMap());

  Wednesday copyWith({
    bool? open,
    List<Time>? time,
    String? id,
  }) {
    return Wednesday(
      open: open ?? this.open,
      time: time ?? this.time,
      id: id ?? this.id,
    );
  }
}
