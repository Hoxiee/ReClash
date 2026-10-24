import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/card.dart';
import 'package:reclash/ui/list.dart';
import 'package:reclash/ui/selection_mark.dart';
import 'package:reclash/views/setup.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestSetupSession extends SetupSession {
  _TestSetupSession({
    required this.step,
    required this.acceptedDisclaimerVersion,
    required this.profileId,
    this.coverage = SetupCoverage.tun,
    this.report,
    this.regionCode,
    this.regionChosen = false,
  });

  final SetupStep step;
  final int acceptedDisclaimerVersion;
  final int? profileId;
  final SetupCoverage coverage;
  final SetupReport? report;
  final String? regionCode;
  final bool regionChosen;
  var saveResult = true;
  var prepareCalls = 0;
  var startCalls = 0;
  var applyCalls = 0;

  @override
  SetupSessionState build() => SetupSessionState(
    active: true,
    step: step,
    draft: SetupDraft(
      profileId: profileId,
      coverage: coverage,
      regionCode: regionCode,
      regionChosen: regionChosen,
    ),
    report: report,
  );

  @override
  bool get isAndroid => false;

  @override
  Future<bool> saveConfig(Config config) async => saveResult;

  @override
  Future<bool> prepareCore() async {
    prepareCalls++;
    return true;
  }

  @override
  Future<bool> startConnection() async {
    startCalls++;
    return true;
  }

  @override
  Future<bool> applyProfile() async {
    applyCalls++;
    return true;
  }

  @override
  Future<DateTime?> nativeRunTime() async => null;

  @override
  Future<RouteSnapshot?> routeSnapshot() async =>
      const RouteSnapshot(coreEpoch: 1, routeVersion: 1);

  @override
  Future<ProbeResult?> probeRoute(String url) async =>
      const ProbeResult(statusCode: 204);
}

class _AgeRetryProfilesAction extends ProfilesAction {
  int importCalls = 0;
  final receivedKeys = <String>[];
  List<int>? receivedData;

  @override
  Future<Profile?> importProfileData(
    List<int> data, {
    required String name,
    String ageSecretKey = '',
    bool select = true,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    importCalls++;
    receivedData = data;
    receivedKeys.add(ageSecretKey);
    if (ageSecretKey.isEmpty) throw const AgeSecretKeyRequiredException();
    return Profile.normal(label: name).copyWith(id: 92);
  }
}

class _WizardImportRequest {
  _WizardImportRequest({
    required this.link,
    required this.select,
    required this.clientSettings,
    required this.reviewContext,
    required this.cancellation,
  });

  final String link;
  final bool select;
  final SubscriptionClientSettings? clientSettings;
  final BuildContext? reviewContext;
  final SubscriptionCancellation? cancellation;
  final completion = Completer<Profile>();
}

class _PendingProfilesAction extends ProfilesAction {
  final requests = <_WizardImportRequest>[];

  @override
  Future<Profile> importProfileFromLink(
    String link, {
    String? label,
    required String ageSecretKey,
    bool select = true,
    SubscriptionClientSettings? clientSettings,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) {
    final request = _WizardImportRequest(
      link: link,
      select: select,
      clientSettings: clientSettings,
      reviewContext: reviewContext,
      cancellation: cancellation,
    );
    requests.add(request);
    return request.completion.future;
  }
}

final class _LocalPlatformFile extends PlatformFile {
  _LocalPlatformFile(this.file, this.bytes);

  final File file;
  final Uint8List bytes;

  @override
  String get name => file.uri.pathSegments.last;

  @override
  Uri get uri => file.uri;

  @override
  XFile get xFile => XFile(file.path);

  @override
  int? lengthSync() => null;

  @override
  Future<int> length() async => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

class _ReturningFilePicker extends FilePickerPlatform {
  _ReturningFilePicker(this.file);

