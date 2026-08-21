import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/order_provider.dart';
import '../../common/app_colors.dart';
import '../../common/widgets/text_styles.dart';
import '../bottom_sheets/edit_address_sheet.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/cartlsit/cart.dart';
import '../home/data/model/response/cartlsit/item.dart';
import '../home/data/model/response/cartlsit/item_options.dart';
import '../home/data/model/response/shops_model/location.dart' as shops_model;
import '../home/data/model/response/shops_model/result.dart';
import '../home/data/model/response/shops_model/store.dart' as shops_model;
import '../home/presentation/providers/active_pack_provider.dart';
import '../home/presentation/restaurant_details.dart';
import '../home/presentation/widgets/add_to_cart_bottom_sheet.dart';
import '../home/presentation/widgets/add_to_pack_sheet.dart';
import '../payment/payment_screen.dart';
import '../profile/data/controller/profile_controller.dart';
import 'unavailable_items_banner.dart';

/// Where the terms line points. Both are blank until the real pages are
/// published: a blank one renders as plain text rather than as an underlined
/// word that opens nothing.
const String _termsUrl = '';
const String _privacyUrl = '';

const _pageBackground = Color(0xffF6F4F0);
const _cardRadius = 24.0;
const _cardShadow = [
  BoxShadow(color: Color(0x0F1E1A1D), blurRadius: 20, offset: Offset(0, 8)),
];

/// Rebuilds a [ShopResult] from the cart's shop so tapping "Add Another Pack"
/// can drop the customer straight back into the restaurant they're already
/// ordering from. The menu is refetched by shop id, so a lightweight shop is
/// enough to open the details screen.
ShopResult _shopResultFromCart(Cart cart) {
  final shop = cart.shop;
  final store = shop?.store;
  final location = shop?.location;
  return ShopResult(
    id: shop?.id,
    shopName: shop?.shopName,
    isOpen: shop?.isOpen,
    store: store == null
        ? null
        : shops_model.Store(
            id: store.id,
            storeName: store.storeName,
            storeDisplayImage: store.storeDisplayImage,
          ),
    location: location == null
        ? null
        : shops_model.Location(
            type: location.type,
            coordinates: location.coordinates?.toList(),
            address: location.address,
            state: location.state,
            city: location.city,
          ),
  );
}

/// Formats an amount the way prices are read locally — `₦12,500`.
String _naira(num? value) {
  final amount = (value ?? 0).round();
  final digits = amount.abs().toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}₦$grouped';
}

/// Picks this screen's cart out of a refetched cart list. Returns null when the
/// cart is no longer there — that means the last pack was removed and the
/// server dropped the whole cart.
Cart? _findCart(List<Cart> carts, String? cartId) {
  for (final cart in carts) {
    if (cart.id == cartId) return cart;
  }
  return null;
}

class CheckoutScreen extends HookConsumerWidget {
  final Cart selectedItems;

  const CheckoutScreen({required this.selectedItems, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionVisible = useState(true);
    final userDetails =
        ref.watch(profileControllerProvider).userDetails.valueOrNull;
    final messageController = useTextEditingController();
    final noteController = useTextEditingController();
    final promoCodeController = useTextEditingController();
    final promoCodeMessage = useState<String?>(null);
    final promoCodeIsError = useState(false);

    // [selectedItems] is only the snapshot the previous screen was holding, so
    // removing a pack would leave it on screen no matter how the request went.
    // Watch the controller's cart instead and prefer it once a fetch lands.
    // The refetch briefly clears the value while loading, so the last resolved
    // cart is kept in a ref rather than falling back to the stale snapshot and
    // flashing the deleted pack back in.
    final carts = ref
        .watch(shopControllerProvider.select((s) => s.fetchCart))
        .valueOrNull
        ?.carts;
    final liveCart = useRef<Cart?>(null);
    if (carts != null && selectedItems.id != null) {
      liveCart.value = _findCart(carts, selectedItems.id) ??
          Cart(id: selectedItems.id, shop: selectedItems.shop, items: const []);
    }
    final cart = liveCart.value ?? selectedItems;

    final items = cart.items ?? const <Item>[];

    // The vendor can switch "Accepting orders" off after items were added, so
    // the cart is re-checked here rather than trusting the earlier menu screen.
    final isAcceptingOrders = cart.shop?.isOpen != false;

    /// The API keys every item to a pack, so group by that rather than by list
    /// position — two meals in the same pack belong on the same card, and the
    /// delete call needs the real pack number.
    final packs = <int, List<Item>>{};
    for (var i = 0; i < items.length; i++) {
      final packNumber = items[i].packNumber?.toInt() ?? (i + 1);
      packs.putIfAbsent(packNumber, () => []).add(items[i]);
    }
    final packNumbers = packs.keys.toList()..sort();

    debugPrint('[checkout] shop=${cart.shop?.shopName} open=$isAcceptingOrders '
        'items=${items.length} packs=${packNumbers.length} '
        'total=${cart.totalPrice}');
    for (final n in packNumbers) {
      for (final i in packs[n]!) {
        debugPrint('[checkout] pack $n | ${i.mealVariant?.meal?.mealName} '
            'price=${i.mealVariant?.meal?.price} qty=${i.mealQuantity} '
            'available=${i.available} packaging=${i.packagingFee} '
            'options=${(i.options ?? []).map((o) => '${o.optionItemVariant?.optionItem?.item} x${o.quantity} @${o.optionItemVariant?.optionItem?.price}').toList()}');
      }
    }

    /// Aim the next add-to-cart at [packNumber] and drop the customer back on
    /// the menu. Checkout is replaced rather than pushed so we don't leave a
    /// stale cart snapshot behind on the stack.
    void buildIntoPack(int packNumber) {
      final shopId = cart.shop?.id;
      if (shopId == null) {
        Navigator.pop(context);
        return;
      }
      ref.read(activePackProvider.notifier).select(shopId, packNumber);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsView(
            restaurant: _shopResultFromCart(cart),
          ),
        ),
      );
    }

