import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fazt_order/src/features/home/data/model/response/meal_details/meal_details.dart';

class AddToCartState {
  final int quantity;
  final Map<String, Map<String, int>> selectedItemsWithQuantity;

  AddToCartState({
    required this.quantity,
    required this.selectedItemsWithQuantity,
  });

  AddToCartState copyWith({
    int? quantity,
    Map<String, Map<String, int>>? selectedItemsWithQuantity,
  }) {
    return AddToCartState(
      quantity: quantity ?? this.quantity,
      selectedItemsWithQuantity: selectedItemsWithQuantity ?? this.selectedItemsWithQuantity,
    );
  }
}

class AddToCartNotifier extends StateNotifier<AddToCartState> {
  AddToCartNotifier() : super(AddToCartState(quantity: 1, selectedItemsWithQuantity: {}));

  void updateQuantity(int quantity) {
    if (quantity < 1) return;
    state = state.copyWith(quantity: quantity);
  }

  void updateSelection(String groupId, Map<String, int> selection) {
    final newSelection = Map<String, Map<String, int>>.from(state.selectedItemsWithQuantity);
    newSelection[groupId] = selection;
    state = state.copyWith(selectedItemsWithQuantity: newSelection);
  }

  int calculateTotalPrice(dynamic mealDetails) {
    if (mealDetails == null) return 0;

    int basePrice = mealDetails.mealVariant?.meal?.price ?? 0;
    num optionsPrice = 0;
    final options = mealDetails.mealVariant?.meal?.optionGroup;

    if (options != null) {
      for (final optionGroup in options) {
        final selectedItemsForGroup = state.selectedItemsWithQuantity[optionGroup.id ?? ''] ?? {};
        final items = optionGroup.items ?? [];

        for (final entry in selectedItemsForGroup.entries) {
          final itemId = entry.key;
          final qty = entry.value;

          final itemWhere = items.where((item) => item.variant?.id == itemId);
          final item = itemWhere.isEmpty ? null : itemWhere.first;
          if (item != null) {
            optionsPrice += ((item.price ?? 0) * qty).toInt();
          }
        }
      }
    }

    return (basePrice + optionsPrice).toInt() * state.quantity;
  }
}

final addToCartProvider = StateNotifierProvider.autoDispose<AddToCartNotifier, AddToCartState>((ref) {
  return AddToCartNotifier();
});
