/// Status vocabularies shared by the order lists.
///
/// Food orders and parcels run separate state machines on the backend, but both
/// come back on the same `orders` feed, so the lists filter on the union of the
/// two. Parcels have no kitchen statuses (`preparing`/`ready`) and add
/// `rider_arrived_for_pickup`; food orders never report that one.
library;

/// Statuses that belong on the Ongoing tab.
///
/// `received` and `ready` only ever appear on parcels created under the old
/// shared flow — a paid parcel now stays `paid` until a rider accepts it, so
/// both are kept purely so legacy rows don't fall out of the list.
const kOngoingOrderStatuses = <String>{
  'processing',
  'paid',
  'received',
  'preparing',
  'accepted',
  'ready',
  'rider_arrived_for_pickup',
  'in_transit',
  'arrived',
};

/// Statuses where the order has left the ongoing flow for good.
///
/// A cancelled parcel that had been paid for comes back as `refunded` once the
/// money has landed in the sender's wallet.
const kCompletedOrderStatuses = <String>{
  'delivered',
  'cancelled',
  'rejected',
  'refunded',
};