    /// Offer only what may actually join [packNumber], asking the backend
    /// rather than reopening the whole menu. Falls back to the menu when the
    /// cart has no id to address.
    void addToExistingPack(int packNumber) {
      final shopId = cart.shop?.id;
      final cartId = cart.id;
      if (shopId == null || cartId == null || cartId.isEmpty) {
        buildIntoPack(packNumber);
        return;
      }
      showAddToPackSheet(
        context,
        shopId: shopId,
        cartId: cartId,
        packNumber: packNumber,
      );
    }

    /// Reopen the meal's own customization sheet on a line already in the cart,
    /// seeded with what was chosen for it. The steppers on the row cover *how
    /// many*; this is the only way back to *what is in it* — swapping a side,
    /// adding an extra that was skipped — without deleting the line and
    /// building it again from the menu.
    ///
    /// The sheet saves through the controller and refetches the cart itself, and
    /// this screen renders whatever the controller holds, so there is nothing
    /// left to do when it closes.
    Future<void> editItem(Item item) async {
      final cartId = cart.id;
      if (cartId == null || cartId.isEmpty) return;
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: kcTransparent,
        // Dragging the sheet away pops the route outright, under the sheet's
        // own guard rather than through it — the one dismissal it cannot hold
        // while it is writing to the cart. The ✕ and the barrier both answer to
        // that guard, so the way out stays open until the moment it shouldn't
        // be, and this one is left off.
        enableDrag: false,
        builder: (_) => AddToCartBottomSheet.edit(
          item: item,
          cartId: cartId,
          shopId: cart.shop?.id,
        ),
      );
    }

    /// Removing a pack takes every item in it with it.
    Future<void> removePack(int packNumber) async {
      final controller = ref.read(shopControllerProvider.notifier);
      final removed =
          await controller.removePackFromCart(cart.id ?? '', packNumber);
      if (removed) {
        // Await the refetch so the list this screen renders is the updated one.
        await controller.fetchCart();
        // Removing a pack resequences the remaining pack numbers, so a
        // remembered target can now mean a different pack.
        final shopId = cart.shop?.id;
        if (shopId != null) {
          ref.read(activePackProvider.notifier).clear(shopId);
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't remove that pack. Please try again."),
          ),
        );
      }
    }

    /// Drops one meal and leaves the rest of its pack standing.
    Future<void> removeItem(Item item) async {
      final controller = ref.read(shopControllerProvider.notifier);
      final removed =
          await controller.removeItemFromCart(cart.id ?? '', item.id ?? '');
      if (removed != null) {
        await controller.fetchCart();
        // Only an emptied pack resequences the rest, which is what would leave
        // a remembered target pointing at some other pack. Taking one meal out
        // of a pack that still has meals in it leaves the numbering alone, so
        // the customer keeps building where they were.
        final shopId = cart.shop?.id;
        if (removed.packEmptied && shopId != null) {
          ref.read(activePackProvider.notifier).clear(shopId);
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't remove that item. Please try again."),
          ),
        );
      }
    }

    /// Sets how many of a meal a line holds. Every change re-prices the whole
    /// cart, so the screen reloads from the server rather than holding a
    /// second copy of the numbers.
    Future<void> changeItemQuantity(Item item, int quantity) async {
      final controller = ref.read(shopControllerProvider.notifier);
      final updated = await controller.updateMealQuantity(
        cart.id ?? '',
        item.id ?? '',
        item.mealVariant?.id ?? '',
        quantity,
      );
      await controller.fetchCart();
      // A rejection means this screen and the server disagree about the cart —
      // most likely the item moved or went away elsewhere. The reload above is
      // the fix; this only says what happened.
      if (updated == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't update that quantity. Please try again."),
          ),
        );
      }
    }

    // The review runs in two steps on one screen: what is being ordered, then
    // where it goes and how it is paid for. Both live here rather than on
    // separate routes, so stepping back to fix a pack never unwinds
    // navigation, and the notes typed on the second step survive the trip —
    // the controllers outlive the step.
    final step = useState(0);

    void goToStep(int next) {
      FocusScope.of(context).unfocus();
      step.value = next;
    }

    // Nothing is payable without items, and the vendor can close while the
    // cart sits here. Both gate the button on either step.
    // Out-of-stock lines stay in the cart, but the order would be refused, so
    // checkout waits until they are removed or restocked.
    final hasUnavailableItems =
        cart.hasUnavailableItems == true || items.any((i) => !i.available);
    final canProceed =
        items.isNotEmpty && isAcceptingOrders && !hasUnavailableItems;

    // The order step is the mock's white page with a grey heading band; the
    // delivery step keeps the warm card ground the receipt summary is drawn
    // against. Both are on this screen, so the colour follows the step.
    final background = step.value == 0 ? kcWhite : _pageBackground;

    Widget orderStep() => SingleChildScrollView(
          key: const PageStorageKey('review-order'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isAcceptingOrders) ...[
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ShopClosedNotice(shopName: cart.shop?.shopName),
                ),
                const Gap(12),
              ],
              if (cart.unavailableItems?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: UnavailableItemsBanner(cart: cart),
                ),
              const _SectionBand('Order Summary'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderHeader(
                      storeImage: cart.shop?.store?.storeDisplayImage,
                      shopName: cart.shop?.shopName,
                      itemCount: items.length,
                      packCount: packNumbers.length,
                      isExpanded: isSelectionVisible.value,
                      onToggle: () =>
                          isSelectionVisible.value = !isSelectionVisible.value,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: !isSelectionVisible.value
                          ? const SizedBox(width: double.infinity)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(18),
                                if (items.isEmpty) const _EmptyCartNotice(),
                                for (final packNumber in packNumbers) ...[
                                  _PackTile(
                                    // Keyed by pack so the "removing" spinner
                                    // stays with its own pack when the list
                                    // shifts up after a delete.
                                    key: ValueKey(packNumber),
                                    packNumber: packNumber,
                                    items: packs[packNumber]!,
                                    // Adding *into* an existing pack goes
                                    // through the picker the backend answers
                                    // with — its contents decide what may
                                    // join. Only "Add Another Pack", below,
                                    // still returns to the full menu.
                                    onAddToThisPack: () =>
                                        addToExistingPack(packNumber),
                                    onEditItem: editItem,
                                    onRemove: () => removePack(packNumber),
                                    onRemoveItem: removeItem,
                                    onChangeItemQuantity: changeItemQuantity,
                                  ),
                                  const Gap(20),
                                ],
                              ],
                            ),
                    ),
                    const Gap(6),
                    _AddPackButton(
                      // A fresh pack, rather than appending to whichever one
                      // was last touched.
                      onTap: () => buildIntoPack(nextPackNumber(cart)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    Widget deliveryStep() => SingleChildScrollView(
          key: const PageStorageKey('review-delivery'),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeliveryCard(
                address: userDetails?.user?.location?.address,
                onEdit: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditAddressBottomSheet(
                      onUpdate: (newAddress) {
                        ref
                            .read(orderProvider.notifier)
                            .updateDeliveryAddress(newAddress);
                      },
                    ),
                  );
                },
              ),
              const Gap(22),
              const _SectionLabel('Notes'),
              const Gap(10),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NoteField(
                      icon: const Icon(Iconsax.message,
                          size: 17, color: kcPrimary300),
                      label: 'Message for the restaurant',
                      hint: 'e.g. no onions, extra napkins…',
                      controller: messageController,
                    ),
                    const Gap(18),
                    _NoteField(
                      icon: SvgPicture.asset('asset/svgs/delivery_icon.svg',
                          width: 17, height: 17),
                      label: 'Note for the rider',
                      hint: 'e.g. call when you get to the gate…',
                      controller: noteController,
                    ),
                  ],
                ),
              ),
              const Gap(22),
              const _SectionLabel('Summary'),
              const Gap(10),
              _PaymentSummary(
                cart: cart,
                itemCount: items.length,
                promoCodeController: promoCodeController,
                promoCodeMessage: promoCodeMessage.value,
                promoCodeIsError: promoCodeIsError.value,
                onApplyPromoCode: () async {
                  final controller = ref.read(shopControllerProvider.notifier);
                  final code = promoCodeController.text.trim();
                  if (code.isEmpty) return;
                  final applied = await controller.applyCartPromoCode(
                    cart.id ?? '',
                    code,
                  );
                  if (!applied) {
                    promoCodeIsError.value = true;
                    promoCodeMessage.value =
                        'This promo code could not be applied right now.';
                    return;
                  }
                  await controller.fetchCart();
                  final updated = ref
                      .read(shopControllerProvider)
                      .fetchCart
                      .valueOrNull
                      ?.carts
                      ?.firstWhere(
                        (entry) => entry.id == cart.id,
                        orElse: () => cart,
                      );
                  final error = updated?.promoCodeError;
                  if (error != null && error.trim().isNotEmpty) {
                    promoCodeIsError.value = true;
                    promoCodeMessage.value = error;
                    return;
                  }
                  if ((updated?.promoCodeRuleId ?? '').isNotEmpty) {
                    promoCodeIsError.value = false;
                    promoCodeMessage.value = 'Promo code applied successfully.';
                    return;
                  }
                  if ((updated?.promoCode ?? '').isNotEmpty) {
                    promoCodeIsError.value = true;
                    promoCodeMessage.value =
                        'This promo code is valid, but a better discount is already active on your order.';
                    return;
                  }
                  promoCodeIsError.value = false;
                  promoCodeMessage.value = 'Promo code removed.';
                },
                onRemovePromoCode: () async {
                  final controller = ref.read(shopControllerProvider.notifier);
                  final removed = await controller.removeCartPromoCode(
                    cart.id ?? '',
                  );
                  if (removed) {
                    await controller.fetchCart();
                    promoCodeIsError.value = false;
                    promoCodeMessage.value = 'Promo code removed.';
                    promoCodeController.clear();
                  }
                },
              ),
            ],
          ),
        );

    return PopScope(
      // On the second step the arrow and the system back gesture mean "back to
      // the order", not "leave the review" — the customer is one level in.
      canPop: step.value == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goToStep(0);
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          surfaceTintColor: kcTransparent,
          elevation: 0,
          titleSpacing: 0,
          title: Text(
            'Review',
            style: ktBodyBoldSize20.copyWith(color: kcPrimaryNeutral100),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _CircleIconButton(
              icon: Iconsax.arrow_left_2,
              onTap: () =>
                  step.value == 0 ? Navigator.pop(context) : goToStep(0),
            ),
          ),
          leadingWidth: 60,
          bottom: PreferredSize(
            // Label, gap and rule come to ~58 at the default text scale; the
            // extra room keeps a larger scale from overflowing the app bar.
            preferredSize: const Size.fromHeight(68),
            child: _StepBar(
              step: step.value,
              // Backwards only. Going forward is the button's job, because
              // that is what checks the order is payable first.
              onSelect: goToStep,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: step.value == 0 ? orderStep() : deliveryStep(),
        ),
        bottomNavigationBar: _CheckoutBar(
          total: cart.totalPrice,
          enabled: canProceed,
          label: !isAcceptingOrders
              ? 'CLOSED'
              : hasUnavailableItems
                  ? 'Remove unavailable items to continue'
                  : step.value == 0
                      ? 'Continue'
                      : 'Make Payment',
          // The terms are shown against the button that actually commits to
          // them, not against the one that only turns the page.
          showTerms: step.value == 1,
          onPay: () {
            if (step.value == 0) {
              goToStep(1);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  selectedItems: cart,
                  vendorMessage: messageController.text,
                  riderMessage: noteController.text,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The two stages of the review, and which one is open.
///
/// Only backwards is tappable: the order has to be payable before the delivery
/// step means anything, and that check belongs to the button at the bottom.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.onSelect});

  final int step;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget segment(int index, String label) {
      final isCurrent = index == step;
      return Expanded(
        child: InkWell(
          onTap: index < step ? () => onSelect(index) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ktBodySemiBoldSize14.copyWith(
                    color:
                        isCurrent ? kcPrimaryNeutral100 : kcPrimaryNeutral500,
                  ),
                ),
                const Gap(10),
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: index <= step ? kcPrimary300 : kcPrimaryNeutral900,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          segment(0, 'Your Order'),
          const Gap(14),
          segment(1, 'Delivery & Payment'),
        ],
      ),
    );
  }
}

/// Full-bleed heading strip. On the order step the page itself is white, so
/// the band is what separates the order from the header above it.
class _SectionBand extends StatelessWidget {
  const _SectionBand(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _pageBackground,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Text(
        text,
        style: ktBodyBoldSize18.copyWith(color: kcPrimaryNeutral100),
      ),
    );
  }
}

/// Uppercase micro-heading that gives the page its vertical rhythm.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: ktLabelBoldSize11.copyWith(
          color: kcPrimaryNeutral500,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

/// Elevated white surface every checkout section sits on.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kcWhite,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: child,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcWhite,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, size: 18, color: kcPrimaryNeutral100),
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.address, required this.onEdit});

  final String? address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final hasAddress = (address ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kcPrimary980, kcWhite],
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: kcPrimary600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33819228),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Iconsax.location, size: 19, color: kcPrimary100),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DELIVER TO',
                  style: ktLabelBoldSize11.copyWith(
                    color: kcPrimary300,
                    letterSpacing: 1.2,
                  ),
                ),
                const Gap(3),
                Text(
                  hasAddress ? address! : 'No address added yet',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ktBodySemiBoldSize14.copyWith(
                    color:
                        hasAddress ? kcPrimaryNeutral100 : kcPrimaryNeutral500,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          _PillButton(
            onTap: onEdit,
            icon: Iconsax.edit_2,
            label: hasAddress ? 'Edit' : 'Add',
          ),
        ],
      ),
    );
  }
}

