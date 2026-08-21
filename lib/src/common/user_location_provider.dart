import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A plain lat/lng pair, in decimal degrees.
///
/// Deliberately not the GeoJSON `[lng, lat]` list the API stores on the user —
/// that ordering is the source of enough confusion already, so it is unpacked
/// once, at the edge, into named fields.
class Coordinates {
  const Coordinates({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinates && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'Coordinates(lat: $lat, lng: $lng)';
}

const _coordinatesCacheKey = 'user_coordinates';

final userLocationProvider =
    StateNotifierProvider<UserLocationController, Coordinates?>((ref) {
  return UserLocationController();
});

/// The coordinates the homepage requests should carry: the delivery address
/// the user set, restored from the cache on launch.
final effectiveCoordinatesProvider = Provider<Coordinates?>((ref) {
  return ref.watch(userLocationProvider);
});

/// The user's delivery location.
///
/// Whatever address the user set is what every location-aware request uses —
/// the handset's own position is never consulted, so the feed does not move
/// around under someone ordering food to an address they are not standing at.
///
/// The last known pair is cached in Hive, which is what lets the first request
/// after a cold start go out already located instead of waiting on the profile
/// response.
class UserLocationController extends StateNotifier<Coordinates?> {
  UserLocationController() : super(_readCache());

  static Coordinates? _readCache() {
    final cached = Hive.box('data').get(_coordinatesCacheKey);
    if (cached is! Map) return null;
    final lat = (cached['lat'] as num?)?.toDouble();
    final lng = (cached['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return Coordinates(lat: lat, lng: lng);
  }

  /// Adopt the delivery address saved on the profile. [coordinates] is the
  /// GeoJSON `[lng, lat]` list the API returns.
  ///
  /// A profile that carries no location leaves the cached pair alone: losing
  /// the coordinates we already had would send the next request out unlocated
  /// for no gain.
  void setProfileCoordinates(List<double>? coordinates) {
    if (coordinates == null || coordinates.length < 2) return;
    final updated = Coordinates(lat: coordinates[1], lng: coordinates[0]);
    if (state == updated) return;
    state = updated;
    Hive.box('data').put(
      _coordinatesCacheKey,
      {'lat': updated.lat, 'lng': updated.lng},
    );
  }
}
