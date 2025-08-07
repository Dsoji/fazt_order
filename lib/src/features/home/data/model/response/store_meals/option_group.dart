import 'dart:convert';

import 'item.dart';

class OptionGroup {
  String? groupName;
  int? least;
  int? most;
  String? shop;
  List<Item>? items;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  OptionGroup({
    this.groupName,
    this.least,
    this.most,
    this.shop,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'OptionGroup(groupName: $groupName, least: $least, most: $most, shop: $shop, items: $items, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory OptionGroup.fromMap(Map<String, dynamic> data) => OptionGroup(
        groupName: data['groupName'] as String?,
        least: data['least'] as int?,
        most: data['most'] as int?,
        shop: data['shop'] as String?,
        items: (data['items'] as List<dynamic>?)
            ?.map((e) => Item.fromMap(e as Map<String, dynamic>))
            .toList(),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'groupName': groupName,
        'least': least,
        'most': most,
        'shop': shop,
        'items': items?.map((e) => e.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
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
    String? groupName,
    int? least,
    int? most,
    String? shop,
    List<Item>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return OptionGroup(
      groupName: groupName ?? this.groupName,
      least: least ?? this.least,
      most: most ?? this.most,
      shop: shop ?? this.shop,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
