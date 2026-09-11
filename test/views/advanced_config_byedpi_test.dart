import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpAdvancedConfig(
    WidgetTester tester, {
    required bool supported,
    required bool developerMode,
  }) async {
    final container = ProviderContainer(
      overrides: [
        byeDpiSupportedProvider.overrideWithValue(supported),
        appSettingProvider.overrideWithBuild(
          (_, _) => AppSettingProps(developerMode: developerMode),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AdvancedConfigView()),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows ByeDPI without developer mode on supported platforms', (
    tester,
  ) async {
    await pumpAdvancedConfig(tester, supported: true, developerMode: false);

    expect(find.text('DPI bypass'), findsOneWidget);
  });

  testWidgets('hides ByeDPI on unsupported platforms', (tester) async {
    await pumpAdvancedConfig(tester, supported: false, developerMode: true);

    expect(find.text('DPI bypass'), findsNothing);
  });

  test('ignores saved ByeDPI state on unsupported platforms', () {
    final container = ProviderContainer(
      overrides: [
        byeDpiSupportedProvider.overrideWithValue(false),
        desyncSettingProvider.overrideWithBuild(
          (_, _) => const DesyncProps(enabled: true, onlyDpi: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(effectiveDesyncSettingProvider), defaultDesyncProps);
  });
}
