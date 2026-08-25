import 'package:flutter/material.dart';

/// A small pill that renders an order status with a colour tuned to its meaning.
///
/// Keeps status styling consistent across the Ongoing and Completed order lists
/// so the same status always reads the same way to the user.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.foreground,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _configFor(String? status) {
    switch (status) {
      case 'processing':
        return const _StatusConfig(
            'Processing', Color(0xFFC98100), Color(0xFFFFF3E1));
      case 'paid':
      // Parcels created under the old shared flow can still report `received`.
      case 'received':
        return const _StatusConfig('Paid', Color(0xFF178A0F), Color(0xFFEAF7E8));
      case 'accepted':
        return const _StatusConfig(
            'Accepted', Color(0xFF178A0F), Color(0xFFEAF7E8));
      case 'preparing':
        return const _StatusConfig(
            'Preparing', Color(0xFFC98100), Color(0xFFFFF3E1));
      case 'ready':
        return const _StatusConfig(
            'Ready', Color(0xFFC98100), Color(0xFFFFF3E1));
      case 'rider_arrived_for_pickup':
        return const _StatusConfig(
            'Rider at pickup', Color(0xFF343DFF), Color(0xFFE8E9FF));
      case 'in_transit':
        return const _StatusConfig(
            'In transit', Color(0xFF343DFF), Color(0xFFE8E9FF));
      case 'arrived':
        return const _StatusConfig(
            'Arrived', Color(0xFF343DFF), Color(0xFFE8E9FF));
      case 'delivered':
        return const _StatusConfig(
            'Delivered', Color(0xFF178A0F), Color(0xFFEAF7E8));
      case 'cancelled':
        return const _StatusConfig(
            'Cancelled', Color(0xFFC00100), Color(0xFFFDE8E7));
      case 'rejected':
        return const _StatusConfig(
            'Rejected', Color(0xFFC00100), Color(0xFFFDE8E7));
      case 'refunded':
        return const _StatusConfig(
            'Refunded', Color(0xFF635D60), Color(0xFFF0EEEF));
      default:
        final label = (status == null || status.isEmpty)
            ? 'Unknown'
            : status[0].toUpperCase() + status.substring(1);
        return _StatusConfig(
            label, const Color(0xFF635D60), const Color(0xFFF0EEEF));
    }
  }
}

class _StatusConfig {
  const _StatusConfig(this.label, this.foreground, this.background);

  final String label;
  final Color foreground;
  final Color background;
}
