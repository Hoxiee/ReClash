import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/views/setup/steps/finish.dart';
import 'package:reclash/views/setup/steps/subscription.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _ImportAction extends ProfilesAction {
  static final identities = <bool>[];

  @override
  Future<ProfileImportResult> importProfile(
    ProfileImportRequest request,
  ) async {
    identities.add(ref.read(appSettingProvider).sendDeviceIdentity);
    return const ProfileImportResult.cancelled();
  }
}

Widget _subscription() => SetupSubscriptionStep(onNext: () {}, onBack: () {});
Widget _finish({bool revisit = false}) =>
    SetupFinishStep(onDone: () {}, onBack: () {}, revisit: revisit);

Future<void> _show(
  WidgetTester tester,
  ProviderContainer container,
  Widget child,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(child: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  AppSettingProps settings = const AppSettingProps(),
  SmartRoutingProps routing = const SmartRoutingProps(),
  Widget? child,
}) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      ...buildConfigOverrides(
        Config(
          themeProps: defaultThemeProps,
          appSettingProps: settings,
          smartRoutingProps: routing,
        ),
      ),
      profilesProvider.overrideWith(() => TestProfiles(const [])),
      profilesActionProvider.overrideWith(_ImportAction.new),
    ],
  );
  addTearDown(container.dispose);
  container.listen(configProvider, (_, _) {});
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 1600));
  await _show(tester, container, child ?? _subscription());
  return container;
}

Future<void> _select(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('setup-app-region')).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _import(WidgetTester tester) async {
  await tester.ensureVisible(find.text('URL'));
  await tester.tap(find.text('URL'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'https://example.com/sub');
  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(_ImportAction.identities.clear);

  testWidgets('late import completion ignores a disposed wizard step', (
    tester,
  ) async {
    final container = await _pump(tester);
    final importer = find.byType(AddProfileView);
    final notify = tester.widget<AddProfileView>(importer).onProfileAdded!;
    final owner = ModalRoute.of(tester.element(importer))!;
    await _show(tester, container, const SizedBox());
    expect(owner.isActive, isTrue);
    expect(find.byType(SetupSubscriptionStep), findsNothing);
    notify(const Profile(id: 99, autoUpdateDuration: Duration(days: 1)));
    await tester.pump();
    expect(container.read(appSettingProvider).autoRun, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Russia grants HWID before the first subscription import', (
    tester,
  ) async {
    final container = await _pump(tester);
    final selector = find.byKey(const ValueKey('setup-app-region')).last;
    expect(
      tester.getTopLeft(selector).dy,
      lessThan(tester.getTopLeft(find.text('URL')).dy),
    );
    expect(find.text('Send HWID'), findsOneWidget);

    await _select(tester, 'Russia');
    expect(container.read(smartRoutingSettingProvider).enabled, isFalse);
    await _import(tester);
    expect(_ImportAction.identities, [true]);
  });

  testWidgets('manual HWID off survives rebuilding, navigation and revisit', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _select(tester, 'Russia');
    await tester.tap(find.byKey(const ValueKey('setup-send-hwid')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(locale: 'ru'));
    await tester.pumpAndSettle();
    await _select(tester, 'Russia');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);

    await _show(tester, container, _finish());
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    await _show(tester, container, _subscription());
    await _show(tester, container, _finish(revisit: true));
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    await _show(tester, container, _subscription());
    await _import(tester);
    expect(_ImportAction.identities, [false]);
  });

  testWidgets('HWID off outside Russia applies without confirmation', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _select(tester, 'Russia');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    await _select(tester, 'Iran');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);

    await tester.tap(find.byKey(const ValueKey('setup-send-hwid')).last);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    expect(find.text('Turn off'), findsNothing);
  });

  testWidgets(
    'Other keeps routing independent and supplies operational markers',
    (tester) async {
      final container = await _pump(tester, child: _finish());
      final toggle = find.byKey(const ValueKey('setup-smart-routing')).last;
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      final props = container.read(smartRoutingSettingProvider);
      expect(props.enabled, isTrue);
      expect(props.rcxParams.openMarkers, isNotEmpty);
      expect(props.rcxParams.canaryForeign, isNotEmpty);
      expect(props.censorCountries, isEmpty);
      expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);

      await _show(tester, container, _subscription());
      await _select(tester, 'Iran');
      expect(container.read(smartRoutingSettingProvider).enabled, isTrue);
      await _select(tester, 'Other');
      expect(container.read(smartRoutingSettingProvider).enabled, isTrue);
      expect(
        container.read(smartRoutingSettingProvider).openMarkers,
        isNotEmpty,
      );
    },
  );

  testWidgets('finish preset opens the strategy dialog without enabling', (
    tester,
  ) async {
    final container = await _pump(tester, child: _finish());
    expect(find.text('Geo resources'), findsOneWidget);
    expect(
      find.text('Access control'),
      system.isAndroid ? findsOneWidget : findsNothing,
    );
    await tester.tap(find.text('Preset'));
    await tester.pumpAndSettle();
    expect(find.byType(SmartRoutingView), findsNothing);
    expect(find.text('Saver'), findsOneWidget);
    expect(container.read(smartRoutingSettingProvider).enabled, isFalse);
    expect(container.read(desyncSettingProvider).enabled, isFalse);
  });
}