/// Small solid action pill — used for the address edit affordance.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcWhite,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: kcPrimary300),
              const Gap(5),
              Text(label,
                  style: ktLabelSemiBoldSize12.copyWith(color: kcPrimary300)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.storeImage,
    required this.shopName,
    required this.itemCount,
    required this.packCount,
    required this.isExpanded,
    required this.onToggle,
  });

  final String? storeImage;
  final String? shopName;
  final int itemCount;
  final int packCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final summary = [
      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
      if (packCount > 0) '$packCount ${packCount == 1 ? 'pack' : 'packs'}',
    ].join('  ·  ');

    return Row(
      children: [
        _StoreAvatar(imageUrl: storeImage),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shopName ?? 'Unknown Shop',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    ktBodySemiBoldSize16.copyWith(color: kcPrimaryNeutral100),
              ),
              const Gap(3),
              Text(
                summary,
                style:
                    ktLabelRegularSize12.copyWith(color: kcPrimaryNeutral500),
              ),
            ],
          ),
        ),
        const Gap(8),
        Material(
          color: kcPrimaryNeutral950,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Hide Selection' : 'Show Selection',
                    style: ktLabelSemiBoldSize12.copyWith(
                        color: kcPrimaryNeutral300),
                  ),
                  const Gap(4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Iconsax.arrow_down_1,
                        size: 13, color: kcPrimaryNeutral300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  const _StoreAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    const fallback = SizedBox(
      height: size,
      width: size,
      child: Center(
        child: Icon(Iconsax.shop, size: 20, color: kcPrimaryNeutral500),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kcPrimary800, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: size,
          width: size,
          color: kcPrimaryNeutral950,
          child: (imageUrl ?? '').isEmpty
              ? fallback
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => fallback,
                  errorWidget: (_, __, ___) => fallback,
                ),
        ),
      ),
    );
  }
}

