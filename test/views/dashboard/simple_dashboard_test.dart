import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/subscriptions/provider_settings.dart';
import 'package:reclash/views/dashboard/dashboard.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/views/dashboard/simple/home.dart';
import 'package:reclash/views/dashboard/simple/location_card.dart';
import 'package:reclash/views/dashboard/simple/mode_card.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/simple/power_button.dart';
import 'package:reclash/views/dashboard/simple/simple_dashboard.dart';
import 'package:reclash/views/dashboard/simple/services_card.dart';
import 'package:reclash/views/dashboard/simple/subscription_card.dart';
import 'package:reclash/views/dashboard/simple/widget_list.dart';
import 'package:reclash/widgets/announcement_card.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';
import '../../helpers/test_update_runtime.dart';
import '../doctor/doctor_fakes.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _ModeStatus extends RcxStatusState {
  _ModeStatus(this.initial);

  final RcxStatus? initial;

  @override
  RcxStatus? build() => initial;
}

class _ModeAction extends RcxRoutingAction {
  final manualCalls = <bool>[];
  bool fail = false;

  @override
  Future<void> setManualMode(bool manual) async {
    manualCalls.add(manual);
    if (fail) throw StateError('mode failed');
  }
}

const _automaticMode = RcxStatus(
  tunnelMode: 'direct',
  scenario: RcxScenarioStatus(id: 'user/home', holdsMode: true),
);

const _phone = Size(412, 915);
const _desktop = Size(1280, 800);
const _gb = 1024 * 1024 * 1024;
final _removeWidget = RegExp('^Remove ');

/// Subscription headers carry expiry as Unix seconds.
int _expiresIn(Duration duration) =>
    DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;

ProviderHints _hints(Map<String, Object?> fields) =>
    ProviderHints(SubscriptionMetadata(fields));