  final PlatformFile file;
  int calls = 0;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    calls++;
    return file;
  }
}

class _TestSetupAction extends SetupAction {
  @override
  void build() {}

  @override
  Future<bool> setRunning(
    bool running, {
    bool initialize = false,
    bool silence = false,
    Object? owner,
    bool allowPrompt = false,
  }) async => true;

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool suppressErrors = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    await preloadInvoke?.call();
    return true;
  }

  @override
  void resetCoreTraffic() {}
}

({ProviderContainer container, Profile profile, _TestSetupSession session})
_harness({
  SetupStep step = SetupStep.language,
  int acceptedDisclaimerVersion = 0,
  SetupCoverage coverage = SetupCoverage.tun,
  SetupReport? report,
  String? regionCode,
  bool regionChosen = false,
  bool safeMode = false,
  String? locale = 'en',
  String? actualRegionCode,
  String? suggestedRegionCode,
  ProfilesAction? profileAction,
}) {
  final profile = Profile.normal(label: 'Wizard profile');
  final session = _TestSetupSession(
    step: step,
    acceptedDisclaimerVersion: acceptedDisclaimerVersion,
    profileId: profile.id,
    coverage: coverage,
    report: report,
    regionCode: regionCode,
    regionChosen: regionChosen,
  );
  final settings = AppSettingProps(
    setupCompleted: false,
    acceptedDisclaimerVersion: acceptedDisclaimerVersion,
    locale: locale,
    regionCode: actualRegionCode,
  );
  final container = ProviderContainer(
    overrides: [
      appSettingProvider.overrideWithBuild((_, _) => settings),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      detectedRegionProvider.overrideWith(
        (_) async => suggestedRegionCode == null
            ? null
            : RegionDetectionResult(
                suggestedRegionCode,
                RegionDetectionSource.timeZone,
              ),
      ),
      safeModeProvider.overrideWithValue(safeMode),
      appVisibleProvider.overrideWithValue(false),
      runTimeProvider.overrideWithBuild((_, _) => null),
      setupActionProvider.overrideWith(_TestSetupAction.new),
      if (profileAction != null)
        profilesActionProvider.overrideWith(() => profileAction),
      setupSessionProvider.overrideWith(() => session),
    ],
  );
  globalState.container = container;
  container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
  container.listen(setupSessionProvider, (_, _) {}, fireImmediately: true);
  return (container: container, profile: profile, session: session);
}

Future<void> _pumpWizard(
  WidgetTester tester,
  ProviderContainer container, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  container.read(viewSizeProvider.notifier).value = size;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(
            appSettingProvider.select((state) => state.locale),
          );
          return TestApp(
            locale: getLocaleForString(locale),
            child: const SetupWizard(isAndroid: false),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _startLinkImport(WidgetTester tester, String link) async {
  final field = find.byType(TextField).first;
  await tester.ensureVisible(field);
  await tester.enterText(field, link);
  final button = find
      .widgetWithText(FilledButton, currentAppLocalizations.import)
      .first;
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

Future<void> _chooseRequestClient(WidgetTester tester, String label) async {
  final requestAs = find.text(
    currentAppLocalizations.subscriptionClientRequestAs,
  );
  await tester.ensureVisible(requestAs);
  await tester.tap(requestAs);
  await tester.pumpAndSettle();
  final option = find.text(label).last;
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starts with language and updates localized labels reactively', (
    tester,
  ) async {
    final harness = _harness();
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Қазақша'), findsOneWidget);
    expect(find.text('Türkmençe'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(harness.container.read(appSettingProvider).locale, 'es');
    expect(find.text('Elige tu idioma'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(
      harness.container.read(setupSessionProvider).step,
      SetupStep.agreement,
    );
    expect(
      harness.container.read(appSettingProvider).acceptedDisclaimerVersion,
      0,
    );
  });

  testWidgets('agreement requires reading to the end before accepting', (
    tester,
  ) async {
    final harness = _harness(step: SetupStep.agreement);
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container, size: const Size(390, 640));

    final readToEnd = find.widgetWithText(FilledButton, 'Read to the end');
    expect(tester.widget<FilledButton>(readToEnd).onPressed, isNull);
    await tester.tap(readToEnd, warnIfMissed: false);
    await tester.pump();
    expect(
      harness.container.read(appSettingProvider).acceptedDisclaimerVersion,
      0,
    );
    expect(
      harness.container.read(setupSessionProvider).step,
      SetupStep.agreement,
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -6000));
    await tester.pumpAndSettle();
    final agree = find.widgetWithText(FilledButton, 'Agree');
    expect(tester.widget<FilledButton>(agree).onPressed, isNotNull);
    await tester.tap(agree);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(appSettingProvider).acceptedDisclaimerVersion,
      disclaimerVersion,
    );
    expect(
      harness.container.read(setupSessionProvider).step,
      SetupStep.profile,
    );
  });

  testWidgets('narrow and desktop wizard layouts do not overflow', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.coverage,
      acceptedDisclaimerVersion: disclaimerVersion,
      coverage: SetupCoverage.system,
    );
    addTearDown(harness.container.dispose);

    await _pumpWizard(tester, harness.container, size: const Size(360, 640));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpWizard(tester, harness.container, size: const Size(1280, 820));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected draft coverage shows a check without a filled card', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.coverage,
      acceptedDisclaimerVersion: disclaimerVersion,
      coverage: SetupCoverage.system,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    final row = find.ancestor(
      of: find.text('System proxy'),
      matching: find.byType(DecorationListItem),
    );
    expect(
      find.descendant(of: row, matching: find.byType(SelectionCheck)),
      findsOneWidget,
    );
    final card = tester.widget<CommonCard>(
      find.descendant(of: row, matching: find.byType(CommonCard)),
    );
    expect(card.isSelected, isTrue);
    expect(card.fillsSelection, isFalse);
  });

  testWidgets('safe mode explains the stub and never starts a connection', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.region,
      acceptedDisclaimerVersion: disclaimerVersion,
      safeMode: true,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    await tester.tap(find.text('Check connection'));
    await tester.pumpAndSettle();

    expect(find.text('Connect later'), findsOneWidget);
    expect(
      find.textContaining('Safe mode does not start a real connection'),
      findsOneWidget,
    );
    expect(harness.session.prepareCalls, 0);
    expect(harness.session.startCalls, 0);
    expect(harness.session.applyCalls, 0);
  });