/// One pack of the order: its meals, their selections, and a remove action.
class _PackTile extends HookWidget {
  const _PackTile({
    super.key,
    required this.packNumber,
    required this.items,
    required this.onAddToThisPack,
    required this.onRemove,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.onChangeItemQuantity,
  });

  final int packNumber;
  final List<Item> items;
  final VoidCallback onAddToThisPack;
  final Future<void> Function() onRemove;

  /// Reopens the meal's customization sheet on one item, so what is in it can
  /// be changed and not only how many of it there are.
  final Future<void> Function(Item item) onEditItem;

  /// Drops a single meal and leaves the rest of the pack standing — the
  /// pack-level [onRemove] takes everything in the pack with it.
  final Future<void> Function(Item item) onRemoveItem;

  /// Sets how many of the meal an item holds.
  final Future<void> Function(Item item, int quantity) onChangeItemQuantity;

  @override
  Widget build(BuildContext context) {
    // Deleting a pack takes a round trip plus a cart refetch. The state is kept
    // per tile so the spinner sits on the pack being removed, and the button is
    // dead while it spins — repeat taps would fire the delete more than once.
    final isRemoving = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pack $packNumber',
              style: ktBodyBoldSize18.copyWith(color: kcPrimaryNeutral100),
            ),
            const Spacer(),
            Material(
              color: kcPrimaryRed900,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isRemoving.value
                    ? null
                    : () async {
                        isRemoving.value = true;
                        try {
                          await onRemove();
                        } finally {
                          // A successful remove takes this tile out of the
                          // tree, so only touch the state if it survived.
                          if (context.mounted) isRemoving.value = false;
                        }
                      },
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: isRemoving.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kcPrimaryRed400,
                          ),
                        )
                      : const Icon(Iconsax.trash,
                          color: kcPrimaryRed400, size: 18),
                ),
              ),
            ),
          ],
        ),
        for (var i = 0; i < items.length; i++) ...[
          const Gap(16),
          _PackItemRow(
            // Keyed by item for the same reason the tiles are keyed by pack:
            // the rows shift up after a delete, and the "removing" spinner has
            // to travel with its own row.
            key: ValueKey(items[i].id ?? '$packNumber-$i'),
            item: items[i],
            onEdit: () => onEditItem(items[i]),
            onRemove: () => onRemoveItem(items[i]),
            onChangeQuantity: (quantity) =>
                onChangeItemQuantity(items[i], quantity),
          ),
        ],
        // A pack built around a customised meal takes nothing but more of
        // that same meal, so the pill would only ever open a picker holding
        // the meal already on screen. It is left off there; "Add Another
        // Pack" below is the way on.
        if (!packHoldsCustomisedMeal(items)) ...[
          const Gap(14),
          // A compact pill rather than a bare icon: it sits under the meals as
          // an obvious second action, without competing with the dashed "Add
          // Another Pack" button that follows the whole list.
          Material(
            color: kcPrimary980,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onAddToThisPack,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 16, color: kcPrimary300),
                    const Gap(6),
                    Text(
                      'Add to this pack',
                      style:
                          ktLabelSemiBoldSize12.copyWith(color: kcPrimary300),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The meal quantity the backend accepts on a cart item. Past this the request
/// comes back rejected, so the stepper stops here rather than finding out.
const int _maxMealQuantity = 10;

/// One meal in a pack: what it is, how many, what was chosen inside it, and the
/// way back into that choice.
class _PackItemRow extends HookWidget {
  const _PackItemRow({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onRemove,
    required this.onChangeQuantity,
  });

  final Item item;

  /// Reopens the meal's customization sheet on this line.
  final Future<void> Function() onEdit;

  final Future<void> Function() onRemove;

  /// Sets the meal quantity, only ever 1–[_maxMealQuantity]. Taking the last
  /// one out is a delete, which [onRemove] does outright.
  final Future<void> Function(int quantity) onChangeQuantity;

  @override
  Widget build(BuildContext context) {
    final meal = item.mealVariant?.meal;
    final quantity = (item.mealQuantity ?? 1).toInt();
    final options = item.options ?? const <ItemOption>[];
    final packagingFee = item.packagingFee ?? 0;

    // Same reasoning as the pack-level delete: the request plus its cart
    // refetch takes a moment, so the spinner sits on the row being removed and
    // the button is dead while it spins.
    final isRemoving = useState(false);

    // Items saved before the API returned ids can't be addressed one at a
    // time; the pack delete is still there for them.
    final canRemove = (item.id ?? '').isNotEmpty;

    // Every quantity change is a round trip that re-prices the whole cart, so
    // the stepper goes dead until it lands — a second tap would be aimed at a
    // number the server is already replacing.
    final isUpdating = useState(false);
    Future<void> runUpdate(Future<void> Function() request) async {
      if (isUpdating.value) return;
      isUpdating.value = true;
      try {
        await request();
      } finally {
        // A change that empties the row takes it out of the tree, so only
        // touch the state if it's still there.
        if (context.mounted) isUpdating.value = false;
      }
    }

    // The change is addressed by both ids, and the backend checks the variant
    // against the item, so a row missing either can only be shown as it is.
    final canChangeQuantity =
        canRemove && (item.mealVariant?.id ?? '').isNotEmpty;

    // What exactly is out of stock: the meal itself, or specific add-ons.
    final isAvailable = item.available;
    final mealOut = item.mealVariant?.inStock == false;
    final outOptionNames = [
      for (final o in options)
        if (o.optionItemVariant?.inStock == false)
          o.optionItemVariant?.optionItem?.item ?? 'An add-on',
    ];
    final unavailableLabel = mealOut || outOptionNames.isEmpty
        ? 'Out of stock'
        : '${outOptionNames.join(', ')} ${outOptionNames.length > 1 ? 'are' : 'is'} out of stock';

    return Opacity(
      opacity: isAvailable ? 1 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Bullet(),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal?.mealName ?? 'Courier Item',
                      style: ktBodySemiBoldSize16.copyWith(
                          color: kcPrimaryNeutral100),
                    ),
                    if (!isAvailable) ...[
                      const Gap(4),
                      Text(
                        unavailableLabel,
                        style: ktLabelRegularSize12.copyWith(
                            color: const Color(0xFFC00100)),
                      ),
                    ],
                    const Gap(4),
                    Text(
                      _naira(meal?.price),
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral500),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              if (canChangeQuantity)
                _QuantityStepper(
                  quantity: quantity,
                  isBusy: isUpdating.value,
                  // One below the bottom is a delete of the whole item, which the
                  // × already does and says so; leaving it off the stepper keeps
                  // an accidental extra tap from emptying the row.
                  canDecrease: quantity > 1,
                  canIncrease: quantity < _maxMealQuantity,
                  onDecrease: () =>
                      runUpdate(() => onChangeQuantity(quantity - 1)),
                  onIncrease: () =>
                      runUpdate(() => onChangeQuantity(quantity + 1)),
                )
              else if (quantity > 1)
                Text(
                  '×$quantity',
                  style:
                      ktBodySemiBoldSize14.copyWith(color: kcPrimaryNeutral400),
                ),
              if (canRemove) ...[
                const Gap(2),
                _RemoveItemButton(
                  isRemoving: isRemoving.value,
                  onTap: () async {
                    isRemoving.value = true;
                    try {
                      await onRemove();
                    } finally {
                      // A successful remove takes this row out of the tree, so
                      // only touch the state if it's still there.
                      if (context.mounted) isRemoving.value = false;
                    }
                  },
                ),
              ],
            ],
          ),
          if (options.isNotEmpty) ...[
            const Gap(12),
            _SelectionsPanel(
              options: options,
              // Editing needs the same two ids the quantity change does: the
              // sheet saves back onto this line, and a line the API cannot
              // address can only be read out.
              onEdit: canChangeQuantity ? onEdit : null,
            ),
          ],
          // The packaging charge is per portion, so it belongs against the line
          // that caused it rather than only in the summary total. A meal with
          // options is never charged for packaging and reads 0 — show nothing at
          // all there instead of a ₦0 line.
          if (packagingFee > 0) ...[
            const Gap(14),
            _PackagingRow(fee: packagingFee),
          ],
        ],
      ),
    );
  }
}

