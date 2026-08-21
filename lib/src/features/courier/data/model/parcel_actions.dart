import 'dart:convert';

/// What the caller may do with a parcel right now — `GET /parcels/:id/actions`.
///
/// **Drive every action button from this, not from a status switch.** The list
/// arrives already filtered to what this caller, in this role, may do from the
/// current status. Transition rules are a backend concern and will change; a
/// hardcoded status list or role table in the app goes stale silently.
class ParcelActions {
  final String? status;

  /// Backend copy for the current status, e.g. "Payment confirmed, finding you
  /// a rider". Render it rather than mapping the status to a string here.
  final String? statusDescription;

  final bool canCancel;
  final List<ParcelAction> actions;

  const ParcelActions({
    this.status,
    this.statusDescription,
    this.canCancel = false,
    this.actions = const [],
  });

  static const ParcelActions none = ParcelActions();

  /// The cancel entry, if the caller has one. Pulled out because cancelling
  /// goes through its own endpoint (`POST /parcels/:id/cancel`) rather than the
  /// generic status transition.
  ParcelAction? get cancelAction {
    final match = actions.where((a) => a.status == 'cancelled');
    return match.isEmpty ? null : match.first;
  }

  /// Whether the parcel is still waiting to be paid for.
  ///
  /// The one place a status is read directly. Payment is not a lifecycle
  /// transition, so it never appears in [actions] — a `pending` parcel comes
  /// back with cancel as its only entry — yet the sender still has to be able
  /// to pay for it from the details screen. `processing` is deliberately
  /// excluded: a charge is already in flight there, and offering a second one
  /// invites a double payment.
  bool get awaitingPayment => status == 'pending';

  /// Everything except cancel — the forward moves through the lifecycle.
  List<ParcelAction> get advanceActions =>
      actions.where((a) => a.status != 'cancelled').toList();

  /// Statuses a parcel sits in before any rider has taken it on.
  ///
  /// `received` and `ready` are the old shared-flow spellings of `paid`.
  static const Set<String> _beforeRiderAccepts = {
    'pending',
    'processing',
    'paid',
    'received',
    'ready',
  };

  /// Whether no rider has accepted the parcel yet, from [status] alone.
  ///
  /// The sender may always cancel up to that point, so this backs the cancel
  /// button when the backend's own answer is unavailable — the actions call
  /// failed, or came back without a cancel entry. It is a deliberate second
  /// copy of a backend rule, kept because the alternative is a sender stranded
  /// with an uncancellable parcel that no rider has even looked at; the
  /// backend still has the last word, and refuses the call with its own
  /// message if this is ever wrong.
  ///
  /// Only the pre-rider window is duplicated. Cancelling from `accepted` or
  /// `rider_arrived_for_pickup` is the backend's call alone, since whether a
  /// rider already en route may be stood down is exactly the kind of rule that
  /// moves.
  static bool cancellableBeforeRider(String? status) =>
      status != null && _beforeRiderAccepts.contains(status);

  /// [cancellableBeforeRider] for this response's own status.
  bool get cancellableByStatus => cancellableBeforeRider(status);

  factory ParcelActions.fromMap(Map<String, dynamic> data) {
    final root = _payloadOf(data);
    final actions = (root['actions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ParcelAction.fromMap)
        .toList();

    return ParcelActions(
      status: root['status'] as String?,
      statusDescription: root['statusDescription'] as String? ??
          root['status_description'] as String?,
      // The flag is the backend's answer, but its absence is not a "no". A
      // response that lists a cancel action and omits `canCancel` still means
      // the caller may cancel, and reading the missing flag as false is what
      // hides the button entirely.
      canCancel: _asBool(root['canCancel']) ??
          actions.any((a) => a.status == 'cancelled'),
      actions: actions,
    );
  }

  /// The object the action fields actually live on.
  ///
  /// Callers hand this whatever the request helper unwrapped, which is usually
  /// the response's `data`. Some responses nest one level further — under
  /// `data` again, or under `parcel` — and a wrapper has none of the fields
  /// read here, so descend rather than parse an envelope into an empty
  /// [ParcelActions] with cancel switched off.
  static Map<String, dynamic> _payloadOf(Map<String, dynamic> data) {
    const keys = ['actions', 'canCancel', 'statusDescription'];
    if (keys.any(data.containsKey)) return data;

    for (final key in ['data', 'parcel', 'result']) {
      final nested = data[key];
      if (nested is Map<String, dynamic> && keys.any(nested.containsKey)) {
        return nested;
      }
    }
    return data;
  }

  /// A JSON boolean that may have arrived as `"true"` or `1`. Null when the
  /// key is absent, so a missing flag stays distinguishable from a false one.
  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalised = value.trim().toLowerCase();
      if (normalised == 'true') return true;
      if (normalised == 'false') return false;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'statusDescription': statusDescription,
        'canCancel': canCancel,
        'actions': actions.map((a) => a.toMap()).toList(),
      };

  factory ParcelActions.fromJson(String data) =>
      ParcelActions.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelActions copyWith({
    String? status,
    String? statusDescription,
    bool? canCancel,
    List<ParcelAction>? actions,
  }) =>
      ParcelActions(
        status: status ?? this.status,
        statusDescription: statusDescription ?? this.statusDescription,
        canCancel: canCancel ?? this.canCancel,
        actions: actions ?? this.actions,
      );

  @override
  String toString() =>
      'ParcelActions(status: $status, canCancel: $canCancel, actions: '
      '${actions.length})';
}

/// One transition the caller may make.
class ParcelAction {
  /// The status this action moves the parcel to.
  final String? status;

  /// Backend-supplied button copy.
  final String? label;

  /// Show a confirmation step before firing this one.
  final bool requiresConfirmation;

  const ParcelAction({
    this.status,
    this.label,
    this.requiresConfirmation = false,
  });

  factory ParcelAction.fromMap(Map<String, dynamic> data) => ParcelAction(
        status: data['status'] as String?,
        label: data['label'] as String?,
        requiresConfirmation: data['requiresConfirmation'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'label': label,
        'requiresConfirmation': requiresConfirmation,
      };

  factory ParcelAction.fromJson(String data) =>
      ParcelAction.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelAction copyWith({
    String? status,
    String? label,
    bool? requiresConfirmation,
  }) =>
      ParcelAction(
        status: status ?? this.status,
        label: label ?? this.label,
        requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      );

  @override
  String toString() => 'ParcelAction(status: $status, label: $label)';
}
