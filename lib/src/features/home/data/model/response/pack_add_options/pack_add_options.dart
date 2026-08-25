import 'dart:convert';

import '../meal_variant_menu/result.dart';

/// `GET /carts/:cartId/pack/:packNumber/add-options` — what may be dropped into
/// an existing pack.
///
/// Answers in one of two shapes, so the app never has to reopen the whole
/// restaurant page to offer "Add to This Pack":
///
/// - [PackType.combinable] — the pack holds meals with no option items, so any
///   other such meal may join it. Show [eligibleMeals] as the picker.
/// - [PackType.mealOptions] — the pack holds a meal that has option items, so
///   only more of *that same meal* may join, with its own options. Open only
///   [meal]'s option sheet.
///
/// Asking the backend rather than filtering the menu locally is the point: it
/// owns the combination rules, and a client-side guess produces adds that come
/// back rejected after the user has already chosen.
class PackAddOptions {
  final int? packNumber;
  final PackType packType;

  /// The packaging that applies to this pack. Carried through from the
  /// response; the charge itself is rendered by checkout, not here.
  final PackPackaging? packaging;

  /// [PackType.combinable] only — everything that may join this pack.
  final List<MealVariantMenuResult> eligibleMeals;

  /// [PackType.mealOptions] only — the id of the one meal variant this pack
  /// accepts more of.
  final String? mealVariant;

  /// [PackType.mealOptions] only — the meal already in the pack, as a full
  /// document.
  final Map<String, dynamic>? meal;

  /// [PackType.mealOptions] only — that meal's option groups.
  final List<PackOptionGroup> optionGroups;

  const PackAddOptions({
    this.packNumber,
    this.packType = PackType.unknown,
    this.packaging,
    this.eligibleMeals = const [],
    this.mealVariant,
    this.meal,
    this.optionGroups = const [],
  });

  static const PackAddOptions none = PackAddOptions();

  /// Whether the pack can take any addition at all — a combinable pack with no
  /// eligible meals left has nothing to offer.
  bool get hasAnythingToAdd => packType == PackType.combinable
      ? eligibleMeals.isNotEmpty
      : packType == PackType.mealOptions && mealVariant != null;

  factory PackAddOptions.fromMap(Map<String, dynamic> data) => PackAddOptions(
        packNumber: (data['packNumber'] as num?)?.toInt(),
        packType: PackType.parse(data['packType'] as String?),
        packaging: data['packaging'] is Map<String, dynamic>
            ? PackPackaging.fromMap(data['packaging'] as Map<String, dynamic>)
            : null,
        eligibleMeals: (data['eligibleMeals'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_eligibleMealFrom)
            .toList(),
        mealVariant: data['mealVariant'] as String?,
        meal: data['meal'] as Map<String, dynamic>?,
        optionGroups: (data['optionGroups'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PackOptionGroup.fromMap)
            .toList(),
      );

  /// An eligible meal is a menu entry under a different key: this endpoint
  /// names the variant id `mealVariant`, the menu names it `id`. Remapping it
  /// here lets the picker feed straight into the existing add-to-cart sheet
  /// instead of needing a parallel widget.
  static MealVariantMenuResult _eligibleMealFrom(Map<String, dynamic> data) =>
      MealVariantMenuResult.fromMap({
        ...data,
        'id': data['mealVariant'] ?? data['id'],
      });

  Map<String, dynamic> toMap() => {
        'packNumber': packNumber,
        'packType': packType.wireValue,
        'packaging': packaging?.toMap(),
        'eligibleMeals': eligibleMeals.map((e) => e.toMap()).toList(),
        'mealVariant': mealVariant,
        'meal': meal,
        'optionGroups': optionGroups.map((e) => e.toMap()).toList(),
      };

  factory PackAddOptions.fromJson(String data) =>
      PackAddOptions.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'PackAddOptions(packNumber: $packNumber, packType: '
      '$packType, eligibleMeals: ${eligibleMeals.length})';
}

/// Which of the two answers came back.
enum PackType {
  /// The pack holds only meals without option items; any other such meal may
  /// join it.
  combinable,

  /// The pack holds a meal with option items; only more of that meal may join.
  mealOptions,

  /// An answer this build doesn't know. Treated as "offer nothing" rather than
  /// guessed at — sending an add the backend will reject is worse than not
  /// offering one.
  unknown;

  static PackType parse(String? value) => switch (value) {
        'combinable' => PackType.combinable,
        'meal_options' => PackType.mealOptions,
        _ => PackType.unknown,
      };

  String? get wireValue => switch (this) {
        PackType.combinable => 'combinable',
        PackType.mealOptions => 'meal_options',
        PackType.unknown => null,
      };
}

/// The packaging that applies to a pack.
class PackPackaging {
  final int? packNumber;
  final bool chargeable;
  final String? packageId;
  final String? packageName;
  final num? price;

  const PackPackaging({
    this.packNumber,
    this.chargeable = false,
    this.packageId,
    this.packageName,
    this.price,
  });

  factory PackPackaging.fromMap(Map<String, dynamic> data) => PackPackaging(
        packNumber: (data['packNumber'] as num?)?.toInt(),
        chargeable: data['chargeable'] as bool? ?? false,
        packageId: data['packageId'] as String?,
        packageName: data['packageName'] as String?,
        price: data['price'] as num?,
      );

  Map<String, dynamic> toMap() => {
        'packNumber': packNumber,
        'chargeable': chargeable,
        'packageId': packageId,
        'packageName': packageName,
        'price': price,
      };

  @override
  String toString() =>
      'PackPackaging(packageName: $packageName, price: $price)';
}

/// One option group on the meal a `meal_options` pack holds.
class PackOptionGroup {
  final String? groupName;
  final int? least;
  final int? most;
  final bool isRequired;
  final List<PackOptionItem> items;

  const PackOptionGroup({
    this.groupName,
    this.least,
    this.most,
    this.isRequired = false,
    this.items = const [],
  });

  factory PackOptionGroup.fromMap(Map<String, dynamic> data) => PackOptionGroup(
        groupName: data['groupName'] as String?,
        least: (data['least'] as num?)?.toInt(),
        most: (data['most'] as num?)?.toInt(),
        isRequired: data['isRequired'] as bool? ?? false,
        items: (data['items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PackOptionItem.fromMap)
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'groupName': groupName,
        'least': least,
        'most': most,
        'isRequired': isRequired,
        'items': items.map((e) => e.toMap()).toList(),
      };

  @override
  String toString() => 'PackOptionGroup(groupName: $groupName)';
}

class PackOptionItem {
  final String? item;
  final num? price;

  const PackOptionItem({this.item, this.price});

  factory PackOptionItem.fromMap(Map<String, dynamic> data) => PackOptionItem(
        item: data['item'] as String?,
        price: data['price'] as num?,
      );

  Map<String, dynamic> toMap() => {'item': item, 'price': price};

  @override
  String toString() => 'PackOptionItem(item: $item, price: $price)';
}
