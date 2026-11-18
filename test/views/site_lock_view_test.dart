import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/core/desktop/site_lock_policy.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/site_lock.dart';

import '../helpers/preferences.dart';
import '../helpers/test_app.dart';

// Stands in for the Core: refresh() would otherwise query a running core.
class _FixedSiteLockReport extends SiteLockReportState {
  _FixedSiteLockReport(this._report);

  final SiteLockReport? _report;
  SiteLockReport? Function(List<SiteLock> locks)? answer;
  final pushed = <List<SiteLock>>[];

  @override
  SiteLockReport? build() => _report;

  @override
  Future<void> refresh() async {}

  @override
  Future<SiteLockReport?> push(List<SiteLock> locks) async {
    pushed.add(locks);
    final report = answer?.call(locks);
    state = report;
    return report;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _FixedSiteLockReport core;

  setUpAll(() => mockPreferences());

  Future<void> pumpView(
    WidgetTester tester, {
    required bool hostFirewall,
    List<SiteLock> locks = const [],
    SiteLockReport? report,
    SiteLockHostStatus hostStatus = SiteLockHostStatus.inactive,
    bool tunEnabled = true,
    CoreStatus coreStatus = CoreStatus.disconnected,
  }) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        siteLockReportStateProvider.overrideWith(
          () => core = _FixedSiteLockReport(report),
        ),
        coreStatusProvider.overrideWithValue(coreStatus),
        siteLockHostStateProvider.overrideWithBuild((_, _) => hostStatus),
        siteLocksProvider.overrideWithBuild((_, _) => locks),
        patchClashConfigProvider.overrideWithBuild(
          (_, _) => PatchClashConfig(tun: Tun(enable: tunEnabled)),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1800);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: SiteLockView(hostFirewall: hostFirewall)),
      ),
    );
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(SiteLockView)));

  Finder rowOf(String title) =>
      find.ancestor(of: find.text(title), matching: find.byType(ListItem));

  Finder subtitleOf(String title, String text) =>
      find.descendant(of: rowOf(title), matching: find.text(text));

  testWidgets('an empty list shows the empty state and no rows', (
    tester,
  ) async {
    await pumpView(tester, hostFirewall: false);

    expect(find.text(l10n(tester).siteLockEmpty), findsOneWidget);
    expect(find.byType(ListItem), findsNothing);
    await unmount(tester);
  });

  testWidgets(
    'a row subtitle states the exit, the missing exit, a problem or off',
    (tester) async {
      await pumpView(
        tester,
        hostFirewall: false,
        locks: const [
          SiteLock(id: 'ready', name: 'Ready site', match: ['a.example']),
          SiteLock(id: 'orphan', name: 'Orphan site', match: ['b.example']),
          SiteLock(id: 'broken', name: 'Broken site', match: ['c.example']),
          SiteLock(
            id: 'paused',
            name: 'Paused site',
            enabled: false,
            match: ['d.example'],
          ),
        ],
        report: const SiteLockReport(
          applied: true,
          locks: [
            SiteLockState(
              id: 'ready',
              status: SiteLockStatus.ready,
              exit: 'US-1',
            ),
            SiteLockState(id: 'orphan', status: SiteLockStatus.noExit),
          ],
          problems: [
            SiteLockProblem(
              id: 'broken',
              field: 'match',
              message: 'Not a site',
            ),
          ],
        ),
      );
      final l = l10n(tester);

      expect(
        subtitleOf('Ready site', l.siteLockThrough('US-1')),
        findsOneWidget,
      );
      expect(subtitleOf('Orphan site', l.siteLockNoExit), findsOneWidget);
      expect(subtitleOf('Broken site', 'Not a site'), findsOneWidget);
      expect(subtitleOf('Paused site', l.siteLockOff), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('a lock without a name is titled by its first site', (
    tester,
  ) async {
    await pumpView(
      tester,
      hostFirewall: false,
      locks: const [
        SiteLock(id: 'unnamed', match: ['chatgpt.com', 'openai.com']),
      ],
    );

    expect(rowOf('chatgpt.com'), findsOneWidget);
    expect(find.text('openai.com'), findsNothing);
    await unmount(tester);
  });

  testWidgets('the row switch disables its lock in the saved list', (
    tester,
  ) async {
    await pumpView(
      tester,
      hostFirewall: false,
      locks: const [
        SiteLock(id: 'mail', name: 'Mail', match: ['mail.example']),
      ],
    );

    await tester.tap(find.byType(CommonSwitch));
    await tester.pump();

    final locks = container.read(siteLocksProvider);
    expect(locks.single.id, 'mail');
    expect(locks.single.enabled, isFalse);
    await unmount(tester);
  });

  testWidgets('a rejected push shows the rejection banner', (tester) async {
    await pumpView(
      tester,
      hostFirewall: false,
      locks: const [
        SiteLock(id: 'mail', name: 'Mail', match: ['mail.example']),
      ],
      report: const SiteLockReport(applied: false),
    );

    expect(find.text(l10n(tester).siteLockRejectedTitle), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('core-only entries warn and name the lock they belong to', (
    tester,
  ) async {
    await pumpView(
      tester,
      hostFirewall: false,
      locks: const [
        SiteLock(id: 'geo', name: 'Geo', match: ['geosite:openai']),
      ],
      report: const SiteLockReport(
        applied: true,
        warnings: [
          SiteLockWarning(code: 'core-only', locks: ['geo']),
        ],
      ),
    );
    final l = l10n(tester);

    expect(find.text(l.siteLockCoreOnlyTitle), findsOneWidget);
    expect(find.text(l.siteLockCoreOnlyBody('Geo')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a missing helper warns only when the host firewall applies', (
    tester,
  ) async {
    const locks = [
      SiteLock(id: 'mail', name: 'Mail', match: ['mail.example']),
    ];
    await pumpView(
      tester,
      hostFirewall: true,
      locks: locks,
      hostStatus: SiteLockHostStatus.helperUnavailable,
    );
    final l = l10n(tester);
    expect(find.text(l.siteLockHelperTitle), findsOneWidget);
    await unmount(tester);

    await pumpView(
      tester,
      hostFirewall: false,
      locks: locks,
      hostStatus: SiteLockHostStatus.helperUnavailable,
    );
    expect(find.text(l.siteLockHelperTitle), findsNothing);
    await unmount(tester);
  });

  testWidgets(
    'a lift the helper has not done yet warns that sites stay blocked',
    (tester) async {
      const locks = [
        SiteLock(
          id: 'mail',
          name: 'Mail',
          enabled: false,
          match: ['m.example'],
        ),
      ];
      await pumpView(
        tester,
        hostFirewall: true,
        locks: locks,
        hostStatus: SiteLockHostStatus.helperUnavailable,
      );
      final l = l10n(tester);
      expect(find.text(l.siteLockStillBlockedTitle), findsOneWidget);
      expect(find.text(l.siteLockHelperTitle), findsNothing);
      await unmount(tester);

      await pumpView(tester, hostFirewall: true, locks: locks);
      expect(find.text(l.siteLockStillBlockedTitle), findsNothing);
      await unmount(tester);
    },
  );

  testWidgets('an edit the core refuses keeps the sheet open and unsaved', (
    tester,
  ) async {
    const lock = SiteLock(
      id: 'mail',
      name: 'Mail',
      match: ['DOMAIN-SUFFIX,mail.example'],
      exits: [SiteLockExit(type: 'ss', server: '203.0.113.1', port: 443)],
    );
    await pumpView(
      tester,
      hostFirewall: false,
      locks: const [lock],
      coreStatus: CoreStatus.connected,
    );
    core.answer = (_) => const SiteLockReport(
      problems: [
        SiteLockProblem(id: 'mail', field: 'match.0', message: 'refused'),
      ],
    );
    await tester.tap(find.text('Mail'));
    await tester.pumpAndSettle();
    tester.widget<FormPage>(find.byType(FormPage)).onSave!();
    await tester.pumpAndSettle();

    expect(core.pushed.single.single.id, 'mail');
    expect(
      find.textContaining('DOMAIN-SUFFIX,mail.example: refused'),
      findsOneWidget,
    );
    expect(find.byType(FormPage), findsOneWidget);

    core.answer = (_) => const SiteLockReport(applied: true);
    tester.widget<FormPage>(find.byType(FormPage)).onSave!();
    await tester.pumpAndSettle();

    expect(find.byType(FormPage), findsNothing);
    expect(container.read(siteLocksProvider).single.match, [
      'DOMAIN-SUFFIX,mail.example',
    ]);
    // Lets the editor's exit query, which no core answers here, time out.
    await tester.pump(const Duration(seconds: 11));
    await unmount(tester);
  });

  testWidgets('TUN off warns while the host firewall applies', (tester) async {
    await pumpView(
      tester,
      hostFirewall: true,
      locks: const [
        SiteLock(id: 'mail', name: 'Mail', match: ['mail.example']),
      ],
      tunEnabled: false,
    );

    expect(find.text(l10n(tester).siteLockTunOffTitle), findsOneWidget);
    await unmount(tester);
  });
}
