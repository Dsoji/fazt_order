import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../webview_flutter.dart';
import '../../../common/app_colors.dart';
import '../../home/data/controller/shop_controller.dart';
import '../../home/data/model/response/my_orders_list/payment.dart';
import 'order_detail_widgets.dart' show formatPrice;

/// The way back into a Paystack charge that was never completed.
///
/// A customer can close the checkout webview, lose signal, or simply put the
/// phone down; the order is then left at `paymentStatus: pending` with its
/// `paymentUrl` still live. That URL is the whole mechanism here — reopening it
/// resumes the same charge rather than starting a second one. The webview
/// verifies the reference and refetches the orders feed on its way out, so
/// nothing needs to be checked before opening it.
class PendingPaymentAction extends HookConsumerWidget {
  const PendingPaymentAction({
    super.key,
    required this.orderId,
    required this.payment,
    this.dense = false,
    this.onResolved,
  });

  /// The order this payment belongs to. Display only — the resume itself is
  /// driven entirely by the payment's own URL and reference.
  final String? orderId;

  final Payment? payment;

  /// Row-sized: just the button, for an order card in a list. The full form
  /// adds the explanation and suits a detail screen.
  final bool dense;

  /// Fired once the payment is settled, so the surrounding screen can react.
  final VoidCallback? onResolved;

  /// Payment states that mean the money has not landed yet. Anything else —
  /// including a status this build doesn't recognise — is left alone rather
  /// than offered a second charge.
  static const _unsettledStatuses = {
    'pending',
    'initiated',
    'processing',
    'awaiting_payment',
    'failed',
  };

  /// Whether [payment] is an unfinished charge with somewhere to send the
  /// customer back to.
  ///
  /// The URL is the requirement, not the payment method: it exists only on a
  /// redirect flow, and without it there is nothing this button can do — a
  /// parcel in that state needs a fresh charge, which is the actions section's
  /// job.
  static bool isResumable(Payment? payment) {
    if (payment == null) return false;
    if ((payment.paymentUrl ?? '').isEmpty) return false;
    final status = payment.paymentStatus?.toLowerCase();
    return status != null && _unsettledStatuses.contains(status);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isResumable(payment)) return const SizedBox.shrink();

    final busy = useState(false);
    final amount = payment?.total ?? 0;
    final label = amount <= 0
        ? 'Complete payment'
        : 'Complete payment ₦${formatPrice(amount.round())}';

    final button = _ActionButton(
      label: label,
      busy: busy.value,
      onPressed: () => _resume(context, ref, busy),
    );

    if (dense) return button;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Iconsax.info_circle, size: 16, color: _kWarnText),
              Gap(8),
              Expanded(
                child: Text(
                  'This order has not been paid for yet. Pick up where you '
                  'left off and finish paying here.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: _kWarnText,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          button,
        ],
      ),
    );
  }

  /// Reopens the charge's own Paystack page.
  ///
  /// The webview verifies the reference and refetches the orders feed when it
  /// closes; the refresh here is what this widget's own screen reads, so it
  /// runs before the caller is told anything changed.
  Future<void> _resume(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> busy,
  ) async {
    if (busy.value) return;
    final url = payment?.paymentUrl;
    if (url == null || url.isEmpty) return;

    busy.value = true;
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FaztWebViewScreen(
            uri: url,
            reference: _referenceOf(payment) ?? '',
            title: 'Complete Payment',
          ),
        ),
      );

      await ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
      onResolved?.call();
    } finally {
      if (context.mounted) busy.value = false;
    }
  }

  static String? _referenceOf(Payment? payment) {
    final reference = payment?.paymentReference ?? payment?.transactionId;
    return (reference == null || reference.isEmpty) ? null : reference;
  }
}

const _kWarnText = Color(0xFF8A5A00);

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Material(
        color: kcPrimary300,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: busy ? null : onPressed,
          child: Center(
            child: busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kcWhite,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.card, size: 16, color: kcWhite),
                      const Gap(8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kcWhite,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