/// The ✦ that marks a line inside a pack. A glyph rather than an icon, so it
/// grows with the text beside it at any accessibility scale.
class _Bullet extends StatelessWidget {
  const _Bullet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '✦',
        style: ktBodySemiBoldSize16.copyWith(color: kcPrimaryNeutral100),
      ),
    );
  }
}

/// What was chosen inside a meal, and the way back into that choice.
///
/// Deliberately a read-out: the options are listed rather than made steppable,
/// so a customised meal has one door — the sheet it was built in — instead of
/// two half-views of the same thing. Adding an option the meal doesn't carry
/// yet is only possible in there.
class _SelectionsPanel extends StatelessWidget {
  const _SelectionsPanel({required this.options, required this.onEdit});

  final List<ItemOption> options;

  /// Null where the line cannot be addressed by the API, which leaves the panel
  /// a plain read-out with no way in.
  final Future<void> Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    final total = options.fold<num>(0, (sum, o) => sum + _lineTotal(o));

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: _pageBackground,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your Selections',
                        style: ktBodySemiBoldSize14.copyWith(
                            color: kcPrimaryNeutral100),
                      ),
                    ),
                    const Gap(12),
                    Text(
                      '+ ${_naira(total)}',
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral500),
                    ),
                  ],
                ),
                for (final option in options) ...[
                  const Gap(9),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _label(option),
                          style: ktBodyRegularSize14.copyWith(
                              color: kcPrimaryNeutral500),
                        ),
                      ),
                      const Gap(12),
                      Text(
                        _naira(_lineTotal(option)),
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null) _EditSelectionsButton(onTap: onEdit!),
        ],
      ),
    );
  }

  /// An option's quantity counts apart from the meal's, so the charge is the
  /// option's price times its own count.
  static num _lineTotal(ItemOption option) =>
      (option.optionItemVariant?.optionItem?.price ?? 0) *
      (option.quantity ?? 1);

  /// The option's name, carrying its count only when there is more than one.
  static String _label(ItemOption option) {
    final name = option.optionItemVariant?.optionItem?.item ?? 'Option';
    final quantity = option.quantity ?? 1;
    return quantity > 1 ? '$name ×$quantity' : name;
  }
}