  testWidgets('finishing a saved setup does not start a connection', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.result,
      acceptedDisclaimerVersion: disclaimerVersion,
      report: const SetupReport(verdict: SetupVerdict.saved),
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(harness.container.read(appSettingProvider).setupCompleted, isTrue);
    expect(harness.container.read(appSettingProvider).autoRun, isFalse);
    expect(harness.session.startCalls, 0);
  });

  testWidgets(
    'invalid profile links show inline errors and file cancel is inert',
    (tester) async {
      final originalPicker = FilePickerPlatform.instance;
      final originalDownloadDirectory = AppPath.downloadDirectory;
      final originalSupportDirectory = AppPath.supportDirectory;
      final originalTemporaryDirectory = AppPath.temporaryDirectory;
      final originalCacheDirectory = AppPath.cacheDirectory;
      final tempDirectory = Directory.systemTemp;
      AppPath.downloadDirectory = () async => tempDirectory;
      AppPath.supportDirectory = () async => tempDirectory;
      AppPath.temporaryDirectory = () async => tempDirectory;
      AppPath.cacheDirectory = () async => tempDirectory;
      FilePickerPlatform.instance = _CancelledFilePicker();
      await appPath.rebind();
      addTearDown(() {
        FilePickerPlatform.instance = originalPicker;
        AppPath.downloadDirectory = originalDownloadDirectory;
        AppPath.supportDirectory = originalSupportDirectory;
        AppPath.temporaryDirectory = originalTemporaryDirectory;
        AppPath.cacheDirectory = originalCacheDirectory;
      });

      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await tester.enterText(find.byType(TextField).first, 'not a link');
      await tester.ensureVisible(find.text('Import'));
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid profile URL'), findsOneWidget);
      expect(harness.container.read(profilesProvider), hasLength(1));

      await tester.ensureVisible(find.text('File'));
      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid profile URL'), findsNothing);
      expect(harness.container.read(profilesProvider), hasLength(1));
      expect(
        harness.container.read(setupSessionProvider).draft.profileId,
        harness.profile.id,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('subscription import forwards Auto and a fixed request client', (
    tester,
  ) async {
    final imports = _PendingProfilesAction();
    final harness = _harness(
      step: SetupStep.profile,
      acceptedDisclaimerVersion: disclaimerVersion,
      profileAction: imports,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container, size: const Size(1280, 880));
    expect(
      find.text(currentAppLocalizations.subscriptionClientAuto),
      findsOneWidget,
    );

    await _startLinkImport(tester, 'https://example.test/auto');
    expect(imports.requests, hasLength(1));
    final automatic = imports.requests.single;
    expect(automatic.clientSettings?.preset, SubscriptionClientPreset.auto);
    expect(automatic.select, isFalse);
    expect(automatic.reviewContext?.mounted, isTrue);
    expect(automatic.cancellation?.cancelled, isFalse);
    automatic.completion.complete(harness.profile);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(setupSessionProvider).step,
      SetupStep.coverage,
    );
    await tester.tap(find.byTooltip(currentAppLocalizations.back));
    await tester.pumpAndSettle();

    await _chooseRequestClient(
      tester,
      currentAppLocalizations.subscriptionClientClash,
    );
    await _startLinkImport(tester, 'https://example.test/fixed');
    expect(imports.requests, hasLength(2));
    final fixed = imports.requests.last;
    expect(fixed.clientSettings?.preset, SubscriptionClientPreset.clash);
    expect(fixed.link, 'https://example.test/fixed');
    expect(fixed.select, isFalse);
    fixed.completion.complete(harness.profile);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(currentProfileIdProvider),
      harness.profile.id,
    );
  });

  testWidgets('invalid custom User-Agent stays inline before preparing Core', (
    tester,
  ) async {
    final imports = _PendingProfilesAction();
    final harness = _harness(
      step: SetupStep.profile,
      acceptedDisclaimerVersion: disclaimerVersion,
      profileAction: imports,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container, size: const Size(1280, 880));
    await _chooseRequestClient(
      tester,
      currentAppLocalizations.subscriptionClientCustom,
    );
    await _startLinkImport(tester, 'https://example.test/profile');
    await tester.pumpAndSettle();
    expect(
      find.text(
        currentAppLocalizations.subscriptionClientCustomUserAgentInvalid,
      ),
      findsOneWidget,
    );
    expect(imports.requests, isEmpty);
    expect(harness.session.prepareCalls, 0);
    expect(
      harness.container.read(setupSessionProvider).draft.profileId,
      harness.profile.id,
    );
  });

  testWidgets('cancelled import cannot replace a newer pending import', (
    tester,
  ) async {
    final imports = _PendingProfilesAction();
    final harness = _harness(
      step: SetupStep.profile,
      acceptedDisclaimerVersion: disclaimerVersion,
      profileAction: imports,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container, size: const Size(1280, 880));
    await _startLinkImport(tester, 'https://example.test/first');
    final cancelled = imports.requests.single;
    final cancel = find.widgetWithText(
      TextButton,
      currentAppLocalizations.cancel,
    );
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pump();
    expect(cancelled.cancellation?.cancelled, isTrue);
    expect(
      harness.container.read(setupSessionProvider).draft.profileId,
      harness.profile.id,
    );

    await _startLinkImport(tester, 'https://example.test/retry');
    final retry = imports.requests.last;
    cancelled.completion.complete(
      Profile.normal(label: 'Late import').copyWith(id: 93),
    );
    await tester.pump();
    expect(
      harness.container.read(setupSessionProvider).draft.profileId,
      harness.profile.id,
    );
    expect(retry.cancellation?.cancelled, isFalse);
    expect(
      tester
          .widget<FilledButton>(
            find
                .widgetWithText(FilledButton, currentAppLocalizations.import)
                .first,
          )
          .onPressed,
      isNull,
    );

    final imported = Profile.normal(label: 'Retry import').copyWith(id: 94);
    harness.container.read(profilesProvider.notifier).put(imported);
    retry.completion.complete(imported);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(setupSessionProvider).draft.profileId,
      imported.id,
    );
    expect(
      harness.container.read(currentProfileIdProvider),
      harness.profile.id,
    );
    expect(
      find.widgetWithText(TextButton, currentAppLocalizations.cancel),
      findsNothing,
    );
  });

  testWidgets('disposing the wizard cancels a pending import', (tester) async {
    final imports = _PendingProfilesAction();
    final harness = _harness(
      step: SetupStep.profile,
      acceptedDisclaimerVersion: disclaimerVersion,
      profileAction: imports,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container, size: const Size(1280, 880));
    await _startLinkImport(tester, 'https://example.test/pending');
    final pending = imports.requests.single;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(pending.cancellation?.cancelled, isTrue);
    pending.completion.complete(
      Profile.normal(label: 'Disposed import').copyWith(id: 95),
    );
    await tester.pump();
    expect(
      harness.container.read(setupSessionProvider).draft.profileId,
      harness.profile.id,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('file import retries with the cached data after an age key', (
    tester,
  ) async {
    final bytes = '-----BEGIN AGE ENCRYPTED FILE-----'.codeUnits;
    final directory = Directory.systemTemp.createTempSync(
      'setup-wizard-age-retry',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/encrypted.yaml')
      ..writeAsBytesSync(bytes);
    final filePicker = _ReturningFilePicker(
      _LocalPlatformFile(file, Uint8List.fromList(bytes)),
    );
    final originalPicker = FilePickerPlatform.instance;
    final originalDownloadDirectory = AppPath.downloadDirectory;
    final originalSupportDirectory = AppPath.supportDirectory;
    final originalTemporaryDirectory = AppPath.temporaryDirectory;
    final originalCacheDirectory = AppPath.cacheDirectory;
    AppPath.downloadDirectory = () async => directory;
    AppPath.supportDirectory = () async => directory;
    AppPath.temporaryDirectory = () async => directory;
    AppPath.cacheDirectory = () async => directory;
    FilePickerPlatform.instance = filePicker;
    await appPath.rebind();
    addTearDown(() {
      FilePickerPlatform.instance = originalPicker;
      AppPath.downloadDirectory = originalDownloadDirectory;
      AppPath.supportDirectory = originalSupportDirectory;
      AppPath.temporaryDirectory = originalTemporaryDirectory;
      AppPath.cacheDirectory = originalCacheDirectory;
    });
    final importAction = _AgeRetryProfilesAction();
    final harness = _harness(
      step: SetupStep.profile,
      acceptedDisclaimerVersion: disclaimerVersion,
      profileAction: importAction,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    final fileButton = find.widgetWithText(TextButton, 'File');
    await tester.ensureVisible(fileButton);
    expect(tester.widget<TextButton>(fileButton).onPressed, isNotNull);
    expect(FilePickerPlatform.instance, same(filePicker));
    await tester.tap(fileButton);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(harness.session.prepareCalls, 1);
    expect(filePicker.calls, 1);
    expect(
      importAction.importCalls,
      1,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((item) => item.data)
          .join(' | '),
    );
    expect(
      find.text(currentAppLocalizations.setupAgeKeyDescription),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.ageSecretKeyRequiredTip),
      findsNothing,
    );
    expect(filePicker.calls, 1);
    expect(importAction.importCalls, 1);

    await tester.enterText(find.byType(TextField).last, 'AGE-SECRET-KEY-1A');
    final retry = find
        .text(currentAppLocalizations.setupLanguageContinue)
        .first;
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(filePicker.calls, 1);
    expect(importAction.importCalls, 2);
    expect(importAction.receivedKeys, ['', 'AGE-SECRET-KEY-1A']);
    expect(importAction.receivedData, bytes);
    expect(
      find.text(currentAppLocalizations.setupAgeKeyDescription),
      findsNothing,
    );
    expect(harness.container.read(setupSessionProvider).draft.profileId, 92);
  });

  testWidgets(
    'desktop results keep the receipt outside main content scrolling',
    (tester) async {
      const phases = [
        SetupPhaseResult(SetupPhase.core, status: SetupPhaseStatus.confirmed),
        SetupPhaseResult(
          SetupPhase.profile,
          status: SetupPhaseStatus.confirmed,
        ),
        SetupPhaseResult(
          SetupPhase.connection,
          status: SetupPhaseStatus.confirmed,
        ),
        SetupPhaseResult(SetupPhase.route, status: SetupPhaseStatus.confirmed),
      ];
      final harness = _harness(
        step: SetupStep.result,
        acceptedDisclaimerVersion: disclaimerVersion,
        regionCode: 'RU',
        regionChosen: true,
        report: SetupReport(
          verdict: SetupVerdict.connected,
          chains: const ['DIRECT', 'Route Alpha'],
          phases: phases,
          error: List.filled(
            40,
            'Diagnostic details keep the result content long.',
          ).join('\n'),
        ),
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, size: const Size(1280, 820));

      expect(
        find.text(currentAppLocalizations.setupReceipt).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Wizard profile').hitTestable(), findsOneWidget);
      expect(
        find.text(currentAppLocalizations.setupCoverageAll).hitTestable(),
        findsOneWidget,
      );
      final receiptCard = find.ancestor(
        of: find.text(currentAppLocalizations.setupReceipt),
        matching: find.byType(CommonCard),
      );
      expect(
        find
            .descendant(
              of: receiptCard.first,
              matching: find.text(currentAppLocalizations.setupConfirmed),
            )
            .hitTestable(),
        findsOneWidget,
      );
      expect(
        find.text(currentAppLocalizations.regionRussia).hitTestable(),
        findsOneWidget,
      );
      expect(
        find
            .descendant(
              of: receiptCard.first,
              matching: find.text('Route Alpha › DIRECT'),
            )
            .hitTestable(),
        findsOneWidget,
      );

      await tester.dragFrom(const Offset(600, 700), const Offset(0, -1400));
      await tester.pumpAndSettle();

      expect(find.text('Wizard profile').hitTestable(), findsOneWidget);
      expect(
        find
            .descendant(
              of: receiptCard.first,
              matching: find.text('Route Alpha › DIRECT'),
            )
            .hitTestable(),
        findsOneWidget,
      );
      for (final phase in [
        currentAppLocalizations.setupPhaseCore,
        currentAppLocalizations.setupPhaseProfile,
        currentAppLocalizations.setupPhaseConnection,
        currentAppLocalizations.setupPhaseRoute,
      ]) {
        expect(find.text(phase), findsOneWidget);
      }
      await tester.ensureVisible(
        find.text(currentAppLocalizations.setupPhaseCore),
      );
      await tester.pumpAndSettle();
      for (final phase in [
        currentAppLocalizations.setupPhaseCore,
        currentAppLocalizations.setupPhaseProfile,
        currentAppLocalizations.setupPhaseConnection,
        currentAppLocalizations.setupPhaseRoute,
      ]) {
        expect(find.text(phase).hitTestable(), findsOneWidget);
      }
      expect(
        find.widgetWithText(FilledButton, 'Done').hitTestable(),
        findsOneWidget,
      );
      expect(
        find
            .widgetWithText(TextButton, currentAppLocalizations.setupRepeat)
            .hitTestable(),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'phone receipt stays available and opens without changing setup',
    (tester) async {
      final harness = _harness(
        step: SetupStep.result,
        acceptedDisclaimerVersion: disclaimerVersion,
        regionCode: 'RU',
        regionChosen: true,
        report: SetupReport(
          verdict: SetupVerdict.connected,
          chains: const ['DIRECT', 'Route Alpha'],
          error: List.filled(
            40,
            'Diagnostic details keep the result content long.',
          ).join('\n'),
        ),
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      final initialDraft = harness.container.read(setupSessionProvider).draft;
      final initialSettings = harness.container.read(appSettingProvider);

      await tester.dragFrom(const Offset(195, 520), const Offset(0, -1200));
      await tester.pumpAndSettle();

      final receiptTitle = find.byTooltip(currentAppLocalizations.setupReceipt);
      expect(receiptTitle.hitTestable(), findsOneWidget);
      await tester.tap(receiptTitle);
      await tester.pumpAndSettle();

      expect(
        find.text(currentAppLocalizations.setupReceiptCoverage).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Route Alpha › DIRECT').hitTestable(), findsOneWidget);
      expect(
        harness.container.read(setupSessionProvider).draft.profileId,
        initialDraft.profileId,
      );
      expect(
        harness.container.read(setupSessionProvider).draft.coverage,
        initialDraft.coverage,
      );
      expect(
        harness.container.read(setupSessionProvider).draft.regionCode,
        initialDraft.regionCode,
      );
      expect(
        harness.container.read(setupSessionProvider).draft.regionChosen,
        initialDraft.regionChosen,
      );
      expect(
        harness.container.read(appSettingProvider).regionCode,
        initialSettings.regionCode,
      );
      expect(
        harness.container.read(appSettingProvider).setupCompleted,
        initialSettings.setupCompleted,
      );

      expect(find.text(currentAppLocalizations.server), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(currentAppLocalizations.server), findsNothing);
      expect(receiptTitle.hitTestable(), findsOneWidget);
      expect(
        harness.container.read(setupSessionProvider).draft.profileId,
        initialDraft.profileId,
      );
      expect(
        harness.container.read(appSettingProvider).regionCode,
        initialSettings.regionCode,
      );
    },
  );

  testWidgets(
    'unconfirmed results do not show an actual route in the receipt',
    (tester) async {
      final harness = _harness(
        step: SetupStep.result,
        acceptedDisclaimerVersion: disclaimerVersion,
        report: const SetupReport(
          verdict: SetupVerdict.unconfirmed,
          chains: ['Route Alpha'],
        ),
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, size: const Size(1280, 820));

      expect(find.text('Route Alpha'), findsNothing);
    },
  );

  testWidgets('local proxy result displays the configured address', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.result,
      acceptedDisclaimerVersion: disclaimerVersion,
      coverage: SetupCoverage.local,
      report: const SetupReport(
        verdict: SetupVerdict.local,
        connectionActive: true,
      ),
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);
    final port = harness.container.read(patchClashConfigProvider).mixedPort;

    expect(find.text('Local proxy is ready'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text('http://127.0.0.1:$port'), findsOneWidget);
  });

  testWidgets('region step suggests the detected region as a draft only', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.region,
      acceptedDisclaimerVersion: disclaimerVersion,
      coverage: SetupCoverage.system,
      regionChosen: false,
      actualRegionCode: 'RU',
      suggestedRegionCode: 'IR',
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);
    final savedConfig = harness.container.read(patchClashConfigProvider);
    final l = currentAppLocalizations;

    expect(find.byType(SelectionCheck), findsNothing);
    expect(find.text(l.setupRecommended), findsOneWidget);
    expect(find.text(l.setupDirectTitle), findsNothing);

    await tester.tap(find.text('Iran'));
    await tester.pumpAndSettle();

    expect(find.byType(SelectionCheck), findsOneWidget);
    expect(find.text('GEOSITE,category-ir,DIRECT'), findsOneWidget);
    expect(find.text(l.regionChangesTitle), findsOneWidget);
    expect(harness.container.read(setupSessionProvider).draft.regionCode, 'IR');
    expect(harness.container.read(appSettingProvider).regionCode, 'RU');
    expect(harness.container.read(patchClashConfigProvider), savedConfig);

    final neutral = find.text(l.setupRegionNeutral);
    await tester.ensureVisible(neutral);
    await tester.tap(neutral);
    await tester.pumpAndSettle();

    final draft = harness.container.read(setupSessionProvider).draft;
    expect(draft.regionChosen, isTrue);
    expect(draft.regionCode, isNull);
    expect(find.text(l.setupDirectTitle), findsNothing);
    expect(harness.container.read(appSettingProvider).regionCode, 'RU');
  });

  testWidgets('direct routes switch keeps the region and drops the preset', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.region,
      acceptedDisclaimerVersion: disclaimerVersion,
      regionCode: 'RU',
      regionChosen: true,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    final toggle = find.byType(Switch);
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    final draft = harness.container.read(setupSessionProvider).draft;
    expect(draft.directRoutes, isFalse);
    expect(draft.regionCode, 'RU');
    expect(
      harness.container.read(appSettingProvider).setupDirectRoutes,
      isFalse,
    );
  });

  testWidgets('back from region returns to coverage with the draft kept', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.region,
      acceptedDisclaimerVersion: disclaimerVersion,
      coverage: SetupCoverage.system,
      regionCode: 'CN',
      regionChosen: true,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    await tester.tap(find.byTooltip(currentAppLocalizations.back));
    await tester.pumpAndSettle();

    final state = harness.container.read(setupSessionProvider);
    expect(state.step, SetupStep.coverage);
    expect(state.draft.regionCode, 'CN');
    expect(state.draft.coverage, SetupCoverage.system);

    await tester.tap(find.text(currentAppLocalizations.setupLanguageContinue));
    await tester.pumpAndSettle();
    expect(harness.container.read(setupSessionProvider).step, SetupStep.region);
  });

  testWidgets('confirmed and saved results hide save-without-connection', (
    tester,
  ) async {
    for (final report in [
      const SetupReport(
        verdict: SetupVerdict.connected,
        connectionActive: true,
      ),
      const SetupReport(verdict: SetupVerdict.saved),
    ]) {
      final harness = _harness(
        step: SetupStep.result,
        acceptedDisclaimerVersion: disclaimerVersion,
        report: report,
      );
      await _pumpWizard(tester, harness.container);
      expect(find.text('Save without connecting'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      harness.container.dispose();
    }
  });

  testWidgets('unconfirmed result offers a back action', (tester) async {
    final harness = _harness(
      step: SetupStep.result,
      acceptedDisclaimerVersion: disclaimerVersion,
      report: const SetupReport(verdict: SetupVerdict.unconfirmed),
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    final change = find.text(currentAppLocalizations.setupChangeSettings);
    expect(change, findsOneWidget);
    await tester.tap(change);
    await tester.pumpAndSettle();
    expect(harness.container.read(setupSessionProvider).step, SetupStep.region);
  });

  testWidgets('failed result offers the localized back action', (tester) async {
    final harness = _harness(
      step: SetupStep.result,
      acceptedDisclaimerVersion: disclaimerVersion,
      report: const SetupReport(verdict: SetupVerdict.failed),
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    expect(
      find.text(currentAppLocalizations.setupChangeSettings),
      findsOneWidget,
    );
  });
}

class _CancelledFilePicker extends FilePickerPlatform {
  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => null;
}
