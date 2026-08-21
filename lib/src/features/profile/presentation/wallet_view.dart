import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/app_colors.dart';
import '../../order/widgets/order_detail_widgets.dart'
    show formatDateTime, formatPrice;
import '../data/controller/profile_controller.dart';
import '../data/model/response/transaction_history.dart';
import '../data/model/response/user_wallet/bank_transfer.dart';
import '../../../common/widgets/app_refresh_indicator.dart';

/// The wallet screen.
///
/// One dark balance card carries the money and the single action (top up);
/// everything below it is a plain, hairline-separated transaction list. The
/// screen deliberately has no other chrome — no nested cards, no gradients —
/// so the balance is the only thing competing for attention.
class WalletView extends HookConsumerWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(profileControllerProvider).wallet;
    final transactionHistory =
        ref.watch(profileControllerProvider).transactionHistory;

    useEffect(() {
      Future.microtask(() {
        ref.read(profileControllerProvider.notifier).fetchWallet();
        ref.read(profileControllerProvider.notifier).fetchTransactionHistory();
      });
      return null;
    }, []);

    Future<void> refresh() async {
      final controller = ref.read(profileControllerProvider.notifier);
      await Future.wait([
        controller.fetchWallet(),
        controller.fetchTransactionHistory(),
      ]);
    }

    return Scaffold(
      backgroundColor: kcPrimaryNeutral990,
      appBar: AppBar(
        backgroundColor: kcPrimaryNeutral990,
        surfaceTintColor: kcPrimaryNeutral990,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2,
              color: kcPrimaryNeutral100),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: kcPrimaryNeutral100,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AppRefreshIndicator(
        onRefresh: refresh,
        color: kcPrimary400,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            walletState.when(
              loading: () => const _BalanceCardSkeleton(),
              error: (error, _) => _BalanceError(
                onRetry: () =>
                    ref.read(profileControllerProvider.notifier).fetchWallet(),
              ),
              data: (walletData) {
                final wallet = walletData.data?.wallet;
                return _BalanceCard(
                  balance: wallet?.availableBalance?.toDouble() ?? 0,
                  pending: (wallet?.pendingBalance ?? 0).toDouble(),
                  onTopUp: () =>
                      _showBankTransferDialog(context, wallet?.bankTransfer),
                );
              },
            ),
            const Gap(28),
            const Text(
              'Transactions',
              style: TextStyle(
                color: kcPrimaryNeutral100,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            transactionHistory.when(
              loading: () => const _TransactionListSkeleton(),
              error: (err, st) => const _ListMessage(
                icon: IconsaxPlusLinear.info_circle,
                title: 'Could not load transactions',
                subtitle: 'Pull down to try again.',
              ),
              data: (data) {
                final list = [...?data.results]..sort((a, b) =>
                    (b.createdAt ?? DateTime(0))
                        .compareTo(a.createdAt ?? DateTime(0)));

                if (list.isEmpty) {
                  return const _ListMessage(
                    icon: IconsaxPlusLinear.receipt_item,
                    title: 'No transactions yet',
                    subtitle: 'Your top ups and orders will show up here.',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 52,
                    color: kcPrimaryNeutral950,
                  ),
                  itemBuilder: (context, index) =>
                      _TransactionTile(transaction: list[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance
// ---------------------------------------------------------------------------

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double pending;
  final VoidCallback onTopUp;

  const _BalanceCard({
    required this.balance,
    required this.pending,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kcPrimaryNeutral100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(
                    color: kcWhite.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Icon(
                IconsaxPlusLinear.wallet_2,
                size: 18,
                color: kcWhite.withValues(alpha: 0.55),
              ),
            ],
          ),
          const Gap(10),
          Text(
            _formatNaira(balance),
            style: const TextStyle(
              color: kcWhite,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          if (pending > 0) ...[
            const Gap(6),
            Text(
              '${_formatNaira(pending)} pending',
              style: TextStyle(
                color: kcWhite.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
          const Gap(22),
          _PrimaryButton(
            label: 'Top up',
            icon: IconsaxPlusLinear.add,
            onPressed: onTopUp,
          ),
        ],
      ),
    );
  }
}

/// The one filled action on the screen — lime on the dark card, lime on white
/// in the dialog.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcPrimary600,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onPressed,
        child: SizedBox(
          height: 46,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: kcPrimaryNeutral100),
                const Gap(6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: kcPrimaryNeutral100,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCardSkeleton extends StatelessWidget {
  const _BalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kcPrimaryNeutral950,
      highlightColor: kcPrimaryNeutral990,
      child: Container(
        width: double.infinity,
        height: 186,
        decoration: BoxDecoration(
          color: kcPrimaryNeutral950,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class _BalanceError extends StatelessWidget {
  final VoidCallback onRetry;

  const _BalanceError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kcPrimaryNeutral950,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance unavailable',
            style: TextStyle(
              color: kcPrimaryNeutral100,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          const Text(
            'We could not reach your wallet just now.',
            style: TextStyle(color: kcPrimaryNeutral500, fontSize: 13),
          ),
          const Gap(14),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: const Row(
              children: [
                Icon(IconsaxPlusLinear.refresh, size: 16, color: kcPrimary400),
                Gap(6),
                Text(
                  'Try again',
                  style: TextStyle(
                    color: kcPrimary400,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transactions
// ---------------------------------------------------------------------------

class _TransactionTile extends StatelessWidget {
  final TransactionRecord transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = _isCredit(transaction.type);
    final status = (transaction.status ?? '').toLowerCase();
    final statusColor = _statusColor(status);
    final amount = (transaction.amount ?? 0).abs();
    final createdAt = transaction.createdAt;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit
                  ? kcPrimaryGreen600.withValues(alpha: 0.1)
                  : kcPrimaryNeutral950,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? IconsaxPlusLinear.arrow_down_1
                  : IconsaxPlusLinear.arrow_up_3,
              size: 18,
              color: isCredit ? kcPrimaryGreen600 : kcPrimaryNeutral400,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(transaction),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kcPrimaryNeutral100,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(3),
                Text(
                  createdAt == null ? '—' : formatDateTime(createdAt),
                  style: const TextStyle(
                    color: kcPrimaryNeutral500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'} ${_formatNaira(amount)}',
                style: TextStyle(
                  color: isCredit ? kcPrimaryGreen600 : kcPrimaryNeutral100,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(3),
              Text(
                _capitalise(transaction.status ?? ''),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionListSkeleton extends StatelessWidget {
  const _TransactionListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Shimmer.fromColors(
            baseColor: kcPrimaryNeutral950,
            highlightColor: kcPrimaryNeutral990,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kcPrimaryNeutral950,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, color: kcPrimaryNeutral950),
                      const Gap(8),
                      Container(
                        height: 10,
                        width: 100,
                        color: kcPrimaryNeutral950,
                      ),
                    ],
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

/// The empty and error placeholders for the transaction list.
class _ListMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ListMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 28, color: kcPrimaryNeutral700),
          const Gap(12),
          Text(
            title,
            style: const TextStyle(
              color: kcPrimaryNeutral300,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kcPrimaryNeutral500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top up dialog
// ---------------------------------------------------------------------------

void _showBankTransferDialog(BuildContext context, BankTransfer? bankTransfer) {
  final accountNumber = bankTransfer?.accountNumber;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: kcPrimaryNeutral990,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Bank transfer',
                    style: TextStyle(
                      color: kcPrimaryNeutral100,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: kcPrimaryNeutral500,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(4),
            const Text(
              'Transfer to this account to top up your wallet.',
              style: TextStyle(color: kcPrimaryNeutral500, fontSize: 12),
            ),
            const Gap(20),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: accountNumber == null
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: accountNumber),
                        );
                        await Fluttertoast.showToast(
                          msg: 'Account number copied',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: kcPrimary400,
                          textColor: kcWhite,
                        );
                      },
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: kcPrimaryNeutral950,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACCOUNT NUMBER',
                              style: TextStyle(
                                color: kcPrimaryNeutral500,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              accountNumber ?? 'Not available',
                              style: const TextStyle(
                                color: kcPrimaryNeutral100,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (accountNumber != null)
                        const Icon(
                          IconsaxPlusLinear.copy,
                          color: kcPrimary400,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(16),
            _transferInfoRow('Bank', bankTransfer?.bankName ?? '—'),
            const Gap(10),
            _transferInfoRow('Account name', bankTransfer?.accountName ?? '—'),
            const Gap(24),
            _PrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
            const Gap(4),
          ],
        ),
      ),
    ),
  );
}

Widget _transferInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: kcPrimaryNeutral500, fontSize: 12),
      ),
      const Gap(12),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: kcPrimaryNeutral100,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// `12500` -> `₦12,500`, `1250.5` -> `₦1,250.50`.
String _formatNaira(double amount) {
  final whole = amount.truncate();
  final kobo = ((amount - whole) * 100).round().abs();
  final formatted = formatPrice(whole);
  return kobo == 0
      ? '₦$formatted'
      : '₦$formatted.${kobo.toString().padLeft(2, '0')}';
}

/// Money coming into the wallet, judged by the transaction type — the status
/// only says whether it went through, not which way it moved.
bool _isCredit(String? type) {
  final t = (type ?? '').toLowerCase();
  return t.contains('fund') ||
      t.contains('deposit') ||
      t.contains('credit') ||
      t.contains('refund') ||
      t.contains('topup') ||
      t.contains('top_up');
}

String _title(TransactionRecord transaction) {
  final type = (transaction.type ?? '').replaceAll('_', ' ').trim();
  final label = type.isEmpty ? 'Transaction' : _capitalise(type);
  final orderNumber = transaction.metadata?.orderNumber;
  return orderNumber == null || orderNumber.isEmpty
      ? label
      : '$label · $orderNumber';
}

String _capitalise(String value) => value
    .split(' ')
    .where((word) => word.isNotEmpty)
    .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
    .join(' ');

Color _statusColor(String status) {
  switch (status) {
    case 'completed':
    case 'success':
    case 'successful':
      return kcPrimaryGreen600;
    case 'pending':
    case 'processing':
      return kcPrimaryOrange700;
    case 'failed':
    case 'cancelled':
    case 'canceled':
      return kcPrimaryRed500;
    default:
      return kcPrimaryNeutral500;
  }
}
