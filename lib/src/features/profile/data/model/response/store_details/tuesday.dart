import 'dart:convert';

class Tuesday {
  bool? open;
  List<dynamic>? time;
  String? id;

  Tuesday({this.open, this.time, this.id});

  @override
  String toString() => 'Tuesday(open: $open, time: $time, id: $id)';

  factory Tuesday.fromMap(Map<String, dynamic> data) => Tuesday(
        open: data['open'] as bool?,
        time: data['time'] as List<dynamic>?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'open': open,
        'time': time,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Tuesday].
  factory Tuesday.fromJson(String data) {
    return Tuesday.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Tuesday] to a JSON string.
  String toJson() => json.encode(toMap());

  Tuesday copyWith({
    bool? open,
    List<dynamic>? time,
    String? id,
  }) {
    return Tuesday(
      open: open ?? this.open,
      time: time ?? this.time,
      id: id ?? this.id,
    );
  }
}
