import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/route_state.dart';

void main() {
  group('resumableSetupStep', () {
    test('keeps language and agreement gates in front of saved steps', () {
      expect(resumableSetupStep(-1, accepted: false), SetupStep.language);
      expect(
        resumableSetupStep(SetupStep.language.index, accepted: true),
        SetupStep.language,
      );
      expect(
        resumableSetupStep(SetupStep.profile.index, accepted: false),
        SetupStep.agreement,
      );
      expect(
        resumableSetupStep(SetupStep.agreement.index, accepted: true),
        SetupStep.profile,
      );
      expect(
        resumableSetupStep(SetupStep.checking.index, accepted: true),
        SetupStep.region,
      );
      expect(
        resumableSetupStep(SetupStep.coverage.index, accepted: true),
        SetupStep.coverage,
      );
      expect(resumableSetupStep(99, accepted: true), SetupStep.region);
    });
  });

  group('initializeSetupSettings', () {
    test('uses persisted setup status when already initialized', () {
      const settings = AppSettingProps(setupCompleted: false, setupStep: 4);
      expect(
        initializeSetupSettings(settings, installed: true, hasProfiles: true),
        settings,
      );
    });

    test('recognizes an installed legacy app from consent or profiles', () {
      expect(
        initializeSetupSettings(
          const AppSettingProps(acceptedDisclaimerVersion: 1),
          installed: true,
          hasProfiles: false,
        ).setupCompleted,
        isTrue,
      );
      expect(
        initializeSetupSettings(
          const AppSettingProps(),
          installed: true,
          hasProfiles: true,
        ).setupCompleted,
        isTrue,
      );
    });

    test('does not infer setup completion for an unmarked install', () {
      final initialized = initializeSetupSettings(
        const AppSettingProps(),
        installed: true,
        hasProfiles: false,
      );
      expect(initialized.setupCompleted, isFalse);
      expect(initialized.setupStep, 0);
    });

    test('a fresh install remains incomplete despite profile data', () {
      expect(
        initializeSetupSettings(
          const AppSettingProps(acceptedDisclaimerVersion: 3),
          installed: false,
          hasProfiles: true,
        ).setupCompleted,
        isFalse,
      );
    });
  });

  test('a saved explicit neutral region differs from no choice', () {
    const undecided = SetupDraft(coverage: SetupCoverage.local);
    final neutral = undecided.withRegion(null);
    expect(undecided.regionChosen, isFalse);
    expect(neutral.regionChosen, isTrue);
    expect(neutral.regionCode, isNull);
  });

  group('SetupReport', () {
    test('only confirmed outcomes count as confirmed', () {
      for (final verdict in [
        SetupVerdict.connected,
        SetupVerdict.partial,
        SetupVerdict.local,
      ]) {
        expect(SetupReport(verdict: verdict).confirmed, isTrue);
      }
      for (final verdict in SetupVerdict.values) {
        if (verdict == SetupVerdict.connected ||
            verdict == SetupVerdict.partial ||
            verdict == SetupVerdict.local) {
          continue;
        }
        expect(SetupReport(verdict: verdict).confirmed, isFalse);
      }
    });

    test('stale reports retain phase evidence but discard the route stamp', () {
      const report = SetupReport(
        verdict: SetupVerdict.connected,
        phases: [
          SetupPhaseResult(
            SetupPhase.route,
            status: SetupPhaseStatus.confirmed,
          ),
        ],
        stamp: RouteStamp(
          coreEpoch: 2,
          routeVersion: 3,
          hostEpoch: 4,
          proxied: true,
        ),
        connectionActive: true,
      );

      final stale = report.asStale();

      expect(stale.verdict, SetupVerdict.stale);
      expect(stale.phases, report.phases);
      expect(stale.stamp, isNull);
      expect(stale.connectionActive, isTrue);
      expect(stale.confirmed, isFalse);
    });
  });
}