/// The way back into a customised meal. Sits flush under the selections it
/// edits, so it reads as that panel's action rather than the pack's.
class _EditSelectionsButton extends StatelessWidget {
  const _EditSelectionsButton({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcPrimary300,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Edit Selections',
                  style: ktLabelSemiBoldSiz15.copyWith(color: kcWhite),
                ),
              ),
              const Icon(Iconsax.arrow_right_3, size: 16, color: kcWhite),
            ],
          ),
        ),
      ),
    );
  }
}

/// The takeaway pack charged against one meal.
///
/// The cart carries the charge but not the packaging's name, so this says what
/// the charge is for rather than naming the material it is made of.
class _PackagingRow extends StatelessWidget {
  const _PackagingRow({required this.fee});

  final num fee;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Bullet(),
        const Gap(10),
        Expanded(
          child: Text(
            'Takeaway pack',
            style: ktBodySemiBoldSize16.copyWith(color: kcPrimaryNeutral100),
          ),
        ),
        const Gap(12),
        Text(
          _naira(fee),
          style: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral500),
        ),
      ],
    );
  }
}

/// Per-item delete. Deliberately quieter than the pack's own trash button —
/// this drops one meal, the one above drops the whole pack.
class _RemoveItemButton extends StatelessWidget {
  const _RemoveItemButton({required this.isRemoving, required this.onTap});

  final bool isRemoving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcTransparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isRemoving ? null : onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: isRemoving
              ? const SizedBox(
                  height: 13,
                  width: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: kcPrimaryRed400,
                  ),
                )
              : const Icon(Iconsax.close_circle,
                  size: 15, color: kcPrimaryNeutral500),
        ),
      ),
    );
  }
}

