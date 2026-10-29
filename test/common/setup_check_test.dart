import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/route_state.dart';

final _at = DateTime(2026, 10, 29, 12);

PathResult _path({
  Map<PathStep, PathStepResult> steps = const {},
  bool finished = true,
  bool cancelled = false,
}) {
  var path = PathResult.start(PathScope.setup, _at);
  for (final step in PathScope.setup.steps) {
    path = path.withStep(
      steps[step] ?? PathStepResult(step, status: PathStepStatus.pass),
    );
  }
  return finished ? path.finish(_at, cancelled: cancelled) : path;
}

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

  group('setupVerdictOf', () {
    test('a cancelled or unfinished path is stale', () {
      expect(
        setupVerdictOf(_path(cancelled: true), coverage: SetupCoverage.tun),
        SetupVerdict.stale,
      );
      expect(
        setupVerdictOf(_path(finished: false), coverage: SetupCoverage.tun),
        SetupVerdict.stale,
      );
    });

    test('a cancelled path stays stale even with a failed step', () {
      final path = _path(
        cancelled: true,
        steps: {
          PathStep.server: const PathStepResult(
            PathStep.server,
            status: PathStepStatus.fail,
            cause: FailureCause.refused,
          ),
        },
      );

      expect(
        setupVerdictOf(path, coverage: SetupCoverage.tun),
        SetupVerdict.stale,
      );
    });

    test('a step that failed with a cause is failed', () {
      final path = _path(
        steps: {
          PathStep.server: const PathStepResult(
            PathStep.server,
            status: PathStepStatus.fail,
            cause: FailureCause.refused,
          ),
        },
      );

      expect(
        setupVerdictOf(path, coverage: SetupCoverage.tun),
        SetupVerdict.failed,
      );
    });

    test('a step that is not up without a cause is unconfirmed', () {
      final path = _path(
        steps: {
          PathStep.tunnel: const PathStepResult(
            PathStep.tunnel,
            status: PathStepStatus.fail,
          ),
        },
      );

      expect(
        setupVerdictOf(path, coverage: SetupCoverage.tun),
        SetupVerdict.unconfirmed,
      );
    });

    test('a passing path without a passing internet step is unconfirmed', () {
      for (final status in [PathStepStatus.unknown, PathStepStatus.skipped]) {
        final path = _path(
          steps: {
            PathStep.internet: PathStepResult(
              PathStep.internet,
              status: status,
            ),
          },
        );

        expect(
          setupVerdictOf(path, coverage: SetupCoverage.tun),
          SetupVerdict.unconfirmed,
          reason: status.name,
        );
      }
    });

    test('a passing internet step confirms the connection', () {
      expect(
        setupVerdictOf(_path(), coverage: SetupCoverage.tun),
        SetupVerdict.connected,
      );
      expect(
        setupVerdictOf(_path(), coverage: SetupCoverage.system),
        SetupVerdict.connected,
      );
    });

    test('a passing internet step on local coverage is local', () {
      expect(
        setupVerdictOf(_path(), coverage: SetupCoverage.local),
        SetupVerdict.local,
      );
    });
  });

  group('SetupOutcome', () {
    test('only confirmed outcomes count as confirmed', () {
      for (final verdict in [
        SetupVerdict.connected,
        SetupVerdict.partial,
        SetupVerdict.local,
      ]) {
        expect(SetupOutcome(verdict: verdict).confirmed, isTrue);
      }
      for (final verdict in SetupVerdict.values) {
        if (verdict == SetupVerdict.connected ||
            verdict == SetupVerdict.partial ||
            verdict == SetupVerdict.local) {
          continue;
        }
        expect(SetupOutcome(verdict: verdict).confirmed, isFalse);
      }
    });

    test('stale outcomes keep the path but discard the route stamp', () {
      final path = _path();
      final outcome = SetupOutcome(
        verdict: SetupVerdict.connected,
        path: path,
        error: 'x',
        stamp: const RouteStamp(
          coreEpoch: 2,
          routeVersion: 3,
          hostEpoch: 4,
          proxied: true,
        ),
        connectionActive: true,
      );

      final stale = outcome.asStale();

      expect(stale.verdict, SetupVerdict.stale);
      expect(stale.path, same(path));
      expect(stale.error, 'x');
      expect(stale.stamp, isNull);
      expect(stale.connectionActive, isTrue);
      expect(stale.confirmed, isFalse);
    });
  });
}
