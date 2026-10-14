import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:reclash/views/setup/region.dart';
import 'package:reclash/views/setup/steps/coverage.dart';
import 'package:reclash/views/setup/steps/subscription.dart';

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
Widget _coverage() => SetupCoverageStep(onNext: () {}, onBack: () {});

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
  await tester.tap(find.widgetWithText(TextButton, 'Change').last);
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
    final strip = find.byType(SetupDetectedStrip);
    expect(
      tester.getTopLeft(strip).dy,
      lessThan(tester.getTopLeft(find.text('URL')).dy),
    );

    await _select(tester, 'Russia');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    expect(container.read(smartRoutingSettingProvider).enabled, isFalse);
    await _import(tester);
    expect(_ImportAction.identities, [true]);
  });

  testWidgets('HWID turned off in settings survives later region picks', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _select(tester, 'Russia');
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(sendDeviceIdentity: false));
    await tester.pumpAndSettle();

    await _select(tester, 'Russia');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    await _select(tester, 'Iran');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);

    await _show(tester, container, _coverage());
    await _select(tester, 'Other');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    await _show(tester, container, _subscription());
    await _import(tester);
    expect(_ImportAction.identities, [false]);
  });

  testWidgets('the coverage step hosts the same detected strip', (
    tester,
  ) async {
    final container = await _pump(tester, child: _coverage());

    expect(find.byType(SetupDetectedStrip), findsOneWidget);
    await _select(tester, 'Iran');

    expect(container.read(appSettingProvider).region, 'IR');
    expect(container.read(smartRoutingSettingProvider).preset, 'ir');
    expect(find.textContaining('Detected: Iran'), findsOneWidget);
  });

  testWidgets('Other keeps routing off and supplies operational markers', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _select(tester, 'Iran');
    await _select(tester, 'Other');

    final props = container.read(smartRoutingSettingProvider);
    expect(props.enabled, isFalse);
    expect(props.censorCountries, isEmpty);
    expect(props.openMarkers, isNotEmpty);
    expect(props.rcxParams.canaryForeign, isNotEmpty);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
  });
}
