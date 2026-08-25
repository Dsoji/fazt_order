/// One row of `GET /notifications/pending-popups` — a notification the backend
/// flagged `data.popup: true`, i.e. one that must be acknowledged, not just
/// listed.
///
/// Wallet credit/debit and order-cancelled rows all share this shape; the
/// per-kind fields sit in [data].
class AppPopup {
  const AppPopup({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data = const {},
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;

  /// Order-cancelled popups carry the canceller's reason as its own field so it
  /// can sit on a separate line instead of being folded into [message].
  String? get reason => _text(data['reason']);

  String? get orderId => _text(data['orderId']);

  /// `vendor`, `manager` or `admin`.
  String? get cancelledByRole => _text(data['cancelledByRole']);

  bool get isOrderCancelled => type == 'order' && data['reason'] != null;

  factory AppPopup.fromMap(Map<String, dynamic> map) => AppPopup(
        id: (map['id'] ?? map['_id'] ?? '').toString(),
        type: (map['type'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        message: (map['message'] ?? '').toString(),
        data: map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : const {},
      );

  static String? _text(dynamic v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty ? null : s;
  }
}
