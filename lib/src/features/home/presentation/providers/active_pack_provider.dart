import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/model/response/cartlsit/cart.dart';
import '../../data/model/response/cartlsit/cartlsit.dart';
import '../../data/model/response/cartlsit/item.dart';

/// Groups a cart's items the way the API keys them — by `packNumber`.
///
/// Items that predate pack numbers fall back to their list position, matching
/// what checkout does, so an older cart still renders as one pack per item
/// instead of collapsing into a single pack.
Map<int, List<Item>> groupItemsByPack(Cart? cart) {
  final items = cart?.items ?? const <Item>[];
  final packs = <int, List<Item>>{};
  for (var i = 0; i < items.length; i++) {
    final packNumber = items[i].packNumber?.toInt() ?? (i + 1);
    packs.putIfAbsent(packNumber, () => []).add(items[i]);
  }
  return packs;
}

/// Whether a pack holds a meal that was customised with option items.
///
/// Such a pack can only ever take more of that same meal — the rule is the
/// backend's, and `GET /carts/:cartId/pack/:packNumber/add-options` answers
/// with just that one meal. Offering "Add to this pack" there sends the
/// customer to a picker with a single row they already have, so the pill is
/// left off those packs entirely and "Add Another Pack" is the way on.
bool packHoldsCustomisedMeal(List<Item> items) =>
    items.any((item) => (item.options ?? const []).isNotEmpty);

/// Pack numbers present in the cart, ascending.
List<int> packNumbersOf(Cart? cart) =>
    groupItemsByPack(cart).keys.toList()..sort();

/// The number a brand new pack would take. Packs are numbered from 1, and the
/// highest is used rather than the count so removing pack 2 of 3 doesn't make
/// the next pack collide with the existing pack 3.
int nextPackNumber(Cart? cart) {
  final numbers = packNumbersOf(cart);
  return numbers.isEmpty ? 1 : numbers.last + 1;
}

/// The cart belonging to [shopId], if the customer has one open.
Cart? cartForShop(CartLsit? cartList, String? shopId) {
  if (shopId == null) return null;
  final match = (cartList?.carts ?? const <Cart>[])
      .where((cart) => cart.shop?.id == shopId);
  return match.isEmpty ? null : match.first;
}

/// Which pack the next add-to-cart lands in, per shop.
///
/// `POST /carts` takes an optional `packNumber` on every item, so which pack a
/// meal joins is entirely the app's call — no part of this is negotiated with
/// the server. Keeping the choice here is what lets a customer build several
/// packs in one visit to the menu instead of the server opening a fresh pack
/// for every item.
///
/// The target is **sticky**: once a pack is active, every add goes into it, and
/// it changes only when the customer says so — "Add Another Pack" or "Add to
/// this pack". The cart bar always names the active pack, so this is never
/// silent. State is keyed by shop id so backing out to a different restaurant
/// can't carry a stale pack number across.
class ActivePackNotifier extends StateNotifier<Map<String, int>> {
  ActivePackNotifier() : super(const {});

  int? packFor(String? shopId) => shopId == null ? null : state[shopId];

  void select(String shopId, int packNumber) {
    state = {...state, shopId: packNumber};
  }

  void clear(String shopId) {
    state = {...state}..remove(shopId);
  }
}

final activePackProvider =
    StateNotifierProvider<ActivePackNotifier, Map<String, int>>(
  (ref) => ActivePackNotifier(),
);
