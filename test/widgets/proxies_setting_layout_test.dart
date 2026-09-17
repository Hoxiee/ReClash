import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/proxies/setting.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<Profile>? profiles,
  Size size = const Size(360, 800),
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(
        profiles == null ? TestProfiles.new : () => TestProfiles(profiles),
      ),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

Future<void> _pumpSetting(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: Scaffold(body: ProxiesSetting())),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('chip rows wrap without horizontal scroll at side-sheet width', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpSetting(tester, container);

    expect(find.byType(ProxiesSetting), findsOneWidget);
    expect(tester.takeException(), isNull);

    final scrollers = tester.widgetList<SingleChildScrollView>(
      find.descendant(
        of: find.byType(ProxiesSetting),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scrollers, isNotEmpty);
    for (final scroller in scrollers) {
      expect(scroller.scrollDirection, Axis.vertical);
    }

    final wraps = tester.widgetList<Wrap>(
      find.descendant(
        of: find.byType(ProxiesSetting),
        matching: find.byType(Wrap),
      ),
    );
    expect(wraps.length, greaterThanOrEqualTo(4));
    for (final wrap in wraps) {
      expect(wrap.runSpacing, 8);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a wrapped chip still updates the style', (tester) async {
    final container = _containerFor(tester);
    await _pumpSetting(tester, container);

    expect(
      container.read(proxiesStyleSettingProvider).layout,
      ProxiesLayout.standard,
    );

    await tester.tap(find.byType(SettingTextCard).first);
    await tester.pump();

    expect(
      container.read(proxiesStyleSettingProvider).layout,
      ProxiesLayout.values.first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('provider block renders as a rounded section card', (
    tester,
  ) async {
    final profile = Profile.normal().copyWith(
      panelMeta: const PanelMeta(proxiesView: 'type:list'),
    );
    final container = _containerFor(tester, profiles: [profile]);
    container.read(currentProfileIdProvider.notifier).value = profile.id;
    await _pumpSetting(tester, container);

    final panelItem = find.byType(DecorationListItem);
    expect(panelItem, findsOneWidget);
    expect(
      find.ancestor(of: panelItem, matching: find.byType(SettingSection)),
      findsOneWidget,
    );
    expect(find.byType(Switch), findsOneWidget);

    await tester.ensureVisible(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(container.read(proxiesStyleSettingProvider).followPanel, isFalse);
    expect(tester.takeException(), isNull);
  });
}
