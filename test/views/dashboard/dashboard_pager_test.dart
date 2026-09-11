import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_pager.dart';
import 'package:reclash/views/dashboard/widgets/provider_summary_page.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _pageSettle = Duration(milliseconds: 500);

// The hero orb animates for as long as its page is on screen, so pumpAndSettle
// never returns once the pager lands back on the connection page.
Future<void> _pumpPageChange(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(_pageSettle);
  await tester.pump(_pageSettle);
}

class _TestDesyncSetting extends DesyncSetting {
  _TestDesyncSetting(this.initial);

  final DesyncProps initial;

  @override
  DesyncProps build() => initial;
}

Profile _profile({PanelMeta? panelMeta, SubscriptionInfo? subscriptionInfo}) {
  return Profile(
    id: 1,
    label: 'Local profile',
    url: 'https://example.com/sub',
    lastUpdateDate: DateTime(2026, 9, 8, 12),
    autoUpdateDuration: const Duration(hours: 1),
    subscriptionInfo: subscriptionInfo,
    panelMeta: panelMeta,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpPager(
    WidgetTester tester, {
    Profile? profile,
    Size size = const Size(900, 1200),
    double textScaleFactor = 1,
    DesyncProps desync = const DesyncProps(),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    const group = Group(
      name: 'Selector',
      type: GroupType.Selector,
      hidden: false,
      now: 'Node A',
      all: [Proxy(name: 'Node A', type: 'Shadowsocks')],
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([?profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
        desyncSettingProvider.overrideWith(() => _TestDesyncSetting(desync)),
        byeDpiSupportedProvider.overrideWithValue(true),
        groupsProvider.overrideWithValue(const [group]),
        tunEnabledProvider.overrideWith((ref) => true),
        initProvider.overrideWithBuild((_, _) => true),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = size;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: Scaffold(body: DashboardPager()),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('only-dpi mode has no provider transition', (tester) async {
    await pumpPager(
      tester,
      profile: _profile(),
      desync: const DesyncProps(enabled: true, onlyDpi: true),
    );

    expect(find.byKey(const ValueKey('dashboard-show-provider')), findsNothing);
    await tester.fling(
      find.byKey(const ValueKey('dashboard-hero-page')),
      const Offset(0, -300),
      1200,
    );
    await _pumpPageChange(tester);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsNothing);
  });

  testWidgets('affordance opens and closes provider page', (tester) async {
    await pumpPager(tester, profile: _profile());

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('dashboard-show-connection')));
    await _pumpPageChange(tester);

    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('the system back leaves the provider page', (tester) async {
    await pumpPager(tester, profile: _profile());

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);

    await tester.binding.handlePopRoute();
    await _pumpPageChange(tester);

    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('affordances expose localized button semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPager(tester, profile: _profile());

    final showProvider = tester.getSemantics(
      find.byKey(const ValueKey('dashboard-show-provider')),
    );
    expect(showProvider.label, 'Show subscription details');
    expect(showProvider.flagsCollection.isButton, isTrue);

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    final showConnection = tester.getSemantics(
      find.byKey(const ValueKey('dashboard-show-connection')),
    );
    expect(showConnection.label, 'Return to connection');
    expect(showConnection.flagsCollection.isButton, isTrue);
    semantics.dispose();
  });

  testWidgets('vertical fling snaps between dashboard pages', (tester) async {
    await pumpPager(tester, profile: _profile());

    await tester.fling(
      find.byKey(const ValueKey('dashboard-hero-page')),
      const Offset(0, -300),
      1200,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('dashboard-provider-page')),
      const Offset(0, 300),
      1200,
    );
    await _pumpPageChange(tester);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('provider summary scrolls before returning at its boundary', (
    tester,
  ) async {
    const announcement =
        'Maintenance starts Friday at 21:00 UTC.\n\n'
        'Connections may reconnect briefly while every region is upgraded.\n\n'
        'Follow https://example.com/status for the complete service timeline.\n\n'
        'This message remains fully visible on the provider page.\n\n'
        'Regional maintenance details.\n\n'
        'Expected impact and recovery notes.\n\n'
        'Support contacts and status updates.\n\n'
        'Final confirmation after maintenance.';
    await pumpPager(
      tester,
      profile: _profile(
        panelMeta: const PanelMeta(
          serviceName: 'An exceptionally long provider service name',
          accountUsername: 'long-account-name@example.com',
          announce: announcement,
        ),
        subscriptionInfo: SubscriptionInfo(
          upload: 25,
          download: 25,
          total: 100,
          expire: DateTime(2027).millisecondsSinceEpoch ~/ 1000,
        ),
      ),
      size: const Size(900, 700),
    );
    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    final providerScroll = tester.widget<SingleChildScrollView>(
      find
          .descendant(
            of: find.byType(ProviderSummaryPage),
            matching: find.byType(SingleChildScrollView),
          )
          .first,
    );
    final controller = providerScroll.controller!;
    expect(controller.position.maxScrollExtent, greaterThan(0));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    await tester.fling(
      find.byKey(const ValueKey('dashboard-provider-page')),
      const Offset(0, 180),
      900,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);
  });

  testWidgets('trackpad pan snaps between dashboard pages', (tester) async {
    await pumpPager(tester, profile: _profile());

    await tester.trackpadFlingFrom(
      tester.getCenter(find.byKey(const ValueKey('dashboard-hero-page'))),
      const Offset(0, -160),
      600,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);

    await tester.trackpadFlingFrom(
      tester.getCenter(find.byKey(const ValueKey('dashboard-provider-page'))),
      const Offset(0, 160),
      600,
    );
    await _pumpPageChange(tester);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('mouse wheel snaps between dashboard pages', (tester) async {
    await pumpPager(tester, profile: _profile(), size: const Size(900, 700));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    final center = tester.getCenter(
      find.byKey(const ValueKey('dashboard-hero-page')),
    );

    // One notch is smaller than the page threshold, so the gesture accumulates.
    await tester.sendEventToBinding(pointer.hover(center));
    for (var i = 1; i <= 4; i++) {
      await tester.sendEventToBinding(
        pointer.scroll(
          const Offset(0, 40),
          timeStamp: Duration(milliseconds: 20 * i),
        ),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);

    for (var i = 1; i <= 4; i++) {
      await tester.sendEventToBinding(
        pointer.scroll(
          const Offset(0, -40),
          timeStamp: Duration(milliseconds: 1000 + 20 * i),
        ),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
    await _pumpPageChange(tester);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('a stale wheel gesture does not add up to a page turn', (
    tester,
  ) async {
    await pumpPager(tester, profile: _profile(), size: const Size(900, 700));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(
      pointer.hover(
        tester.getCenter(find.byKey(const ValueKey('dashboard-hero-page'))),
      ),
    );

    for (var i = 1; i <= 6; i++) {
      await tester.sendEventToBinding(
        pointer.scroll(
          const Offset(0, 20),
          timeStamp: Duration(milliseconds: 400 * i),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }
    await _pumpPageChange(tester);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('page keys move between dashboard pages', (tester) async {
    await pumpPager(tester, profile: _profile(), size: const Size(900, 700));

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(find.byType(ProviderSummaryPage).hitTestable(), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await _pumpPageChange(tester);
    expect(
      find.byKey(const ValueKey('dashboard-hero-page')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('provider summary shows practical subscription details', (
    tester,
  ) async {
    final expire = DateTime(2027).millisecondsSinceEpoch ~/ 1000;
    await pumpPager(
      tester,
      profile: _profile(
        panelMeta: const PanelMeta(serviceName: 'Example VPN'),
        subscriptionInfo: SubscriptionInfo(
          upload: 25,
          download: 25,
          total: 100,
          expire: expire,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    expect(find.text('Example VPN'), findsOneWidget);
    expect(find.text('Local profile'), findsOneWidget);
    expect(find.textContaining('free of 100B'), findsOneWidget);
    expect(find.text('Upload'), findsNothing);
    expect(find.text('Download'), findsNothing);
    expect(find.text('2026-09-08 12:00:00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('summary shows expired, attention, and perpetual states', (
    tester,
  ) async {
    final expired = DateTime(2025).millisecondsSinceEpoch ~/ 1000;
    var container = await pumpPager(
      tester,
      profile: _profile(subscriptionInfo: SubscriptionInfo(expire: expired)),
    );
    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();
    expect(find.text('2025-01-01 00:00:00'), findsOneWidget);

    container.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    container = await pumpPager(
      tester,
      profile: _profile(
        subscriptionInfo: SubscriptionInfo(
          expire: DateTime(2099).millisecondsSinceEpoch ~/ 1000,
        ),
      ).copyWith(undialableNodes: true),
    );
    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('None of the nodes in this subscription'),
      findsOneWidget,
    );
    expect(find.text('Perpetual subscription'), findsOneWidget);
  });

  testWidgets('the subscription card opens the subscription overview', (
    tester,
  ) async {
    await pumpPager(tester, profile: _profile());
    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('provider-plan-card')));
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionOverviewView), findsOneWidget);
  });

  testWidgets('provider summary shows full announcement text', (tester) async {
    const announcement =
        'Maintenance starts Friday at 21:00 UTC. Connections may reconnect '
        'briefly while every region is upgraded. Follow https://example.com/status '
        'for the complete service timeline.';
    await pumpPager(
      tester,
      profile: _profile(
        panelMeta: const PanelMeta(
          serviceName: 'Example VPN',
          announce: announcement,
        ),
      ),
      size: const Size(360, 520),
    );

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    final announcementText = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.textSpan?.toPlainText() == announcement,
      ),
    );
    expect(announcementText.maxLines, isNull);
    expect(announcementText.overflow, isNull);
    expect(find.text('Announcements'), findsOneWidget);
  });

  testWidgets('summary falls back to profile without panel metadata', (
    tester,
  ) async {
    await pumpPager(tester, profile: _profile());

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    expect(find.text('Local profile'), findsOneWidget);
    expect(
      find.text('This subscription reports no traffic quota or end date'),
      findsOneWidget,
    );
    expect(find.text('2026-09-08 12:00:00'), findsOneWidget);
    expect(find.byKey(const ValueKey('provider-plan-card')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ProviderSummaryPage),
        matching: find.text('Support'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(ProviderSummaryPage),
        matching: find.text('Update'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary has an empty state without active profile', (
    tester,
  ) async {
    await pumpPager(tester);

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a VPN profile'), findsWidgets);
    expect(find.byKey(const ValueKey('provider-plan-card')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('provider page fits a compact viewport with large text', (
    tester,
  ) async {
    await pumpPager(
      tester,
      profile: _profile(
        panelMeta: const PanelMeta(
          serviceName: 'An exceptionally long provider service name',
          announce: 'A complete provider announcement remains available.',
        ),
        subscriptionInfo: const SubscriptionInfo(total: 100),
      ),
      size: const Size(420, 720),
      textScaleFactor: 1.5,
    );

    await tester.tap(find.byKey(const ValueKey('dashboard-show-provider')));
    await tester.pumpAndSettle();
    while (tester.takeException() != null) {}
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
