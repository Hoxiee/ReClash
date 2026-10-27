import 'package:reclash/ui/switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/widgets/update_preferences.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/provider_settings.dart';
import 'package:reclash/widgets/provider_setting.dart';

import '../helpers/test_profiles.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/config/general.dart';
import 'package:reclash/views/developer.dart';

import '../helpers/test_app.dart';

class _PersistingSetupSession extends SetupSession {
  @override
  Future<bool> saveConfig(Config config) async => true;
}

class _TestProviderSettingsAction extends ProviderSettingsAction {
  const _TestProviderSettingsAction(super.ref, this.shouldFail);

  final bool Function() shouldFail;

  @override
  void returnToProvider([Iterable<String>? ids]) {
    if (shouldFail()) throw StateError('provider return failed');
    super.returnToProvider(ids);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late String previousAppEnv;
  ProviderSettingsInput? providerInput;
  var failReturning = false;

  setUp(() {
    previousAppEnv = globalState.appEnv;
    globalState.appEnv = 'stable';
    providerInput = null;
    failReturning = false;
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        detectedRegionProvider.overrideWith((ref) async => null),
        setupSessionProvider.overrideWith(_PersistingSetupSession.new),
        providerSettingsInputProvider.overrideWith((ref) => providerInput),
        providerSettingsActionProvider.overrideWith(
          (ref) => _TestProviderSettingsAction(ref, () => failReturning),
        ),
      ],
    );
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    container.listen(patchClashConfigProvider, (_, _) {});
    container.listen(configProvider, (_, _) {});
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1800));
  });

  tearDown(() {
    container.dispose();
    globalState.appEnv = previousAppEnv;
  });

  void setProviderSettings({bool released = true}) {
    providerInput = ProviderSettingsInput(
      ProviderHints(
        readSubscriptionMetadata({
          'reclash-view': ['proxies.type:list;app.black:true'],
        }).metadata,
      ),
    );
    container.invalidate(providerSettingsInputProvider);
    final applied = applyProviderSettings(
      container.read(configProvider),
      providerInput!,
    );
    container.read(providerSettingsProvider.notifier).value =
        applied.providerSettings;
    container.read(proxiesStyleSettingProvider.notifier).value = applied
        .proxiesStyleProps
        .copyWith(type: released ? ProxiesType.tab : ProxiesType.list);
    container.read(themeSettingProvider.notifier).value = applied.themeProps
        .copyWith(pureBlack: !released);
  }

  Future<void> pumpApplication(WidgetTester tester) async {
    const size = Size(412, 915);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openProviderReturn(WidgetTester tester) async {
    final button = find.text('Return settings to provider');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('provider return is hidden without overridden settings', (
    tester,
  ) async {
    await pumpApplication(tester);
    expect(find.text('Return settings to provider'), findsNothing);

    setProviderSettings(released: false);
    await tester.pumpAndSettle();
    expect(find.text('Return settings to provider'), findsNothing);
  });

  testWidgets('confirmed provider return resets all settings after scrolling', (
    tester,
  ) async {
    setProviderSettings();
    container
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            generalOverrideKeys: {GeneralOverrideKey.ipv6},
            dnsOverrideKeys: {DnsOverrideKey.nameserver},
            tunOverrideKeys: {TunOverrideKey.mtu},
          ),
        );
    container
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            accessControlProps: state.accessControlProps.copyWith(
              acceptReleased: ['com.provider.included'],
              rejectReleased: ['com.provider.excluded'],
            ),
          ),
        );
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(onlyStatisticsProxy: true));
    await pumpApplication(tester);
    expect(find.text('Return settings to provider'), findsOneWidget);

    await openProviderReturn(tester);
    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.tab);
    expect(container.read(themeSettingProvider).pureBlack, isFalse);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.list);
    expect(container.read(themeSettingProvider).pureBlack, isTrue);
    expect(container.read(appSettingProvider).onlyStatisticsProxy, isTrue);
    expect(container.read(providerSettingsProvider).userOwned, isEmpty);
    expect(
      container.read(patchClashConfigProvider).generalOverrideKeys,
      isEmpty,
    );
    expect(container.read(patchClashConfigProvider).dnsOverrideKeys, isEmpty);
    expect(container.read(patchClashConfigProvider).tunOverrideKeys, isEmpty);
    expect(
      container.read(vpnSettingProvider).accessControlProps.acceptReleased,
      isEmpty,
    );
    expect(
      container.read(vpnSettingProvider).accessControlProps.rejectReleased,
      isEmpty,
    );
    expect(find.text('Return settings to provider'), findsNothing);
  });

  testWidgets(
    'core and app-list overrides alone make provider return available',
    (tester) async {
      setProviderSettings(released: false);
      await pumpApplication(tester);
      expect(find.text('Return settings to provider'), findsNothing);

      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) =>
                state.copyWith(dnsOverrideKeys: {DnsOverrideKey.nameserver}),
          );
      await tester.pumpAndSettle();
      expect(find.text('Return settings to provider'), findsOneWidget);
      await openProviderReturn(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).dnsOverrideKeys, isEmpty);
      expect(find.text('Return settings to provider'), findsNothing);

      container
          .read(vpnSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              accessControlProps: state.accessControlProps.copyWith(
                rejectReleased: ['com.provider.excluded'],
              ),
            ),
          );
      await tester.pumpAndSettle();
      expect(find.text('Return settings to provider'), findsOneWidget);
      await openProviderReturn(tester);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(
        container.read(vpnSettingProvider).accessControlProps.rejectReleased,
        isEmpty,
      );
      expect(find.text('Return settings to provider'), findsNothing);
    },
  );

  testWidgets('provider return is hidden while the active profile loads', (
    tester,
  ) async {
    setProviderSettings();
    providerInput = null;
    container.invalidate(providerSettingsInputProvider);
    await pumpApplication(tester);
    expect(find.text('Return settings to provider'), findsNothing);
    expect(container.read(providerSettingsReturnAvailableProvider), isFalse);
  });

  testWidgets('cancelling provider return keeps user settings', (tester) async {
    setProviderSettings();
    await pumpApplication(tester);
    await openProviderReturn(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.tab);
    expect(container.read(themeSettingProvider).pureBlack, isFalse);
    expect(find.text('Return settings to provider'), findsOneWidget);
  });

  testWidgets('provider return does not reset a newly selected profile', (
    tester,
  ) async {
    setProviderSettings();
    await pumpApplication(tester);
    await openProviderReturn(tester);
    container.read(currentProfileIdProvider.notifier).value = 42;
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.tab);
    expect(container.read(themeSettingProvider).pureBlack, isFalse);
  });

  testWidgets('provider return stops when its settings view is disposed', (
    tester,
  ) async {
    setProviderSettings();
    await pumpApplication(tester);
    await openProviderReturn(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.tab);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed provider return shows an error and allows retry', (
    tester,
  ) async {
    setProviderSettings();
    failReturning = true;
    await pumpApplication(tester);
    await openProviderReturn(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('provider return failed', findRichText: true),
      findsOneWidget,
    );
    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.tab);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    failReturning = false;
    await openProviderReturn(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.list);
    expect(find.text('Return settings to provider'), findsNothing);
  });

  testWidgets(
    'opens independent update preferences from application settings',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ApplicationSettingView()),
        ),
      );
      await tester.pumpAndSettle();
      final row = find.text('Update preferences');
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byType(UpdatePreferences), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    },
  );

  testWidgets('log settings are grouped only in application settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(logLevel: LogLevel.warning));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    final capture = find.text('Logcat');
    final level = find.text('Log level');
    final captureSwitch = find.descendant(
      of: find.widgetWithText(ListTile, 'Logcat'),
      matching: find.byType(CommonSwitch),
    );
    expect(capture, findsOneWidget);
    expect(level, findsOneWidget);
    expect(find.text('warning'), findsOneWidget);
    expect(tester.widget<CommonSwitch>(captureSwitch).value, isFalse);
    await tester.ensureVisible(level);
    await tester.tap(level);
    await tester.pumpAndSettle();
    await tester.tap(find.text('debug'));
    await tester.pumpAndSettle();
    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);
    expect(container.read(appSettingProvider).openLogs, isFalse);

    await tester.ensureVisible(capture);
    await tester.tap(capture);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).openLogs, isTrue);
    expect(tester.widget<CommonSwitch>(captureSwitch).value, isTrue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: GeneralView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(level, findsNothing);
    expect(capture, findsNothing);
    expect(find.text('Logs and diagnostics'), findsNothing);
    expect(find.text('Turning off Logcat hides the logs entry.'), findsNothing);
    expect(container.read(appSettingProvider).openLogs, isTrue);
    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(level, findsOneWidget);
    expect(find.text('debug'), findsOneWidget);
    expect(tester.widget<CommonSwitch>(captureSwitch).value, isTrue);
    await tester.ensureVisible(capture);
    await tester.tap(capture);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).openLogs, isFalse);
    expect(tester.widget<CommonSwitch>(captureSwitch).value, isFalse);
    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);
  });

  testWidgets('reopening setup from developer tools keeps a live run', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(setupCompleted: true));
    container.read(runTimeProvider.notifier).value = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DeveloperView()),
      ),
    );
    await tester.pumpAndSettle();

    final entry = find.text('Set up connection');
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(container.read(setupSessionProvider).active, isTrue);
    expect(container.read(isStartProvider), isTrue);
    expect(container.read(runTimeProvider), 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opens regional adaptation from application settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ApplicationSettingView()),
      ),
    );
    await tester.pumpAndSettle();

    final regionRow = find.text('App region');
    await tester.ensureVisible(regionRow);
    await tester.tap(regionRow);
    await tester.pumpAndSettle();

    expect(find.text('Russia'), findsOneWidget);
  });
}
