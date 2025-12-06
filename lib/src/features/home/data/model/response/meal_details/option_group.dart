import 'dart:convert';

import 'item.dart';

class OptionGroup {
  String? id;
  String? groupName;
  int? least;
  int? most;
  List<Item>? items;
  bool? isDeleted;
  bool? isRequired;

  OptionGroup(
      {this.id,
      this.groupName,
      this.least,
      this.most,
      this.items,
      this.isDeleted,
      this.isRequired});

  @override
  String toString() {
    return 'OptionGroup(id: $id, groupName: $groupName, least: $least, most: $most, items: $items, isDeleted: $isDeleted, isRequired: $isRequired)';
  }

  factory OptionGroup.fromMap(Map<String, dynamic> data) => OptionGroup(
        id: data['id'] as String?,
        groupName: data['groupName'] as String?,
        least: data['least'] as int?,
        most: data['most'] as int?,
        items: (data['items'] as List<dynamic>?)
            ?.map((e) => Item.fromMap(e as Map<String, dynamic>))
            .toList(),
        isDeleted: data['isDeleted'] as bool?,
        isRequired: data['isRequired'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'groupName': groupName,
        'least': least,
        'most': most,
        'items': items?.map((e) => e.toMap()).toList(),
        'isDeleted': isDeleted,
        'isRequired': isRequired,
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
    List<Item>? items,
    bool? isDeleted,
    bool? isRequired,
  }) {
    return OptionGroup(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      least: least ?? this.least,
      most: most ?? this.most,
      items: items ?? this.items,
      isDeleted: isDeleted ?? this.isDeleted,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}
