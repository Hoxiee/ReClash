import 'dart:async';

import 'package:reclash/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StartupCoordinator', () {
    test('starts Core before setup needs profile validation', () async {
      final events = <String>[];
      final coreReady = Completer<void>();

      final outcome = await const StartupCoordinator().run(
        startCore: () async {
          events.add('core-start');
          await coreReady.future;
          events.add('core-ready');
        },
        handleFailedPreference: () async {
          events.add('preferences');
          return true;
        },
        handleSetupWizard: () async {
          events.add('setup');
          coreReady.complete();
          await Future<void>.delayed(Duration.zero);
          events.add('profile-validated');
        },
        handleDisclaimer: () async {
          events.add('disclaimer');
          return true;
        },
        showCrashRecoveryTip: () async => events.add('recovery'),
        showCrashlyticsTip: () async => events.add('crashlytics'),
        initializeRuntime: () async => events.add('runtime'),
        applyWindowVisibility: () async => events.add('visibility'),
        startOptionalEffects: () => events.add('optional'),
      );

      expect(outcome, StartupOutcome.completed);
      expect(events, [
        'preferences',
        'core-start',
        'setup',
        'core-ready',
        'profile-validated',
        'disclaimer',
        'recovery',
        'crashlytics',
        'runtime',
        'visibility',
        'optional',
      ]);
    });

    test('Linux visibility completes before runtime authorization', () async {
      final events = <String>[];
      final visibilityStarted = Completer<void>();
      final visibilityReady = Completer<void>();

      final startup = const StartupCoordinator().run(
        startCore: () async => events.add('core'),
        handleFailedPreference: () async {
          events.add('preferences');
          return true;
        },
        handleSetupWizard: () async => events.add('setup'),
        handleDisclaimer: () async {
          events.add('disclaimer');
          return true;
        },
        showCrashRecoveryTip: () async => events.add('recovery'),
        showCrashlyticsTip: () async => events.add('crashlytics'),
        initializeRuntime: () async => events.add('runtime'),
        applyWindowVisibility: () async {
          events.add('visibility-start');
          visibilityStarted.complete();
          await visibilityReady.future;
          events.add('visibility-ready');
        },
        startOptionalEffects: () => events.add('optional'),
        showWindowBeforeRuntime: true,
      );

      await visibilityStarted.future;
      expect(events, [
        'preferences',
        'core',
        'setup',
        'disclaimer',
        'recovery',
        'crashlytics',
        'visibility-start',
      ]);

      visibilityReady.complete();
      expect(await startup, StartupOutcome.completed);
      expect(events, [
        'preferences',
        'core',
        'setup',
        'disclaimer',
        'recovery',
        'crashlytics',
        'visibility-start',
        'visibility-ready',
        'runtime',
        'optional',
      ]);
    });

    test('default visibility waits for runtime initialization', () async {
      final events = <String>[];
      final runtimeStarted = Completer<void>();
      final runtimeReady = Completer<void>();

      final startup = const StartupCoordinator().run(
        startCore: () async => events.add('core'),
        handleFailedPreference: () async {
          events.add('preferences');
          return true;
        },
        handleSetupWizard: () async => events.add('setup'),
        handleDisclaimer: () async {
          events.add('disclaimer');
          return true;
        },
        showCrashRecoveryTip: () async => events.add('recovery'),
        showCrashlyticsTip: () async => events.add('crashlytics'),
        initializeRuntime: () async {
          events.add('runtime-start');
          runtimeStarted.complete();
          await runtimeReady.future;
          events.add('runtime-ready');
        },
        applyWindowVisibility: () async => events.add('visibility'),
        startOptionalEffects: () => events.add('optional'),
      );

      await runtimeStarted.future;
      expect(events, [
        'preferences',
        'core',
        'setup',
        'disclaimer',
        'recovery',
        'crashlytics',
        'runtime-start',
      ]);

      runtimeReady.complete();
      expect(await startup, StartupOutcome.completed);
      expect(events, [
        'preferences',
        'core',
        'setup',
        'disclaimer',
        'recovery',
        'crashlytics',
        'runtime-start',
        'runtime-ready',
        'visibility',
        'optional',
      ]);
    });

    test('stops before Core when preferences require exit', () async {
      final events = <String>[];

      final outcome = await const StartupCoordinator().run(
        startCore: () async => events.add('core'),
        handleFailedPreference: () async {
          events.add('preferences');
          return false;
        },
        handleSetupWizard: () async => events.add('setup'),
        handleDisclaimer: () async => true,
        showCrashRecoveryTip: () async => events.add('recovery'),
        showCrashlyticsTip: () async => events.add('crashlytics'),
        initializeRuntime: () async => events.add('runtime'),
        applyWindowVisibility: () async => events.add('visibility'),
        startOptionalEffects: () => events.add('optional'),
      );

      expect(outcome, StartupOutcome.exitRequested);
      expect(events, ['preferences']);
    });

    test('waits for Core before exiting after rejected consent', () async {
      final events = <String>[];

      final outcome = await const StartupCoordinator().run(
        startCore: () async => events.add('core'),
        handleFailedPreference: () async {
          events.add('preferences');
          return true;
        },
        handleSetupWizard: () async => events.add('setup'),
        handleDisclaimer: () async {
          events.add('disclaimer');
          return false;
        },
        showCrashRecoveryTip: () async => events.add('recovery'),
        showCrashlyticsTip: () async => events.add('crashlytics'),
        initializeRuntime: () async => events.add('runtime'),
        applyWindowVisibility: () async => events.add('visibility'),
        startOptionalEffects: () => events.add('optional'),
      );

      expect(outcome, StartupOutcome.exitRequested);
      expect(events, ['preferences', 'core', 'setup', 'disclaimer']);
    });
  });
}
