import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 77;

final _russia = const SmartRoutingProps(enabled: true).applyPreset('ru');

Future<void> _reveal(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
  Finder? scrollable,
}) async {
  final list = scrollable ?? find.byType(Scrollable).first;
  await tester.scrollUntilVisible(finder, delta, scrollable: list);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  // The studio floats its app bar over the scroll content, so a row aligned to
  // the viewport top lands under the bar and won't hit-test. Nudge it clear.
  final top = tester.getRect(finder).top;
  if (top < 120) {
    await tester.drag(list, Offset(0, 120 - top));
    await tester.pumpAndSettle();
  }
}

Future<void> _openDrill(WidgetTester tester, String title) async {
  await _reveal(tester, find.text(title));
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required SmartRoutingProps props,
  Profile? profile,
  Size size = const Size(420, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: profile == null
        ? const []
        : [
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            currentProfileIdProvider.overrideWithBuild((_, _) => _profileId),
          ],
  );
  addTearDown(container.dispose);
  container.read(viewSizeProvider.notifier).update((_) => size);
  // The view gates its tuning surfaces on `unlocked`; an active config always
  // migrates enabled⇒unlocked, so mirror that invariant for in-memory props.
  container.read(smartRoutingSettingProvider.notifier).value = props.copyWith(
    unlocked: props.unlocked || props.enabled,
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        includeNavigatorKey: true,
        child: RoutingStudioView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('a disabled engine offers only the switch and an off hint', (
    tester,
  ) async {
    await _pump(tester, props: const SmartRoutingProps());

    expect(find.text('Smart routing'), findsWidgets);
    expect(find.byType(ExperimentalBadge), findsOneWidget);
    expect(
      find.text('Turn smart routing on to let it pick servers for you'),
      findsOneWidget,
    );
    expect(find.text('Strategy'), findsNothing);
    expect(find.text('Comparison ladder'), findsNothing);
    expect(find.text('When to switch'), findsNothing);
  });

  testWidgets('enabling asks for experimental consent first', (tester) async {
    final container = await _pump(tester, props: const SmartRoutingProps());

    await tester.tap(find.byType(Switch), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(ExperimentalNoticeDialog), findsOneWidget);
    expect(container.read(smartRoutingSettingProvider).unlocked, isFalse);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(smartRoutingSettingProvider).unlocked, isFalse);

    await tester.tap(find.byType(Switch), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable anyway'));
    await tester.pumpAndSettle();
    expect(container.read(smartRoutingSettingProvider).unlocked, isTrue);
  });

  testWidgets('the decision core stays inline on the master list', (
    tester,
  ) async {
    await _pump(tester, props: _russia);

    for (final label in [
      'Strategy',
      'Allowed to compete',
      'Comparison ladder',
    ]) {
      await _reveal(tester, find.text(label));
      expect(find.text(label), findsWidgets, reason: 'missing core: $label');
    }
  });

  testWidgets('every later stage shows as a drill-in row', (tester) async {
    await _pump(tester, props: _russia);

    for (final label in [
      'When to switch',
      'Timing',
      'Signals',
      'Service routes',
      'Behaviour',
      'Backup',
      'Routing log',
    ]) {
      await _reveal(tester, find.text(label));
      expect(find.text(label), findsWidgets, reason: 'missing row: $label');
    }
  });

  testWidgets('the comparison ladder sits inline, not behind a page', (
    tester,
  ) async {
    await _pump(tester, props: _russia);

    await _reveal(tester, find.textContaining('Hold a step to move it'));
    expect(find.textContaining('Hold a step to move it'), findsOneWidget);
  });

  testWidgets('the switch-trigger knobs open from their drill row', (
    tester,
  ) async {
    await _pump(tester, props: _russia);

    await _openDrill(tester, 'When to switch');
    expect(find.text('Faster by at least'), findsOneWidget);
  });

  testWidgets('the cadence knobs open from the pace drill row', (tester) async {
    await _pump(tester, props: _russia);

    await _openDrill(tester, 'Timing');
    expect(find.text('Servers per check'), findsOneWidget);
  });

  testWidgets('the measurement inputs open from the signals drill row', (
    tester,
  ) async {
    await _pump(tester, props: _russia);

    await _openDrill(tester, 'Signals');
    expect(find.text('Reachability probes'), findsOneWidget);
  });

  testWidgets('picking a strategy inline updates the engine', (tester) async {
    final container = await _pump(tester, props: _russia);

    await _reveal(tester, find.text('Saver'));
    await tester.tap(find.text('Saver'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.strategy, SmartRoutingStrategy.saver);
    expect(props.dwellSeconds, SmartRoutingStrategy.saver.pacing.dwellSeconds);
  });

  testWidgets('the diagnostics toggle persists from the behaviour page', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      props: const SmartRoutingProps(enabled: true, preset: 'ru'),
    );

    await _openDrill(tester, 'Behaviour');
    await tester.tap(find.text('Diagnostics logging'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).smartRoutingDiagnostics, isTrue);
  });

  testWidgets('a service route toggle persists in the active profile', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'profile').copyWith(id: _profileId);
    final container = await _pump(
      tester,
      props: const SmartRoutingProps(enabled: true, preset: 'ru'),
      profile: profile,
    );

    await _openDrill(tester, 'Service routes');
    await tester.tap(find.text('Gemini access'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Use service route'));
    await tester.pumpAndSettle();

    final updated = container.read(currentProfileProvider)!;
    expect(
      updated.serviceRoutePolicies
          .singleWhere((policy) => policy.capabilityId == 'gemini-access')
          .enabled,
      isTrue,
    );
  });
}
