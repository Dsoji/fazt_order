import 'dart:convert';

class Thursday {
  bool? open;
  String? id;
  List<dynamic>? time;

  Thursday({this.open, this.id, this.time});

  @override
  String toString() => 'Thursday(open: $open, id: $id, time: $time)';

  factory Thursday.fromMap(Map<String, dynamic> data) => Thursday(
        open: data['open'] as bool?,
        id: data['_id'] as String?,
        time: data['time'] as List<dynamic>?,
      );

  Map<String, dynamic> toMap() => {
        'open': open,
        '_id': id,
        'time': time,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Thursday].
  factory Thursday.fromJson(String data) {
    return Thursday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Thursday] to a JSON string.
  String toJson() => json.encode(toMap());

  Thursday copyWith({
    bool? open,
    String? id,
    List<dynamic>? time,
  }) {
    return Thursday(
      open: open ?? this.open,
      id: id ?? this.id,
      time: time ?? this.time,
    );
  }
}
