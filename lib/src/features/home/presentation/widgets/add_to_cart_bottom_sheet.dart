import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/utils/failures.dart';
import '../../data/controller/shop_controller.dart';
import '../../data/model/response/cartlsit/cart.dart';
import '../../data/model/response/cartlsit/item.dart' as cart;
import '../../data/model/response/cartlsit/item_options.dart';
import '../../data/model/response/meal_details/item.dart' as meal_details;
import '../../data/model/response/meal_details/option_group.dart'
    as meal_details;
import '../../data/model/response/meal_variant_menu/result.dart';
import '../providers/active_pack_provider.dart';
import '../providers/add_to_cart_provider.dart';
import 'promo_tag_badge.dart';

final _logger = Logger();

/// The meal quantity the cart accepts on one line. Past this the quantity
/// endpoint an edit saves through rejects the change, so the sheet stops here.
const int _maxMealQuantity = 10;

class AddToCartBottomSheet extends HookConsumerWidget {
  /// The menu line being added. Null when the sheet was opened to edit
  /// something already in the cart, where the line itself says which meal to
  /// load.
  final MealVariantMenuResult? menuItem;

  /// The shop this meal is being added for. Passed in where the caller already
  /// knows it, since the pack target is kept per shop and the menu payload does
  /// not always carry the shop back on each item.
  final String? shopId;

  /// The cart line being edited, when the sheet was opened from checkout. Its
  /// options seed the selection, so the customer starts from what they chose
  /// the first time rather than from an empty sheet.
  final cart.Item? editingItem;

  /// The cart holding [editingItem].
  final String? editingCartId;

  const AddToCartBottomSheet({
    super.key,
    required MealVariantMenuResult this.menuItem,
    this.shopId,
  })  : editingItem = null,
        editingCartId = null;

  /// Reopens the customization sheet on a line already in the cart, so what is
  /// *in* the meal can be changed and not only how many of it there are.
  ///
  /// The pack is the line's own — an edit stays where the customer put it.
  const AddToCartBottomSheet.edit({
    super.key,
    required cart.Item item,
    required String cartId,
    this.shopId,
  })  : menuItem = null,
        editingItem = item,
        editingCartId = cartId;

  bool get _isEditing => editingItem != null;

