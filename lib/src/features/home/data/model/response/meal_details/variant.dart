import 'dart:convert';

class Variant {
  String? id;
  bool? inStock;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  Variant({
    this.id,
    this.inStock,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() {
    return 'Variant(id: $id, inStock: $inStock, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  factory Variant.fromMap(Map<String, dynamic> data) => Variant(
        id: data['id'] as String?,
        inStock: data['inStock'] as bool?,
        notes: data['notes'] as String?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'inStock': inStock,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Variant].
  factory Variant.fromJson(String data) {
    return Variant.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Variant] to a JSON string.
  String toJson() => json.encode(toMap());

  Variant copyWith({
    String? id,
    bool? inStock,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Variant(
      id: id ?? this.id,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
