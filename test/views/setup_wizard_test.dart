import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/application_setting.dart';
import 'package:reclash/views/setup/layout.dart';
import 'package:reclash/views/setup/setup.dart';
import 'package:reclash/views/setup/steps/check.dart';
import 'package:reclash/views/setup/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _provider = Profile(
  id: 1,
  label: 'Provider',
  autoUpdateDuration: defaultUpdateDuration,
);

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

/// Records what the check step asks of the core instead of starting one.
class _RecordingSetupAction extends SetupAction {
  final requests = <(bool running, bool initialize)>[];
  int authorizations = 0;
  bool started = true;

  @override
  void beginTunAuthorization({bool allowPrompt = true}) => authorizations++;

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) async {
    requests.add((running, initialize));
    // The check step waits on `isStartProvider`, which reads the run time.
    if (started) {
      ref.read(runTimeProvider.notifier).value = running ? 1 : null;
    }
    return started;
  }
}

/// A doctor that answers with a prepared snapshot, so the check step can be
/// driven through a verdict without a core.
class _FakeDoctor extends ConnectionDoctor {
  _FakeDoctor({this.initial = _observing, this.settled});

  static const _observing = DoctorSnapshot(
    supported: true,
    state: DoctorExamState.observing,
    health: DoctorHealth.unknown,
    confidence: DoctorConfidence.insufficient,
    severity: DoctorSeverity.info,
  );

  final DoctorSnapshot initial;

  /// What [start] resolves to; null leaves the snapshot where it was.
  DoctorSnapshot? settled;

  final starts = <DoctorExamMode>[];
  int refreshes = 0;
  int cancels = 0;
  int flushes = 0;

  @override
  DoctorSnapshot build() => initial;

  @override
  Future<DoctorSnapshot> start(DoctorExamMode mode) async {
    starts.add(mode);
    final next = settled;
    if (next != null) state = next;
    return state;
  }

  @override
  Future<DoctorSnapshot> refresh({int minimumRevision = 0}) async {
    refreshes++;
    return state;
  }

  @override
  Future<DoctorSnapshot> cancel() async {
    cancels++;
    state = state.copyWith(state: DoctorExamState.cancelled);
    return state;
  }

  @override
  Future<DoctorSnapshot> flushDns() async {
    flushes++;
    return state;
  }
}

class _TestCheckGateway implements SetupCheckGateway {
  _TestCheckGateway({this.isAndroid = false});

  @override
  final bool isAndroid;

  bool batteryGranted = false;
  Error? batteryOpenError;
  int batteryOpens = 0;
  int batteryChecks = 0;

  @override
  Future<void> checkBatteryOptimizationDisable(ProviderReader read) async {
    batteryChecks++;
    read(batteryOptimizationDisableProvider.notifier).value = batteryGranted;
  }

  @override
  Future<void> openBatteryOptimizationSettings() async {
    batteryOpens++;
    final error = batteryOpenError;
    if (error != null) throw error;
  }
}

DoctorSnapshot _snapshot({
  DoctorExamState state = DoctorExamState.complete,
  DoctorHealth health = DoctorHealth.healthy,
  DoctorSeverity severity = DoctorSeverity.info,
  DoctorConfidence confidence = DoctorConfidence.confirmed,
  DoctorPathKind pathKind = DoctorPathKind.tun,
  String causeCode = '',
  DoctorLayer layer = DoctorLayer.unknown,
  List<DoctorStage> stages = const [
    DoctorStage(id: 'app', state: DoctorStageState.passed),
    DoctorStage(id: 'ingress', state: DoctorStageState.passed),
    DoctorStage(id: 'route', state: DoctorStageState.passed),
    DoctorStage(id: 'internet', state: DoctorStageState.passed),
    DoctorStage(id: 'response', state: DoctorStageState.passed),
  ],
}) => DoctorSnapshot(
  revision: 1,
  supported: true,
  state: state,
  health: health,
  severity: severity,
  confidence: confidence,
  pathKind: pathKind,
  captureState: DoctorCaptureState.active,
  stages: stages,
  causeCode: causeCode,
  layer: layer,
  progress: const DoctorProgress(completed: 5, total: 5),
  freshUntil: DateTime.now().millisecondsSinceEpoch + 60000,
);

