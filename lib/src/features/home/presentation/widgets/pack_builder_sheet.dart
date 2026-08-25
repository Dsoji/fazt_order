import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/widgets/text_styles.dart';
import '../../data/controller/shop_controller.dart';
import '../../data/model/response/cartlsit/item.dart';
import '../providers/active_pack_provider.dart';
import 'add_to_pack_sheet.dart';

/// What the customer sees after "Tap to view": every pack they have built so
/// far for this restaurant, with the two ways to keep going — carry on filling
/// an existing pack, or open a fresh one.
///
/// Nothing here talks to the server beyond removing a pack. Packs are a client
/// arrangement of cart items, so choosing a target is local state; the choice
/// only reaches the API as the `packNumber` on the next add-to-cart.
class PackBuilderSheet extends ConsumerWidget {
  const PackBuilderSheet({
    super.key,
    required this.shopId,
    required this.onCheckout,
  });

  final String shopId;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = cartForShop(
      ref.watch(shopControllerProvider.select((s) => s.fetchCart)).valueOrNull,
      shopId,
    );
    final packs = groupItemsByPack(cart);
    final packNumbers = packs.keys.toList()..sort();
    final activePack = ref.watch(activePackProvider)[shopId];

    /// Point the next add at [packNumber] and get out of the way, so the
    /// customer lands back on the menu ready to pick the item.
    void target(int packNumber) {
      ref.read(activePackProvider.notifier).select(shopId, packNumber);
      Navigator.pop(context);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: kcWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        color: kcPrimaryNeutral950,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: kcPrimaryNeutral300, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your packs',
                          style: ktBodyBoldSize18.copyWith(
                              color: kcPrimaryNeutral100),
                        ),
                        const Gap(3),
                        Text(
                          packNumbers.length == 1
                              ? 'Each pack is packed and delivered separately'
                              : '${packNumbers.length} packs, packed separately',
                          style: ktLabelRegularSize12.copyWith(
                              color: kcPrimaryNeutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final packNumber in packNumbers) ...[
                    _PackCard(
                      packNumber: packNumber,
                      items: packs[packNumber]!,
                      isActive: packNumber == activePack,
                      // Which meals may join a pack depends on what is
                      // already in it, and only the backend knows — so this
                      // opens the picker it answers with rather than dropping
                      // the customer back on the full menu.
                      onAddToThisPack: () => showAddToPackSheet(
                        context,
                        shopId: shopId,
                        cartId: cart?.id ?? '',
                        packNumber: packNumber,
                      ),
                      onRemove: () async {
                        final controller =
                            ref.read(shopControllerProvider.notifier);
                        final removed = await controller.removePackFromCart(
                            cart?.id ?? '', packNumber);
                        if (!removed) return;
                        await controller.fetchCart();
                        // Pack numbers are resequenced as a group after a
                        // removal — they stay dense from 1 — so any remembered
                        // target may now point at a different pack, not just
                        // the one that went away. Clearing it makes the next
                        // add open a fresh pack rather than land somewhere
                        // unexpected.
                        ref.read(activePackProvider.notifier).clear(shopId);
                      },
                    ),
                    const Gap(12),
                  ],
                  _AddAnotherPackButton(
                    onTap: () => target(nextPackNumber(cart)),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: kcWhite,
                border: Border(top: BorderSide(color: kcPrimaryNeutral900)),
              ),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onCheckout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimary300,
                    foregroundColor: kcWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Checkout ${packNumbers.length} '
                    '${packNumbers.length == 1 ? 'pack' : 'packs'}',
                    style: ktLabelBoldSize15.copyWith(color: kcWhite),
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

/// One built pack: what is in it, and the plus button that resumes filling it.
class _PackCard extends StatefulWidget {
  const _PackCard({
    required this.packNumber,
    required this.items,
    required this.isActive,
    required this.onAddToThisPack,
    required this.onRemove,
  });

  final int packNumber;
  final List<Item> items;
  final bool isActive;
  final VoidCallback onAddToThisPack;
  final Future<void> Function() onRemove;

  @override
  State<_PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<_PackCard> {
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: kcPrimaryNeutral990,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isActive ? kcPrimary400 : kcPrimaryNeutral900,
          width: widget.isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 22,
                width: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: kcPrimary600,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${widget.packNumber}',
                  style: ktLabelBoldSize11.copyWith(color: kcPrimary100),
                ),
              ),
              const Gap(8),
              Text(
                'Pack ${widget.packNumber}',
                style:
                    ktLabelSemiBoldSize12.copyWith(color: kcPrimaryNeutral200),
              ),
              if (widget.isActive) ...[
                const Gap(8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kcPrimary980,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Adding here',
                    style: ktLabelSemiBoldSize11.copyWith(color: kcPrimary300),
                  ),
                ),
              ],
              const Spacer(),
              Material(
                color: kcPrimaryRed900,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _isRemoving
                      ? null
                      : () async {
                          setState(() => _isRemoving = true);
                          try {
                            await widget.onRemove();
                          } finally {
                            // A successful remove takes this card out of the
                            // tree; only touch state if it survived.
                            if (mounted) setState(() => _isRemoving = false);
                          }
                        },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: _isRemoving
                        ? const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kcPrimaryRed400,
                            ),
                          )
                        : const Icon(Iconsax.trash,
                            color: kcPrimaryRed400, size: 15),
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0) const Gap(10),
            _PackItemRow(item: widget.items[i]),
          ],
          // A pack built around a customised meal takes nothing but more of
          // that same meal, so the pill would only ever open a picker holding
          // the meal already on screen. It is left off there; "Add Another
          // Pack" below is the way on.
          if (!packHoldsCustomisedMeal(widget.items)) ...[
            const Gap(12),
            // A compact pill rather than a bare icon: it sits under the meals
            // as an obvious second action, without competing with the dashed
            // "Add Another Pack" button that follows the whole list.
            Material(
              color: kcPrimary980,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: widget.onAddToThisPack,
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
      ),
    );
  }
}

class _PackItemRow extends StatelessWidget {
  const _PackItemRow({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final meal = item.mealVariant?.meal;
    final quantity = (item.mealQuantity ?? 1).toInt();
    final options = item.options ?? const [];
    final imageUrl = meal?.mealImage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 40,
            width: 40,
            child: imageUrl == null || imageUrl.isEmpty
                ? Container(
                    color: kcPrimaryNeutral950,
                    child: const Icon(Icons.fastfood,
                        size: 16, color: kcPrimaryNeutral700),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: kcPrimaryNeutral950,
                      child: const Icon(Icons.fastfood,
                          size: 16, color: kcPrimaryNeutral700),
                    ),
                  ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quantity > 1
                    ? '${quantity}x ${meal?.mealName ?? 'Item'}'
                    : (meal?.mealName ?? 'Item'),
                style:
                    ktLabelSemiBoldSize12.copyWith(color: kcPrimaryNeutral100),
              ),
              if (options.isNotEmpty) ...[
                const Gap(3),
                Text(
                  options
                      .map((o) => o.optionItemVariant?.optionItem?.item)
                      .whereType<String>()
                      .join(' · '),
                  style: ktLabelRegularSize11.copyWith(
                      color: kcPrimaryNeutral500),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AddAnotherPackButton extends StatelessWidget {
  const _AddAnotherPackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcPrimary980,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: kcPrimary300),
              const Gap(6),
              Text(
                'Add Another Pack',
                style: ktLabelSemiBoldSize14.copyWith(color: kcPrimary300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
