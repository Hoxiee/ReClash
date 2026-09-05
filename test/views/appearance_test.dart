import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/appearance/appearance.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 1400);
  });

  tearDown(() => container.dispose());

  Future<void> pumpAppearanceView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AppearanceView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  Finder switchOf(String title) {
    final item = find.ancestor(
      of: find.text(title),
      matching: find.byType(DecorationListItem),
    );
    return find.descendant(of: item, matching: find.byType(Switch)).first;
  }

  ThemeProps readTheme() => container.read(themeSettingProvider);

  testWidgets('every tab renders on a phone-sized view', (tester) async {
    container.read(viewSizeProvider.notifier).value = const Size(360, 800);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AppearanceView()),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Color', 'Layout', 'Motion', 'Theme']) {
      await openTab(tester, label);
      expect(tester.takeException(), isNull, reason: label);
    }
    expect(find.text('Show sidebar labels'), findsNothing);
  });

  group('theme mode', () {
    testWidgets('defaults to the dark theme', (tester) async {
      await pumpAppearanceView(tester);

      expect(readTheme().themeMode, ThemeMode.dark);
    });

    testWidgets('switches to light and back to dark', (tester) async {
      await pumpAppearanceView(tester);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.light);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.dark);

      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.system);
    });
  });

  group('schedule', () {
    testWidgets('enabling it writes the default window', (tester) async {
      await pumpAppearanceView(tester);

      expect(readTheme().scheduledTheme, isFalse);
      expect(find.text('Dark at'), findsNothing);

      await tester.tap(switchOf('Scheduled'));
      await tester.pumpAndSettle();

      expect(readTheme().scheduledTheme, isTrue);
      expect(readTheme().darkAt, '22:00');
      expect(readTheme().lightAt, '07:00');
      expect(find.text('Dark at'), findsOneWidget);
      expect(find.text('Light at'), findsOneWidget);
    });
  });

  group('pure black', () {
    testWidgets('toggles both ways', (tester) async {
      await pumpAppearanceView(tester);
      final toggle = switchOf('Pure black mode');

      expect(readTheme().pureBlack, isFalse);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isTrue);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isFalse);
    });
  });

  group('dashboard style', () {
    testWidgets('selecting the new dashboard writes the setting', (
      tester,
    ) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Layout');

      expect(container.read(appSettingProvider).newDashboard, isTrue);

      await tester.tap(find.text('Classic'));
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).newDashboard, isFalse);

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).newDashboard, isTrue);
    });
  });

  group('text scale', () {
    testWidgets('is disabled until its toggle is enabled', (tester) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Layout');

      expect(readTheme().textScale.enable, isFalse);

      await tester.tap(switchOf('Text scaling'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isTrue);
    });

    testWidgets('the slider writes a new scale once enabled', (tester) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Layout');
      await tester.tap(switchOf('Text scaling'));
      await tester.pumpAndSettle();
      final before = readTheme().textScale.scale;

      final slider = find.descendant(
        of: find.byType(DisabledMask),
        matching: find.byType(Slider),
      );
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.scale, isNot(before));
    });

    testWidgets('renders the scale as a rounded percentage', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith.textScale(enable: true, scale: 1.2),
          );

      await pumpAppearanceView(tester);
      await openTab(tester, 'Layout');

      expect(find.text('120%'), findsOneWidget);
    });
  });

  group('motion', () {
    testWidgets('reduce motion is left to the user', (tester) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Motion');

      expect(container.read(appSettingProvider).reduceMotion, isFalse);

      await tester.tap(switchOf('Reduce motion'));
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).reduceMotion, isTrue);
    });
  });
}
