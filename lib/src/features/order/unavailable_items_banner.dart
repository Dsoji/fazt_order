import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/text_styles.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/cartlsit/cart.dart';

/// Tells the customer which lines the server took out of [cart] because the
/// meal (or an add-on) was deleted from the menu. Dismissing calls the API and
/// refetches, so it only goes away once the customer has acknowledged it.
class UnavailableItemsBanner extends ConsumerStatefulWidget {
  const UnavailableItemsBanner({required this.cart, super.key});

  final Cart cart;

  @override
  ConsumerState<UnavailableItemsBanner> createState() =>
      _UnavailableItemsBannerState();
}

class _UnavailableItemsBannerState
    extends ConsumerState<UnavailableItemsBanner> {
  bool _dismissing = false;

  Future<void> _dismiss() async {
    final cartId = widget.cart.id;
    if (cartId == null || cartId.isEmpty || _dismissing) return;
    setState(() => _dismissing = true);
    await ref
        .read(shopControllerProvider.notifier)
        .dismissUnavailableItems(cartId);
    if (mounted) setState(() => _dismissing = false);
  }

  @override
  Widget build(BuildContext context) {
    final notices = widget.cart.unavailableItems ?? const [];
    if (notices.isEmpty) return const SizedBox.shrink();

    const accent = Color(0xFFC00100);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.info_circle, size: 18, color: accent),
              const Gap(8),
              Expanded(
                child: Text(
                  'Removed from your cart',
                  style: ktBodySemiBoldSize14.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const Gap(8),
          for (final notice in notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                notice.message,
                style:
                    ktLabelRegularSize12.copyWith(color: kcPrimaryNeutral300),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _dismissing ? null : _dismiss,
              child: _dismissing
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}
