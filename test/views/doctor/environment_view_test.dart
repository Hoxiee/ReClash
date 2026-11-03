import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/application_setting.dart';
import 'package:reclash/views/doctor/finding.dart';
import 'package:reclash/views/doctor/health.dart';
import 'package:reclash/views/doctor/path.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import 'doctor_fakes.dart';

class _Remedy implements Remedy {
  _Remedy(this.id, this.reach);

  @override
  final String id;
  @override
  final RemedyReach reach;
  @override
  FixKind get kind => FixKind.auto;
  @override
  bool get undoable => false;
  @override
  Duration get settle => Duration.zero;
  @override
  Future<void> apply(RemedyRequest request) async {}
}

class _PlanKernel extends FakeDoctorKernel {
  final plans = <HealPlan>[];
  final confirmations = <bool>[];

  @override
  Future<RemedyOutcome> apply(String remedyId, {bool confirmed = false}) async {
    confirmations.add(confirmed);
    return super.apply(remedyId, confirmed: confirmed);
  }

  @override
  Future<PlanOutcome> heal(HealPlan plan) async {
    plans.add(plan);
    return PlanOutcome(planId: plan.id, healed: true, steps: const []);
  }
}

Finding _finding(String id, String titleKey, String detailKey, String remedy) =>
    Finding(
      id: id,
      severity: CheckSeverity.warning,
      evidence: const [],
      titleKey: titleKey,
      detailKey: detailKey,
      remedyIds: [remedy],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await mockPreferences();
    await AppLocalizations.load(const Locale('en'));
  });

  test('causeText names every cause but unknown', () {
    final l = currentAppLocalizations;
    for (final cause in FailureCause.values) {
      if (cause == FailureCause.unknown) continue;
      expect(
        causeText(l, cause),
        isNot(l.doctorCauseUnknown),
        reason: '$cause',
      );
    }
    expect(causeText(l, FailureCause.unknown), l.doctorCauseUnknown);
  });

  test('environment findings read their title and detail arguments', () {
    final l = currentAppLocalizations;
    Finding make(
      String title,
      String detail, [
      Map<String, Object> args = const {},
    ]) => Finding(
      id: 'env.x',
      severity: CheckSeverity.warning,
      evidence: const [],
      titleKey: title,
      detailKey: detail,
      args: args,
    );
    final cases = <(Finding, String, String)>[
      (
        make('doctorHostsServerTitle', 'doctorHostsServerDetail', {
          'domain': 'a.example',
          'count': 2,
        }),
        l.doctorHostsServerTitle,
        l.doctorHostsServerDetail('a.example', 2),
      ),
      (
        make('doctorHostsServicesTitle', 'doctorHostsServicesDetail', {
          'domains': 'x, y',
          'count': 3,
        }),
        l.doctorHostsServicesTitle,
        l.doctorHostsServicesDetail('x, y', 3),
      ),
      (
        make('doctorHostsLargeTitle', 'doctorHostsLargeDetail', {'lines': 900}),
        l.doctorHostsLargeTitle,
        l.doctorHostsLargeDetail(900),
      ),
      (
        make('doctorInterceptorTitle', 'doctorInterceptorDetail', {
          'name': 'AV',
        }),
        l.doctorInterceptorTitle,
        l.doctorInterceptorDetail('AV'),
      ),
      (
        make('doctorInterceptorTitle', 'doctorInterceptorUnknownDetail'),
        l.doctorInterceptorTitle,
        l.doctorInterceptorUnknownDetail,
      ),
      (
        make('doctorForeignTunnelTitle', 'doctorForeignTunnelDetail', {
          'name': 'tun0',
        }),
        l.doctorForeignTunnelTitle,
        l.doctorForeignTunnelDetail('tun0'),
      ),
      (
        make('doctorTunnelNameTitle', 'doctorTunnelNameDetail', {
          'name': 'tun1',
        }),
        l.doctorTunnelNameTitle,
        l.doctorTunnelNameDetail('tun1'),
      ),
      (
        make('doctorDeadProxyTitle', 'doctorDeadProxyDetail', {
          'address': '1.2.3.4:80',
        }),
        l.doctorDeadProxyTitle,
        l.doctorDeadProxyDetail('1.2.3.4:80'),
      ),
      (
        make('doctorProxyTakenTitle', 'doctorProxyTakenDetail', {
          'address': '5.6.7.8:1',
        }),
        l.doctorProxyTakenTitle,
        l.doctorProxyTakenDetail('5.6.7.8:1'),
      ),
      (
        make('doctorProxyTakenTitle', 'doctorProxyOffDetail'),
        l.doctorProxyTakenTitle,
        l.doctorProxyOffDetail,
      ),
      (
        make('doctorPortTakenTitle', 'doctorPortTakenDetail', {
          'port': 7890,
          'owner': 'nginx',
        }),
        l.doctorPortTakenTitle(7890),
        l.doctorPortTakenDetail('nginx'),
      ),
      (
        make('doctorPortTakenTitle', 'doctorPortReservedDetail', {
          'port': 7890,
        }),
        l.doctorPortTakenTitle(7890),
        l.doctorPortReservedDetail(7890),
      ),
      (
        make('doctorDeadDnsTitle', 'doctorDeadDnsDetail'),
        l.doctorDeadDnsTitle,
        l.doctorDeadDnsDetail,
      ),
    ];
    for (final (finding, title, detail) in cases) {
      expect(findingTitle(l, finding), title);
      expect(findingDetail(l, finding), detail);
    }
  });

  group('foreign remedies', () {
    final foreign = _finding(
      'env.interceptor',
      'doctorInterceptorTitle',
      'doctorInterceptorUnknownDetail',
      'env.foreignFix',
    );
    final own = _finding(
      'config.directMode',
      'doctorDirectModeTitle',
      'doctorDirectModeDetail',
      'config.ruleMode',
    );

    Future<_PlanKernel> pump(
      WidgetTester tester,
      Widget child, [
      List<Finding> findings = const [],
    ]) async {
      final kernel = _PlanKernel();
      await tester.pumpWidget(
        TestApp(
          locale: const Locale('en'),
          overrides: [
            diagnosticKernelProvider.overrideWithValue(kernel),
            findingsProvider.overrideWith((ref) => Stream.value(findings)),
            diagnosticRemediesProvider.overrideWithValue([
              _Remedy('env.foreignFix', RemedyReach.foreign),
              _Remedy('config.ruleMode', RemedyReach.app),
            ]),
            remedyKindsProvider.overrideWithValue(const {
              'env.foreignFix': FixKind.auto,
              'config.ruleMode': FixKind.auto,
            }),
          ],
          child: child,
        ),
      );
      await tester.pumpAndSettle();
      return kernel;
    }

    Widget button() => const Center(
      child: FindingFixButton(remedyId: 'env.foreignFix', kind: FixKind.auto),
    );

    testWidgets('applies only after the user confirms', (tester) async {
      final kernel = await pump(tester, button());
      final l = currentAppLocalizations;

      await tester.tap(find.text(l.doctorFixConfirm));
      await tester.pumpAndSettle();
      expect(find.text(l.doctorConfirmForeignTitle), findsOneWidget);
      expect(kernel.applied, isEmpty);

      await tester.tap(find.text(l.doctorConfirmForeignAction));
      await tester.pumpAndSettle();
      expect(kernel.applied, ['env.foreignFix']);
      expect(kernel.confirmations, [true]);
    });

    testWidgets('does nothing when the user cancels', (tester) async {
      final kernel = await pump(tester, button());
      final l = currentAppLocalizations;

      await tester.tap(find.text(l.doctorFixConfirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();

      expect(kernel.applied, isEmpty);
    });

    testWidgets('fix everything leaves foreign remedies out', (tester) async {
      late WidgetRef captured;
      late BuildContext captureContext;
      final kernel = await pump(
        tester,
        Consumer(
          builder: (context, ref, _) {
            captured = ref;
            captureContext = context;
            return const SizedBox.shrink();
          },
        ),
      );

      await fixEverything(captureContext, captured, [foreign, own]);

      expect(kernel.plans.single.remedyIds, ['config.ruleMode']);
    });
  });

  testWidgets('the auto-heal toggle flips the setting', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        locale: Locale('en'),
        wrapInProviderScope: true,
        child: ApplicationSettingView(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ApplicationSettingView)),
    );
    final l = currentAppLocalizations;
    expect(container.read(appSettingProvider).autoHeal, isTrue);

    await tester.scrollUntilVisible(
      find.text(l.doctorAutoHeal),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(l.doctorAutoHeal));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).autoHeal, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
