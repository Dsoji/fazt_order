import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/controller/shop_controller.dart';
import '../../data/model/response/meal_details/item.dart' as meal_details;
import '../../data/model/response/meal_variant_menu/result.dart';
import '../providers/add_to_cart_provider.dart';

final _logger = Logger();

class AddToCartBottomSheet extends HookConsumerWidget {
  final MealVariantMenuResult menuItem;

  const AddToCartBottomSheet({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() {
        ref
            .read(shopControllerProvider.notifier)
            .fetchMealDetails(menuItem.id ?? '');
      });
      return null;
    }, [menuItem.id]);

    final mealDetailsAsync = ref.watch(shopControllerProvider).mealDetails;
    final cartState = ref.watch(addToCartProvider);
    final cartNotifier = ref.read(addToCartProvider.notifier);

    final totalPrice = useMemoized(() {
      return cartNotifier.calculateTotalPrice(mealDetailsAsync.valueOrNull);
    }, [
      cartState.selectedItemsWithQuantity,
      cartState.quantity,
      mealDetailsAsync,
    ]);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 20,
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

                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: mealDetails.mealVariant?.meal?.mealImage !=
                                      null &&
                                  mealDetails
                                      .mealVariant!.meal!.mealImage!.isNotEmpty
                              ? Image.network(
                                  mealDetails.mealVariant!.meal!.mealImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.fastfood,
                                        color: Colors.grey[600],
                                        size: 50,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.fastfood,
                                    color: Colors.grey[600],
                                    size: 50,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Food name
                        Text(
                          mealDetails.mealVariant?.meal?.mealName ??
                              'Food Item',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          mealDetails.mealVariant?.meal?.mealDescription ??
                              'Delicious food description',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price
                        Text(
                          'From ₦${mealDetails.mealVariant?.meal?.price ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral200,
                          ),
                        ),
                        const Gap(16),
                        const Divider(
                          color: AppColors.neutral200,
                          thickness: 0.5,
                        ),
                        const Gap(16),

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
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.neutral200,
                              thickness: 0.5,
                              height: 32,
                            ),
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
                          })
                        else
                          const Column(
                            children: [],
                          ),

                        // Add to Cart Section
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 16),
                          child: Row(
                            children: [
                              // Quantity Selector
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: AppColors.brand400, width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cartNotifier.updateQuantity(
                                            cartState.quantity - 1);
                                      },
                                      child: const Icon(
                                        Icons.remove,
                                        color: AppColors.brand300,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${cartState.quantity}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brand300,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        cartNotifier.updateQuantity(
                                            cartState.quantity + 1);
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        color: AppColors.brand300,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Add to Cart Button
                              Expanded(
                                child: FullButton(
                                  text: 'Add to Cart ₦$totalPrice',
                                  width: double.infinity,
                                  height: 48,
                                  isLoading: ref
                                      .watch(shopControllerProvider)
                                      .addToCart
                                      .isLoading,
                                  onPressed: () async {
                                    try {
                                      // Check if required options are selected
                                      final options = mealDetails
                                          .mealVariant?.meal?.optionGroup;
                                      bool hasRequiredSelections = true;

                                      if (options != null) {
                                        for (final optionGroup in options) {
                                          final groupItems =
                                              optionGroup.items ?? [];
                                          final hasInStockItem =
                                              groupItems.any((i) =>
                                                  i.variant?.inStock == true);
                                          if (!hasInStockItem) {
                                            continue;
                                          }
                                          final hasLeast =
                                              optionGroup.least != null &&
                                                  optionGroup.least! > 0;
                                          final isRequired =
                                              (optionGroup.isRequired == true) ||
                                                  hasLeast;
                                          if (isRequired) {
                                            final minRequired = hasLeast
                                                ? optionGroup.least!
                                                : 1;
                                            final selectedItemsForGroup =
                                                cartState.selectedItemsWithQuantity[
                                                        optionGroup.id ?? ''] ??
                                                    {};

                                            // Filter to only count in-stock items for required check
                                            final inStockSelectedItems =
                                                <String, int>{};
                                            final items =
                                                optionGroup.items ?? [];

                                            for (final entry
                                                in selectedItemsForGroup
                                                    .entries) {
                                              final itemVariantId = entry.key;

                                              final itemWhere = items.where(
                                                  (item) =>
                                                      item.variant?.id ==
                                                      itemVariantId);
                                              final item = itemWhere.isEmpty
                                                  ? null
                                                  : itemWhere.first;

                                              if (item != null &&
                                                  item.variant?.inStock ==
                                                      true) {
                                                inStockSelectedItems[
                                                        itemVariantId] =
                                                    entry.value;
                                              }
                                            }

                                            if (inStockSelectedItems.length <
                                                minRequired) {
                                              hasRequiredSelections = false;
                                              break;
                                            }
                                          }
                                        }
                                      }

                                      if (!hasRequiredSelections) {
                                        Fluttertoast.showToast(
                                          msg:
                                              '🚨 Please select all required options',
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.yellow[600],
                                          textColor: Colors.black,
                                          fontSize: 14.0,
                                        );

                                        return;
                                      }

                                      // Prepare the options data for the API
                                      List<Map<String, dynamic>> optionsData =
                                          [];

                                      for (final optionGroup in options ?? []) {
                                        final selectedItemsForGroup =
                                            cartState.selectedItemsWithQuantity[
                                                    optionGroup.id ?? ''] ??
                                                {};
                                        final items = optionGroup.items ?? [];

                                        for (final entry
                                            in selectedItemsForGroup.entries) {
                                          final itemVariantId = entry.key;

                                          final itemWhere = items.where(
                                              (item) =>
                                                  item.variant?.id ==
                                                  itemVariantId);
                                          final item = itemWhere.isEmpty
                                              ? null
                                              : itemWhere.first;

                                          if (item != null &&
                                              item.variant?.inStock == true) {
                                            optionsData.add({
                                              "optionItemVariant": entry.key,
                                              "quantity": entry.value,
                                            });
                                          }
                                        }
                                      }

                                      final result = await ref
                                          .read(shopControllerProvider.notifier)
                                          .addToCart(
                                            menuItem.id ?? '',
                                            cartState.quantity,
                                            optionsData,
                                          );

                                      if (result == true) {
                                        await ref
                                            .read(
                                                shopControllerProvider.notifier)
                                            .fetchCart();
                                        Navigator.pop(context);
                                      }
                                    } catch (e, stackTrace) {
                                      _logger.e(
                                          'Error adding to cart: $e\n$stackTrace');
                                      Fluttertoast.showToast(
                                        msg:
                                            'An error occurred. Please try again.',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.0,
                                      );
                                    }
                                  },
                                  color: AppColors.brand400,
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 150,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
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
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load meal details',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(shopControllerProvider.notifier)
                                  .fetchMealDetails(menuItem.id ?? '');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand400,
                              foregroundColor: Colors.white,
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
          ],
        ),
      ),
    );
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            if (isRequired) ...[
              const Spacer(),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconsaxPlusLinear.tick_circle,
                    color: AppColors.brand300,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.brand300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          maxSelection == null
              ? 'Select as many as you\'d like'
              : maxSelection == 1
                  ? 'Select 1 from here'
                  : 'Select up to $maxSelection from here',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final item = items[index];
          final itemId = item.id ?? '';
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
      child: Opacity(
        opacity: inStock ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: inStock
                  ? isSelected
                      ? AppColors.brand300
                      : Colors.grey[300]!
                  : Colors.grey[400]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors.brand300.withOpacity(0.1)
                : Colors.transparent,
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
                color: inStock
                    ? (isSelected ? AppColors.brand300 : Colors.grey[600])
                    : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: inStock
                              ? (isSelected ? AppColors.brand300 : Colors.black)
                              : Colors.grey[500],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (!inStock)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Quantity controls (only show when selected and in stock)
              if (isSelected && quantity > 0 && inStock) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brand300.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brand300, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) {
                            onQuantityChanged(quantity - 1);
                          } else {
                            onQuantityChanged(0);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.remove,
                            size: 16,
                            color: AppColors.brand300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brand300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          onQuantityChanged(quantity + 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.brand300,
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
      ),
    );
  }
}
