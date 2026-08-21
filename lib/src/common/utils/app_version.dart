/// Dotted-numeric version comparison, done on the device.
///
/// The backend decides *whether* an update is warranted; this decides whether
/// the build actually in the user's hand is older than the one being offered.
/// Both have to agree before a popup appears, so a stale version record or a
/// `currentVersion` that never reached the server can't nag someone who is
/// already on the newest build.
library;

/// Compares two versions, returning <0, 0 or >0 the way [Comparable] does.
///
/// Returns `null` when either side can't be read as a version — the caller is
/// expected to fall back on the backend's answer rather than guess, because
/// silently swallowing an unparseable version would disable a compulsory
/// update without saying so.
///
/// Handles the three shapes these versions actually arrive in:
/// - `1.4.2` — plain dotted numeric
/// - `1.4.2-beta` — with a pre-release tag, which sorts *below* `1.4.2`
/// - `1.0.2+27` — Flutter's `version+build`, where the build number is ignored
///
/// Segment counts need not match: `1.4` and `1.4.0` are equal, so a two-part
/// version from the dashboard compares correctly against a three-part build
/// name.
int? compareAppVersions(String? a, String? b) {
  final left = _Version.parse(a);
  final right = _Version.parse(b);
  if (left == null || right == null) return null;
  return left.compareTo(right);
}

/// Whether [latest] is strictly newer than [installed].
///
/// `null` when the comparison can't be made.
bool? isNewerVersion({required String? latest, required String? installed}) {
  final result = compareAppVersions(latest, installed);
  return result == null ? null : result > 0;
}

class _Version implements Comparable<_Version> {
  const _Version(this.numbers, this.preRelease);

  final List<int> numbers;

  /// Empty for a final release. A version carrying one is older than the same
  /// version without — `1.4.2-beta` precedes `1.4.2`.
  final List<String> preRelease;

  static _Version? parse(String? raw) {
    var value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    // Flutter build metadata (`1.0.2+27`) says nothing about ordering here —
    // two builds of the same version are the same version as far as the update
    // prompt is concerned.
    final plus = value.indexOf('+');
    if (plus != -1) value = value.substring(0, plus);

    var preRelease = const <String>[];
    final dash = value.indexOf('-');
    if (dash != -1) {
      preRelease = value
          .substring(dash + 1)
          .split('.')
          .where((part) => part.isNotEmpty)
          .toList();
      value = value.substring(0, dash);
    }

    final parts = value.split('.');
    final numbers = <int>[];
    for (final part in parts) {
      final number = int.tryParse(part.trim());
      if (number == null || number < 0) return null;
      numbers.add(number);
    }
    if (numbers.isEmpty) return null;

    return _Version(numbers, preRelease);
  }

  @override
  int compareTo(_Version other) {
    // Compare position by position, treating a missing segment as 0 so `1.4`
    // and `1.4.0` come out equal.
    final length =
        numbers.length > other.numbers.length ? numbers.length : other.numbers.length;
    for (var i = 0; i < length; i++) {
      final mine = i < numbers.length ? numbers[i] : 0;
      final theirs = i < other.numbers.length ? other.numbers[i] : 0;
      if (mine != theirs) return mine.compareTo(theirs);
    }

    if (preRelease.isEmpty && other.preRelease.isEmpty) return 0;
    // A pre-release is older than the release it leads up to.
    if (preRelease.isEmpty) return 1;
    if (other.preRelease.isEmpty) return -1;

    for (var i = 0; i < preRelease.length && i < other.preRelease.length; i++) {
      final mine = preRelease[i];
      final theirs = other.preRelease[i];
      if (mine == theirs) continue;

      final mineNumber = int.tryParse(mine);
      final theirsNumber = int.tryParse(theirs);
      // Numeric identifiers order numerically and rank below alphanumeric ones,
      // so `1.4.2-rc.2` beats `1.4.2-rc.10` on neither count.
      if (mineNumber != null && theirsNumber != null) {
        return mineNumber.compareTo(theirsNumber);
      }
      if (mineNumber != null) return -1;
      if (theirsNumber != null) return 1;
      return mine.compareTo(theirs);
    }

    // Everything shared matched; the one with more identifiers is the later.
    return preRelease.length.compareTo(other.preRelease.length);
  }
}
