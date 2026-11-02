import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/providers/state.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _TestRunTime extends RunTime {
  _TestRunTime(this.initial);

  final int? initial;

  @override
  int? build() => initial;
}

class _TestSetupSession extends SetupSession {
  _TestSetupSession({this.saveResult = true});

  bool saveResult;
  bool android = false;
  int saveCalls = 0;
  int startCalls = 0;
  int applyCalls = 0;
  final List<List<String>> directRules = [];
  List<String>? domesticApps = const [];
  final List<String> scannedRegions = [];

  @override
  bool get isAndroid => android;

  @override
  Future<bool> saveConfig(Config config) async {
    saveCalls++;
    return saveResult;
  }

  @override
  Future<void> addDirectRules(List<String> rawRules) async {
    directRules.add(rawRules);
  }

  @override
  Future<List<String>?> domesticPackages(String regionCode) async {
    scannedRegions.add(regionCode);
    return domesticApps;
  }

  @override
  Future<void> startConnection() async {
    startCalls++;
    ref.read(runTimeProvider.notifier).value = 0;
  }

  @override
  Future<bool> applyProfile() async {
    applyCalls++;
    return true;
  }
}

const _russia = AppSettingProps(
  setupCompleted: false,
  acceptedDisclaimerVersion: disclaimerVersion,
  setupStep: 5,
  setupCoverage: 'tun',
  setupRegionCode: 'RU',
  setupRegionChosen: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({
    ProviderContainer container,
    Profile profile,
    Profile other,
    _TestSetupSession session,
  })
  makeHarness({
    AppSettingProps settings = const AppSettingProps(
      setupCompleted: false,
      acceptedDisclaimerVersion: disclaimerVersion,
      setupStep: 5,
    ),
    bool running = false,
    bool safeMode = false,
    Future<RegionDetectionResult?> Function()? detect,
    _TestSetupSession? session,
  }) {
    final profile = Profile.normal(label: 'Wizard profile');
    final other = Profile.normal(label: 'Other profile');
    final setupSession = session ?? _TestSetupSession();
    final core = _MockCoreHandlerInterface();
    final container = ProviderContainer(
      overrides: [
        appSettingProvider.overrideWithBuild((_, _) => settings),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile, other])),
        runTimeProvider.overrideWith(
          () => _TestRunTime(
            running ? DateTime.now().millisecondsSinceEpoch : null,
          ),
        ),
        appVisibleProvider.overrideWithValue(true),
        coreStatusProvider.overrideWithValue(CoreStatus.connected),
        detectedRegionProvider.overrideWith(
          (_) => detect == null ? Future.value(null) : detect(),
        ),
        safeModeProvider.overrideWithValue(safeMode),
        setupSessionProvider.overrideWith(() => setupSession),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen(appSettingProvider, (_, _) {})
      ..listen(currentProfileIdProvider, (_, _) {})
      ..listen(vpnSettingProvider, (_, _) {})
      ..listen(networkSettingProvider, (_, _) {});
    return (
      container: container,
      profile: profile,
      other: other,
      session: setupSession,
    );
  }

  group('resuming', () {
    test('restores the persisted step and draft without touching live '
        'settings', () {
      final harness = makeHarness(
        settings: const AppSettingProps(
          setupCompleted: false,
          setupStep: 4,
          acceptedDisclaimerVersion: disclaimerVersion,
          setupProfileId: 72,
          setupCoverage: 'system',
          regionCode: 'CN',
          setupRegionCode: 'RU',
          setupRegionChosen: true,
        ),
      );

      final state = harness.container.read(setupSessionProvider);

      expect(state.active, isTrue);
      expect(state.step, SetupStep.region);
      expect(state.draft.profileId, 72);
      expect(state.draft.coverage, SetupCoverage.system);
      expect(state.draft.regionCode, 'RU');
      expect(state.draft.regionChosen, isTrue);
      expect(
        harness.container.read(currentProfileIdProvider),
        harness.profile.id,
      );
      expect(harness.container.read(appSettingProvider).regionCode, 'CN');
    });

    test('legacy nullable completion starts at the language step', () {
      final harness = makeHarness(
        settings: const AppSettingProps(
          acceptedDisclaimerVersion: disclaimerVersion,
          setupStep: 0,
        ),
      );

      final state = harness.container.read(setupSessionProvider);
      expect(state.active, isTrue);
      expect(state.step, SetupStep.language);
    });

    test('profiles on hand do not skip any step', () async {
      final harness = makeHarness(
        settings: const AppSettingProps(
          setupCompleted: false,
          acceptedDisclaimerVersion: disclaimerVersion,
          setupStep: 2,
        ),
      );
      final session = harness.container.read(setupSessionProvider.notifier);
      SetupStep step() => harness.container.read(setupSessionProvider).step;

      expect(step(), SetupStep.profile);
      for (final next in [
        SetupStep.coverage,
        SetupStep.region,
        SetupStep.summary,
      ]) {
        expect(await session.next(next), isTrue);
        expect(step(), next);
      }
    });
  });

  group('region detection', () {
    test('waits until a shown wizard asks for it', () async {
      var detections = 0;
      final harness = makeHarness(
        detect: () async {
          detections++;
          return null;
        },
      );
      harness.container.listen(setupSessionProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(detections, 0);

      harness.container
          .read(setupSessionProvider.notifier)
          .followDetectedRegion();
      await Future<void>.delayed(Duration.zero);
      expect(detections, 1);
    });

    test('preselects the detected region in the initial draft', () async {
      final harness = makeHarness(
        detect: () async =>
            const RegionDetectionResult('RU', RegionDetectionSource.timeZone),
      );
      harness.container.listen(detectedRegionProvider, (_, _) {});
      await harness.container.read(detectedRegionProvider.future);
      harness.container
          .read(setupSessionProvider.notifier)
          .followDetectedRegion();

      final draft = harness.container.read(setupSessionProvider).draft;

      expect(draft.regionCode, 'RU');
      expect(draft.regionChosen, isTrue);
    });

    test('preselects a region detected after the session started', () async {
      final detection = Completer<RegionDetectionResult?>();
      final harness = makeHarness(detect: () => detection.future);
      harness.container.listen(setupSessionProvider, (_, _) {});
      harness.container
          .read(setupSessionProvider.notifier)
          .followDetectedRegion();
      expect(
        harness.container.read(setupSessionProvider).draft.regionChosen,
        isFalse,
      );

      detection.complete(
        const RegionDetectionResult('IR', RegionDetectionSource.localeCountry),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        harness.container.read(setupSessionProvider).draft.regionCode,
        'IR',
      );
    });

    test('never overrides a region the user already chose', () async {
      final detection = Completer<RegionDetectionResult?>();
      final harness = makeHarness(detect: () => detection.future);
      harness.container.listen(setupSessionProvider, (_, _) {});
      harness.container
          .read(setupSessionProvider.notifier)
          .followDetectedRegion();
      harness.container.read(setupSessionProvider.notifier).selectRegion('CN');

      detection.complete(
        const RegionDetectionResult('RU', RegionDetectionSource.timeZone),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        harness.container.read(setupSessionProvider).draft.regionCode,
        'CN',
      );
    });

    test('never overrides an explicit neutral choice', () async {
      final detection = Completer<RegionDetectionResult?>();
      final harness = makeHarness(detect: () => detection.future);
      harness.container.listen(setupSessionProvider, (_, _) {});
      harness.container
          .read(setupSessionProvider.notifier)
          .followDetectedRegion();
      harness.container.read(setupSessionProvider.notifier).selectRegion(null);

      detection.complete(
        const RegionDetectionResult('RU', RegionDetectionSource.timeZone),
      );
      await Future<void>.delayed(Duration.zero);

      final draft = harness.container.read(setupSessionProvider).draft;
      expect(draft.regionChosen, isTrue);
      expect(draft.regionCode, isNull);
    });

    test('keeps a region saved in the settings', () async {
      final harness = makeHarness(
        settings: const AppSettingProps(
          setupCompleted: false,
          acceptedDisclaimerVersion: disclaimerVersion,
          regionCode: 'CN',
        ),
        detect: () async =>
            const RegionDetectionResult('RU', RegionDetectionSource.timeZone),
      );
      harness.container.listen(detectedRegionProvider, (_, _) {});
      await harness.container.read(detectedRegionProvider.future);
      harness.container
          .read(setupSessionProvider.notifier)
          .followDetectedRegion();

      expect(
        harness.container.read(setupSessionProvider).draft.regionCode,
        'CN',
      );
    });
  });

  group('navigation', () {
    test('next persists the step and never scans apps', () async {
      final fake = _TestSetupSession()..android = true;
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);

      expect(await session.next(SetupStep.region), isTrue);

      expect(
        harness.container.read(appSettingProvider).setupStep,
        SetupStep.region.index,
      );
      expect(fake.saveCalls, greaterThan(0));
      expect(fake.scannedRegions, isEmpty);
    });

    test('next past the agreement requires consent', () async {
      final harness = makeHarness(
        settings: const AppSettingProps(setupCompleted: false),
      );
      final session = harness.container.read(setupSessionProvider.notifier);

      expect(await session.next(SetupStep.profile), isFalse);
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.language,
      );
      expect(await session.next(SetupStep.agreement), isTrue);
    });

    test('a failed save keeps the previous step', () async {
      final fake = _TestSetupSession(saveResult: false);
      final harness = makeHarness(
        session: fake,
        settings: const AppSettingProps(
          setupCompleted: false,
          acceptedDisclaimerVersion: disclaimerVersion,
          setupStep: 2,
        ),
      );
      final session = harness.container.read(setupSessionProvider.notifier);

      expect(await session.next(SetupStep.coverage), isFalse);

      final state = harness.container.read(setupSessionProvider);
      expect(state.step, SetupStep.profile);
      expect(state.saveError, isTrue);
    });

    test('accepting the agreement stores consent and opens the profile '
        'step', () async {
      final harness = makeHarness(
        settings: const AppSettingProps(setupCompleted: false, setupStep: 1),
      );
      final session = harness.container.read(setupSessionProvider.notifier);
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.agreement,
      );

      expect(await session.acceptAgreement(), isTrue);

      expect(
        harness.container.read(appSettingProvider).acceptedDisclaimerVersion,
        disclaimerVersion,
      );
      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.profile,
      );
    });

    test(
      'draft selections persist apart from the live configuration',
      () async {
        final harness = makeHarness(
          settings: const AppSettingProps(
            setupCompleted: false,
            acceptedDisclaimerVersion: disclaimerVersion,
            regionCode: 'CN',
          ),
        );
        final session = harness.container.read(setupSessionProvider.notifier);

        session.selectProfile(harness.other.id);
        session.selectCoverage(SetupCoverage.local);
        session.selectRegion(null);
        await Future<void>.delayed(Duration.zero);

        final settings = harness.container.read(appSettingProvider);
        expect(
          harness.container.read(currentProfileIdProvider),
          harness.profile.id,
        );
        expect(settings.regionCode, 'CN');
        expect(settings.setupProfileId, harness.other.id);
        expect(settings.setupCoverage, SetupCoverage.local.name);
        expect(settings.setupRegionChosen, isTrue);
        expect(settings.setupRegionCode, isNull);
      },
    );

    test('reopen restores the saved draft at the profile step', () async {
      final harness = makeHarness(
        settings: AppSettingProps(
          setupCompleted: true,
          acceptedDisclaimerVersion: disclaimerVersion,
          regionCode: 'CN',
          setupProfileId: 81,
          setupCoverage: SetupCoverage.system.name,
          setupRegionChosen: true,
        ),
      );
      final session = harness.container.read(setupSessionProvider.notifier);

      expect(harness.container.read(setupSessionProvider).active, isFalse);
      expect(await session.reopen(), isTrue);

      final settings = harness.container.read(appSettingProvider);
      final state = harness.container.read(setupSessionProvider);
      expect(settings.setupCompleted, isFalse);
      expect(settings.regionCode, 'CN');
      expect(state.active, isTrue);
      expect(state.step, SetupStep.profile);
      expect(state.draft.profileId, 81);
      expect(state.draft.coverage, SetupCoverage.system);
      expect(state.draft.regionChosen, isTrue);
      expect(state.draft.regionCode, isNull);
    });

    test('reopen without consent starts from the language step', () async {
      final harness = makeHarness(
        settings: const AppSettingProps(setupCompleted: true),
      );

      await harness.container.read(setupSessionProvider.notifier).reopen();

      expect(
        harness.container.read(setupSessionProvider).step,
        SetupStep.language,
      );
    });
  });

  group('local apps', () {
    test('are scanned only when asked for', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank', 'ru.gov'];
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);

      await session.next(SetupStep.region);
      expect(fake.scannedRegions, isEmpty);
      expect(
        harness.container.read(setupSessionProvider).draft.directApps,
        isNull,
      );

      await session.findDirectApps();

      expect(fake.scannedRegions, ['RU']);
      expect(harness.container.read(setupSessionProvider).draft.directApps, [
        'ru.bank',
        'ru.gov',
      ]);
      expect(
        harness.container.read(setupSessionProvider).scanningApps,
        isFalse,
      );
    });

    test('a refused permission leaves the apps unset', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = null;
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);

      await session.findDirectApps();

      final state = harness.container.read(setupSessionProvider);
      expect(fake.scannedRegions, ['RU']);
      expect(state.draft.directApps, isNull);
      expect(state.error, isNull);
      expect(state.scanningApps, isFalse);
    });

    test('clearing forgets the found apps', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank'];
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);
      await session.findDirectApps();

      session.clearDirectApps();

      expect(
        harness.container.read(setupSessionProvider).draft.directApps,
        isNull,
      );
    });

    test('changing the region discards them and scans the new one', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank'];
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);
      await session.findDirectApps();

      session.selectRegion('IR');
      expect(
        harness.container.read(setupSessionProvider).draft.directApps,
        isNull,
      );
      fake.domesticApps = ['ir.bank'];
      await session.findDirectApps();

      expect(fake.scannedRegions, ['RU', 'IR']);
      expect(harness.container.read(setupSessionProvider).draft.directApps, [
        'ir.bank',
      ]);
    });

    test('are offered only on Android TUN with a chosen region of direct '
        'rules', () {
      bool offers({
        bool android = true,
        AppSettingProps settings = _russia,
        void Function(SetupSession session)? edit,
      }) {
        final fake = _TestSetupSession()..android = android;
        final harness = makeHarness(session: fake, settings: settings);
        final session = harness.container.read(setupSessionProvider.notifier);
        edit?.call(session);
        return session.offersDirectApps;
      }

      expect(offers(), isTrue);
      expect(offers(android: false), isFalse);
      expect(
        offers(settings: _russia.copyWith(setupCoverage: 'local')),
        isFalse,
      );
      expect(
        offers(settings: _russia.copyWith(setupRegionChosen: false)),
        isFalse,
      );
      expect(
        offers(settings: _russia.copyWith(setupRegionCode: null)),
        isFalse,
      );
      expect(
        offers(edit: (session) => session.selectDirectRoutes(false)),
        isFalse,
      );
    });

    test('are not scanned when they are not offered', () async {
      final fake = _TestSetupSession()..android = true;
      final harness = makeHarness(
        session: fake,
        settings: _russia.copyWith(setupCoverage: 'local'),
      );

      await harness.container
          .read(setupSessionProvider.notifier)
          .findDirectApps();

      expect(fake.scannedRegions, isEmpty);
    });
  });

  group('finish', () {
    test('only acts on the summary step', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake);
      final session = harness.container.read(setupSessionProvider.notifier);
      await session.next(SetupStep.region);

      final finished = await session.finish(connect: true, autoRun: true);

      expect(finished, isFalse);
      expect(harness.container.read(setupSessionProvider).active, isTrue);
      expect(
        harness.container.read(appSettingProvider).setupCompleted,
        isFalse,
      );
      expect(fake.startCalls, 0);
    });

    test('commits the draft once', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);
      session.selectProfile(harness.other.id);
      session.selectCoverage(SetupCoverage.local);

      expect(await session.finish(connect: false, autoRun: false), isTrue);

      final settings = harness.container.read(appSettingProvider);
      expect(
        harness.container.read(currentProfileIdProvider),
        harness.other.id,
      );
      expect(settings.regionCode, 'RU');
      expect(settings.setupCompleted, isTrue);
      expect(harness.container.read(setupSessionProvider).active, isFalse);
      expect(fake.directRules, [
        ['GEOSITE,category-ru,DIRECT', 'GEOIP,RU,DIRECT,no-resolve'],
      ]);
      final network = harness.container.read(networkSettingProvider);
      expect(network.systemProxy, isFalse);
    });

    test('adds no rules for a declined preset or a neutral region', () async {
      final declined = _TestSetupSession();
      final first = makeHarness(session: declined, settings: _russia);
      first.container
          .read(setupSessionProvider.notifier)
          .selectDirectRoutes(false);
      await first.container
          .read(setupSessionProvider.notifier)
          .finish(connect: false, autoRun: false);
      expect(declined.directRules, isEmpty);

      final neutral = _TestSetupSession();
      final second = makeHarness(
        session: neutral,
        settings: _russia.copyWith(setupRegionCode: null),
      );
      await second.container
          .read(setupSessionProvider.notifier)
          .finish(connect: false, autoRun: false);
      expect(neutral.directRules, isEmpty);
    });

    test('connect starts the connection when it is not running', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake);

      await harness.container
          .read(setupSessionProvider.notifier)
          .finish(connect: true, autoRun: false);
      await Future<void>.delayed(Duration.zero);

      expect(fake.startCalls, 1);
      expect(fake.applyCalls, 0);
    });

    test('connect re-applies the profile when already running', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake, running: true);

      await harness.container
          .read(setupSessionProvider.notifier)
          .finish(connect: true, autoRun: false);
      await Future<void>.delayed(Duration.zero);

      expect(fake.startCalls, 0);
      expect(fake.applyCalls, 1);
    });

    test('without connect nothing is started', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake);

      await harness.container
          .read(setupSessionProvider.notifier)
          .finish(connect: false, autoRun: false);
      await Future<void>.delayed(Duration.zero);

      expect(fake.startCalls, 0);
      expect(fake.applyCalls, 0);
    });

    test('safe mode completes without starting anything', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake, safeMode: true);

      final finished = await harness.container
          .read(setupSessionProvider.notifier)
          .finish(connect: true, autoRun: true);
      await Future<void>.delayed(Duration.zero);

      expect(finished, isTrue);
      expect(fake.startCalls, 0);
      expect(fake.applyCalls, 0);
    });

    test('stores auto-run only with a profile outside safe mode', () async {
      const settings = AppSettingProps(
        setupCompleted: false,
        acceptedDisclaimerVersion: disclaimerVersion,
        setupStep: 5,
        autoRun: true,
      );
      Future<bool> autoRun({bool safeMode = false, bool profile = true}) async {
        final harness = makeHarness(settings: settings, safeMode: safeMode);
        final session = harness.container.read(setupSessionProvider.notifier);
        if (!profile) session.selectProfile(null);
        await session.finish(connect: false, autoRun: true);
        return harness.container.read(appSettingProvider).autoRun;
      }

      expect(await autoRun(), isTrue);
      expect(await autoRun(safeMode: true), isFalse);
      expect(await autoRun(profile: false), isFalse);
    });

    test('a failed save keeps setup incomplete with a save error', () async {
      final fake = _TestSetupSession(saveResult: false);
      final harness = makeHarness(session: fake);

      final finished = await harness.container
          .read(setupSessionProvider.notifier)
          .finish(connect: true, autoRun: true);

      final state = harness.container.read(setupSessionProvider);
      expect(finished, isFalse);
      expect(state.active, isTrue);
      expect(state.saveError, isTrue);
      expect(
        harness.container.read(appSettingProvider).setupCompleted,
        isFalse,
      );
      expect(fake.startCalls, 0);
    });

    test('an Android VPN lets the found local apps bypass it', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank', 'ru.gov'];
      final harness = makeHarness(session: fake, settings: _russia);
      harness.container
          .read(vpnSettingProvider.notifier)
          .update(
            (props) => props.copyWith(
              accessControlProps: const AccessControlProps(
                rejectList: ['org.game'],
              ),
            ),
          );
      final session = harness.container.read(setupSessionProvider.notifier);
      await session.findDirectApps();

      await session.finish(connect: false, autoRun: false);

      final access = harness.container
          .read(vpnSettingProvider)
          .accessControlProps;
      expect(access.enable, isTrue);
      expect(access.mode, AccessControlMode.rejectSelected);
      expect(access.rejectList, ['org.game', 'ru.bank', 'ru.gov']);
    });

    test('an allow list drops the local apps instead', () async {
      final fake = _TestSetupSession()
        ..android = true
        ..domesticApps = ['ru.bank'];
      final harness = makeHarness(session: fake, settings: _russia);
      harness.container
          .read(vpnSettingProvider.notifier)
          .update(
            (props) => props.copyWith(
              accessControlProps: const AccessControlProps(
                enable: true,
                mode: AccessControlMode.acceptSelected,
                acceptList: ['ru.bank', 'org.browser'],
              ),
            ),
          );
      final session = harness.container.read(setupSessionProvider.notifier);
      await session.findDirectApps();

      await session.finish(connect: false, autoRun: false);

      final access = harness.container
          .read(vpnSettingProvider)
          .accessControlProps;
      expect(access.mode, AccessControlMode.acceptSelected);
      expect(access.acceptList, ['org.browser']);
    });
  });

  group('skip', () {
    test('requires consent', () async {
      final harness = makeHarness(
        settings: const AppSettingProps(setupCompleted: false),
      );

      final skipped = await harness.container
          .read(setupSessionProvider.notifier)
          .skip();

      expect(skipped, isFalse);
      expect(harness.container.read(setupSessionProvider).active, isTrue);
      expect(
        harness.container.read(appSettingProvider).setupCompleted,
        isFalse,
      );
    });

    test('selects the draft profile and completes without the rest of the '
        'draft', () async {
      final fake = _TestSetupSession();
      final harness = makeHarness(session: fake, settings: _russia);
      final session = harness.container.read(setupSessionProvider.notifier);
      session.selectProfile(harness.other.id);
      session.selectCoverage(SetupCoverage.local);

      expect(await session.skip(), isTrue);

      final settings = harness.container.read(appSettingProvider);
      expect(
        harness.container.read(currentProfileIdProvider),
        harness.other.id,
      );
      expect(settings.setupCompleted, isTrue);
      expect(settings.regionCode, isNull);
      expect(
        harness.container.read(networkSettingProvider).systemProxy,
        isTrue,
      );
      expect(fake.directRules, isEmpty);
      expect(fake.startCalls, 0);
      expect(harness.container.read(setupSessionProvider).active, isFalse);
    });

    test('ignores a draft profile that no longer exists', () async {
      final harness = makeHarness();
      final session = harness.container.read(setupSessionProvider.notifier);
      session.selectProfile(harness.other.id + 1000);

      expect(await session.skip(), isTrue);

      expect(
        harness.container.read(currentProfileIdProvider),
        harness.profile.id,
      );
    });
  });
}
