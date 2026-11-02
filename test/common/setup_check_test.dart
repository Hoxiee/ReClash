import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/models/models.dart';

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
        resumableSetupStep(SetupStep.region.index, accepted: true),
        SetupStep.region,
      );
      expect(
        resumableSetupStep(SetupStep.coverage.index, accepted: true),
        SetupStep.coverage,
      );
      expect(
        resumableSetupStep(SetupStep.summary.index, accepted: true),
        SetupStep.summary,
      );
      expect(resumableSetupStep(99, accepted: true), SetupStep.summary);
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

  group('SetupDraft.withRegion', () {
    const packages = ['a.b', 'c.d'];
    final draft = const SetupDraft(
      coverage: SetupCoverage.tun,
      regionCode: 'RU',
      regionChosen: true,
    ).withDirectApps(packages);

    test('keeps found apps when the region stays the same', () {
      expect(draft.withRegion('RU').directApps, packages);
    });

    test('clears found apps when the region changes', () {
      expect(draft.withRegion('IR').directApps, isNull);
      expect(draft.withRegion(null).directApps, isNull);
    });
  });
}
