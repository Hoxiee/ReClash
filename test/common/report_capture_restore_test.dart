import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/preferences.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

import '../helpers/preferences.dart';

Config _config(LogLevel level) => const Config(
  themeProps: defaultThemeProps,
).copyWith.patchClashConfig(logLevel: level);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a capture cut short puts the replaced level back on startup', () async {
    await mockPreferences();
    await preferences.saveReportCaptureRestoreLevel(LogLevel.warning);

    final config = await preferences.restoreReportCaptureLevel(
      _config(LogLevel.debug),
    );

    expect(config.patchClashConfig.logLevel, LogLevel.warning);
    expect(await preferences.getReportCaptureRestoreLevel(), isNull);
    expect(
      (await preferences.getConfig())?.patchClashConfig.logLevel,
      LogLevel.warning,
    );
  });

  test('a level the user changed since stays, and the key clears', () async {
    await mockPreferences();
    await preferences.saveReportCaptureRestoreLevel(LogLevel.warning);

    final config = await preferences.restoreReportCaptureLevel(
      _config(LogLevel.info),
    );

    expect(config.patchClashConfig.logLevel, LogLevel.info);
    expect(await preferences.getReportCaptureRestoreLevel(), isNull);
  });

  test('without a pending capture the config is untouched', () async {
    await mockPreferences();
    final before = _config(LogLevel.debug);

    expect(await preferences.restoreReportCaptureLevel(before), same(before));
  });
}
