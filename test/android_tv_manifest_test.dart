import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android manifest keeps phone and TV launcher contracts', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains(
        '<uses-feature\n        android:name="android.hardware.touchscreen"\n        android:required="false" />',
      ),
    );
    expect(
      manifest,
      contains(
        '<uses-feature\n        android:name="android.software.leanback"\n        android:required="false" />',
      ),
    );
    expect(manifest, contains('android:banner="@mipmap/ic_banner"'));

    final aliases = RegExp(
      r'<activity-alias\b(.*?)</activity-alias>',
      dotAll: true,
    ).allMatches(manifest).map((match) => match.group(1)!).toList();
    expect(aliases, isNotEmpty);
    for (final alias in aliases) {
      expect(alias, contains('android:exported="true"'));
      expect(alias, contains('android.intent.action.MAIN'));
      expect(alias, contains('android.intent.category.LAUNCHER'));
      expect(alias, contains('android.intent.category.LEANBACK_LAUNCHER'));
    }
  });
}