/// The −/+ pair on a meal row.
///
/// Both buttons go dead together while a change is in flight, and the count in
/// the middle only ever shows what the server last returned: the cart is
/// re-priced on every change, so a locally incremented number would be a guess
/// sitting next to totals that hadn't moved yet.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.isBusy,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool isBusy;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kcWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kcPrimaryNeutral900),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Iconsax.minus,
            onTap: canDecrease && !isBusy ? onDecrease : null,
          ),
          SizedBox(
            width: 30,
            child: Center(
              child: isBusy
                  ? const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: kcPrimaryNeutral400,
                      ),
                    )
                  : Text(
                      '$quantity',
                      style: ktLabelSemiBoldSize11.copyWith(
                          color: kcPrimaryNeutral100),
                    ),
            ),
          ),
          _StepperButton(
            icon: Iconsax.add,
            onTap: canIncrease && !isBusy ? onIncrease : null,
          ),
        ],
      ),
    );
  }
}

/// One end of a stepper. A null [onTap] is the disabled state — the icon greys
/// out rather than the button disappearing, so the control keeps its width as
/// the count moves between its limits.
class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcTransparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Icon(
            icon,
            size: 14,
            color: onTap == null ? kcPrimaryNeutral500 : kcPrimaryNeutral100,
          ),
        ),
      ),
    );
  }
}

/// Blocks checkout when the vendor has switched "Accepting orders" off while
/// the customer still had items in the cart.
class _ShopClosedNotice extends StatelessWidget {
  const _ShopClosedNotice({this.shopName});

  final String? shopName;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFC00100);
    final name =
        (shopName == null || shopName!.isEmpty) ? 'This restaurant' : shopName!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD4),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.info_circle, size: 18, color: accent),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not accepting orders',
                  style: ktBodySemiBoldSize14.copyWith(color: accent),
                ),
                const Gap(3),
                Text(
                  '$name has paused new orders. Your cart is saved — you can '
                  'check out once they start accepting orders again.',
                  style:
                      ktLabelRegularSize12.copyWith(color: kcPrimaryNeutral300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartNotice extends StatelessWidget {
  const _EmptyCartNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: kcWhite,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Iconsax.bag_2, size: 22, color: kcPrimaryNeutral600),
          ),
          const Gap(10),
          Text(
            'Your packs are empty',
            style: ktBodySemiBoldSize14.copyWith(color: kcPrimaryNeutral200),
          ),
          const Gap(3),
          Text(
            'Add a pack to continue with this order',
            style: ktLabelRegularSize12.copyWith(color: kcPrimaryNeutral500),
          ),
        ],
      ),
    );
  }
}

class _AddPackButton extends StatelessWidget {
  const _AddPackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(color: kcPrimary700, radius: 16),
      child: Material(
        color: kcTransparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, size: 18, color: kcPrimary400),
                const Gap(6),
                Text(
                  'Add Another Pack',
                  style: ktLabelSemiBoldSize14.copyWith(color: kcPrimary400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
  });

  final Widget icon;
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kcPrimary980,
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                label,
                style:
                    ktLabelSemiBoldSize14.copyWith(color: kcPrimaryNeutral200),
              ),
            ),
            Text(
              'Optional',
              style: ktLabelRegularSize11.copyWith(color: kcPrimaryNeutral600),
            ),
          ],
        ),
        const Gap(10),
        TextField(
          controller: controller,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral100),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral600),
            filled: true,
            fillColor: _pageBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: border(kcTransparent),
            enabledBorder: border(kcTransparent),
            focusedBorder: border(kcPrimary500),
          ),
        ),
      ],
    );
  }
}

