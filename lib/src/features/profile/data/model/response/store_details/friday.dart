import 'dart:convert';

class Friday {
  bool? open;
  String? id;
  List<dynamic>? time;

  Friday({this.open, this.id, this.time});

  @override
  String toString() => 'Friday(open: $open, id: $id, time: $time)';

  factory Friday.fromMap(Map<String, dynamic> data) => Friday(
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
  /// Parses the string and returns the resulting Json object as [Friday].
  factory Friday.fromJson(String data) {
    return Friday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Friday] to a JSON string.
  String toJson() => json.encode(toMap());

  Friday copyWith({
    bool? open,
    String? id,
    List<dynamic>? time,
  }) {
    return Friday(
      open: open ?? this.open,
      id: id ?? this.id,
      time: time ?? this.time,
    );
  }
}
