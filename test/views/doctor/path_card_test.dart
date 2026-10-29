import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/simple/path_card.dart';
import 'package:reclash/views/doctor/path.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import 'doctor_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => mockPreferences());

  final now = DateTime(2026, 10, 29);
  final passed = PathResult(
    scope: PathScope.full,
    startedAt: now,
    finishedAt: now,
    steps: [
      for (final step in PathStep.values)
        PathStepResult(
          step,
          status: PathStepStatus.pass,
          duration: const Duration(milliseconds: 10),
        ),
    ],
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    PathResult? path,
    bool started = true,
  }) async {
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        overrides: [
          ...doctorOverrides(
            kernel: FakeDoctorKernel(),
            findings: const [],
            path: path,
          ),
          isStartProvider.overrideWithValue(started),
        ],
        child: const Center(
          child: SizedBox(width: 320, child: SimplePathCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectChain() {
    for (final step in PathStep.values) {
      expect(find.byGlyph(step.glyph), findsOneWidget);
    }
  }

  testWidgets('keeps the full path visible after every step passes', (
    tester,
  ) async {
    await pumpCard(tester, path: passed);

    expectChain();
    expect(
      find.text(currentAppLocalizations.doctorPathAllPass(90)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the waiting path before connecting', (tester) async {
    await pumpCard(tester, started: false);

    expectChain();
    expect(find.text(currentAppLocalizations.doctorPathIdle), findsOneWidget);
  });

  testWidgets('shows the path while the first result is loading', (
    tester,
  ) async {
    await pumpCard(tester);

    expectChain();
    expect(
      find.text(currentAppLocalizations.doctorPathChecking),
      findsOneWidget,
    );
  });

  testWidgets('keeps the path and cause visible after a failed step', (
    tester,
  ) async {
    final failed = PathResult.start(PathScope.full, now)
        .withStep(
          const PathStepResult(
            PathStep.network,
            status: PathStepStatus.fail,
            cause: FailureCause.noNetwork,
          ),
        )
        .finish(now);
    await pumpCard(tester, path: failed);

    expectChain();
    expect(
      find.text(currentAppLocalizations.doctorCauseNoNetwork),
      findsOneWidget,
    );
  });

  testWidgets('opens the detailed path from a successful card', (tester) async {
    await pumpCard(tester, path: passed);

    await tester.tap(find.text(currentAppLocalizations.doctorPathTitle));
    await tester.pumpAndSettle();

    expect(find.byType(PathSheet), findsOneWidget);
    expect(find.byType(PathStepList), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