Profile _subscription({
  Map<String, Object?> fields = const {},
  required SubscriptionInfo info,
}) => Profile.normal(label: 'Plan', url: 'https://subs.example.test/feed')
    .copyWith(
      id: 7,
      subscriptionInfo: info,
      subscriptionSnapshot: SubscriptionSnapshot(
        metadata: SubscriptionMetadata(fields),
        receivedAt: DateTime.utc(2026),
      ),
    );

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    registerFallbackValue(const ServiceCheckParams(timeout: 0));
    registerFallbackValue(const OutboundIpParams(timeout: 0));
    await mockPreferences();
  });

  ProviderContainer newContainer({
    ProviderHints hints = ProviderHints.empty,
    Profile? profile,
    List<Override> overrides = const [],
  }) {
    final core = _MockCore();
    when(
      () => core.serviceCheck(any()),
    ).thenAnswer((_) => Completer<List<ServiceCheckItem>>().future);
    when(
      () => core.outboundIp(any()),
    ).thenAnswer((_) => Completer<OutboundIpResult?>().future);
    final next = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        providerHintsProvider.overrideWithValue(hints),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        if (profile != null) currentProfileProvider.overrideWithValue(profile),
        ...overrides,
      ],
    );
    next.listen(appSettingProvider, (_, _) {});
    globalState.container = next;
    return next;
  }

  setUp(() {
    container = newContainer();
  });

  tearDown(() => container.dispose());

  /// For a test whose provider data must exist when the container first builds.
  void useContainer({
    ProviderHints hints = ProviderHints.empty,
    Profile? profile,
    List<Override> overrides = const [],
  }) {
    container.dispose();
    container = newContainer(
      hints: hints,
      profile: profile,
      overrides: overrides,
    );
  }

  void chooseSimple({List<SimpleDashboardWidget>? widgets}) {
    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            dashboardStyle: DashboardStyle.simple,
            simpleDashboardWidgets: widgets ?? state.simpleDashboardWidgets,
          ),
        );
  }

  List<SimpleDashboardWidget> savedWidgets() =>
      container.read(appSettingProvider).simpleDashboardWidgets;

  // The power button's halo and the probes keep frames scheduled, so
  // pumpAndSettle would never return.
  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpPage(WidgetTester tester, {Size size = _phone}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardPage()),
      ),
    );
    await tester.pump();
  }

  Future<void> openWidgets(WidgetTester tester) async {
    await tester.tap(find.text('Widgets'));
    await settle(tester);
  }

  Future<void> openEditor(WidgetTester tester) async {
    await pumpPage(tester);
    await openWidgets(tester);
    await tester.tap(find.byTooltip('Edit widgets'));
    await settle(tester);
  }

  double centerX(WidgetTester tester, Finder finder) =>
      tester.getCenter(finder).dx;

  Future<_ModeAction> pumpMode(
    WidgetTester tester, {
    RcxStatus? status = _automaticMode,
    List<Mode> modes = Mode.values,
  }) async {
    final action = _ModeAction();
    useContainer(
      overrides: [
        rcxStatusStateProvider.overrideWith(() => _ModeStatus(status)),
        rcxRoutingActionProvider.overrideWith(() => action),
        availableModesProvider.overrideWithValue(modes),
      ],
    );
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.rule));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 320,
              child: SingleChildScrollView(child: SimpleModeCard()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return action;
  }

  Finder modeButton(Mode mode) => find.byWidgetPredicate(
    (widget) =>
        widget is DashboardConnectedButton &&
        widget.semanticLabel == mode.label,
  );

  testWidgets('Auto is separate and disabled choices follow the live mode', (
    tester,
  ) async {
    final action = await pumpMode(tester);

    expect(find.text('Auto'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DashboardConnectedGroup),
        matching: find.text('Auto'),
      ),
      findsNothing,
    );
    expect(find.byType(DashboardConnectedButton), findsNWidgets(3));

    for (final effective in Mode.values) {
      container
          .read(rcxStatusStateProvider.notifier)
          .apply(_automaticMode.copyWith(tunnelMode: effective.name));
      await tester.pump();
      for (final mode in Mode.values) {
        expect(
          tester.getSemantics(modeButton(mode)),
          isSemantics(
            isButton: true,
            isEnabled: false,
            isSelected: mode == effective,
            hasTapAction: false,
          ),
        );
        await tester.tap(modeButton(mode));
        await tester.pump();
      }
    }
    expect(container.read(patchClashConfigProvider).mode, Mode.rule);
    expect(action.manualCalls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'turning Auto off unlocks choices and turning it on restores control',
    (tester) async {
      final action = await pumpMode(tester);
      await tester.tap(find.byType(DashboardSwitch));
      await tester.pump();
      expect(action.manualCalls, [true]);
      expect(
        tester.widget<DashboardSwitch>(find.byType(DashboardSwitch)).value,
        isTrue,
      );

      container
          .read(rcxStatusStateProvider.notifier)
          .apply(
            _automaticMode.copyWith(
              scenario: _automaticMode.scenario!.copyWith(manual: true),
            ),
          );
      await tester.pump();
      expect(
        tester.widget<DashboardSwitch>(find.byType(DashboardSwitch)).value,
        isFalse,
      );
      await tester.tap(modeButton(Mode.direct));
      await tester.pump();
      expect(container.read(patchClashConfigProvider).mode, Mode.direct);

      await tester.tap(find.byType(DashboardSwitch));
      await tester.pump();
      expect(action.manualCalls, [true, false]);
      container.read(rcxStatusStateProvider.notifier).apply(_automaticMode);
      await tester.pump();
      await tester.tap(modeButton(Mode.global));
      await tester.pump();
      expect(container.read(patchClashConfigProvider).mode, Mode.direct);
      expect(
        tester.widget<DashboardSwitch>(find.byType(DashboardSwitch)).value,
        isTrue,
      );
    },
  );

  testWidgets('losing the scenario removes Auto and restores manual choices', (
    tester,
  ) async {
    await pumpMode(tester);
    container.read(rcxStatusStateProvider.notifier).apply(const RcxStatus());
    await tester.pump();

    expect(find.byType(DashboardSwitch), findsNothing);
    await tester.tap(modeButton(Mode.direct));
    await tester.pump();
    expect(container.read(patchClashConfigProvider).mode, Mode.direct);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a scenario without mode control offers only manual choices', (
    tester,
  ) async {
    await pumpMode(
      tester,
      status: const RcxStatus(scenario: RcxScenarioStatus(id: 'user/groups')),
      modes: const [Mode.rule, Mode.direct],
    );

    expect(find.byType(DashboardSwitch), findsNothing);
    expect(modeButton(Mode.global), findsNothing);
    await tester.tap(modeButton(Mode.direct));
    await tester.pump();
    expect(container.read(patchClashConfigProvider).mode, Mode.direct);
  });

  testWidgets('a failed Auto toggle keeps authoritative state and can retry', (
    tester,
  ) async {
    final action = await pumpMode(tester);
    action.fail = true;
    await tester.tap(find.byType(DashboardSwitch));
    await tester.pump();
    expect(action.manualCalls, [true]);
    expect(
      tester.widget<DashboardSwitch>(find.byType(DashboardSwitch)).value,
      isTrue,
    );
    expect(tester.takeException(), isNull);

    action.fail = false;
    await tester.tap(find.byType(DashboardSwitch));
    await tester.pump();
    expect(action.manualCalls, [true, true]);
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'DashboardPage shows the detailed dashboard until simple is chosen',
    (tester) async {
      await pumpPage(tester);
      expect(find.byType(DashboardView), findsOneWidget);
      expect(find.byType(SimpleDashboardView), findsNothing);

      chooseSimple();
      await settle(tester);

      expect(find.byType(SimpleDashboardView), findsOneWidget);
      expect(find.byType(DashboardView), findsNothing);
    },
  );

  testWidgets('the phone pager names Home and Widgets over the home page', (
    tester,
  ) async {
    chooseSimple();
    await pumpPage(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Widgets'), findsOneWidget);
    expect(find.byTooltip('Detailed dashboard'), findsOneWidget);
    expect(find.byTooltip('Edit widgets'), findsNothing);
  });

  testWidgets('a pending app update sits above the button on Home', (
    tester,
  ) async {
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '0.8.95',
      buildNumber: '1',
    );
    useContainer(
      overrides: [
        appUpdateActionProvider.overrideWith(
          () => _PendingUpdate(
            AppUpdateState(
              phase: UpdatePhase.offered,
              release: testUpdateRelease(),
            ),
          ),
        ),
      ],
    );
    chooseSimple();
    await pumpPage(tester);

    final card = find.byKey(const ValueKey('app-update-card'));
    expect(card, findsOneWidget);
    expect(
      tester.getRect(card).bottom,
      lessThan(tester.getRect(find.byType(PowerButton)).top),
    );
  });

  testWidgets('Detailed dashboard on Home switches the style back', (
    tester,
  ) async {
    chooseSimple();
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Detailed dashboard'));
    await settle(tester);

    expect(
      container.read(appSettingProvider).dashboardStyle,
      DashboardStyle.detailed,
    );
    expect(find.byType(DashboardView), findsOneWidget);
  });

  testWidgets('tapping the Widgets title moves the pager to the widget list', (
    tester,
  ) async {
    chooseSimple();
    await pumpPage(tester);
    expect(find.byTooltip('Edit widgets'), findsNothing);

    await openWidgets(tester);

    expect(
      centerX(tester, find.text('Mode')),
      inInclusiveRange(0, _phone.width),
    );
    expect(find.byTooltip('Edit widgets'), findsOneWidget);
    expect(find.byTooltip('Detailed dashboard'), findsNothing);
  });

  group('swipe pager', () {
    double? pagerAt(WidgetTester tester) =>
        tester.widget<PageView>(find.byType(PageView)).controller?.page;

    Future<void> swipe(WidgetTester tester, Finder from, double dx) async {
      await tester.drag(from, Offset(dx, 0));
      await settle(tester);
    }

    testWidgets('a swipe turns the page and never holds it between two', (
      tester,
    ) async {
      chooseSimple();
      await pumpPage(tester);

      final gesture = await tester.startGesture(const Offset(200, 120));
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump(const Duration(milliseconds: 50));
      expect(pagerAt(tester), 0);
      await gesture.up();
      await settle(tester);

      expect(find.byTooltip('Edit widgets'), findsOneWidget);
      expect(pagerAt(tester), 1);

      await swipe(tester, find.byType(SimpleWidgetList), 200);
      expect(find.byTooltip('Detailed dashboard'), findsOneWidget);
      expect(pagerAt(tester), 0);
    });

    testWidgets('a short slow drag leaves the page where it was', (
      tester,
    ) async {
      chooseSimple();
      await pumpPage(tester);

      final gesture = await tester.startGesture(const Offset(200, 120));
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await settle(tester);

      expect(find.byTooltip('Detailed dashboard'), findsOneWidget);
      expect(pagerAt(tester), 0);
    });

    testWidgets('dragging the power button swipes nothing', (tester) async {
      chooseSimple();
      await pumpPage(tester);

      await swipe(tester, find.byType(PowerButton), -250);

      expect(find.byTooltip('Detailed dashboard'), findsOneWidget);
      expect(pagerAt(tester), 0);
    });
  });

  testWidgets('the services card tells the manager which services it shows', (
    tester,
  ) async {
    chooseSimple();
    await pumpPage(tester);
    await openWidgets(tester);

    final shown = container.read(shownServiceTargetsProvider);
    expect(shown, isNotEmpty);
    expect(shown.length, lessThanOrEqualTo(4));
    for (final target in shown) {
      expect(
        find.descendant(
          of: find.byType(SimpleServicesCard),
          matching: find.text(target.label),
        ),
        findsOneWidget,
        reason: target.label,
      );
    }
  });

  testWidgets('entering edit keeps the pager on the widget list', (
    tester,
  ) async {
    chooseSimple();
    await openEditor(tester);

    expect(find.byTooltip(_removeWidget), findsNWidgets(6));
    expect(
      centerX(tester, find.text('Mode')),
      inInclusiveRange(0, _phone.width),
    );
  });

  testWidgets('hiding a widget offers it back at the end of the list', (
    tester,
  ) async {
    chooseSimple(
      widgets: const [
        SimpleDashboardWidget.outboundMode,
        SimpleDashboardWidget.speed,
        SimpleDashboardWidget.services,
        SimpleDashboardWidget.ipQuality,
        SimpleDashboardWidget.trustedNetworks,
      ],
    );
    await openEditor(tester);

    await tester.tap(find.byTooltip('Remove Mode'));
    // The card goes out before its room closes.
    await settle(tester);
    await settle(tester);

    expect(savedWidgets(), const [
      SimpleDashboardWidget.speed,
      SimpleDashboardWidget.services,
      SimpleDashboardWidget.ipQuality,
      SimpleDashboardWidget.trustedNetworks,
    ]);
    expect(find.byTooltip(_removeWidget), findsNWidgets(4));
    expect(find.text('Available to add'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byTooltip('Add Mode'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SimpleWidgetList),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byTooltip('Add Mode'));
    await settle(tester);

    expect(savedWidgets(), const [
      SimpleDashboardWidget.speed,
      SimpleDashboardWidget.services,
      SimpleDashboardWidget.ipQuality,
      SimpleDashboardWidget.trustedNetworks,
      SimpleDashboardWidget.outboundMode,
    ]);
    expect(find.byTooltip('Add Mode'), findsNothing);
  });

  testWidgets('done leaves edit mode', (tester) async {
    chooseSimple();
    await openEditor(tester);

    await tester.tap(find.byTooltip('Done'));
    await settle(tester);

    expect(find.byTooltip(_removeWidget), findsNothing);
    expect(find.byTooltip('Edit widgets'), findsOneWidget);
  });

  testWidgets(
    'an empty widget list says so and still offers every widget to add',
    (tester) async {
      chooseSimple(widgets: const []);
      await pumpPage(tester);
      await openWidgets(tester);

      expect(
        find.text('No widgets yet. Add them in the editor.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Edit widgets'));
      await settle(tester);

      expect(find.text('Available to add'), findsOneWidget);
      expect(find.text('Mode'), findsOneWidget);
      expect(find.byTooltip(_removeWidget), findsNothing);
    },
  );

  testWidgets(
    'a desktop window shows Home and the widgets at once, without a pager',
    (tester) async {
      chooseSimple();
      await pumpPage(tester, size: _desktop);

      expect(find.text('Home'), findsNothing);
      expect(find.text('Widgets'), findsNothing);
      expect(find.text('Mode'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SimpleWidgetList),
          matching: find.byType(LocationCard),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Start'), findsOneWidget);
      expect(find.byTooltip('Edit widgets'), findsOneWidget);
      expect(find.byTooltip('Detailed dashboard'), findsOneWidget);
    },
  );

  testWidgets('a stopped core still shows the flag in the server name', (
    tester,
  ) async {
    const group = Group(
      type: GroupType.Selector,
      name: 'Proxy',
      now: '🇩🇪 Germany ⚡',
      all: [
        Proxy(name: '🇩🇪 Germany ⚡', type: 'vless'),
        Proxy(name: '🇳🇱 Netherlands', type: 'vless'),
      ],
    );
    useContainer(
      overrides: [
        groupsProvider.overrideWithBuild((_, _) => [group]),
        visibleGroupsStateProvider.overrideWithValue(
          const GroupsState(value: [group]),
        ),
      ],
    );
    chooseSimple();
    await pumpPage(tester);

    final card = find.byType(LocationCard);
    expect(
      find.descendant(
        of: card,
        matching: find.byWidgetPredicate(
          (widget) => widget is ShapeFlag && widget.code == 'de',
        ),
      ),
      findsOneWidget,
    );
    expect(find.descendant(of: card, matching: find.text('Germany')), findsOne);
    expect(find.descendant(of: card, matching: find.text('+1')), findsOne);
  });

  group('provider widget hint', () {
    final base = Config.realFromJson(null);

    ProviderSettingsInput input(Map<String, Object?> fields) =>
        ProviderSettingsInput(_hints(fields));

    test('maps only the names with a simple counterpart, in hint order', () {
      expect(
        _hints({
          'presentation.widgets': [
            'servicestatus',
            'networkspeed',
            'outboundmode',
          ],
        }).simpleWidgets,
        [SimpleDashboardWidget.services, SimpleDashboardWidget.outboundMode],
      );
    });

    test('is null when no listed name has a simple counterpart', () {
      expect(
        _hints({
          'presentation.widgets': ['networkspeed', 'profiles'],
        }).simpleWidgets,
        isNull,
      );
      expect(_hints({}).simpleWidgets, isNull);
    });

    test('a provided list replaces the simple list', () {
      final config = applyProviderSettings(
        base,
        input({
          'presentation.widgets': ['servicestatus', 'outboundmode'],
        }),
      );
      expect(config.appSettingProps.simpleDashboardWidgets, [
        SimpleDashboardWidget.services,
        SimpleDashboardWidget.outboundMode,
      ]);
      expect(isProviderManaged(config, 'simpleWidgets'), isTrue);
    });

    test('a list naming nothing simple leaves the user list alone', () {
      final config = applyProviderSettings(
        base,
        input({
          'presentation.widgets': ['networkspeed'],
        }),
      );
      expect(
        config.appSettingProps.simpleDashboardWidgets,
        base.appSettingProps.simpleDashboardWidgets,
      );
      expect(
        config.providerSettings.applied.containsKey('simpleWidgets'),
        isFalse,
      );
    });

    test('a user edit keeps the list and releases it from the provider', () {
      final hint = input({
        'presentation.widgets': ['servicestatus', 'outboundmode'],
      });
      final applied = applyProviderSettings(base, hint);
      final edited = applied.copyWith(
        appSettingProps: applied.appSettingProps.copyWith(
          simpleDashboardWidgets: const [SimpleDashboardWidget.speed],
        ),
      );

      final after = applyProviderSettings(edited, hint);
      expect(after.appSettingProps.simpleDashboardWidgets, const [
        SimpleDashboardWidget.speed,
      ]);
      expect(after.providerSettings.userOwned, contains('simpleWidgets'));
      expect(isProviderReleased(after, hint, 'simpleWidgets'), isTrue);

      final withdrawn = applyProviderSettings(after, input({}));
      expect(withdrawn.appSettingProps.simpleDashboardWidgets, const [
        SimpleDashboardWidget.speed,
      ]);
    });

    test('withdrawing an unchanged provider list restores the user list', () {
      final applied = applyProviderSettings(
        base,
        input({
          'presentation.widgets': ['servicestatus'],
        }),
      );
      final withdrawn = applyProviderSettings(applied, input({}));
      expect(
        withdrawn.appSettingProps.simpleDashboardWidgets,
        base.appSettingProps.simpleDashboardWidgets,
      );
    });
  });

  testWidgets('a provider list sets the simple widgets it maps to', (
    tester,
  ) async {
    useContainer(
      hints: _hints({
        'presentation.widgets': ['servicestatus', 'networkspeed'],
      }),
    );
    container.read(providerSettingsSyncProvider);
    chooseSimple();
    await pumpPage(tester);
    await openWidgets(tester);

    expect(savedWidgets(), [SimpleDashboardWidget.services]);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Mode'), findsNothing);
  });

  testWidgets('denyWidgets keeps the provider list and offers no editor', (
    tester,
  ) async {
    useContainer(
      hints: _hints({
        'presentation.widgets': ['servicestatus'],
        'settings.restrictions': ['denywidgets'],
      }),
    );
    container.read(providerSettingsSyncProvider);
    chooseSimple();
    await pumpPage(tester);
    await openWidgets(tester);

    expect(savedWidgets(), [SimpleDashboardWidget.services]);
    expect(find.byTooltip('Edit widgets'), findsNothing);
  });

  group('subscription card provider actions', () {
    Future<void> pumpSubscription(
      WidgetTester tester, {
      Map<String, Object?> fields = const {},
      required SubscriptionInfo info,
    }) async {
      useContainer(
        profile: _subscription(fields: fields, info: info),
      );
      chooseSimple();
      await pumpPage(tester);
    }

    Finder inCard(Finder matching) =>
        find.descendant(of: find.byType(SubscriptionCard), matching: matching);

    final dueSoon = _expiresIn(const Duration(days: 3, hours: 12));
    final farAway = _expiresIn(const Duration(days: 400));

    testWidgets('renew appears under the gauges once the days run low', (
      tester,
    ) async {
      await pumpSubscription(
        tester,
        fields: {
          'provider.buyPlanUrl': 'https://buy.example.test/plan',
          'provider.buyPlanDays': 5,
        },
        info: SubscriptionInfo(expire: dueSoon),
      );

      expect(inCard(find.text('Renew subscription')), findsOneWidget);
    });

    testWidgets('renew stays away above the provider threshold', (
      tester,
    ) async {
      await pumpSubscription(
        tester,
        fields: {
          'provider.buyPlanUrl': 'https://buy.example.test/plan',
          'provider.buyPlanDays': 2,
        },
        info: SubscriptionInfo(expire: dueSoon),
      );

      expect(inCard(find.text('Renew subscription')), findsNothing);
    });

    testWidgets('renew needs a provider link', (tester) async {
      await pumpSubscription(
        tester,
        fields: {'provider.buyPlanDays': 5},
        info: SubscriptionInfo(expire: dueSoon),
      );

      expect(inCard(find.text('Renew subscription')), findsNothing);
    });

    testWidgets('top-up appears once usage passes the provider threshold', (
      tester,
    ) async {
      await pumpSubscription(
        tester,
        fields: {
          'provider.buyTrafficUrl': 'https://buy.example.test/gb',
          'provider.buyTrafficPercent': 40,
        },
        info: SubscriptionInfo(
          upload: 25 * _gb,
          download: 25 * _gb,
          total: 100 * _gb,
          expire: farAway,
        ),
      );

      expect(inCard(find.text('Top up traffic')), findsOneWidget);
    });

    testWidgets('top-up stays away below the provider threshold', (
      tester,
    ) async {
      await pumpSubscription(
        tester,
        fields: {
          'provider.buyTrafficUrl': 'https://buy.example.test/gb',
          'provider.buyTrafficPercent': 60,
        },
        info: SubscriptionInfo(
          upload: 25 * _gb,
          download: 25 * _gb,
          total: 100 * _gb,
          expire: farAway,
        ),
      );

      expect(inCard(find.text('Top up traffic')), findsNothing);
    });

    testWidgets('top-up needs a provider link', (tester) async {
      await pumpSubscription(
        tester,
        fields: {'provider.buyTrafficPercent': 40},
        info: SubscriptionInfo(
          upload: 25 * _gb,
          download: 25 * _gb,
          total: 100 * _gb,
          expire: farAway,
        ),
      );

      expect(inCard(find.text('Top up traffic')), findsNothing);
    });

    testWidgets('support shows only when the provider sends a support link', (
      tester,
    ) async {
      await pumpSubscription(
        tester,
        fields: {'provider.supportUrl': 'https://support.example.test/help'},
        info: const SubscriptionInfo(),
      );
      expect(inCard(find.byTooltip('Support')), findsOneWidget);
    });

    testWidgets('no support link, no support button', (tester) async {
      await pumpSubscription(tester, info: const SubscriptionInfo());

      expect(inCard(find.byTooltip('Support')), findsNothing);
    });
  });

  group('provider messages', () {
    testWidgets('critical diagnostics stay off the simple home page', (
      tester,
    ) async {
      useContainer(
        overrides: [
          ...doctorOverrides(
            kernel: FakeDoctorKernel(),
            findings: [clockSkewFinding],
          ),
        ],
      );
      container.listen(findingsProvider, (_, _) {});
      chooseSimple();
      await pumpPage(tester);
      await settle(tester);
      expect(container.read(findingsProvider).value, [clockSkewFinding]);
      expect(
        find.descendant(
          of: find.byType(SimpleHome),
          matching: find.text(currentAppLocalizations.doctorCauseClockSkew),
        ),
        findsNothing,
      );
      expect(find.byType(SimplePower), findsOneWidget);
    });

    testWidgets('an announcement opens the widgets page and is not on home', (
      tester,
    ) async {
      useContainer(hints: _hints({'provider.announce': 'Maintenance tonight'}));
      chooseSimple();
      await pumpPage(tester);

      expect(
        find.descendant(
          of: find.byType(SimpleHome),
          matching: find.text('Maintenance tonight'),
        ),
        findsNothing,
      );

      await openWidgets(tester);

      expect(
        find.descendant(
          of: find.byType(SimpleWidgetList),
          matching: find.byType(OpenAnnouncementCard),
        ),
        findsOneWidget,
      );
      expect(find.text('Maintenance tonight'), findsOneWidget);
    });

    testWidgets('a notice is a card on the widgets page and not on home', (
      tester,
    ) async {
      useContainer(hints: _hints({'provider.notice': 'Server maintenance'}));
      chooseSimple();
      await pumpPage(tester);

      final notice = find.byKey(const ValueKey('provider-notice-card'));
      expect(
        find.descendant(of: find.byType(SimpleHome), matching: notice),
        findsNothing,
      );

      await openWidgets(tester);

      expect(
        find.descendant(of: find.byType(SimpleWidgetList), matching: notice),
        findsOneWidget,
      );
      expect(find.text('Server maintenance'), findsOneWidget);
    });
  });
}

class _PendingUpdate extends AppUpdateAction {
  _PendingUpdate(this.initial);

  final AppUpdateState initial;

  @override
  bool get isSupported => false;

  @override
  AppUpdateState build() => initial;
}
