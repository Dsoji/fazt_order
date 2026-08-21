import 'dart:convert';

/// The outcome of the one-grant-per-device new-customer promo, as it comes back
/// on `POST /auth/signup` (`data.newCustomerPromotion`, present only for
/// `role: user` signups) and, in the same shape minus the grant, from
/// `POST /auth/new-customer-promo/eligibility`.
///
/// **Signup succeeds either way.** A `granted: false` is not a failed
/// registration and must never trigger a retry — the account already exists,
/// and a second attempt fails on the duplicate email.
class NewCustomerPromotion {
  /// Whether this account actually got the promo.
  final bool granted;

  /// The refusal reason: this handset has already claimed it once. Signing out
  /// and creating another account on the same device is exactly the loop this
  /// closes.
  final bool deviceLocked;

  /// Present only when there is something to say — `granted: true` carries no
  /// message. Dashboard-editable, so show it verbatim rather than substituting
  /// copy of our own.
  final String? message;

  /// Only on the eligibility endpoint: whether a signup from this device would
  /// be granted the promo.
  final bool? eligible;

  /// Only on the eligibility endpoint: a machine-readable reason string.
  final String? reason;

  const NewCustomerPromotion({
    this.granted = false,
    this.deviceLocked = false,
    this.message,
    this.eligible,
    this.reason,
  });

  /// What to assume when the block is absent, which is the normal case for a
  /// non-`user` signup. Nothing to show, nothing to grey out.
  static const NewCustomerPromotion unknown = NewCustomerPromotion();

  /// Whether the signup screen should offer the promo at all. Absent
  /// eligibility means we never asked, so the promo stays on show — failing
  /// open here only risks a refusal the user sees later, whereas failing closed
  /// would hide a promo they are entitled to.
  bool get isOffered => eligible ?? true;

  /// Something worth putting in front of the user.
  bool get hasMessage => (message ?? '').trim().isNotEmpty;

  factory NewCustomerPromotion.fromMap(Map<String, dynamic> data) =>
      NewCustomerPromotion(
        granted: data['granted'] as bool? ?? false,
        deviceLocked: data['deviceLocked'] as bool? ?? false,
        message: data['message'] as String?,
        eligible: data['eligible'] as bool?,
        reason: data['reason'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'granted': granted,
        'deviceLocked': deviceLocked,
        'message': message,
        'eligible': eligible,
        'reason': reason,
      };

  factory NewCustomerPromotion.fromJson(String data) =>
      NewCustomerPromotion.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  NewCustomerPromotion copyWith({
    bool? granted,
    bool? deviceLocked,
    String? message,
    bool? eligible,
    String? reason,
  }) =>
      NewCustomerPromotion(
        granted: granted ?? this.granted,
        deviceLocked: deviceLocked ?? this.deviceLocked,
        message: message ?? this.message,
        eligible: eligible ?? this.eligible,
        reason: reason ?? this.reason,
      );

  @override
  String toString() => 'NewCustomerPromotion(granted: $granted, deviceLocked: '
      '$deviceLocked, eligible: $eligible, reason: $reason)';
}
