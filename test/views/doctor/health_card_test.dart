import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/doctor/health.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import 'doctor_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => mockPreferences());

  Future<FakeDoctorKernel> pumpCard(
    WidgetTester tester, {
    List<Finding> findings = const [],
  }) async {
    final kernel = FakeDoctorKernel();
    await tester.pumpWidget(
      TestApp(
        locale: const Locale('en'),
        overrides: doctorOverrides(kernel: kernel, findings: findings),
        child: const Center(child: SizedBox(width: 360, child: HealthCard())),
      ),
    );
    await tester.pumpAndSettle();
    return kernel;
  }

  testWidgets('says all set when no check raises a finding', (tester) async {
    await pumpCard(tester);

    expect(find.text(currentAppLocalizations.doctorAllSet), findsOneWidget);
  });

  testWidgets('collapses several warnings into a count and their titles', (
    tester,
  ) async {
    await pumpCard(tester, findings: [directModeFinding, batteryFinding]);
    final l = currentAppLocalizations;

    expect(find.text(l.doctorIssueCount(2)), findsOneWidget);
    expect(find.text(l.doctorDirectModeTitle), findsOneWidget);
    expect(find.text(l.doctorBatteryOptimizationTitle), findsOneWidget);
    expect(find.text(l.doctorFix), findsNothing);
  });

  testWidgets('expands on tap and applies the fix its button names', (
    tester,
  ) async {
    final kernel = await pumpCard(
      tester,
      findings: [directModeFinding, batteryFinding],
    );
    final l = currentAppLocalizations;

    await tester.tap(find.text(l.doctorIssueCount(2)));
    await tester.pumpAndSettle();
    expect(find.text(l.doctorFix), findsOneWidget);

    await tester.tap(find.text(l.doctorFix));
    await tester.pumpAndSettle();

    expect(kernel.applied, ['config.ruleMode']);
  });

  testWidgets('a critical finding takes the card on the error container', (
    tester,
  ) async {
    await pumpCard(tester, findings: [clockSkewFinding]);
    final colorScheme = Theme.of(
      tester.element(find.byType(HealthCard)),
    ).colorScheme;

    expect(
      find.text(currentAppLocalizations.doctorCauseClockSkew),
      findsOneWidget,
    );
    expect(
      tester.widget<DashboardCard>(find.byType(DashboardCard)).color,
      colorScheme.errorContainer,
    );
  });
}
