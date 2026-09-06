import 'package:fazt_order/src/common/utils/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareAppVersions', () {
    test('orders plain dotted versions', () {
      expect(compareAppVersions('1.4.0', '1.3.0'), greaterThan(0));
      expect(compareAppVersions('1.3.0', '1.4.0'), lessThan(0));
      expect(compareAppVersions('1.4.0', '1.4.0'), 0);
      expect(compareAppVersions('1.10.0', '1.9.0'), greaterThan(0));
      expect(compareAppVersions('2.0.0', '1.99.99'), greaterThan(0));
    });

    test('treats missing segments as zero', () {
      expect(compareAppVersions('1.4', '1.4.0'), 0);
      expect(compareAppVersions('1.4.1', '1.4'), greaterThan(0));
    });

    test('ignores Flutter build metadata', () {
      expect(compareAppVersions('1.0.2+27', '1.0.2+9'), 0);
      expect(compareAppVersions('1.0.3+1', '1.0.2+99'), greaterThan(0));
    });

    test('sorts a pre-release below its release', () {
      expect(compareAppVersions('1.4.2-beta', '1.4.2'), lessThan(0));
      expect(compareAppVersions('1.4.2', '1.4.2-beta'), greaterThan(0));
      expect(compareAppVersions('1.4.2-beta', '1.4.1'), greaterThan(0));
    });

    test('orders numeric pre-release identifiers numerically', () {
      expect(compareAppVersions('1.4.2-rc.10', '1.4.2-rc.2'), greaterThan(0));
      expect(compareAppVersions('1.4.2-rc.2', '1.4.2-rc.2'), 0);
    });

    test('returns null rather than guessing at unreadable input', () {
      expect(compareAppVersions(null, '1.0.0'), isNull);
      expect(compareAppVersions('1.0.0', null), isNull);
      expect(compareAppVersions('', '1.0.0'), isNull);
      expect(compareAppVersions('latest', '1.0.0'), isNull);
      expect(compareAppVersions('1.x.0', '1.0.0'), isNull);
    });
  });

  group('isNewerVersion', () {
    test('reports a genuine upgrade', () {
      expect(isNewerVersion(latest: '1.4.0', installed: '1.3.0'), isTrue);
    });

    test('reports no upgrade when already current or ahead', () {
      expect(isNewerVersion(latest: '1.4.0', installed: '1.4.0'), isFalse);
      expect(isNewerVersion(latest: '1.4.0', installed: '1.5.0'), isFalse);
      // A local build ahead of the store's, e.g. an internal release.
      expect(isNewerVersion(latest: '1.4.0', installed: '1.4.0+31'), isFalse);
    });

    test('is null when it cannot tell', () {
      expect(isNewerVersion(latest: null, installed: '1.0.0'), isNull);
    });
  });
}
