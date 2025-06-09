import 'dart:convert';

class Saturday {
  bool? open;
  String? id;
  List<dynamic>? time;

  Saturday({this.open, this.id, this.time});

  @override
  String toString() => 'Saturday(open: $open, id: $id, time: $time)';

  factory Saturday.fromMap(Map<String, dynamic> data) => Saturday(
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
  /// Parses the string and returns the resulting Json object as [Saturday].
  factory Saturday.fromJson(String data) {
    return Saturday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Saturday] to a JSON string.
  String toJson() => json.encode(toMap());

  Saturday copyWith({
    bool? open,
    String? id,
    List<dynamic>? time,
  }) {
    return Saturday(
      open: open ?? this.open,
      id: id ?? this.id,
      time: time ?? this.time,
    );
  }
}
