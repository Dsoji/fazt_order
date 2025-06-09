import 'dart:convert';

class Sunday {
  bool? open;
  String? id;
  List<dynamic>? time;

  Sunday({this.open, this.id, this.time});

  @override
  String toString() => 'Sunday(open: $open, id: $id, time: $time)';

  factory Sunday.fromMap(Map<String, dynamic> data) => Sunday(
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
  /// Parses the string and returns the resulting Json object as [Sunday].
  factory Sunday.fromJson(String data) {
    return Sunday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Sunday] to a JSON string.
  String toJson() => json.encode(toMap());

  Sunday copyWith({
    bool? open,
    String? id,
    List<dynamic>? time,
  }) {
    return Sunday(
      open: open ?? this.open,
      id: id ?? this.id,
      time: time ?? this.time,
    );
  }
}
