/// A cart line the server took out because its meal, or an add-on the customer
/// picked, was deleted from the menu. Shown once as a notice, then dismissed.
class UnavailableItem {
  static const mealRemoved = 'meal_removed';
  static const optionRemoved = 'option_removed';

  final String? cartItemId;
  final String? mealVariant;
  final String? mealName;
  final String? mealImage;
  final String? reason;
  final List<String> optionNames;
  final num? mealQuantity;
  final num? packNumber;
  final DateTime? removedAt;

  const UnavailableItem({
    this.cartItemId,
    this.mealVariant,
    this.mealName,
    this.mealImage,
    this.reason,
    this.optionNames = const [],
    this.mealQuantity,
    this.packNumber,
    this.removedAt,
  });

  bool get isOptionRemoved => reason == optionRemoved;

  /// Falls back to a generic name when the meal record was hard-deleted.
  String get displayName =>
      (mealName == null || mealName!.isEmpty) ? 'An item' : mealName!;

  /// The sentence shown to the customer.
  String get message {
    if (isOptionRemoved && optionNames.isNotEmpty) {
      return '$displayName was removed because ${optionNames.join(', ')} '
          'is no longer available.';
    }
    return '$displayName is no longer on the menu and was removed from your cart.';
  }

  factory UnavailableItem.fromMap(Map<String, dynamic> data) => UnavailableItem(
        cartItemId: data['cartItemId']?.toString(),
        mealVariant: data['mealVariant']?.toString(),
        mealName: data['mealName'] as String?,
        mealImage: data['mealImage'] as String?,
        reason: data['reason'] as String?,
        optionNames: (data['optionNames'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        mealQuantity: data['mealQuantity'] as num?,
        packNumber: data['packNumber'] as num?,
        removedAt: data['removedAt'] == null
            ? null
            : DateTime.tryParse(data['removedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'cartItemId': cartItemId,
        'mealVariant': mealVariant,
        'mealName': mealName,
        'mealImage': mealImage,
        'reason': reason,
        'optionNames': optionNames,
        'mealQuantity': mealQuantity,
        'packNumber': packNumber,
        'removedAt': removedAt?.toIso8601String(),
      };
}
