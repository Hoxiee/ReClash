import 'package:reclash/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StartupCoordinator', () {
    test('runs optional effects only after mandatory readiness', () async {
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
        'setup',
        'disclaimer',
        'recovery',
        'crashlytics',
        'core',
        'runtime',
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

    test('stops before Core when consent is rejected', () async {
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
      expect(events, ['preferences', 'setup', 'disclaimer']);
    });
  });
}
