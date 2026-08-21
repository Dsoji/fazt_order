import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/widgets/reusable_buttons.dart';
import '../../../common/widgets/text_styles.dart';
import '../../order/widgets/order_detail_widgets.dart' show formatPrice;
import '../../profile/data/controller/profile_controller.dart';

/// Asks how the parcel should be paid for, right before the charge happens.
///
/// Returns `'wallet'` or `'paystack'` — the value `POST /orders/parcel` takes
/// as its payment method — or `null` if the user backed out. The wallet
/// balance is fetched while the sheet is open so the choice is made against a
/// real number rather than a guess; when the balance cannot be read the option
/// stays selectable and the backend's "Insufficient balance" is what settles
/// it.
Future<String?> showParcelPaymentMethodSheet(
  BuildContext context, {
  required num amount,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ParcelPaymentMethodSheet(amount: amount),
  );
}

class _ParcelPaymentMethodSheet extends HookConsumerWidget {
  const _ParcelPaymentMethodSheet({required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<String?>(null);
    final walletState = ref.watch(profileControllerProvider).wallet;

    useEffect(() {
      Future.microtask(
          () => ref.read(profileControllerProvider.notifier).fetchWallet());
      return null;
    }, const []);

    final balance =
        walletState.valueOrNull?.data?.wallet?.availableBalance?.toDouble();
    final walletLoading = walletState.isLoading && balance == null;
    // Only a balance we actually read can rule the wallet out. A failed or
    // still-loading fetch leaves the option open.
    final insufficient = balance != null && balance < amount;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(20),
            Text(
              'How would you like to pay?',
              style: ktBodySemiBoldSize20.copyWith(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const Gap(4),
            Text(
              'You are paying ₦${formatPrice(amount.round())} for this delivery.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Gap(20),
            _MethodTile(
              icon: Iconsax.wallet_1,
              title: 'Wallet',
              subtitle: walletLoading
                  ? 'Checking balance…'
                  : balance == null
                      ? 'Balance unavailable'
                      : 'Balance ₦${formatPrice(balance.round())}',
              trailingNote: insufficient ? 'Insufficient balance' : null,
              isSelected: selected.value == 'wallet',
              isEnabled: !insufficient,
              onTap: () => selected.value = 'wallet',
            ),
            const Gap(12),
            _MethodTile(
              icon: Iconsax.card,
              title: 'Card / Bank Transfer',
              subtitle: 'Pay securely with Paystack',
              isSelected: selected.value == 'paystack',
              isEnabled: true,
              onTap: () => selected.value = 'paystack',
            ),
            const Gap(24),
            FullButton(
              text: 'Continue',
              width: double.infinity,
              height: 48,
              color: selected.value == null
                  ? AppColors.brand400.withValues(alpha: 0.4)
                  : AppColors.brand400,
              textColor: kcWhite,
              onPressed: () {
                if (selected.value == null) return;
                Navigator.pop(context, selected.value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    this.trailingNote,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingNote;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brand980 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppColors.brand400 : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.brand400),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      trailingNote ?? subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: trailingNote != null
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Iconsax.tick_circle : Iconsax.record_circle,
                size: 20,
                color: isSelected ? AppColors.brand400 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