  /// The meal variant the sheet is working on. The menu line and the cart line
  /// carry the same kind of id — it is what `fetchMealDetails` reads and what
  /// `POST /carts` is keyed by — so either can drive the sheet.
  String get _mealVariantId =>
      menuItem?.id ?? editingItem?.mealVariant?.id ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() {
        ref
            .read(shopControllerProvider.notifier)
            .fetchMealDetails(_mealVariantId);
      });
      return null;
    }, [_mealVariantId]);

    final mealDetailsAsync = ref.watch(shopControllerProvider).mealDetails;
    final cartState = ref.watch(addToCartProvider);
    final cartNotifier = ref.read(addToCartProvider.notifier);

    // An edit can take more than one call to save, and the cart is only whole
    // again once the last of them lands. The sheet closes itself off while they
    // run — the PopScope and the close button below both read this — so the
    // customer cannot walk away mid-write and be left guessing what stuck.
    final isSaving = useState(false);

    // The customer's existing choices only become addressable once the meal's
    // option groups are known: the cart stores option variants flat, while the
    // sheet keeps them under the group they belong to. Seeded once — after
    // that the sheet's own state is the newer of the two.
    final hasSeeded = useRef(false);
    final mealDetails = mealDetailsAsync.valueOrNull;
    useEffect(() {
      // The controller holds one meal's details at a time, and the sheet can
      // open while the last meal's are still in there — seeding off those would
      // match nothing and then call itself done. Wait for this meal's own.
      if (!_isEditing ||
          hasSeeded.value ||
          mealDetails == null ||
          mealDetails.mealVariant?.id != _mealVariantId) {
        return null;
      }
      hasSeeded.value = true;

      final chosen = <String, int>{
        for (final option
            in editingItem?.options ?? const <ItemOption>[])
          if ((option.optionItemVariant?.id ?? '').isNotEmpty)
            option.optionItemVariant!.id!: option.quantity ?? 1,
      };
      final byGroup = <String, Map<String, int>>{};
      for (final group in mealDetails.mealVariant?.meal?.optionGroup ??
          const <meal_details.OptionGroup>[]) {
        for (final groupItem in group.items ?? const <meal_details.Item>[]) {
          final variantId = groupItem.variant?.id ?? '';
          final quantity = chosen[variantId];
          if (quantity == null) continue;
          byGroup.putIfAbsent(group.id ?? '', () => {})[variantId] = quantity;
        }
      }

      // Seeding writes to a provider, which cannot happen while this build is
      // still running.
      Future.microtask(() {
        if (!context.mounted) return;
        final notifier = ref.read(addToCartProvider.notifier);
        notifier.updateQuantity((editingItem?.mealQuantity ?? 1).toInt());
        byGroup.forEach(notifier.updateSelection);
      });
      return null;
    }, [mealDetails]);

    // Which pack this meal joins. The customer picks the target on the menu
    // screen and it sticks; with nothing picked yet the meal opens the next
    // pack, so a first add lands in Pack 1 rather than wherever the server
    // would have put it.
    final resolvedShopId = shopId ?? menuItem?.shop?.id;
    final shopCart = cartForShop(
      ref.watch(shopControllerProvider.select((s) => s.fetchCart)).valueOrNull,
      resolvedShopId,
    );
    final nextPack = nextPackNumber(shopCart);
    final chosenPack = ref.watch(activePackProvider)[resolvedShopId];
    // A pack the customer chose can go stale — they emptied the cart, the pack
    // was removed at checkout, or it has since filled with a customised meal
    // that leaves no room for this one — so a target the backend would refuse
    // is dropped in favour of a fresh pack rather than posted and rejected. An
    // edit ignores the target altogether and stays in its own pack.
    final targetPack = _isEditing
        ? (editingItem?.packNumber?.toInt() ?? nextPack)
        : (chosenPack != null &&
                chosenPack <= nextPack &&
                _packAccepts(shopCart, chosenPack))
            ? chosenPack
            : nextPack;

    final totalPrice = useMemoized(() {
      return cartNotifier.calculateTotalPrice(mealDetailsAsync.valueOrNull);
    }, [
      cartState.selectedItemsWithQuantity,
      cartState.quantity,
      mealDetailsAsync,
    ]);

    // Up to the moment they commit, the customer can back out however they
    // like — the close button, the barrier, the system back gesture. Only once
    // a save is actually in flight does the sheet hold them, and only until it
    // lands.
    return PopScope(
      canPop: !isSaving.value,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: kcWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: kcPrimaryNeutral900,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          isSaving.value ? null : () => Navigator.pop(context),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: const BoxDecoration(
                          color: kcPrimaryNeutral950,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: isSaving.value
                              ? kcPrimaryNeutral800
                              : kcPrimaryNeutral300,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content area with AsyncValue.when
              Flexible(
                child: mealDetailsAsync.when(
                  data: (mealDetails) {
                    final options = mealDetails.mealVariant?.meal?.optionGroup;

                    final meal = mealDetails.mealVariant?.meal;
                    final promotion = meal?.promotionDisplay;
                    final price = meal?.price;
                    final discounted = discountedPrice(price, promotion);
                    final tag =
                        promotionTagText(promotion, tag: promotion?.tag);
                    final imageUrl = meal?.mealImage;
                    final description = meal?.mealDescription ?? '';

                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food image
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 190,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const _MealImageFallback(),
                                      )
                                    : const _MealImageFallback(),
                              ),
                              if (tag != null)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  right: 10,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: PromoTagBadge(label: tag),
                                  ),
                                ),
                            ],
                          ),
                          const Gap(14),

                          // Food name
                          Text(
                            meal?.mealName ?? 'Food Item',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: kcBlack,
                              height: 1.2,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const Gap(6),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: kcPrimaryNeutral500,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const Gap(10),

                          // Base price — struck through when a promotion is running
                          if (discounted != null)
                            Row(
                              children: [
                                Text(
                                  '₦${discounted.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: kcPrimaryOrange700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₦${price ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kcPrimaryNeutral600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'From ₦${price ?? 0}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: kcPrimary300,
                              ),
                            ),
                          const Gap(18),

                          // Dynamic customization sections based on optionGroup
                          if (options != null &&
                              options.any((g) => (g.items ?? []).any(
                                  (i) => i.variant?.inStock == true)))
                            Builder(builder: (_) {
                              final visibleOptions = options
                                  .where((g) => (g.items ?? []).any(
                                      (i) => i.variant?.inStock == true))
                                  .toList();
                              return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: visibleOptions.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 18),
                              itemBuilder: (context, index) {
                                final optionGroup = visibleOptions[index];
                                final items = optionGroup.items ?? [];

                                final optionNames = items.map((item) {
                                  final price = item.price ?? 0;
                                  return price > 0
                                      ? '${item.item} ₦$price'
                                      : item.item ?? '';
                                }).toList();

                                return buildCustomizationSection(
                                  optionGroup.groupName ?? 'Customization',
                                  optionNames,
                                  items,
                                  isRequired: optionGroup.isRequired ?? false,
                                  maxSelection: (optionGroup.most != null &&
                                          optionGroup.most! > 0)
                                      ? optionGroup.most
                                      : null,
                                  groupId: optionGroup.id ?? '',
                                  selectedItemIdsWithQuantity:
                                      cartState.selectedItemsWithQuantity[
                                              optionGroup.id ?? ''] ??
                                          {},
                                  onSelectionChanged:
                                      (selectedItemIdsWithQuantity) {
                                    cartNotifier.updateSelection(
                                        optionGroup.id ?? '',
                                        selectedItemIdsWithQuantity);
                                  },
                                );
                              },
                            );
                            }),
                        ],
                      ),
                    );
                  },
                  loading: () => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: Shimmer.fromColors(
                      baseColor: kcPrimaryNeutral900,
                      highlightColor: kcPrimaryNeutral950,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 190,
                            decoration: BoxDecoration(
                              color: kcWhite,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(width: 180, height: 20, color: kcWhite),
                          const SizedBox(height: 10),
                          Container(
                              width: double.infinity,
                              height: 13,
                              color: kcWhite),
                          const SizedBox(height: 6),
                          Container(width: 220, height: 13, color: kcWhite),
                          const SizedBox(height: 16),
                          Container(width: 90, height: 18, color: kcWhite),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stackTrace) {
                    _logger.e('Error loading meal details: $error\n$stackTrace');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: const BoxDecoration(
                                color: kcPrimaryNeutral950,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                color: kcPrimaryNeutral500,
                                size: 28,
                              ),
                            ),
                            const Gap(14),
                            const Text(
                              'Failed to load meal details',
                              style: TextStyle(
                                fontSize: 15,
                                color: kcPrimaryNeutral300,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(4),
                            const Text(
                              'Check your connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: kcPrimaryNeutral500,
                              ),
                            ),
                            const Gap(18),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(shopControllerProvider.notifier)
                                    .fetchMealDetails(_mealVariantId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kcPrimary300,
                                foregroundColor: kcWhite,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Quantity + add to cart, pinned below the scrolling content.
              if (mealDetailsAsync.hasValue)
                _ActionBar(
                  quantity: cartState.quantity,
                  totalPrice: totalPrice,
                  isLoading: _isEditing
                      ? isSaving.value
                      : ref.watch(shopControllerProvider).addToCart.isLoading,
                  // An edit is saved through the quantity endpoint, which stops
                  // at ten — so the stepper stops there too rather than finding
                  // out on save. Adding is left as it was.
                  canIncrement:
                      !_isEditing || cartState.quantity < _maxMealQuantity,
                  onDecrement: () =>
                      cartNotifier.updateQuantity(cartState.quantity - 1),
                  onIncrement: () =>
                      cartNotifier.updateQuantity(cartState.quantity + 1),
                  label:
                      _isEditing ? 'Save changes' : 'Add to Pack $targetPack',
                  onAddToCart: () {
                    final groups = mealDetailsAsync
                        .valueOrNull?.mealVariant?.meal?.optionGroup;
                    if (_isEditing) {
                      _saveEdit(
                        context,
                        ref,
                        isSaving,
                        options: groups,
                        selectedItemsWithQuantity:
                            cartState.selectedItemsWithQuantity,
                        quantity: cartState.quantity,
                      );
                    } else {
                      _addToCart(
                        context,
                        ref,
                        options: groups,
                        selectedItemsWithQuantity:
                            cartState.selectedItemsWithQuantity,
                        quantity: cartState.quantity,
                        packNumber: targetPack,
                        shopId: resolvedShopId,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Whether pack [packNumber] of [shopCart] can still take this meal.
  ///
  /// A pack holding a customised meal only ever accepts more of that same meal
  /// — the rule is the backend's, and `POST /carts` refuses anything else (see
  /// [packHoldsCustomisedMeal], which is why checkout hides "Add to this pack"
  /// on those packs). Without this the sticky pack target keeps aiming at a
  /// pack the server will reject: customise a meal, then add a plain one from
  /// the same shop, and the add fails every time until the customer opens a
  /// new pack by hand. A pack that can't take the meal isn't an error here —
  /// the meal simply opens the next one, and the action bar's label says so.
  bool _packAccepts(Cart? shopCart, int packNumber) {
    final items = groupItemsByPack(shopCart)[packNumber] ?? const <cart.Item>[];
    if (!packHoldsCustomisedMeal(items)) return true;
    return items.every((item) => item.mealVariant?.id == _mealVariantId);
  }

  /// Every required group has as much chosen as it asks for.
  ///
  /// A group nobody can order from — everything in it sold out — is not held
  /// against the customer, and only in-stock choices count towards the ones
  /// that are.
  bool _hasAllRequiredOptions(
    List<meal_details.OptionGroup>? options,
    Map<String, Map<String, int>> selectedItemsWithQuantity,
  ) {
    for (final optionGroup in options ?? const <meal_details.OptionGroup>[]) {
      final groupItems = optionGroup.items ?? [];
      final hasInStockItem = groupItems.any((i) => i.variant?.inStock == true);
      if (!hasInStockItem) continue;

      final hasLeast = optionGroup.least != null && optionGroup.least! > 0;
      final isRequired = (optionGroup.isRequired == true) || hasLeast;
      if (!isRequired) continue;

      final minRequired = hasLeast ? optionGroup.least! : 1;
      final selectedItemsForGroup =
          selectedItemsWithQuantity[optionGroup.id ?? ''] ?? {};

      final inStockSelectedCount = selectedItemsForGroup.keys.where((id) {
        final match = groupItems.where((item) => item.variant?.id == id);
        return match.isNotEmpty && match.first.variant?.inStock == true;
      }).length;

      if (inStockSelectedCount < minRequired) {
        Fluttertoast.showToast(
          msg: '🚨 Please select all required options',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.yellow[600],
          textColor: Colors.black,
          fontSize: 14.0,
        );
        return false;
      }
    }
    return true;
  }

  /// The chosen options in the shape both `POST /carts` and the edit take:
  /// `{optionItemVariant, quantity}`. Sold-out choices are dropped rather than
  /// sent to be rejected.
  List<Map<String, dynamic>> _optionsPayload(
    List<meal_details.OptionGroup>? options,
    Map<String, Map<String, int>> selectedItemsWithQuantity,
  ) {
    final optionsData = <Map<String, dynamic>>[];
    for (final optionGroup in options ?? const <meal_details.OptionGroup>[]) {
      final selectedItemsForGroup =
          selectedItemsWithQuantity[optionGroup.id ?? ''] ?? {};
      final items = optionGroup.items ?? [];

      for (final entry in selectedItemsForGroup.entries) {
        final match = items.where((item) => item.variant?.id == entry.key);
        if (match.isNotEmpty && match.first.variant?.inStock == true) {
          optionsData.add({
            "optionItemVariant": entry.key,
            "quantity": entry.value,
          });
        }
      }
    }
    return optionsData;
  }

  /// Validates required option groups, then posts the line item. Only in-stock
  /// selections are counted or sent.
  Future<void> _addToCart(
    BuildContext context,
    WidgetRef ref, {
    required List<meal_details.OptionGroup>? options,
    required Map<String, Map<String, int>> selectedItemsWithQuantity,
    required int quantity,
    required int packNumber,
    required String? shopId,
  }) async {
    try {
      if (!_hasAllRequiredOptions(options, selectedItemsWithQuantity)) return;

      final result = await ref.read(shopControllerProvider.notifier).addToCart(
            _mealVariantId,
            quantity,
            _optionsPayload(options, selectedItemsWithQuantity),
            packNumber: packNumber,
          );

      if (result == true) {
        // Keep building into the same pack until the customer moves on, so a
        // meal and its sides land together instead of in packs of one.
        if (shopId != null) {
          ref.read(activePackProvider.notifier).select(shopId, packNumber);
        }
        await ref.read(shopControllerProvider.notifier).fetchCart();

        // Whether the server honoured the pack we asked for is the one thing
        // this feature rests on and the one thing we cannot tell from the
        // client alone. Log what came back so a mismatch is obvious.
        final saved = cartForShop(
          ref.read(shopControllerProvider).fetchCart.valueOrNull,
          shopId,
        );
        _logger.d(
          'add-to-cart: asked for pack $packNumber on shop $shopId; '
          'cart ${saved?.id} now holds packs '
          '${groupItemsByPack(saved).map((k, v) => MapEntry(k, v.length))}',
        );
        // `true` tells the opener the item actually landed in the cart, so it
        // can follow up (e.g. the discount rail sends the user to Orders).
        if (context.mounted) Navigator.pop(context, true);
      } else {
        // A refused add used to leave the sheet exactly as it was — no toast,
        // no close — which reads as a dead button rather than a failure. Say
        // what the server said, and leave the sheet open so the selections the
        // customer made are still there to retry with.
        final error = ref.read(shopControllerProvider).addToCart.error;
        _logger.e('add-to-cart refused for pack $packNumber: $error');
        Fluttertoast.showToast(
          msg: error is FailureHandler && error.message.isNotEmpty
              ? error.message
              : "Couldn't add that to your cart. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error adding to cart: $e\n$stackTrace');
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  /// Saves the sheet's selections back onto the cart line it was opened on.
  ///
  /// [isSaving] is what shuts the sheet's exits while the controller works
  /// through the calls the edit needs — an edit that changes which options the
  /// meal carries is a rebuild, and half of one is not a state to leave the
  /// cart in.
  Future<void> _saveEdit(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isSaving, {
    required List<meal_details.OptionGroup>? options,
    required Map<String, Map<String, int>> selectedItemsWithQuantity,
    required int quantity,
  }) async {
    final item = editingItem;
    final cartId = editingCartId;
    if (item == null || cartId == null || isSaving.value) return;
    if (!_hasAllRequiredOptions(options, selectedItemsWithQuantity)) return;

    isSaving.value = true;
    try {
      final outcome =
          await ref.read(shopControllerProvider.notifier).editCartItem(
                cartId: cartId,
                item: item,
                mealQuantity: quantity,
                options: _optionsPayload(options, selectedItemsWithQuantity),
              );
      if (!context.mounted) return;

      if (outcome == CartItemEditOutcome.failed) {
        Fluttertoast.showToast(
          msg: "Couldn't save those changes. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      if (outcome == CartItemEditOutcome.duplicated) {
        // The edit is in the pack; so is what it was meant to replace. Saying
        // so is the only honest move — the customer is the one who can decide
        // which of the two to drop.
        Fluttertoast.showToast(
          msg: 'Saved — but the meal you edited is still in the pack. '
              'Remove the one you no longer want.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange[700],
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }

      // `true` tells checkout the cart moved, so it can settle on the refetched
      // one rather than the snapshot it opened the sheet with.
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      _logger.e('Error saving cart item edit: $e\n$stackTrace');
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } finally {
      // A save that ends in a pop takes the sheet — and this notifier — with
      // it, so only touch it while the sheet is still there.
      if (context.mounted) isSaving.value = false;
    }
  }

  // Helper method to build customization sections
  Widget buildCustomizationSection(
    String title,
    List<String> options,
    List<meal_details.Item> items, {
    required bool isRequired,
    required int? maxSelection,
    required String groupId,
    required Map<String, int> selectedItemIdsWithQuantity,
    required Function(Map<String, int>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kcBlack,
                ),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brand980,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusLinear.tick_circle,
                      color: kcPrimary300,
                      size: 11,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 11,
                        color: kcPrimary300,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          maxSelection == null
              ? 'Select as many as you\'d like'
              : maxSelection == 1
                  ? 'Select 1 from here'
                  : 'Select up to $maxSelection from here',
          style: const TextStyle(
            fontSize: 12.5,
            color: kcPrimaryNeutral500,
          ),
        ),
        const SizedBox(height: 10),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final item = items[index];
          final itemVariantId = item.variant?.id ?? '';
          final isSelected =
              selectedItemIdsWithQuantity.containsKey(itemVariantId);
          final quantity = selectedItemIdsWithQuantity[itemVariantId] ?? 0;
          final isInStock = item.variant?.inStock ?? false;

          return buildOptionTileWithQuantity(
            option,
            isInStock,
            maxSelection,
            isSelected: isSelected,
            quantity: quantity,
            onTap: () {
              Map<String, int> newSelection =
                  Map.from(selectedItemIdsWithQuantity);

              if (maxSelection == 1) {
                if (isSelected) {
                  newSelection.clear();
                } else {
                  newSelection.clear();
                  newSelection[itemVariantId] = 1;
                }
              } else {
                if (isSelected) {
                  newSelection.remove(itemVariantId);
                } else {
                  if (maxSelection == null ||
                      newSelection.length < maxSelection) {
                    newSelection[itemVariantId] = 1;
                  } else {
                    Fluttertoast.showToast(
                      msg: 'You can only select up to $maxSelection',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.yellow[600],
                      textColor: Colors.black,
                      fontSize: 14.0,
                    );
                    return;
                  }
                }
              }

              _logger.d('New selection: $newSelection');
              onSelectionChanged(newSelection);
            },
            onQuantityChanged: (newQuantity) {
              Map<String, int> newSelection =
                  Map.from(selectedItemIdsWithQuantity);
              if (newQuantity > 0) {
                newSelection[itemVariantId] = newQuantity;
              } else {
                newSelection.remove(itemVariantId);
              }
              onSelectionChanged(newSelection);
            },
          );
        }),
      ],
    );
  }

  // Updated option tile with quantity controls
  Widget buildOptionTileWithQuantity(
    String option,
    bool inStock,
    int? maxSelection, {
    required bool isSelected,
    required int quantity,
    required VoidCallback onTap,
    required Function(int) onQuantityChanged,
  }) {
    return GestureDetector(
      onTap: inStock ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected && inStock ? kcPrimary300 : kcPrimaryNeutral900,
            width: isSelected && inStock ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected && inStock ? AppColors.brand980 : kcWhite,
        ),
        child: Row(
          children: [
            Icon(
              maxSelection == 1
                  ? (isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked)
                  : (isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
              size: 20,
              color: inStock
                  ? (isSelected ? kcPrimary300 : kcPrimaryNeutral700)
                  : kcPrimaryNeutral800,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  color: inStock ? kcBlack : kcPrimaryNeutral600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (!inStock)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.red800.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Sold out',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.red800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            // Quantity controls (only show when selected and in stock)
            if (isSelected && quantity > 0 && inStock) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                decoration: BoxDecoration(
                  color: kcWhite,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kcPrimary300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onQuantityChanged(
                          quantity > 1 ? quantity - 1 : 0),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.remove,
                          size: 15,
                          color: kcPrimary300,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 22,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kcPrimary300,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onQuantityChanged(quantity + 1),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add,
                          size: 15,
                          color: kcPrimary300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MealImageFallback extends StatelessWidget {
  const _MealImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      color: kcPrimaryNeutral950,
      child: const Icon(
        Icons.fastfood,
        color: kcPrimaryNeutral700,
        size: 42,
      ),
    );
  }
}

/// Quantity stepper + add-to-cart button, pinned to the bottom of the sheet so
/// it stays reachable while the options scroll.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.quantity,
    required this.totalPrice,
    required this.isLoading,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToCart,
    required this.label,
    this.canIncrement = true,
  });

  final int quantity;
  final num totalPrice;
  final bool isLoading;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAddToCart;

  /// What the button says — which pack the meal is joining, or that an edit is
  /// being saved back to the one it is already in.
  final String label;

  final bool canIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: kcWhite,
        border: const Border(
          top: BorderSide(color: kcPrimaryNeutral900),
        ),
        boxShadow: [
          BoxShadow(
            color: kcBlack.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: kcPrimaryNeutral950,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  onTap: onDecrement,
                  enabled: quantity > 1,
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kcBlack,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: onIncrement,
                  enabled: canIncrement,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimary300,
                  disabledBackgroundColor: kcPrimary300,
                  foregroundColor: kcWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kcWhite,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kcWhite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: kcWhite.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₦$totalPrice',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kcWhite,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        height: 34,
        width: 34,
        decoration: const BoxDecoration(
          color: kcWhite,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? kcPrimary300 : kcPrimaryNeutral800,
        ),
      ),
    );
  }
}