/// Receipt-styled summary — notched, dash-torn edge above the total.
class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.cart,
    required this.itemCount,
    required this.promoCodeController,
    required this.promoCodeMessage,
    required this.promoCodeIsError,
    required this.onApplyPromoCode,
    required this.onRemovePromoCode,
  });

  final Cart cart;
  final int itemCount;
  final TextEditingController promoCodeController;
  final String? promoCodeMessage;
  final bool promoCodeIsError;
  final Future<void> Function() onApplyPromoCode;
  final Future<void> Function() onRemovePromoCode;

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.subtotal ?? 0;
    final discount = cart.discount ?? 0;
    final deliveryFee = cart.payableDeliveryFee ?? 0;
    // Already inside totalPrice, and never discounted — promotions don't touch
    // what the vendor is owed for the pack. Hidden when nothing is charged, so
    // vendors who set no packaging up read exactly as they did before.
    final packagingFee = cart.packagingFee ?? 0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kcWhite,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  label:
                      'Subtotal ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                  value: Row(
                    children: [
                      if (discount > 0) ...[
                        Text(
                          _naira(subtotal),
                          style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Gap(6),
                      ],
                      Text(
                        _naira(subtotal - discount),
                        style: ktBodySemiBoldSize14.copyWith(
                            color: kcPrimaryNeutral100),
                      ),
                    ],
                  ),
                ),
                if (discount > 0) ...[
                  const Gap(10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [kcPrimaryGreen950, kcPrimaryGreen990],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.tag,
                            size: 15, color: kcPrimaryGreen500),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'You saved ${_naira(discount)} on this order',
                            style: ktLabelSemiBoldSize12.copyWith(
                                color: kcPrimaryGreen400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Gap(12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kcPrimary980,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.discount_shape,
                              size: 16, color: kcPrimary300),
                          const Gap(8),
                          const Expanded(
                            child: Text(
                              'Promo code',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kcPrimaryNeutral100,
                              ),
                            ),
                          ),
                          if ((cart.promoCode ?? '').isNotEmpty)
                            TextButton(
                              onPressed: () async => onRemovePromoCode(),
                              child: const Text('Remove'),
                            ),
                        ],
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: promoCodeController,
                              textCapitalization: TextCapitalization.characters,
                              style:
                                  const TextStyle(color: kcPrimaryNeutral100),
                              decoration: InputDecoration(
                                hintText: 'Enter code',
                                hintStyle: TextStyle(
                                  color: kcPrimaryNeutral600,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: kcWhite,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: kcPrimary500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          HookBuilder(builder: (context) {
                            final isApplying = useState(false);
                            return FilledButton(
                              onPressed: isApplying.value
                                  ? null
                                  : () async {
                                      isApplying.value = true;
                                      try {
                                        await onApplyPromoCode();
                                      } finally {
                                        if (context.mounted) {
                                          isApplying.value = false;
                                        }
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: kcPrimary300,
                                disabledBackgroundColor: kcPrimary300,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isApplying.value
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kcWhite,
                                      ),
                                    )
                                  : const Text('Apply'),
                            );
                          }),
                        ],
                      ),
                      if ((promoCodeMessage ?? '').isNotEmpty) ...[
                        const Gap(10),
                        Text(
                          promoCodeMessage!,
                          style: TextStyle(
                            color: promoCodeIsError
                                ? kcPrimaryRed400
                                : kcPrimaryGreen500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(12),
                _SummaryRow(
                  label: 'Delivery Fee',
                  value: deliveryFee == 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kcPrimaryGreen990,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'FREE',
                            style: ktLabelBoldSize11.copyWith(
                              color: kcPrimaryGreen500,
                              letterSpacing: 0.8,
                            ),
                          ),
                        )
                      : Text(
                          _naira(deliveryFee),
                          style: ktBodySemiBoldSize14.copyWith(
                              color: kcPrimaryNeutral100),
                        ),
                ),
                if (packagingFee > 0) ...[
                  const Gap(12),
                  _SummaryRow(
                    label: 'Takeaway/Packaging',
                    value: Text(
                      _naira(packagingFee),
                      style: ktBodySemiBoldSize14.copyWith(
                          color: kcPrimaryNeutral100),
                    ),
                  ),
                ],
                const Gap(12),
                _SummaryRow(
                  label: 'Tax and other fees',
                  value: Text(
                    _naira(cart.serviceFee),
                    style: ktBodySemiBoldSize14.copyWith(
                        color: kcPrimaryNeutral100),
                  ),
                ),
              ],
            ),
          ),
          const _ReceiptTear(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total to pay',
                  style:
                      ktBodySemiBoldSize16.copyWith(color: kcPrimaryNeutral200),
                ),
                Text(
                  _naira(cart.totalPrice),
                  style: ktBodyBoldSize20.copyWith(color: kcPrimary200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Punched-out circles either side of a dashed rule — the torn-receipt seam.
class _ReceiptTear extends StatelessWidget {
  const _ReceiptTear();

  @override
  Widget build(BuildContext context) {
    Widget notch(Alignment alignment) => Transform.translate(
          offset: Offset(alignment == Alignment.centerLeft ? -11 : 11, 0),
          child: Container(
            height: 22,
            width: 22,
            decoration: const BoxDecoration(
              color: _pageBackground,
              shape: BoxShape.circle,
            ),
          ),
        );

    return SizedBox(
      height: 22,
      child: Row(
        children: [
          notch(Alignment.centerLeft),
          const Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(color: kcPrimaryNeutral800),
              child: SizedBox(height: 22),
            ),
          ),
          notch(Alignment.centerRight),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral400),
          ),
        ),
        const Gap(12),
        value,
      ],
    );
  }
}

/// Pinned primary action, so the amount and the CTA stay reachable no matter
/// how long the order is.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.enabled,
    required this.onPay,
    required this.label,
    this.showTerms = false,
  });

  final num? total;
  final bool enabled;
  final VoidCallback onPay;

  /// What this step commits to — "Continue" on the order, "Make Payment" on
  /// delivery, or why the button is blocked.
  final String label;

  /// Whether the terms line stands above the button. Shown against the button
  /// that commits to them, not the one that only turns the page.
  final bool showTerms;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kcWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x141E1A1D),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTerms) ...[
              const _TermsLine(),
              const Gap(12),
            ],
            Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [kcPrimary500, kcPrimary300],
                  ),
                  boxShadow: enabled
                      ? const [
                          BoxShadow(
                            color: Color(0x59819228),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: kcTransparent,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: enabled ? onPay : null,
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  ktBodySemiBoldSize16.copyWith(color: kcWhite),
                            ),
                          ),
                          const Gap(12),
                          Text(
                            _naira(total),
                            style: ktBodyBoldSize18.copyWith(color: kcWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The agreement the payment button commits to.
class _TermsLine extends StatelessWidget {
  const _TermsLine();

  @override
  Widget build(BuildContext context) {
    final base = ktLabelRegularSize12.copyWith(color: kcPrimaryNeutral500);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('By proceeding, you agree to our ', style: base),
        const _TermsLink(label: 'Terms of Use', url: _termsUrl),
        Text(' and ', style: base),
        const _TermsLink(label: 'Privacy Policy', url: _privacyUrl),
      ],
    );
  }
}

/// One of the two documents in [_TermsLine].
///
/// With no [url] it renders as plain text: underlining a word that opens
/// nothing promises a page that isn't there.
class _TermsLink extends StatelessWidget {
  const _TermsLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.isNotEmpty;
    final style = ktLabelRegularSize12.copyWith(
      color: hasUrl ? kcPrimary300 : kcPrimaryNeutral500,
      decoration: hasUrl ? TextDecoration.underline : null,
      decorationColor: kcPrimary300,
    );

    if (!hasUrl) return Text(label, style: style);

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      ),
      child: Text(label, style: style),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const dash = 5.0;
    const gap = 5.0;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
          Offset(x, y), Offset((x + dash).clamp(0, size.width), y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path = Path()
      ..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));

    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