DoctorSnapshot _dnsStale() => _snapshot(
  health: DoctorHealth.broken,
  severity: DoctorSeverity.critical,
  causeCode: 'coreResolverStale',
  layer: DoctorLayer.dns,
  stages: const [
    DoctorStage(id: 'app', state: DoctorStageState.passed),
    DoctorStage(id: 'ingress', state: DoctorStageState.passed),
    DoctorStage(id: 'route', state: DoctorStageState.failed),
  ],
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<Profile> profiles = const [],
  AppSettingProps appSettings = const AppSettingProps(),
  Widget child = const SetupWizard(),
  Size size = const Size(900, 1600),
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
  container.listen(vpnSettingProvider, (_, _) {});
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

Widget _checkStep({
  required SetupCheckGateway gateway,
  List<SetupCheckOutcome>? outcomes,
  VoidCallback? onDone,
  VoidCallback? onBack,
  bool revisit = false,
}) => SetupCheckStep(
  gateway: gateway,
  revisit: revisit,
  onDone: onDone ?? () {},
  onBack: onBack ?? () {},
  onOutcome: (outcome, _) => outcomes?.add(outcome),
);

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

Future<void> _past(WidgetTester tester) async {
  await tester.tap(
    find.widgetWithText(FilledButton, 'Continue without a profile'),
  );
  await tester.pumpAndSettle();
}

Future<void> _toCoverage(WidgetTester tester) async {
  await _toSubscription(tester);
  await _past(tester);
}

Future<void> _toCheck(WidgetTester tester, {bool withProfile = false}) async {
  await _toSubscription(tester);
  if (withProfile) {
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  } else {
    await _past(tester);
  }
  await tester.tap(find.widgetWithText(FilledButton, 'Next'));
  await tester.pumpAndSettle();
}

Future<void> _pickRegion(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(TextButton, 'Change'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
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

Switch _autoRunSwitch(WidgetTester tester) => tester.widget<Switch>(
  find
      .descendant(
        of: find.byKey(const ValueKey('setup-auto-run')).first,
        matching: find.byType(Switch),
      )
      .first,
);

String? _focusedText() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  final tile = context.findAncestorWidgetOfExactType<ListTile>();
  if (tile?.title case Text(data: final data?)) return data;
  final button = context
      .findAncestorWidgetOfExactType<ButtonStyleButton>()
      ?.child;
  if (button is Text) return button.data;
  final editable = context.findAncestorWidgetOfExactType<EditableText>();
  if (editable != null) return editable.controller.text;
  String? result;
  void findText(Element candidate) {
    if (result != null) return;
    if (candidate.widget case Text(data: final data?)) result = data;
    candidate.visitChildElements(findText);
  }

  findText(context as Element);
  return result;
}

Future<void> _focusText(
  WidgetTester tester,
  String label, {
  int limit = 30,
}) async {
  for (var index = 0; index < limit && _focusedText() != label; index++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
  }
  expect(_focusedText(), label);
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
      appSettings: const AppSettingProps(locale: 'ru'),
      size: const Size(400, 900),
    );

    expect(_cardScroll(tester).pixels, greaterThan(0));
    expect(find.text('Русский'), findsOneWidget);
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

  testWidgets('TV setup replaces camera import with phone transfer', (
    tester,
  ) async {
    addTearDown(() => system.isTVForTesting = false);
    system.isTVForTesting = true;
    await _pump(tester);
    await _toSubscription(tester);

    expect(find.text('Receive from phone'), findsOneWidget);
    expect(find.text('QR code'), findsNothing);
    expect(find.text('URL'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
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
    await _pump(tester, profiles: const [_provider]);
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

    expect(find.textContaining('No regular node addresses'), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.warning), findsOneWidget);
    expect(container.read(appSettingProvider).autoRun, isFalse);
  });

  testWidgets('the detected strip writes the preset without enabling routing', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toSubscription(tester);

    await _pickRegion(tester, 'Iran');
    await _past(tester);

    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, 'ir');
    expect(props.enabled, isFalse);
    expect(container.read(appSettingProvider).region, 'IR');
    expect(find.textContaining('Detected: Iran'), findsOneWidget);
  });

  testWidgets('leaving the region unpicked leaves the engine off', (
    tester,
  ) async {
    final container = await _pump(tester);
    await _toCheck(tester);

    expect(container.read(appSettingProvider).region, isNull);
    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, neutralPreset);
    expect(props.enabled, isFalse);
  });

  testWidgets('Done records completion and removes the route', (tester) async {
    final container = await _pump(tester);
    await _toCheck(tester);

    await tester.tap(find.byKey(const ValueKey('setup-done')).first);
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

  testWidgets('each step is mounted alone, with no pager under it', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byType(SetupStepScaffold), findsOneWidget);

    await _toLegal(tester);

    // A pager here is a scrollable: revealing a focused footer button through
    // it would scroll the wizard off the step it just opened.
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(SetupStepScaffold), findsOneWidget);
    expect(find.text('Choose your language'), findsNothing);
    expect(find.text('Before you continue'), findsOneWidget);
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

    expect(find.bySemanticsLabel('Step 1 of 5'), findsOneWidget);
    final titleSemantics = tester.getSemantics(find.text('ReClash'));
    expect(titleSemantics.flagsCollection.isHeader, isTrue);
    semantics.dispose();
  });

  testWidgets('no-profile path explains ByeDPI-only where it is offered', (
    tester,
  ) async {
    await _pump(
      tester,
      overrides: [byeDpiSupportedProvider.overrideWithValue(true)],
    );
    await _toSubscription(tester);

    expect(find.textContaining('VPN stays off'), findsOneWidget);
    expect(find.textContaining('ByeDPI-only'), findsOneWidget);
  });

  testWidgets('no-profile path omits ByeDPI where it is unavailable', (
    tester,
  ) async {
    await _pump(
      tester,
      overrides: [byeDpiSupportedProvider.overrideWithValue(false)],
    );
    await _toSubscription(tester);

    expect(find.textContaining('VPN stays off'), findsOneWidget);
    expect(find.textContaining('ByeDPI'), findsNothing);
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

  testWidgets('stored ru language seeds Russia and HWID without routing', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      appSettings: const AppSettingProps(locale: 'ru'),
    );
    await _toCoverage(tester);

    expect(container.read(appSettingProvider).region, 'RU');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, 'ru');
    expect(props.enabled, isFalse);
  });

  testWidgets('ru system locale seeds Russia and HWID without routing', (
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

    expect(container.read(appSettingProvider).region, 'RU');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, 'ru');
    expect(props.enabled, isFalse);
  });

  testWidgets('a Moscow time zone seeds Russia under an English locale', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      overrides: [
        regionSignalsProvider.overrideWithValue(
          const RegionSignals(timeZoneId: 'Europe/Moscow'),
        ),
      ],
    );
    await _toCoverage(tester);

    expect(container.read(appSettingProvider).region, 'RU');
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    final props = container.read(smartRoutingSettingProvider);
    expect(props.preset, 'ru');
    expect(props.enabled, isFalse);
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

  testWidgets('the summary reads in place with the licence outside it', (
    tester,
  ) async {
    await _pump(tester);
    await _toLegal(tester);

    expect(
      find.descendant(
        of: find.byType(SetupScrollCard),
        matching: find.textContaining(
          'what ReClash is, what it is not',
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
            of: find.byType(SetupStepScaffold),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    expect(find.text('Before you continue'), findsOneWidget);
  });

  testWidgets('TV remote completes setup without pointer input', (
    tester,
  ) async {
    addTearDown(() => system.isTVForTesting = false);
    system.isTVForTesting = true;
    final container = await _pump(tester, disableAnimations: true);

    await _focusText(tester, 'Русский');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).locale, 'ru');

    await _focusText(tester, 'Next');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('Before you continue'), findsOneWidget);

    await _focusText(tester, 'Agree');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('Add a connection profile'), findsOneWidget);

    await _focusText(tester, 'Continue without a profile');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('What should go through ReClash?'), findsOneWidget);

    await _focusText(tester, 'Next');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text("Let's check your connection"), findsOneWidget);

    await _focusText(tester, 'Done');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).setupCompleted, isTrue);
  });

  testWidgets('focused TV setup controls stay visible while moving down', (
    tester,
  ) async {
    addTearDown(() => system.isTVForTesting = false);
    system.isTVForTesting = true;
    await _pump(tester, size: const Size(940, 540), disableAnimations: true);

    await _focusText(tester, 'Русский');
    await tester.pumpAndSettle();

    final focusRect = FocusManager.instance.primaryFocus!.rect;
    final cardRect = tester.getRect(find.byType(SetupScrollCard));
    expect(cardRect.overlaps(focusRect), isTrue);
    expect(focusRect.top, greaterThanOrEqualTo(cardRect.top));
    expect(focusRect.bottom, lessThanOrEqualTo(cardRect.bottom));
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
    await _past(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text("Let's check your connection"), findsOneWidget);
    expect(container.read(appSettingProvider).autoRun, isTrue);
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

  group('coverage', () {
    testWidgets('each option writes the settings it stands for', (
      tester,
    ) async {
      final container = await _pump(tester);
      await _toCoverage(tester);

      expect(find.text('What should go through ReClash?'), findsOneWidget);
      expect(find.textContaining('Smart Routing, DNS and rules'), findsOne);

      if (system.isAndroid) {
        await tester.tap(
          find.byKey(const ValueKey('setup-coverage-selectedApps')).first,
        );
        await tester.pumpAndSettle();
        expect(
          container.read(vpnSettingProvider).accessControlProps.enable,
          isTrue,
        );
        expect(find.byKey(const ValueKey('setup-coverage-apps')), findsWidgets);

        await tester.tap(
          find.byKey(const ValueKey('setup-coverage-device')).first,
        );
        await tester.pumpAndSettle();
        expect(
          container.read(vpnSettingProvider).accessControlProps.enable,
          isFalse,
        );
        expect(find.byKey(const ValueKey('setup-coverage-apps')), findsNothing);
        return;
      }

      expect(find.byKey(const ValueKey('setup-coverage-apps')), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('setup-coverage-device')).first,
      );
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).tun.enable, isTrue);
      expect(container.read(networkSettingProvider).systemProxy, isFalse);

      await tester.tap(
        find.byKey(const ValueKey('setup-coverage-localProxy')).first,
      );
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).tun.enable, isFalse);
      expect(container.read(networkSettingProvider).systemProxy, isFalse);

      await tester.tap(
        find.byKey(const ValueKey('setup-coverage-systemProxy')).first,
      );
      await tester.pumpAndSettle();
      expect(container.read(patchClashConfigProvider).tun.enable, isFalse);
      expect(container.read(networkSettingProvider).systemProxy, isTrue);
    });

    testWidgets('the chosen coverage leads the check step plan', (
      tester,
    ) async {
      if (system.isAndroid) return;
      await _pump(tester);
      await _toCoverage(tester);
      await tester.tap(
        find.byKey(const ValueKey('setup-coverage-device')).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('All device traffic'), findsOneWidget);
    });
  });

  group('receipt', () {
    Future<List<int>> showReceipt(
      WidgetTester tester, {
      int index = 3,
      List<Profile> profiles = const [_provider],
    }) async {
      final jumps = <int>[];
      await _pump(
        tester,
        size: const Size(1200, 900),
        appSettings: const AppSettingProps(locale: 'ru'),
        profiles: profiles,
        child: SetupShell(
          stages: const [
            SetupStage.welcome,
            SetupStage.legal,
            SetupStage.subscription,
            SetupStage.coverage,
            SetupStage.check,
          ],
          index: index,
          onJump: jumps.add,
          outcome: SetupCheckOutcome.pending,
          child: const SizedBox.expand(),
        ),
      );
      return jumps;
    }

    testWidgets('a wide layout lists what every decided stage holds', (
      tester,
    ) async {
      await showReceipt(tester);

      expect(find.byType(SetupReceipt), findsOneWidget);
      expect(find.text('Step 4 of 5'), findsOneWidget);
      expect(find.text('Русский'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Provider'), findsOneWidget);
      expect(
        find.text(
          system.isAndroid ? 'Connect device apps' : 'Use the system proxy',
        ),
        findsOneWidget,
      );
      expect(find.text("We'll connect and measure the path"), findsOneWidget);
    });

    testWidgets('visited rows jump back and later ones stay put', (
      tester,
    ) async {
      final jumps = await showReceipt(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(jumps, [2]);

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(jumps, [2]);
    });
  });

  group('check', () {
    testWidgets('connect and check starts the core and runs an exam', (
      tester,
    ) async {
      final setup = _RecordingSetupAction();
      final doctor = _FakeDoctor(settled: _snapshot());
      final outcomes = <SetupCheckOutcome>[];
      await _pump(
        tester,
        profiles: const [_provider],
        overrides: [
          setupActionProvider.overrideWith(() => setup),
          connectionDoctorProvider.overrideWith(() => doctor),
        ],
        child: _checkStep(gateway: _TestCheckGateway(), outcomes: outcomes),
      );

      expect(find.text("Let's check your connection"), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('setup-connect-check')).first);
      await tester.pumpAndSettle();

      expect(setup.authorizations, 1);
      expect(setup.requests, [(true, true)]);
      expect(doctor.starts, [DoctorExamMode.standard]);
      expect(outcomes, [SetupCheckOutcome.running, SetupCheckOutcome.passed]);
    });

    testWidgets('a healthy verdict shows the path and completes setup', (
      tester,
    ) async {
      final doctor = _FakeDoctor(settled: _snapshot());
      final container = await _pump(
        tester,
        profiles: const [_provider],
        overrides: [
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(() => doctor),
        ],
      );
      await _toCheck(tester, withProfile: true);

      await tester.tap(find.byKey(const ValueKey('setup-connect-check')).first);
      await tester.pumpAndSettle();

      expect(find.text('Connection looks healthy'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
      expect(find.text('Proxy / Internet'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('setup-done')).first);
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).setupCompleted, isTrue);
      expect(find.byType(SetupWizard), findsNothing);
    });

    testWidgets('an unhealthy verdict offers a remedy the wizard can run', (
      tester,
    ) async {
      final doctor = _FakeDoctor(settled: _dnsStale());
      final outcomes = <SetupCheckOutcome>[];
      await _pump(
        tester,
        profiles: const [_provider],
        overrides: [
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(() => doctor),
        ],
        child: _checkStep(gateway: _TestCheckGateway(), outcomes: outcomes),
      );

      await tester.tap(find.byKey(const ValueKey('setup-connect-check')).first);
      await tester.pumpAndSettle();

      expect(find.text('DNS data is outdated'), findsOneWidget);
      expect(find.textContaining('Clear the DNS cache'), findsOneWidget);
      expect(outcomes.last, SetupCheckOutcome.failed);

      await tester.tap(find.widgetWithText(FilledButton, 'Flush DNS cache'));
      await tester.pumpAndSettle();

      expect(doctor.flushes, 1);
      expect(doctor.starts, [DoctorExamMode.standard, DoctorExamMode.standard]);
    });

    testWidgets('a failed start reports the failure without a verdict', (
      tester,
    ) async {
      final setup = _RecordingSetupAction()..started = false;
      final doctor = _FakeDoctor();
      final outcomes = <SetupCheckOutcome>[];
      await _pump(
        tester,
        profiles: const [_provider],
        overrides: [
          setupActionProvider.overrideWith(() => setup),
          connectionDoctorProvider.overrideWith(() => doctor),
        ],
        child: _checkStep(gateway: _TestCheckGateway(), outcomes: outcomes),
      );

      await tester.tap(find.byKey(const ValueKey('setup-connect-check')).first);
      await tester.pumpAndSettle();

      expect(doctor.starts, isEmpty);
      expect(outcomes.last, SetupCheckOutcome.failed);
      expect(
        find.textContaining('Could not confirm that the connection started'),
        findsOneWidget,
      );
    });

    testWidgets('saving without connecting never touches the core', (
      tester,
    ) async {
      final setup = _RecordingSetupAction();
      final doctor = _FakeDoctor();
      final outcomes = <SetupCheckOutcome>[];
      await _pump(
        tester,
        profiles: const [_provider],
        overrides: [
          setupActionProvider.overrideWith(() => setup),
          connectionDoctorProvider.overrideWith(() => doctor),
        ],
        child: _checkStep(gateway: _TestCheckGateway(), outcomes: outcomes),
      );

      await tester.tap(find.text('Save without connecting'));
      await tester.pumpAndSettle();

      expect(setup.requests, isEmpty);
      expect(setup.authorizations, 0);
      expect(doctor.starts, isEmpty);
      expect(outcomes, [SetupCheckOutcome.saved]);
      expect(find.text('Settings saved'), findsOneWidget);
      expect(find.byKey(const ValueKey('setup-done')), findsOneWidget);
    });

    testWidgets('auto-run stays off and unreachable without a profile', (
      tester,
    ) async {
      final container = await _pump(
        tester,
        appSettings: const AppSettingProps(autoRun: true),
        overrides: [
          byeDpiSupportedProvider.overrideWithValue(true),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(_FakeDoctor.new),
        ],
        child: _checkStep(gateway: _TestCheckGateway()),
      );

      await tester.tap(find.text('Save without connecting'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add a profile to enable automatic connection'),
        findsOneWidget,
      );
      expect(_autoRunSwitch(tester).value, isFalse);
      expect(_autoRunSwitch(tester).onChanged, isNull);
      expect(container.read(appSettingProvider).autoRun, isTrue);
    });

    testWidgets('a profile lets auto-run be turned on', (tester) async {
      final container = await _pump(
        tester,
        profiles: const [_provider],
        overrides: [
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(_FakeDoctor.new),
        ],
        child: _checkStep(gateway: _TestCheckGateway()),
      );

      await tester.tap(find.text('Save without connecting'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('setup-auto-run')).first);
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).autoRun, isTrue);
      expect(_autoRunSwitch(tester).value, isTrue);
    });

    testWidgets('an Android check asks for the battery exemption once', (
      tester,
    ) async {
      final gateway = _TestCheckGateway(isAndroid: true);
      final container = await _pump(
        tester,
        profiles: const [_provider],
        appSettings: const AppSettingProps(autoRun: true),
        overrides: [
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(_FakeDoctor.new),
        ],
        child: _checkStep(gateway: gateway),
      );

      await tester.tap(find.text('Save without connecting'));
      await tester.pumpAndSettle();
      expect(find.text('Battery optimization'), findsOneWidget);

      gateway.batteryGranted = true;
      await tester.tap(find.text('Battery optimization'));
      await tester.pumpAndSettle();

      expect(gateway.batteryOpens, 1);
      expect(gateway.batteryChecks, 1);
      expect(container.read(batteryOptimizationDisableProvider), isTrue);
      expect(find.text('Battery optimization'), findsNothing);
    });

    testWidgets('a failed battery prompt releases the pending state', (
      tester,
    ) async {
      final gateway = _TestCheckGateway(isAndroid: true)
        ..batteryOpenError = StateError('unavailable');
      await _pump(
        tester,
        profiles: const [_provider],
        appSettings: const AppSettingProps(autoRun: true),
        overrides: [
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(_FakeDoctor.new),
        ],
        child: _checkStep(gateway: gateway),
      );

      await tester.tap(find.text('Save without connecting'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      expect(gateway.batteryOpens, 1);
      expect(gateway.batteryChecks, 0);
      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Checking…'), findsNothing);
    });

    testWidgets('a desktop check never asks for the battery exemption', (
      tester,
    ) async {
      await _pump(
        tester,
        profiles: const [_provider],
        appSettings: const AppSettingProps(autoRun: true),
        overrides: [
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
          connectionDoctorProvider.overrideWith(_FakeDoctor.new),
        ],
        child: _checkStep(gateway: _TestCheckGateway()),
      );

      await tester.tap(find.text('Save without connecting'));
      await tester.pumpAndSettle();

      expect(find.text('Battery optimization'), findsNothing);
    });
  });

  for (final scenario in <(String, Size, double)>[
    ('compact portrait', const Size(360, 640), 1.3),
    ('compact landscape', const Size(640, 360), 1.3),
    ('large text', const Size(400, 720), 2),
    ('desktop', const Size(900, 800), 1),
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
