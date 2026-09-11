import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/setup/setup.dart';
import 'package:reclash/views/setup/steps/finish.dart';
import 'package:reclash/views/setup/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _ExitingSystemAction extends SystemAction {
  static final List<String> calls = [];

  @override
  Future<void> handleExit([bool needSave = true]) async => calls.add('exit');

  @override
  Future<void> handleClose([bool exit = true]) async => calls.add('close');
}

class _RecordingProfilesAction extends ProfilesAction {
  static final List<ProfileImportRequest> requests = [];
  static final List<int> deletedIds = [];
  static Profile? nextProfile;

  @override
  Future<ProfileImportResult> importProfile(
    ProfileImportRequest request,
  ) async {
    requests.add(request);
    final profile = nextProfile;
    if (profile != null) {
      ref.read(profilesProvider.notifier).put(profile);
      return ProfileImportResult.imported(
        profile,
        const ProfileImportSummary(
          format: ProfileImportFormat.clash,
          nodeCount: 0,
          groupCount: 0,
          hasProviders: false,
        ),
      );
    }
    return const ProfileImportResult.cancelled();
  }

  @override
  Future<void> deleteProfile(int id) async {
    deletedIds.add(id);
    await ref.read(profilesProvider.notifier).del(id);
  }
}

class _RestoringBackupAction extends BackupAction {
  static int prepareCalls = 0;
  static int discardCalls = 0;
  static int applyCalls = 0;
  static RestoreOption? appliedOption;
  static const prepared = PreparedRestore(
    stagingPath: '/tmp/setup-restore',
    data: MigrationData(),
    summary: RestoreSummary(
      profiles: 1,
      scripts: 0,
      rules: 0,
      proxyGroups: 0,
      hasSettings: true,
    ),
  );

  @override
  Future<PreparedRestore?> preparePickedRestore() async {
    prepareCalls++;
    return prepared;
  }

  @override
  Future<void> discardPreparedRestore(PreparedRestore prepared) async {
    discardCalls++;
  }

  @override
  Future<void> applyPreparedRestore(
    PreparedRestore prepared,
    RestoreOption option, {
    RestoreApplyContext context = const RestoreApplyContext(),
  }) async {
    applyCalls++;
    appliedOption = option;
    final restored = ref
        .read(appSettingProvider)
        .copyWith(
          disclaimerAccepted: false,
          crashlyticsTip: false,
          crashlytics: true,
          setupCompleted: true,
          setupStep: 0,
        );
    ref.read(appSettingProvider.notifier).value =
        context.mergeAppSettings?.call(restored) ?? restored;
  }
}

class _TestPermissionGateway implements SetupPermissionGateway {
  bool notificationGranted;
  bool batteryGranted = false;
  Error? notificationCheckError;
  Error? notificationRequestError;
  Error? batteryOpenError;
  Completer<void>? notificationRequest;
  Completer<void>? batteryOpen;
  int notificationChecks = 0;
  int notificationRequests = 0;
  int appSettingsOpens = 0;
  int batterySettingsOpens = 0;
  int batteryChecks = 0;

  _TestPermissionGateway({this.notificationGranted = false});

  @override
  bool get isAndroid => true;

  @override
  Future<bool> isNotificationsPermissionGranted() async {
    notificationChecks++;
    final error = notificationCheckError;
    if (error != null) throw error;
    return notificationGranted;
  }

  @override
  Future<void> requestNotificationsPermission() async {
    notificationRequests++;
    final error = notificationRequestError;
    if (error != null) throw error;
    await notificationRequest?.future;
  }

  @override
  Future<void> openAppSettings() async {
    appSettingsOpens++;
  }

  @override
  Future<void> checkBatteryOptimizationDisable(ProviderReader read) async {
    batteryChecks++;
    read(batteryOptimizationDisableProvider.notifier).value = batteryGranted;
  }

