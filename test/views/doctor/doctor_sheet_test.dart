import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/views/doctor/doctor.dart';

import '../../helpers/context_menu.dart';
import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import 'doctor_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => mockPreferences());

  Future<FakeDoctorKernel> pumpSheet(
    WidgetTester tester, {
    List<Finding> findings = const [],
    List<DiagnosticEvent> history = const [],
  }) async {
    final kernel = FakeDoctorKernel();
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        overrides: doctorOverrides(
          kernel: kernel,
          findings: findings,
          history: history,
        ),
        child: const DoctorSheet(),
      ),
    );
    await tester.pumpAndSettle();
    return kernel;
  }

  testWidgets('lists the path, the issues and the incident history', (
    tester,
  ) async {
    await pumpSheet(tester, findings: [directModeFinding]);
    final l = currentAppLocalizations;

    expect(find.text(l.doctorPathTitle), findsOneWidget);
    expect(find.text(l.doctorIssues), findsOneWidget);
    expect(find.text(l.rcxHistory), findsOneWidget);
    expect(find.text(l.doctorDirectModeTitle), findsOneWidget);
  });

  testWidgets('expands and collapses the empty history', (tester) async {
    await pumpSheet(tester);
    final l = currentAppLocalizations;

    final emptyRow = find.descendant(
      of: find.byKey(const ValueKey('doctor-history-empty')),
      matching: find.text(l.doctorHistoryEmpty),
    );
    expect(find.text(l.doctorHistoryEmpty), findsOneWidget);
    expect(emptyRow, findsNothing);

    await tester.tap(find.text(l.rcxHistory));
    await tester.pumpAndSettle();
    expect(emptyRow, findsOneWidget);

    await tester.tap(find.text(l.rcxHistory));
    await tester.pumpAndSettle();
    expect(emptyRow, findsNothing);
    expect(find.text(l.doctorHistoryEmpty), findsOneWidget);
  });

  testWidgets('keeps incidents collapsed until opened and shows newest first', (
    tester,
  ) async {
    final now = DateTime.now();
    await pumpSheet(
      tester,
      history: [
        DiagnosticEvent(
          kind: DiagnosticEventKind.findingRaised,
          at: now.subtract(const Duration(minutes: 1)),
          subject: 'device.batteryOptimization',
          detail: 'Older incident',
        ),
        DiagnosticEvent(
          kind: DiagnosticEventKind.findingCleared,
          at: now,
          subject: 'device.batteryOptimization',
          detail: 'Latest incident',
        ),
      ],
    );
    final l = currentAppLocalizations;
    final header = find.text(l.rcxHistory);
    final summary = find.descendant(
      of: find.byKey(const ValueKey('doctor-history-toggle')),
      matching: find.text(l.doctorEventFindingCleared),
    );
    expect(summary, findsOneWidget);
    expect(find.text('Older incident'), findsNothing);
    expect(find.text('Latest incident'), findsNothing);

    await tester.tap(header);
    await tester.pumpAndSettle();
    expect(summary, findsNothing);
    expect(find.text('Older incident'), findsOneWidget);
    expect(find.text('Latest incident'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Latest incident')).dy,
      lessThan(tester.getTopLeft(find.text('Older incident')).dy),
    );

    await tester.tap(header);
    await tester.pumpAndSettle();
    expect(summary, findsOneWidget);
    expect(find.text('Older incident'), findsNothing);
    expect(find.text('Latest incident'), findsNothing);
  });

  testWidgets('snoozes a warning for a week from its menu', (tester) async {
    final kernel = await pumpSheet(tester, findings: [directModeFinding]);
    final l = currentAppLocalizations;

    await rightClick(tester, find.text(l.doctorDirectModeTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.doctorSnoozeWeek));
    await tester.pumpAndSettle();

    expect(kernel.snoozes, hasLength(1));
    expect(kernel.snoozes.single.id, 'config.directMode');
    final until = kernel.snoozes.single.until;
    expect(until, isNotNull);
    expect(until!.isAfter(DateTime.now().add(const Duration(days: 6))), isTrue);
  });

  testWidgets('offers no snooze menu for a critical finding', (tester) async {
    final kernel = await pumpSheet(tester, findings: [clockSkewFinding]);
    final l = currentAppLocalizations;

    await rightClick(tester, find.text(l.doctorCauseClockSkew));
    await tester.pumpAndSettle();

    expect(find.text(l.doctorSnoozeWeek), findsNothing);
    expect(find.text(l.doctorSnoozeForever), findsNothing);
    expect(kernel.snoozes, isEmpty);
  });
}
