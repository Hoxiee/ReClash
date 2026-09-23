import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _appLicenses = {
  'ReClash': 'assets/data/licenses/ReClash-GPL3.txt',
  'mihomo (ReClash core)': 'assets/data/licenses/mihomo-GPL3.txt',
  'JetBrains Mono': 'assets/data/licenses/JetBrainsMono-OFL.txt',
  'Twemoji Mozilla': 'assets/data/licenses/Twemoji.Mozilla-LICENSE.txt',
  '@incy/link-encoder': 'assets/data/licenses/incy-link-encoder-MIT.txt',
};

/// Hand-bundled licenses appear on the license page only via this registration.
Future<void> registerAppLicenses() async {
  await Future.wait([
    for (final entry in _appLicenses.entries)
      rootBundle.loadString(entry.value).then((text) {
        LicenseRegistry.addLicense(
          () => Stream.value(LicenseEntryWithLineBreaks([entry.key], text)),
        );
      }),
  ]);
}
