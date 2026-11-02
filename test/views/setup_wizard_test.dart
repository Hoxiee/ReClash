import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/ui/input.dart';
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
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/list.dart';
import 'package:reclash/ui/selection_mark.dart';
import 'package:reclash/views/setup.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestSetupSession extends SetupSession {
  _TestSetupSession({
    required this.step,
    required this.profileId,
    this.coverage = SetupCoverage.tun,
    this.regionCode,
    this.regionChosen = false,
    this.android = false,
  });

  final SetupStep step;
  final int? profileId;
  final SetupCoverage coverage;
  final String? regionCode;
  final bool regionChosen;
  final bool android;
  var prepareCalls = 0;
  var startCalls = 0;
  var skipCalls = 0;
  final finishCalls = <({bool connect, bool autoRun})>[];
  final scannedRegions = <String>[];

  @override
  SetupSessionState build() {
    final base = super.build();
    return base.copyWith(
      step: step,
      draft: regionChosen
          ? SetupDraft(
              profileId: profileId,
              coverage: coverage,
              regionCode: regionCode,
              regionChosen: true,
            )
          : base.draft.withProfile(profileId).withCoverage(coverage),
    );
  }

  @override
  bool get isAndroid => android;

  @override
  Future<bool> saveConfig(Config config) async => true;

  @override
  Future<bool> prepareCore() async {
    prepareCalls++;
    return true;
  }

  @override
  Future<void> startConnection() async => startCalls++;

  @override
  Future<bool> applyProfile() async => true;

  @override
  Future<void> addDirectRules(List<String> rawRules) async {}

  @override
  Future<List<String>?> domesticPackages(String regionCode) async {
    scannedRegions.add(regionCode);
    return ['ru.bank'];
  }

  @override
  Future<bool> skip() {
    skipCalls++;
    return super.skip();
  }

  @override
  Future<bool> finish({required bool connect, required bool autoRun}) {
    finishCalls.add((connect: connect, autoRun: autoRun));
    return super.finish(connect: connect, autoRun: autoRun);
  }
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

  final PlatformFile? file;
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
  String? regionCode,
  bool regionChosen = false,
  bool safeMode = false,
  bool profileSelected = true,
  bool android = false,
  String? locale = 'en',
  String? suggestedRegionCode,
  ProfilesAction? profileAction,
}) {
  final profile = Profile.normal(label: 'Wizard profile');
  final session = _TestSetupSession(
    step: step,
    profileId: profileSelected ? profile.id : null,
    coverage: coverage,
    regionCode: regionCode,
    regionChosen: regionChosen,
    android: android,
  );
  final settings = AppSettingProps(
    setupCompleted: false,
    acceptedDisclaimerVersion: acceptedDisclaimerVersion,
    locale: locale,
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

const _phone = Size(412, 915);
const _desktop = Size(1280, 800);

Future<void> _pumpWizard(
  WidgetTester tester,
  ProviderContainer container, {
  Size size = _phone,
  double textScale = 1,
  bool android = false,
  bool tv = false,
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
            child: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: SetupWizard(isAndroid: android, isTV: tv),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

FilledButton _primary(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, label).last);

Future<void> _openImport(WidgetTester tester) async {
  if (find.byType(TextField).evaluate().isNotEmpty) return;
  await _tap(
    tester,
    find.text(currentAppLocalizations.setupProfileImportAnother),
  );
}

Future<void> _startLinkImport(WidgetTester tester, String link) async {
  await _openImport(tester);
  final field = find.byType(TextField).first;
  await tester.ensureVisible(field);
  await tester.enterText(field, link);
  await tester.pump();
  final button = find
      .widgetWithText(FilledButton, currentAppLocalizations.setupProfileAdd)
      .last;
  await tester.tap(button);
  await tester.pump();
}

Future<void> _expandRequestOptions(WidgetTester tester) async {
  await _openImport(tester);
  final disclosure = find.text(currentAppLocalizations.setupProfileOptions);
  await _tap(tester, disclosure);
}

Future<void> _chooseRequestClient(WidgetTester tester, String label) async {
  final requestAs = find.text(
    currentAppLocalizations.subscriptionClientRequestAs,
  );
  await _tap(tester, requestAs);
  await _tap(tester, find.text(label).last);
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

  group('layout', () {
    for (final (name, size, scale) in [
      ('phone', _phone, 1.0),
      ('phone with large text', _phone, 1.3),
      ('desktop', _desktop, 1.0),
    ]) {
      testWidgets('no step overflows on a $name', (tester) async {
        for (final step in SetupStep.values) {
          final harness = _harness(
            step: step,
            acceptedDisclaimerVersion: disclaimerVersion,
            coverage: step == SetupStep.summary
                ? SetupCoverage.local
                : SetupCoverage.tun,
            regionCode: 'RU',
            regionChosen: true,
          );
          addTearDown(harness.container.dispose);
          await _pumpWizard(
            tester,
            harness.container,
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull, reason: '$step');
          await tester.pumpWidget(const SizedBox.shrink());
        }
      });
    }

    testWidgets('profile step stays within bounds while importing', (
      tester,
    ) async {
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, textScale: 1.3);

      await _expandRequestOptions(tester);

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('no step offers a close button', (tester) async {
    final l = currentAppLocalizations;
    for (final step in SetupStep.values) {
      final harness = _harness(
        step: step,
        acceptedDisclaimerVersion: disclaimerVersion,
        coverage: SetupCoverage.local,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(find.byType(CloseButton), findsNothing, reason: '$step');
      expect(find.byTooltip(l.close), findsNothing, reason: '$step');
      expect(
        find.byWidgetPredicate(
          (widget) => widget is GlyphIcon && widget.glyph == AppGlyphs.close,
        ),
        findsNothing,
        reason: '$step',
      );
      for (final button in tester.widgetList<IconButton>(
        find.byType(IconButton),
      )) {
        expect(
          button.tooltip,
          anyOf(l.back, l.setupCopyProxy),
          reason: '$step',
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  group('skip', () {
    testWidgets('is hidden until the agreement is accepted', (tester) async {
      final harness = _harness(step: SetupStep.agreement);
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(
        find.bySemanticsLabel(currentAppLocalizations.setupSkip),
        findsNothing,
      );
    });

    testWidgets('hovering reveals the label', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      expect(find.text(l.setupSkip), findsNothing);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.bySemanticsLabel(l.setupSkip)));
      await tester.pumpAndSettle();

      expect(find.text(l.setupSkip), findsOneWidget);
    });

    testWidgets('remote focus reveals the label', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, android: true, tv: true);
      expect(find.text(l.setupSkip), findsNothing);

      final skip = find.descendant(
        of: find.bySemanticsLabel(l.setupSkip),
        matching: find.byType(InkWell),
      );
      Focus.of(
        tester.element(
          find.descendant(of: skip, matching: find.byType(SizedBox)).first,
        ),
      ).requestFocus();
      await tester.pumpAndSettle();

      expect(find.text(l.setupSkip), findsOneWidget);
    });

    testWidgets('is shown after consent and confirms before skipping', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await tester.tap(find.bySemanticsLabel(l.setupSkip));
      await tester.pumpAndSettle();
      expect(find.text(l.setupSkipTitle), findsOneWidget);
      expect(harness.session.skipCalls, 0);

      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();
      expect(harness.session.skipCalls, 0);
      expect(harness.container.read(setupSessionProvider).active, isTrue);

      await tester.tap(find.bySemanticsLabel(l.setupSkip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.setupSkip).last);
      await tester.pumpAndSettle();

      expect(harness.session.skipCalls, 1);
      expect(harness.container.read(appSettingProvider).setupCompleted, isTrue);
      expect(harness.container.read(setupSessionProvider).active, isFalse);
    });
  });

  group('profile step', () {
    testWidgets('a TV takes the link from a phone instead of a camera', (
      tester,
    ) async {
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, android: true, tv: true);
      await _openImport(tester);
      final l = currentAppLocalizations;

      expect(find.text(l.sendFromPhone), findsOneWidget);
      expect(find.text(l.qrcode), findsNothing);
      expect(find.text(l.file), findsOneWidget);
    });

    testWidgets('a selected profile enables Continue', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(find.text('Wizard profile'), findsOneWidget);
      expect(find.byType(SelectionCheck), findsOneWidget);
      expect(find.text(l.setupProfileWithout), findsNothing);
      await _tap(tester, find.text(l.setupLanguageContinue));
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.coverage,
      );
    });

    testWidgets('profiles without a selection disable Add profile and allow '
        'continuing without one', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileSelected: false,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(_primary(tester, l.setupProfileAdd).onPressed, isNull);
      expect(find.byType(SelectionCheck), findsNothing);

      await _tap(tester, find.text(l.setupProfileWithout));

      final state = harness.container.read(setupSessionProvider);
      expect(state.step, SetupStep.coverage);
      expect(state.draft.profileId, isNull);
    });

    testWidgets('tapping a profile selects it', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileSelected: false,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await _tap(tester, find.text('Wizard profile'));

      expect(
        harness.container.read(setupSessionProvider).draft.profileId,
        harness.profile.id,
      );
      expect(_primary(tester, l.setupLanguageContinue).onPressed, isNotNull);
    });

    testWidgets('Add profile enables once the link field has text', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileSelected: false,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      await _openImport(tester);

      expect(_primary(tester, l.setupProfileAdd).onPressed, isNull);
      await tester.enterText(find.byType(TextField).first, 'https://x.test/a');
      await tester.pump();

      expect(_primary(tester, l.setupProfileAdd).onPressed, isNotNull);
    });

    testWidgets('a successful import stays on the step and selects the new '
        'profile', (tester) async {
      final imports = _PendingProfilesAction();
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileAction: imports,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      final imported = Profile.normal(label: 'Fresh import');
      harness.container.read(profilesProvider.notifier).put(imported);

      await _startLinkImport(tester, 'https://example.test/new');
      imports.requests.single.completion.complete(imported);
      await tester.pumpAndSettle();

      final state = harness.container.read(setupSessionProvider);
      expect(state.step, SetupStep.profile);
      expect(state.draft.profileId, imported.id);
      final row = find.ancestor(
        of: find.text('Fresh import'),
        matching: find.byType(DecorationListItem),
      );
      expect(
        find.descendant(of: row, matching: find.byType(SelectionCheck)),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets(
      'subscription import forwards Auto and a fixed request client',
      (tester) async {
        final imports = _PendingProfilesAction();
        final harness = _harness(
          step: SetupStep.profile,
          acceptedDisclaimerVersion: disclaimerVersion,
          profileAction: imports,
        );
        addTearDown(harness.container.dispose);
        await _pumpWizard(tester, harness.container, size: _desktop);
        await _expandRequestOptions(tester);
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
          SetupStep.profile,
        );

        await _openImport(tester);
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
          harness.container.read(setupSessionProvider).draft.profileId,
          harness.profile.id,
        );
      },
    );

    testWidgets('submitting the link field starts the import', (tester) async {
      final imports = _PendingProfilesAction();
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileAction: imports,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      await _openImport(tester);

      await tester.enterText(find.byType(TextField).first, 'https://x.test/s');
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pump();

      expect(imports.requests.single.link, 'https://x.test/s');
    });

    testWidgets(
      'invalid custom User-Agent stays inline before preparing Core',
      (tester) async {
        final imports = _PendingProfilesAction();
        final harness = _harness(
          step: SetupStep.profile,
          acceptedDisclaimerVersion: disclaimerVersion,
          profileAction: imports,
        );
        addTearDown(harness.container.dispose);
        await _pumpWizard(tester, harness.container, size: _desktop);
        await _expandRequestOptions(tester);
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
      },
    );

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
      await _pumpWizard(tester, harness.container, size: _desktop);
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
        _primary(tester, currentAppLocalizations.setupProfileAdd).onPressed,
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

    testWidgets('disposing the wizard cancels a pending import', (
      tester,
    ) async {
      final imports = _PendingProfilesAction();
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileAction: imports,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, size: _desktop);
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

    testWidgets('an invalid link shows an inline error and a cancelled file '
        'pick is inert', (tester) async {
      final imports = _PendingProfilesAction();
      final filePicker = _ReturningFilePicker(null);
      final originalPicker = FilePickerPlatform.instance;
      final directory = Directory.systemTemp.createTempSync('setup-wizard-nil');
      addTearDown(() => directory.deleteSync(recursive: true));
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
      final harness = _harness(
        step: SetupStep.profile,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileAction: imports,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      final l = currentAppLocalizations;

      await _startLinkImport(tester, 'not a profile link');
      await tester.pumpAndSettle();

      expect(find.text(l.profileUrlInvalidValidationDesc), findsOneWidget);
      expect(imports.requests, isEmpty);
      expect(harness.session.prepareCalls, 0);
      expect(harness.container.read(profilesProvider), hasLength(1));

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();
      final fileTile = find.text(l.file).first;
      await tester.ensureVisible(fileTile);
      await tester.tap(fileTile);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(filePicker.calls, 1);
      expect(find.byType(ErrorBanner), findsNothing);
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.profile,
      );
      expect(harness.container.read(profilesProvider), hasLength(1));
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
      await _openImport(tester);

      final fileTile = find.text(currentAppLocalizations.file).first;
      await tester.ensureVisible(fileTile);
      await tester.tap(fileTile);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      expect(harness.session.prepareCalls, 1);
      expect(filePicker.calls, 1);
      expect(importAction.importCalls, 1);
      expect(
        find.text(currentAppLocalizations.setupAgeKeyDescription),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(find.byType(TextField).last, 'AGE-SECRET-KEY-1A');
      final keyColumn = find
          .ancestor(
            of: find.byType(SecretTextFormField),
            matching: find.byType(Column),
          )
          .first;
      final retry = find.descendant(
        of: keyColumn,
        matching: find.widgetWithText(
          FilledButton,
          currentAppLocalizations.setupLanguageContinue,
        ),
      );
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
  });

  testWidgets('selected coverage shows a check without a filled card', (
    tester,
  ) async {
    final harness = _harness(
      step: SetupStep.coverage,
      acceptedDisclaimerVersion: disclaimerVersion,
      coverage: SetupCoverage.system,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    final card = find
        .ancestor(
          of: find.text('System proxy'),
          matching: find.byType(CommonCard),
        )
        .first;
    expect(
      find.descendant(of: card, matching: find.byType(SelectionCheck)),
      findsOneWidget,
    );
    expect(find.byType(SelectionCheck), findsOneWidget);
    expect(tester.widget<CommonCard>(card).isSelected, isTrue);
    expect(tester.widget<CommonCard>(card).fillsSelection, isFalse);
  });

  testWidgets('choosing a coverage updates the draft', (tester) async {
    final harness = _harness(
      step: SetupStep.coverage,
      acceptedDisclaimerVersion: disclaimerVersion,
    );
    addTearDown(harness.container.dispose);
    await _pumpWizard(tester, harness.container);

    await _tap(tester, find.text('System proxy'));

    expect(
      harness.container.read(setupSessionProvider).draft.coverage,
      SetupCoverage.system,
    );
  });

  group('region step', () {
    testWidgets('preselects the detected region and recommends it', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.region,
        acceptedDisclaimerVersion: disclaimerVersion,
        coverage: SetupCoverage.system,
        suggestedRegionCode: 'IR',
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(
        harness.container.read(setupSessionProvider).draft.regionCode,
        'IR',
      );
      final row = find
          .ancestor(
            of: find.text('Iran'),
            matching: find.byType(DecorationListItem),
          )
          .first;
      expect(
        find.descendant(of: row, matching: find.text(l.setupRecommended)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.byType(SelectionCheck)),
        findsOneWidget,
      );
    });

    testWidgets('a manual choice replaces the preselection', (tester) async {
      final harness = _harness(
        step: SetupStep.region,
        acceptedDisclaimerVersion: disclaimerVersion,
        suggestedRegionCode: 'IR',
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await _tap(tester, find.text('Egypt'));
      await _tap(tester, find.text(currentAppLocalizations.setupRegionNeutral));

      final draft = harness.container.read(setupSessionProvider).draft;
      expect(draft.regionChosen, isTrue);
      expect(draft.regionCode, isNull);
      expect(find.text(currentAppLocalizations.setupDirectTitle), findsNothing);
    });

    testWidgets('the direct routes switch keeps the region', (tester) async {
      final harness = _harness(
        step: SetupStep.region,
        acceptedDisclaimerVersion: disclaimerVersion,
        regionCode: 'RU',
        regionChosen: true,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await _tap(tester, find.byType(Switch));

      final draft = harness.container.read(setupSessionProvider).draft;
      expect(draft.directRoutes, isFalse);
      expect(draft.regionCode, 'RU');
      expect(
        harness.container.read(appSettingProvider).setupDirectRoutes,
        isFalse,
      );
    });

    testWidgets('the rules row expands to show the preset', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.region,
        acceptedDisclaimerVersion: disclaimerVersion,
        regionCode: 'RU',
        regionChosen: true,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      expect(find.text('GEOSITE,category-ru,DIRECT'), findsNothing);

      await _tap(tester, find.text(l.setupDirectRules));

      expect(find.text('GEOSITE,category-ru,DIRECT'), findsOneWidget);
    });

    testWidgets('Android local apps are not scanned until Find is tapped', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.region,
        acceptedDisclaimerVersion: disclaimerVersion,
        regionCode: 'RU',
        regionChosen: true,
        android: true,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container, android: true);

      expect(find.text(l.setupDirectAppsTitle), findsOneWidget);
      expect(harness.session.scannedRegions, isEmpty);

      await _tap(tester, find.text(l.setupDirectAppsFind));

      expect(harness.session.scannedRegions, ['RU']);
      expect(harness.container.read(setupSessionProvider).draft.directApps, [
        'ru.bank',
      ]);
      expect(find.text(l.setupDirectApps(1)), findsOneWidget);
    });

    testWidgets('the local apps row is absent off Android', (tester) async {
      final harness = _harness(
        step: SetupStep.region,
        acceptedDisclaimerVersion: disclaimerVersion,
        regionCode: 'RU',
        regionChosen: true,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(
        find.text(currentAppLocalizations.setupDirectAppsFind),
        findsNothing,
      );
    });

    testWidgets('back returns to coverage with the draft kept', (tester) async {
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

      await tester.tap(
        find.text(currentAppLocalizations.setupLanguageContinue),
      );
      await tester.pumpAndSettle();
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.region,
      );
    });
  });

  group('summary step', () {
    testWidgets('rows navigate to their step', (tester) async {
      final l = currentAppLocalizations;
      for (final (label, step) in [
        (l.setupReceiptProfile, SetupStep.profile),
        (l.setupReceiptCoverage, SetupStep.coverage),
        (l.setupReceiptRegion, SetupStep.region),
        (l.setupDirectSection, SetupStep.region),
      ]) {
        final harness = _harness(
          step: SetupStep.summary,
          acceptedDisclaimerVersion: disclaimerVersion,
          regionCode: 'RU',
          regionChosen: true,
        );
        addTearDown(harness.container.dispose);
        await _pumpWizard(tester, harness.container);

        await _tap(tester, find.text(label));

        expect(
          harness.container.read(setupSessionProvider).step,
          step,
          reason: label,
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Connect finishes with connect on by default', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await _tap(tester, find.widgetWithText(FilledButton, l.setupConnect));

      expect(harness.session.finishCalls, [(connect: true, autoRun: false)]);
      expect(harness.session.startCalls, 1);
      expect(harness.container.read(setupSessionProvider).active, isFalse);
    });

    testWidgets('Done finishes without connecting when the switch is off', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      expect(find.widgetWithText(FilledButton, l.done), findsNothing);

      await _tap(tester, find.text(l.setupConnectNow));
      await _tap(tester, find.widgetWithText(FilledButton, l.done));

      expect(harness.session.finishCalls, [(connect: false, autoRun: false)]);
      expect(harness.session.startCalls, 0);
    });

    testWidgets('the auto-connect switch is passed to finish', (tester) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      await _tap(tester, find.text(l.setupAutoConnect));
      await _tap(tester, find.widgetWithText(FilledButton, l.setupConnect));

      expect(harness.session.finishCalls.single.autoRun, isTrue);
    });

    testWidgets('safe mode hides the connect switches and never starts', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
        safeMode: true,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(find.text(l.setupConnectNow), findsNothing);
      expect(find.text(l.setupAutoConnect), findsNothing);
      expect(find.text(l.setupSafeMode), findsOneWidget);

      await _tap(tester, find.widgetWithText(FilledButton, l.done));

      expect(harness.session.finishCalls.single.connect, isFalse);
      expect(harness.session.startCalls, 0);
      expect(harness.container.read(setupSessionProvider).active, isFalse);
    });

    testWidgets('without a profile there is nothing to connect', (
      tester,
    ) async {
      final l = currentAppLocalizations;
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
        profileSelected: false,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(find.text(l.setupConnectNow), findsNothing);
      expect(find.text(l.setupNoProfile), findsOneWidget);
      expect(find.widgetWithText(FilledButton, l.done), findsOneWidget);
    });

    testWidgets('local coverage shows the local proxy address', (tester) async {
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
        coverage: SetupCoverage.local,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);
      final port = harness.container.read(patchClashConfigProvider).mixedPort;

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('http://127.0.0.1:$port'), findsOneWidget);
    });

    testWidgets('other coverage shows no local proxy address', (tester) async {
      final harness = _harness(
        step: SetupStep.summary,
        acceptedDisclaimerVersion: disclaimerVersion,
      );
      addTearDown(harness.container.dispose);
      await _pumpWizard(tester, harness.container);

      expect(find.byType(SelectableText), findsNothing);
    });
  });
}
