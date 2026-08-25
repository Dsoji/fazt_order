import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/res/app_colors.dart';
import '../../../common/widgets/reusable_buttons.dart';
import '../../home/data/model/response/my_orders_list/item.dart';
import '../../home/data/model/response/my_orders_list/result.dart';
import '../../home/data/model/response/my_orders_list/rider.dart';

/// The building blocks shared by the Ongoing and Completed order detail pages.
///
/// Both pages describe the same order, so they are assembled from the same
/// cards — a gradient header, section cards, the item list with its payment
/// breakdown, the rider, and the delivery details. Keeping them here means a
/// tweak to the look lands on both screens at once.

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

/// The gradient card at the top of an order detail page.
///
/// [gradient] lets a page tint the header to the order's outcome — the brand
/// green for a live or delivered order, a muted grey for one that never made it.
class OrderSummaryCard extends StatelessWidget {
  final OrderResult order;
  final List<Color>? gradient;

  const OrderSummaryCard({super.key, required this.order, this.gradient});

  @override
  Widget build(BuildContext context) {
    final placedAt = order.orderPlacedAt ?? order.createdAt;
    final packCount = order.packCount ?? 0;
    final shopName = order.shop?.shopName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient ?? const [AppColors.brand200, AppColors.brand300],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ID',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      order.orderNumber ?? 'Unknown order number',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    if (shopName != null && shopName.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(10),
              StatusPill(status: order.status),
            ],
          ),
          const Gap(16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (placedAt != null)
                InfoChip(
                  icon: IconsaxPlusLinear.clock,
                  label: formatDateTime(placedAt),
                ),
              if (order.deliveryType != null)
                InfoChip(
                  icon: IconsaxPlusLinear.truck,
                  label: order.deliveryType!.replaceAll('_', ' '),
                ),
              if (packCount > 0)
                InfoChip(
                  icon: IconsaxPlusLinear.box_1,
                  label: '$packCount pack${packCount > 1 ? 's' : ''}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String? status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        status == null ? 'UNKNOWN' : status!.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.brand800),
          const Gap(6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline
// ---------------------------------------------------------------------------

/// One row of the order progress rail.
class TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isReached = isDone || isCurrent;
    final railColor = isDone ? AppColors.brand300 : AppColors.neutral900;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isReached ? AppColors.brand300 : Colors.white,
                    border: Border.all(
                      color:
                          isReached ? AppColors.brand300 : AppColors.neutral800,
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : isCurrent
                          ? Center(
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: railColor)),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isReached
                          ? AppColors.neutral100
                          : AppColors.neutral500,
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The banner shown when an order was cancelled or declined.
class TerminalBanner extends StatelessWidget {
  final String status;

  const TerminalBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isRejected = status == 'rejected';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red950,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red900),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.red500.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconsaxPlusLinear.close_circle,
              size: 20,
              color: AppColors.red500,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRejected ? 'Order declined' : 'Order cancelled',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red400,
                  ),
                ),
                const Gap(2),
                Text(
                  isRejected
                      ? 'The vendor could not take this order. Any payment will be refunded.'
                      : 'This order was cancelled and will not be prepared.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral400,
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
// Rider
// ---------------------------------------------------------------------------

/// The assigned rider, or a placeholder while the order waits for one.
///
/// [canCall] is turned off once the order is finished — the phone number stays
/// on record but there is nothing left to call about.
class RiderCard extends StatelessWidget {
  final Rider? rider;
  final bool canCall;
  final String emptyMessage;

  const RiderCard({
    super.key,
    required this.rider,
    this.canCall = true,
    this.emptyMessage =
        'Rider details will show up here as soon as one is assigned to your order.',
  });

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start a call to $phone')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rider = this.rider;

    if (rider == null || !rider.hasDetails) {
      return SectionCard(
        title: 'Your rider',
        child: Row(
          children: [
            const Icon(
              IconsaxPlusLinear.profile_circle,
              size: 20,
              color: AppColors.neutral500,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final name = rider.fullName ?? 'Your rider';
    final phone = rider.phone;
    final vehicle = [rider.vehicleType, rider.plateNumber]
        .where((value) => value != null && value.isNotEmpty)
        .join(' • ');

    return SectionCard(
      title: 'Your rider',
      child: Column(
        children: [
          Row(
            children: [
              RiderAvatar(rider: rider),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral100,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      vehicle.isEmpty
                          ? (canCall
                              ? 'Delivering your order'
                              : 'Delivered your order')
                          : vehicle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (phone != null) ...[
            const Gap(14),
            DetailRow(
              icon: IconsaxPlusLinear.call,
              label: 'Phone',
              value: phone,
              isLast: true,
              onCopy: () async {
                await Clipboard.setData(ClipboardData(text: phone));
                Fluttertoast.showToast(msg: 'Phone number copied');
              },
            ),
            if (canCall) ...[
              const Gap(4),
              FullButton(
                text: 'Call rider',
                width: double.infinity,
                height: 46,
                fontSize: 14,
                onPressed: () => _call(context, phone),
                color: AppColors.brand300,
                textColor: Colors.white,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class RiderAvatar extends StatelessWidget {
  final Rider rider;

  const RiderAvatar({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    final photo = rider.photo;
    final initial = (rider.firstName?.isNotEmpty == true)
        ? rider.firstName![0].toUpperCase()
        : 'R';

    Widget fallback() => Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          color: AppColors.brand980,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brand300,
            ),
          ),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: (photo == null || photo.isEmpty)
          ? fallback()
          : CachedNetworkImage(
              imageUrl: photo,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              placeholder: (context, url) => fallback(),
              errorWidget: (context, url, error) => fallback(),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items and payment
// ---------------------------------------------------------------------------

/// The order's items followed by its payment breakdown.
///
/// [totalLabel] reads differently once the money has actually moved, so the
/// completed page can say "Total paid" where a pending one says "Total".
class OrderItemsCard extends StatelessWidget {
  final OrderResult order;
  final String totalLabel;

  const OrderItemsCard({
    super.key,
    required this.order,
    this.totalLabel = 'Total paid',
  });

  @override
  Widget build(BuildContext context) {
    final items = order.items ?? [];
    final payment = order.payment;
    final discount = payment?.discount ?? 0;

    return SectionCard(
      title: 'Items',
      trailing: items.isEmpty
          ? null
          : Text(
              '${items.length} item${items.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const Text(
              'No items in this order',
              style: TextStyle(fontSize: 14, color: AppColors.neutral500),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              OrderItemRow(item: items[i]),
              if (i != items.length - 1)
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: AppColors.neutral950,
                ),
            ],
          if (payment != null) ...[
            const Gap(14),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral900),
            const Gap(12),
            if (payment.subtotal != null)
              AmountRow(label: 'Subtotal', amount: payment.subtotal!),
            if (payment.payableDeliveryFee != null ||
                payment.deliveryFee != null)
              AmountRow(
                label: 'Delivery fee',
                amount: payment.payableDeliveryFee ?? payment.deliveryFee ?? 0,
              ),
            if (payment.serviceFee != null)
              AmountRow(
                label: 'Tax and other fees',
                amount: payment.serviceFee!,
              ),
            if (discount > 0)
              AmountRow(
                label: 'Discount',
                amount: discount,
                isDiscount: true,
              ),
            if (payment.total != null) ...[
              const Gap(6),
              AmountRow(
                label: totalLabel,
                amount: payment.total!,
                emphasized: true,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class OrderItemRow extends StatelessWidget {
  final Item item;

  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final options = optionsOf(item);
    final quantity = item.mealQuantity ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.brand950,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'x$quantity',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand200,
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                item.mealVariant?.meal?.mealName ?? 'Unknown meal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral100,
                ),
              ),
            ),
            const Gap(10),
            if (item.itemPrice != null)
              Text(
                '₦${formatPrice(item.itemPrice!)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral100,
                ),
              ),
          ],
        ),
        if (options.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 38, top: 6),
            child: Column(
              children: [
                for (final option in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral400,
                            ),
                          ),
                        ),
                        if (option.quantity != null)
                          Text(
                            'x${formatQuantity(option.quantity!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A selected option on an order item, read out of the raw payload.
class ItemOption {
  final String label;
  final num? quantity;

  const ItemOption(this.label, this.quantity);
}

/// Order items keep their options untyped, so read them defensively and drop
/// anything that does not carry a readable name.
List<ItemOption> optionsOf(Item item) {
  final raw = item.options ?? const [];
  final options = <ItemOption>[];

  for (final entry in raw) {
    if (entry is! Map) continue;

    final variant = entry['optionItemVariant'];
    String? label;
    if (variant is Map) {
      final optionItem = variant['optionItem'];
      if (optionItem is Map && optionItem['item'] is String) {
        label = optionItem['item'] as String;
      } else if (variant['item'] is String) {
        label = variant['item'] as String;
      }
    } else if (variant is String && variant.isNotEmpty) {
      label = variant;
    }

    if (label == null || label.trim().isEmpty) continue;
    options.add(ItemOption(label.trim(), entry['quantity'] as num?));
  }

  return options;
}

class AmountRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool emphasized;
  final bool isDiscount;

  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.emphasized = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: emphasized ? 15 : 13,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
              color: emphasized ? AppColors.neutral100 : AppColors.neutral500,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}₦${formatPrice(amount)}',
            style: TextStyle(
              fontSize: emphasized ? 16 : 13,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              color: emphasized
                  ? AppColors.brand300
                  : isDiscount
                      ? AppColors.green500
                      : AppColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delivery
// ---------------------------------------------------------------------------

/// Where the order was headed and what the vendor was told.
///
/// The OTP is only worth showing while the handover is still ahead, so a
/// finished order passes [showOtp] as false.
class OrderDeliveryCard extends StatelessWidget {
  final OrderResult order;
  final bool showOtp;

  const OrderDeliveryCard({
    super.key,
    required this.order,
    this.showOtp = true,
  });

  @override
  Widget build(BuildContext context) {
    final otp = showOtp ? order.riderOtp : null;
    final instructions = order.storeMessage?.trim();

    return SectionCard(
      title: 'Delivery',
      child: Column(
        children: [
          DetailRow(
            icon: IconsaxPlusLinear.location,
            label: 'Delivery address',
            value: order.deliveryLocation?.address ?? 'No address provided',
          ),
          DetailRow(
            icon: IconsaxPlusLinear.note_text,
            label: 'Note for the vendor',
            value: (instructions == null || instructions.isEmpty)
                ? 'No instructions'
                : instructions,
            isLast: otp == null,
          ),
          if (otp != null) OtpRow(otp: otp),
        ],
      ),
    );
  }
}

class OtpRow extends StatelessWidget {
  final int otp;

  const OtpRow({super.key, required this.otp});

  @override
  Widget build(BuildContext context) {
    final code = otp.toString().padLeft(4, '0');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brand980,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand950),
      ),
      child: Row(
        children: [
          const Icon(
            IconsaxPlusLinear.password_check,
            size: 20,
            color: AppColors.brand300,
          ),
          const Gap(12),
          const Expanded(
            child: Text(
              'OTP to share with your rider',
              style: TextStyle(fontSize: 13, color: AppColors.neutral400),
            ),
          ),
          Text(
            code,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
              color: AppColors.brand200,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

/// A white card with a small uppercase heading — the unit every section of an
/// order detail page is built from.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.neutral500,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Gap(14),
          child,
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final bool isLast;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brand980,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.brand300),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral500,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral100,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              iconSize: 16,
              splashRadius: 18,
              icon: const Icon(
                IconsaxPlusLinear.copy,
                color: AppColors.neutral500,
              ),
            ),
        ],
      ),
    );
  }
}

/// A soft brand-tinted note used to explain what is happening right now.
class WaitingBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const WaitingBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brand980,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand950),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.brand300),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // The action bar is laid out against the full scaffold height,
              // so this must shrink-wrap rather than fill it.
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand200,
                  ),
                ),
                const Gap(2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral400,
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

/// The back button shared by both order detail app bars.
class OrderDetailBackButton extends StatelessWidget {
  const OrderDetailBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const CircleAvatar(
          backgroundColor: AppColors.brand980,
          child: Icon(IconsaxPlusLinear.arrow_left_1, color: Colors.black),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Groups the amount in thousands, e.g. `12500` -> `12,500`.
String formatPrice(int price) {
  final digits = price.abs().toString();
  final buffer = StringBuffer(price.isNegative ? '-' : '');

  for (var i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  return buffer.toString();
}

String formatQuantity(num quantity) =>
    quantity == quantity.roundToDouble() ? '${quantity.toInt()}' : '$quantity';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// e.g. `Today 2:15 PM`, `Yesterday 9:04 AM`, `12 Jul 7:30 PM`.
String formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final orderDate = DateTime(local.year, local.month, local.day);

  final String dayStr;
  if (orderDate == today) {
    dayStr = 'Today';
  } else if (orderDate == today.subtract(const Duration(days: 1))) {
    dayStr = 'Yesterday';
  } else {
    dayStr = '${local.day.toString().padLeft(2, '0')} '
        '${_months[local.month - 1]}';
  }

  return '$dayStr ${formatTime(local)}';
}

/// e.g. `12 Jul 2025`. Used where the year matters, such as an old order.
String formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${local.day.toString().padLeft(2, '0')} '
      '${_months[local.month - 1]} ${local.year}';
}

String formatTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
}
