import 'dart:convert';

class OptionGroup {
  String? id;
  String? groupName;
  int? least;
  int? most;
  String? store;
  List<String>? items;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? version;

  OptionGroup({
    this.id,
    this.groupName,
    this.least,
    this.most,
    this.store,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  @override
  String toString() {
    return 'OptionGroup(id: $id, groupName: $groupName, least: $least, most: $most, store: $store, items: $items, createdAt: $createdAt, updatedAt: $updatedAt, version: $version)';
  }

  factory OptionGroup.fromMap(Map<String, dynamic> data) => OptionGroup(
        id: data['_id'] as String?,
        groupName: data['groupName'] as String?,
        least: data['least'] as int?,
        most: data['most'] as int?,
        store: data['store'] as String?,
        items: (data['items'] as List<dynamic>?)?.cast<String>(),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        version: data['__v'] as int?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'groupName': groupName,
        'least': least,
        'most': most,
        'store': store,
        'items': items,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': version,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [OptionGroup].
  factory OptionGroup.fromJson(String data) {
    return OptionGroup.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [OptionGroup] to a JSON string.
  String toJson() => json.encode(toMap());

  OptionGroup copyWith({
    String? id,
    String? groupName,
    int? least,
    int? most,
    String? store,
    List<String>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return OptionGroup(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      least: least ?? this.least,
      most: most ?? this.most,
      store: store ?? this.store,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
