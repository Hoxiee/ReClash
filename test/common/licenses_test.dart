import 'package:reclash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerAppLicenses adds every hand-bundled license', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    LicenseRegistry.reset();
    addTearDown(LicenseRegistry.reset);

    await registerAppLicenses();
    final packages = await LicenseRegistry.licenses
        .expand((entry) => entry.packages)
        .toSet();

    expect(packages, containsAll(['ReClash', 'mihomo (ReClash core)']));
    expect(packages, containsAll(['JetBrains Mono', 'Twemoji Mozilla']));
    expect(packages, contains('@incy/link-encoder'));
  });
}