  @override
  Future<void> openBatteryOptimizationSettings() async {
    batterySettingsOpens++;
    final error = batteryOpenError;
    if (error != null) throw error;
    await batteryOpen?.future;
  }
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<Profile> profiles = const [],
  AppSettingProps appSettings = const AppSettingProps(),
  Widget child = const SetupWizard(),
  Size size = const Size(1000, 1600),
  double textScale = 1,
  bool disableAnimations = false,
  Locale? locale,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      appSettingProvider.overrideWithBuild((_, _) => appSettings),
      systemActionProvider.overrideWith(_ExitingSystemAction.new),
      ...overrides,
    ],
  );
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = size;
  addTearDown(container.dispose);
  // Both settings providers are autoDispose; in the app `configProvider` holds
  // them, so the test has to hold them too or a step's write is thrown away.
  container.listen(appSettingProvider, (_, _) {});
  container.listen(smartRoutingSettingProvider, (_, _) {});
  container.listen(networkSettingProvider, (_, _) {});
  container.listen(patchClashConfigProvider, (_, _) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        locale: locale,
        homeBuilder: (child) => MediaQuery(
          data: MediaQueryData(
            size: size,
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child,
        ),
        child: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _toLegal(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

Future<void> _toSubscription(WidgetTester tester) async {
  await _toLegal(tester);
  await tester.tap(find.text('Agree'));
  await tester.pumpAndSettle();
}

Future<void> _toRevisitSubscription(WidgetTester tester) async {
  await _toLegal(tester);
}

Future<void> _toFinish(WidgetTester tester) async {
  await _toSubscription(tester);
  await tester.tap(
    find.widgetWithText(FilledButton, 'Continue without a profile'),
  );
  await tester.pumpAndSettle();
}

ScrollPosition _cardScroll(WidgetTester tester) {
  return tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byType(SetupScrollCard),
          matching: find.byType(Scrollable),
        ),
      )
      .position;
}

Finder _stepScroll() => find.descendant(
  of: find.byType(SetupStepScaffold),
  matching: find.byType(SingleChildScrollView),
);

Future<ProviderContainer> _pumpFinish(
  WidgetTester tester,
  SetupPermissionGateway gateway,
) {
  return _pump(
    tester,
    child: SetupFinishStep(
      permissionGateway: gateway,
      onDone: () {},
      onBack: () {},
    ),
  );
}

void main() {
  setUp(() {
    _ExitingSystemAction.calls.clear();
    _RecordingProfilesAction.requests.clear();
    _RecordingProfilesAction.deletedIds.clear();
    _RecordingProfilesAction.nextProfile = null;
    _RestoringBackupAction.prepareCalls = 0;
    _RestoringBackupAction.discardCalls = 0;
    _RestoringBackupAction.applyCalls = 0;
    _RestoringBackupAction.appliedOption = null;
  });

  testWidgets('the first step picks a language and applies it at once', (
    tester,
  ) async {
    final container = await _pump(tester);

    expect(find.text('Choose your language'), findsOne);
    await tester.tap(find.text('Russian'));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).locale, 'ru');
  });

  testWidgets('the language list scrolls inside its own bounded card', (
    tester,
  ) async {
    await _pump(tester, size: const Size(400, 900));

    expect(_stepScroll(), findsNothing);
    expect(_cardScroll(tester).maxScrollExtent, greaterThan(0));
    expect(find.text('System language'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
  });

  testWidgets('the stored language is scrolled into view on open', (
    tester,
  ) async {
    await _pump(
      tester,
      appSettings: const AppSettingProps(locale: 'zh_CN'),
      size: const Size(400, 900),
    );

    expect(_cardScroll(tester).pixels, greaterThan(0));
    expect(find.text('简体中文'), findsOneWidget);
  });

  testWidgets('a screen too short for a bounded list scrolls as one page', (
    tester,
  ) async {
    await _pump(tester, size: const Size(360, 520), textScale: 1.5);

    expect(_stepScroll(), findsOneWidget);
    expect(_cardScroll(tester).maxScrollExtent, 0);
  });

  testWidgets('refusing the disclaimer exits without recording consent', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toLegal(tester);

    await tester.tap(find.text('Do not agree and exit'));
    await tester.pumpAndSettle();

    expect(_ExitingSystemAction.calls, ['exit']);
    expect(container.read(appSettingProvider).disclaimerAccepted, isFalse);
  });

  testWidgets('agreeing records consent and dismisses the crashlytics tip', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toSubscription(tester);

    final settings = container.read(appSettingProvider);
    expect(settings.disclaimerAccepted, isTrue);
    expect(settings.crashlyticsTip, isTrue);
    expect(find.text('Add a connection profile'), findsOne);
  });

  testWidgets('revisit skips legal and preserves privacy settings', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(
        disclaimerAccepted: true,
        crashlytics: true,
        setupCompleted: true,
      ),
      child: const SetupWizard(revisit: true),
    );
    await _toRevisitSubscription(tester);

    final settings = container.read(appSettingProvider);
    expect(find.text('Before you continue'), findsNothing);
    expect(find.text('Add a connection profile'), findsOneWidget);
    expect(settings.disclaimerAccepted, isTrue);
    expect(settings.crashlytics, isTrue);
  });

  testWidgets('revisit has no consent exit action', (tester) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(
        disclaimerAccepted: true,
        setupCompleted: true,
      ),
      child: const SetupWizard(revisit: true),
    );
    await _toRevisitSubscription(tester);

    expect(find.text('Do not agree and exit'), findsNothing);
    expect(container.read(appSettingProvider).disclaimerAccepted, isTrue);
    expect(_ExitingSystemAction.calls, isEmpty);
  });

  testWidgets('an empty profile list offers the three ways to add one', (
    tester,
  ) async {
    await _pump(tester);
    await _toSubscription(tester);

    expect(find.text('QR code'), findsOne);
    expect(find.text('File'), findsOne);
    expect(find.text('URL'), findsOne);
    expect(find.text('Raw configuration'), findsOne);
    expect(find.text('Continue without a profile'), findsNWidgets(2));
  });

  testWidgets('importing a subscription keeps the wizard on screen', (
    tester,
  ) async {
    await _pump(
      tester,
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(_RecordingProfilesAction.requests, [
      isA<ProfileLinkImportRequest>().having(
        (request) => request.url,
        'url',
        'https://example.com/sub',
      ),
    ]);
    expect(find.byType(SetupWizard), findsOne);
  });

  testWidgets('desktop QR import keeps the wizard on screen', (tester) async {
    if (!system.isDesktop) return;
    await _pump(
      tester,
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('QR code'));
    await tester.pumpAndSettle();

    expect(_RecordingProfilesAction.requests, [
      isA<ProfileQrCodeImportRequest>(),
    ]);
    expect(find.byType(SetupWizard), findsOneWidget);
  });

  testWidgets('empty and malformed URLs show inline validation', (
    tester,
  ) async {
    await _pump(tester);
    await _toSubscription(tester);
    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Please enter the profile URL'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'htps://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Please enter a valid profile URL'), findsOneWidget);
  });

  testWidgets('the empty step offers restoring from a backup', (tester) async {
    await _pump(tester);
    await _toSubscription(tester);

    expect(find.text('Restore from a backup'), findsOne);
  });

  testWidgets('cancelling restore preview leaves the wizard intact', (
    tester,
  ) async {
    await _pump(
      tester,
      overrides: [
        backupActionProvider.overrideWith(_RestoringBackupAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('Restore from a backup'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Restore all data'), findsOne);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_RestoringBackupAction.prepareCalls, 1);
    expect(_RestoringBackupAction.discardCalls, 1);
    expect(_RestoringBackupAction.applyCalls, 0);
    expect(find.byType(SetupWizard), findsOne);
    expect(find.text('Restore all data'), findsNothing);
  });

  testWidgets('successful restore preserves the active onboarding state', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(
        disclaimerAccepted: true,
        crashlyticsTip: true,
      ),
      overrides: [
        backupActionProvider.overrideWith(_RestoringBackupAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('Restore from a backup'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore all data'));
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(_RestoringBackupAction.prepareCalls, 1);
    expect(_RestoringBackupAction.discardCalls, 0);
    expect(_RestoringBackupAction.applyCalls, 1);
    expect(_RestoringBackupAction.appliedOption, RestoreOption.all);
    final settings = container.read(appSettingProvider);
    expect(settings.disclaimerAccepted, isTrue);
    expect(settings.crashlyticsTip, isTrue);
    expect(settings.crashlytics, isFalse);
    expect(settings.setupCompleted, isFalse);
    expect(settings.setupStep, 2);
    expect(find.byType(SetupWizard), findsOneWidget);
  });

  testWidgets('an added profile replaces the pickers and unlocks Next', (
    tester,
  ) async {
    await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Provider',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
    );
    await _toSubscription(tester);

    expect(find.text('QR code'), findsNothing);
    expect(find.text('Provider'), findsOne);
    expect(find.text('Next'), findsOne);
  });

  testWidgets('undialable profile warns and leaves auto-run disabled', (
    tester,
  ) async {
    const imported = Profile(
      id: 1,
      label: 'Blocked provider',
      autoUpdateDuration: defaultUpdateDuration,
      undialableNodes: true,
    );
    _RecordingProfilesAction.nextProfile = imported;
    final container = await _pump(
      tester,
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.textContaining('None of the nodes'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(container.read(appSettingProvider).autoRun, isFalse);
  });

  testWidgets('picking a region writes the preset and turns the engine on', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toFinish(tester);

    await tester.tap(find.text('Iran'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, SmartRoutingPreset.iran);
    expect(props.enabled, isTrue);
  });

  testWidgets('leaving the region unpicked leaves the engine off', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toFinish(tester);

    await tester.tap(find.text('Other region or do not use Smart Routing'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, SmartRoutingPreset.off);
    expect(props.enabled, isFalse);
  });

  testWidgets('Done records completion and removes the route', (tester) async {
    final container = await _pump(tester);
    await _toFinish(tester);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).setupCompleted, isTrue);
    expect(find.byType(SetupWizard), findsNothing);
  });

  testWidgets('back on the first step closes the app, not the wizard', (
    tester,
  ) async {
    await _pump(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(_ExitingSystemAction.calls, ['close']);
    expect(find.byType(SetupWizard), findsOne);
  });

  testWidgets('back on a later step goes to the previous one', (tester) async {
    await _pump(tester);
    await _toLegal(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOne);
    expect(_ExitingSystemAction.calls, isEmpty);
  });

  testWidgets('resumes an unfinished required setup step', (tester) async {
    await _pump(tester, appSettings: const AppSettingProps(setupStep: 2));

    expect(find.text('Add a connection profile'), findsOneWidget);
    expect(find.text('Choose your language'), findsNothing);
  });

  testWidgets('revisit starts at language and preserves completed state', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(
        locale: 'ru',
        disclaimerAccepted: true,
        setupCompleted: true,
        setupStep: 3,
      ),
      child: const SetupWizard(revisit: true),
    );

    expect(find.text('Choose your language'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final settings = container.read(appSettingProvider);
    expect(settings.locale, 'ru');
    expect(settings.disclaimerAccepted, isTrue);
    expect(settings.setupCompleted, isTrue);
    expect(settings.setupStep, 3);
    expect(find.byType(SetupWizard), findsNothing);
  });

  testWidgets('application settings opens setup in revisit mode', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(
        locale: 'ru',
        disclaimerAccepted: true,
        setupCompleted: true,
      ),
      child: const ApplicationSettingView(),
    );

    await tester.tap(find.text('Run setup again'));
    await tester.pumpAndSettle();

    expect(find.byType(SetupWizard), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);
    expect(container.read(appSettingProvider).setupCompleted, isTrue);
  });

  testWidgets('shows system language and a visible Back action', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('System language'), findsOneWidget);
    await _toLegal(tester);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('progress and step title expose accessible semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);

    expect(find.bySemanticsLabel('Step 1 of 4'), findsOneWidget);
    final titleSemantics = tester.getSemantics(find.text('ReClash'));
    expect(titleSemantics.flagsCollection.isHeader, isTrue);
    semantics.dispose();
  });

  testWidgets('no-profile path explains VPN and ByeDPI-only mode', (
    tester,
  ) async {
    await _pump(tester);
    await _toSubscription(tester);

    expect(find.textContaining('VPN stays off'), findsOneWidget);
    expect(find.textContaining('ByeDPI-only'), findsOneWidget);
  });

  testWidgets('multiple profiles show active profile and total count', (
    tester,
  ) async {
    await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'First',
          autoUpdateDuration: defaultUpdateDuration,
        ),
        Profile(
          id: 2,
          label: 'Second',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
      overrides: [currentProfileIdProvider.overrideWithBuild((_, _) => 2)],
    );
    await _toSubscription(tester);

    expect(find.text('Second'), findsOneWidget);
    expect(find.text('2 profiles ready'), findsOneWidget);
  });

  testWidgets('cancelled replacement keeps the current profile', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Current',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(_RecordingProfilesAction.deletedIds, isEmpty);
    expect(container.read(profilesProvider), hasLength(1));
    expect(container.read(profilesProvider).single.label, 'Current');
    expect(find.text('QR code'), findsOneWidget);
  });

  testWidgets('successful replacement deletes the old profile last', (
    tester,
  ) async {
    const replacement = Profile(
      id: 2,
      label: 'Replacement',
      autoUpdateDuration: defaultUpdateDuration,
    );
    _RecordingProfilesAction.nextProfile = replacement;
    final container = await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Current',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(_RecordingProfilesAction.deletedIds, [1]);
    expect(container.read(profilesProvider), [replacement]);
    expect(find.text('Replacement'), findsOneWidget);
  });

  testWidgets('profile deletion requires confirmation', (tester) async {
    final container = await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Current',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(profilesProvider), hasLength(1));

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(_RecordingProfilesAction.deletedIds, [1]);
    expect(container.read(profilesProvider), isEmpty);
  });

  testWidgets('locale recommendation does not enable Smart Routing', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(locale: 'ru'),
    );
    await _toFinish(tester);

    expect(find.text('Recommended for your language'), findsOneWidget);
    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, SmartRoutingPreset.off);
    expect(props.enabled, isFalse);
  });

  testWidgets('system locale is used for the region recommendation', (
    tester,
  ) async {
    final container = await _pump(tester, locale: const Locale('ru'));
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Согласен'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Продолжить без профиля'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Рекомендуется для вашего языка'), findsOneWidget);
    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, SmartRoutingPreset.off);
    expect(props.enabled, isFalse);
  });

  testWidgets('auto-run is disabled without a profile and summarized', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(autoRun: true),
    );
    await _toFinish(tester);

    expect(container.read(appSettingProvider).autoRun, isFalse);
    expect(find.text('Add a profile to enable automatic connection'), findsOne);
    expect(find.textContaining('No VPN profile'), findsOneWidget);
    expect(find.text('Automatic connection: off'), findsOneWidget);
    expect(find.text('Done and connect'), findsNothing);
  });

  testWidgets('profile enables auto-run and changes the done action', (
    tester,
  ) async {
    await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Provider',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
      appSettings: const AppSettingProps(autoRun: true),
    );
    await _toSubscription(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Profile: Provider'), findsOneWidget);
    expect(find.text('Automatic connection: on'), findsOneWidget);
    expect(find.text('Done and connect'), findsOneWidget);
  });

  testWidgets('revisit never promises to connect on completion', (
    tester,
  ) async {
    await _pump(
      tester,
      profiles: const [
        Profile(
          id: 1,
          label: 'Provider',
          autoUpdateDuration: defaultUpdateDuration,
        ),
      ],
      appSettings: const AppSettingProps(
        autoRun: true,
        disclaimerAccepted: true,
        setupCompleted: true,
      ),
      child: const SetupWizard(revisit: true),
    );
    await _toRevisitSubscription(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Done and connect'), findsNothing);
  });

  testWidgets('panel defaults take priority over auto-run recommendation', (
    tester,
  ) async {
    const imported = Profile(
      id: 1,
      label: 'Panel profile',
      autoUpdateDuration: defaultUpdateDuration,
      panelMeta: PanelMeta(settings: ['openlogs']),
    );
    _RecordingProfilesAction.nextProfile = imported;
    final container = await _pump(
      tester,
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    await _toSubscription(tester);

    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/sub');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).autoRun, isFalse);
    expect(container.read(profilesProvider), [imported]);
  });

  testWidgets('the disclaimer reads in place with the licence outside it', (
    tester,
  ) async {
    await _pump(tester);
    await _toLegal(tester);

    expect(
      find.descendant(
        of: find.byType(SetupScrollCard),
        matching: find.textContaining(
          'non-commercial uses',
          findRichText: true,
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('GPL-3.0'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SetupScrollCard),
        matching: find.text('GPL-3.0'),
      ),
      findsNothing,
    );
  });

  testWidgets('scroll card retries reveal after the target becomes ready', (
    tester,
  ) async {
    final target = GlobalKey();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: SizedBox(
            height: 220,
            child: SetupScrollCard(
              revealIndex: 2,
              children: [
                const SizedBox(height: 300),
                const SizedBox(height: 300),
                SizedBox(key: target, height: 40),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    final position = _cardScroll(tester);
    expect(position.pixels, greaterThan(0));
    expect(target.currentContext, isNotNull);
  });

  testWidgets('reduced motion changes steps without a fade frame', (
    tester,
  ) async {
    await _pump(tester, disableAnimations: true);

    await tester.tap(find.text('Next'));
    await tester.pump();

    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(PageView),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    expect(find.text('Before you continue'), findsOneWidget);
  });

  testWidgets('keyboard traversal reaches the primary action', (tester) async {
    await _pump(tester);

    for (var i = 0; i < 20; i++) {
      final context = FocusManager.instance.primaryFocus?.context;
      final button = context?.findAncestorWidgetOfExactType<FilledButton>();
      if (button?.child case Text(data: 'Next')) break;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }

    final focused = FocusManager.instance.primaryFocus?.context;
    expect(
      focused?.findAncestorWidgetOfExactType<FilledButton>()?.child,
      isA<Text>().having((text) => text.data, 'label', 'Next'),
    );
  });

  testWidgets('desktop routing controls update settings and summary', (
    tester,
  ) async {
    if (!system.isDesktop) return;
    final container = await _pump(tester);
    await _toFinish(tester);

    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('Setup summary'), findsOneWidget);
    expect(find.text('System proxy'), findsOneWidget);
    expect(find.text('TUN'), findsOneWidget);
    await tester.tap(find.text('System proxy'));
    await tester.tap(find.text('TUN'));
    await tester.pumpAndSettle();

    expect(container.read(networkSettingProvider).systemProxy, isFalse);
    expect(container.read(patchClashConfigProvider).tun.enable, isTrue);
    expect(find.text('System proxy: off'), findsOneWidget);
    expect(find.text('TUN: on'), findsOneWidget);
  });

  testWidgets('revisit without a profile preserves stored auto-run', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(
        autoRun: true,
        disclaimerAccepted: true,
        setupCompleted: true,
      ),
      child: const SetupWizard.revisit(),
    );
    await _toRevisitSubscription(tester);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue without a profile'),
    );
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).autoRun, isTrue);
    expect(
      find.text('Add a profile to enable automatic connection'),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'sticky footer keeps the primary action outside the scroll view',
    (tester) async {
      await _pump(tester, size: const Size(360, 520), textScale: 1.5);
      await _toLegal(tester);

      final action = find.widgetWithText(FilledButton, 'Agree');
      final scrollable = find.byType(SingleChildScrollView);
      expect(action, findsOneWidget);
      expect(find.descendant(of: scrollable, matching: action), findsNothing);
    },
  );

  group('finish permissions', () {
    testWidgets('shows deferred VPN and granted notification states', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway(notificationGranted: true);

      await _pumpFinish(tester, gateway);

      expect(gateway.notificationChecks, 1);
      expect(find.text('Requested on first connection'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      expect(find.text('Allowed'), findsOneWidget);
    });

    testWidgets('blocks repeated notification requests while pending', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway()
        ..notificationRequest = Completer<void>();
      await _pumpFinish(tester, gateway);

      await tester.tap(find.text('Allow').first);
      await tester.pump();
      await tester.tap(find.text('Checking…'));
      await tester.pump();

      expect(gateway.notificationRequests, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gateway.notificationGranted = true;
      gateway.notificationRequest!.complete();
      await tester.pumpAndSettle();

      expect(gateway.notificationChecks, 2);
      expect(find.text('Allowed'), findsOneWidget);
    });

    testWidgets('denied notification opens app settings after one request', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway();
      await _pumpFinish(tester, gateway);

      await tester.tap(find.text('Allow').first);
      await tester.pumpAndSettle();
      expect(find.text('Open settings'), findsOneWidget);

      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(gateway.notificationRequests, 1);
      expect(gateway.appSettingsOpens, 1);
    });

    testWidgets('notification errors recover with an app settings action', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway()
        ..notificationCheckError = StateError('unavailable');
      await _pumpFinish(tester, gateway);

      expect(find.text('Open settings'), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(gateway.appSettingsOpens, 1);
    });

    testWidgets('permission states refresh after returning to the app', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway();
      final container = await _pumpFinish(tester, gateway);
      expect(gateway.notificationChecks, 1);

      gateway.notificationGranted = true;
      gateway.batteryGranted = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(gateway.notificationChecks, 2);
      expect(gateway.batteryChecks, 2);
      expect(container.read(batteryOptimizationDisableProvider), isTrue);
      expect(find.text('Allowed'), findsNWidgets(2));
    });

    testWidgets('battery result refreshes immediately after settings', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway();
      final container = await _pumpFinish(tester, gateway);

      gateway.batteryGranted = true;
      await tester.tap(find.text('Allow').last);
      await tester.pumpAndSettle();

      expect(gateway.batterySettingsOpens, 1);
      expect(gateway.batteryChecks, 2);
      expect(container.read(batteryOptimizationDisableProvider), isTrue);
      expect(find.text('Allowed'), findsOneWidget);
    });

    testWidgets('battery failure always releases the pending state', (
      tester,
    ) async {
      final gateway = _TestPermissionGateway()
        ..batteryOpenError = StateError('unavailable');
      await _pumpFinish(tester, gateway);

      await tester.tap(find.text('Allow').last);
      await tester.pumpAndSettle();

      expect(gateway.batterySettingsOpens, 1);
      expect(find.text('Allow'), findsNWidgets(2));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  for (final scenario in <(String, Size, double)>[
    ('compact portrait', const Size(360, 640), 1.3),
    ('compact landscape', const Size(640, 360), 1.3),
    ('large text', const Size(400, 720), 2),
    ('desktop', const Size(1200, 800), 1),
  ]) {
    testWidgets('${scenario.$1} scrolls to the primary action', (tester) async {
      await _pump(tester, size: scenario.$2, textScale: scenario.$3);

      final action = find.widgetWithText(FilledButton, 'Next');
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();

      expect(action, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
