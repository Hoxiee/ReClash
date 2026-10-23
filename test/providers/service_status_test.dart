import 'dart:async';

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/route_state.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _TestRouteTracker extends RouteTracker {
  _TestRouteTracker(this.initial);

  final RouteState initial;

  @override
  RouteState build() => initial;

  @override
  void attach() {}

  @override
  void detach() {}

  @override
  void resync() {}

  void setRoute(RouteState route) => state = route;
}

ServiceCheckItem _item(String name, {String status = 'available'}) =>
    ServiceCheckItem(
      name: name,
      status: status,
      delay: 12,
      chains: const ['HK-01'],
      checkedAt: 1700000000000,
      coreEpoch: 1,
      routeVersion: 1,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(const ServiceCheckParams(timeout: 0)));

  late _MockCore core;
  late List<ServiceCheckParams> sweeps;

  setUp(() {
    core = _MockCore();
    sweeps = [];
    when(() => core.serviceCheck(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as ServiceCheckParams;
      sweeps.add(params);
      return [for (final name in params.names) _item(name)];
    });
  });

  ProviderContainer container({
    bool proxied = true,
    bool synced = true,
    bool live = true,
    bool visible = true,
    AppSettingProps settings = const AppSettingProps(),
    bool tearDown = true,
  }) {
    final scope = ProviderContainer(
      overrides: [
        routeTrackerProvider.overrideWith(
          () => _TestRouteTracker(
            RouteState(
              coreEpoch: 1,
              routeVersion: 1,
              hostEpoch: 1,
              proxied: proxied,
              synced: synced,
              live: live,
            ),
          ),
        ),
        appSettingProvider.overrideWithBuild((_, _) => settings),
        appVisibleProvider.overrideWithBuild((_, _) => visible),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    if (tearDown) addTearDown(scope.dispose);
    scope.listen(serviceStatusProvider, (_, _) {});
    return scope;
  }

  ServiceStatus notifierOf(ProviderContainer scope) =>
      scope.read(serviceStatusProvider.notifier);

  RoutedProbeState<ServiceTarget, ServiceCheck> stateOf(
    ProviderContainer scope,
  ) => scope.read(serviceStatusProvider);

  void setRoute(ProviderContainer scope, RouteState route) =>
      (scope.read(routeTrackerProvider.notifier) as _TestRouteTracker).setRoute(
        route,
      );

  void timerTest(
    String name,
    Future<void> Function(WidgetTester, ProviderContainer) body, {
    bool proxied = true,
    bool synced = true,
    bool live = true,
    bool visible = true,
    AppSettingProps settings = const AppSettingProps(),
  }) {
    testWidgets(name, (tester) async {
      final scope = container(
        proxied: proxied,
        synced: synced,
        live: live,
        visible: visible,
        settings: settings,
        tearDown: false,
      );
      try {
        await tester.pump();
        await body(tester, scope);
      } finally {
        scope.dispose();
        await tester.pump();
      }
    });
  }

  test('automatic check settings default to active and connected only', () {
    const settings = AppSettingProps();
    expect(settings.autoCheckActiveServices, isTrue);
    expect(settings.autoCheckAllServices, isFalse);
    expect(settings.serviceCheckOnlyWhenConnected, isTrue);
  });

  timerTest('watch only subscribes and never resets the automatic delay', (
    tester,
    scope,
  ) async {
    notifierOf(scope).watch(ServiceTarget.youtube);
    await tester.pump(const Duration(seconds: 2));
    notifierOf(scope).watch(ServiceTarget.claude);
    await tester.pump(const Duration(milliseconds: 999));
    expect(sweeps, isEmpty);
    expect(stateOf(scope).entries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(sweeps.map((s) => s.names.single), [
      for (final target in scope.read(enabledServiceTargetsProvider)) target.id,
    ]);
    expect(sweeps.length, greaterThan(4));
    await tester.pump(const Duration(seconds: 10));
    expect(sweeps.length, scope.read(enabledServiceTargetsProvider).length);
  });

  timerTest(
    'active automatic checks use enabled targets even without watchers',
    (tester, scope) async {
      await tester.pump(const Duration(seconds: 3));
      expect(sweeps.map((s) => s.names.single), [
        for (final target in scope.read(enabledServiceTargetsProvider))
          target.id,
      ]);
      expect(sweeps.map((s) => s.names.single), isNot(contains('github')));
    },
    settings: const AppSettingProps(
      serviceOrder: ['claude', 'google'],
      disabledServices: ['github', 'bilibili'],
    ),
  );

  timerTest(
    'all-services mode checks the ordered catalog including disabled targets',
    (tester, scope) async {
      await tester.pump(const Duration(seconds: 3));
      expect(sweeps.map((s) => s.names.single), [
        for (final target in scope.read(serviceTargetsProvider)) target.id,
      ]);
      expect(sweeps, hasLength(ServiceTarget.values.length));
    },
    settings: const AppSettingProps(
      autoCheckActiveServices: false,
      autoCheckAllServices: true,
      serviceOrder: ['claude', 'google'],
      disabledServices: ['github', 'bilibili'],
    ),
  );

  timerTest('both automatic modes off leave watched services idle', (
    tester,
    scope,
  ) async {
    notifierOf(scope).watch(ServiceTarget.youtube);
    await tester.pump(const Duration(seconds: 10));
    expect(sweeps, isEmpty);
  }, settings: const AppSettingProps(autoCheckActiveServices: false));

  final routeChanges = <String, RouteState Function(RouteState)>{
    'core epoch': (route) => route.copyWith(coreEpoch: 2),
    'host epoch': (route) => route.copyWith(hostEpoch: 2),
    'picks version': (route) => route.copyWith(routeVersion: 2),
    'proxy state': (route) => route.copyWith(proxied: false),
  };
  for (final change in routeChanges.entries) {
    timerTest('waits for a stable ${change.key} for three seconds', (
      tester,
      scope,
    ) async {
      await tester.pump(const Duration(seconds: 2));
      setRoute(scope, change.value(scope.read(routeTrackerProvider)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2999));
      expect(sweeps, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        sweeps,
        hasLength(scope.read(enabledServiceTargetsProvider).length),
      );
    }, settings: const AppSettingProps(serviceCheckOnlyWhenConnected: false));
  }

  for (final field in ['live', 'synced']) {
    timerTest(
      'losing $field cancels the delay and reconnect starts a new one',
      (tester, scope) async {
        await tester.pump(const Duration(seconds: 2));
        final route = scope.read(routeTrackerProvider);
        setRoute(
          scope,
          field == 'live'
              ? route.copyWith(live: false)
              : route.copyWith(synced: false),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(sweeps, isEmpty);
        setRoute(scope, route);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 2999));
        expect(sweeps, isEmpty);
        await tester.pump(const Duration(milliseconds: 1));
        expect(sweeps, isNotEmpty);
      },
    );
  }

  for (final field in ['live', 'synced']) {
    timerTest(
      'an initially $field-disabled route waits for readiness and three seconds',
      (tester, scope) async {
        notifierOf(scope).watch(ServiceTarget.youtube);
        await tester.pump(const Duration(seconds: 5));
        expect(sweeps, isEmpty);
        setRoute(
          scope,
          scope.read(routeTrackerProvider).copyWith(live: true, synced: true),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 2999));
        expect(sweeps, isEmpty);
        await tester.pump(const Duration(milliseconds: 1));
        expect(sweeps, isNotEmpty);
      },
      live: field != 'live',
      synced: field != 'synced',
    );
  }

  timerTest('enabled target changes restart the delay and use the new list', (
    tester,
    scope,
  ) async {
    await tester.pump(const Duration(seconds: 2));
    scope
        .read(appSettingProvider.notifier)
        .update((settings) => settings.copyWith(disabledServices: ['youtube']));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2999));
    expect(sweeps, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(sweeps.map((s) => s.names.single), [
      for (final target in scope.read(enabledServiceTargetsProvider)) target.id,
    ]);
    expect(sweeps.map((s) => s.names.single), isNot(contains('youtube')));
  });

  timerTest('disabling automatic checks during the delay cancels the run', (
    tester,
    scope,
  ) async {
    await tester.pump(const Duration(seconds: 2));
    scope
        .read(appSettingProvider.notifier)
        .update(
          (settings) => settings.copyWith(autoCheckActiveServices: false),
        );
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(sweeps, isEmpty);
  });

  timerTest('disconnecting the proxy cancels connected-only checks', (
    tester,
    scope,
  ) async {
    await tester.pump(const Duration(seconds: 2));
    setRoute(scope, scope.read(routeTrackerProvider).copyWith(proxied: false));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(sweeps, isEmpty);
    setRoute(scope, scope.read(routeTrackerProvider).copyWith(proxied: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2999));
    expect(sweeps, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(sweeps, isNotEmpty);
  });

  timerTest('hiding cancels the delay and showing waits three seconds', (
    tester,
    scope,
  ) async {
    await tester.pump(const Duration(seconds: 2));
    scope.read(appVisibleProvider.notifier).value = false;
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(sweeps, isEmpty);
    scope.read(appVisibleProvider.notifier).value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2999));
    expect(sweeps, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(sweeps, isNotEmpty);
  });

  timerTest('an initially hidden app does not start automatic checks', (
    tester,
    scope,
  ) async {
    await tester.pump(const Duration(seconds: 5));
    expect(sweeps, isEmpty);
  }, visible: false);

  timerTest('automatic direct checks require connected-only to be disabled', (
    tester,
    scope,
  ) async {
    await tester.pump(const Duration(seconds: 5));
    expect(sweeps, isEmpty);
    scope
        .read(appSettingProvider.notifier)
        .update(
          (settings) => settings.copyWith(serviceCheckOnlyWhenConnected: false),
        );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2999));
    expect(sweeps, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(sweeps, isNotEmpty);
    expect(sweeps.every((s) => s.proxyName == directOutbound), isTrue);
  }, proxied: false);

  testWidgets('dispose cancels a pending automatic check', (tester) async {
    final scope = container(tearDown: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    scope.dispose();
    await tester.pump(const Duration(seconds: 5));
    expect(sweeps, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dispose also ignores an in-flight manual answer', (
    tester,
  ) async {
    final gate = Completer<List<ServiceCheckItem>>();
    when(() => core.serviceCheck(any())).thenAnswer((_) => gate.future);
    final scope = container(tearDown: false);
    notifierOf(scope).refresh([ServiceTarget.youtube]);
    await tester.pump();
    expect(stateOf(scope).isLoading(ServiceTarget.youtube), isTrue);
    scope.dispose();
    gate.complete([_item('youtube')]);
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  test(
    'manual refresh checks named targets immediately through the Core route',
    () async {
      final scope = container();
      notifierOf(scope)
        ..watch(ServiceTarget.youtube)
        ..refresh([ServiceTarget.youtube, ServiceTarget.claude]);
      await pumpEventQueue();
      expect(sweeps.map((sweep) => sweep.names), [
        ['youtube'],
        ['claude'],
      ]);
      expect(sweeps.first.proxyName, isEmpty);
      expect(sweeps.first.timeout, probeTimeoutDuration.inMilliseconds);
      expect(
        stateOf(scope).entryOf(ServiceTarget.youtube).phase,
        ProbePhase.fresh,
      );
      expect(stateOf(scope).valueOf(ServiceTarget.youtube)?.node, 'HK-01');
      expect(stateOf(scope).valueOf(ServiceTarget.claude)?.delay, 12);
    },
  );

  timerTest(
    'manual direct refresh ignores automatic and connected-only restrictions',
    (tester, scope) async {
      notifierOf(scope).refresh([ServiceTarget.bilibili]);
      await tester.pump();
      expect(sweeps.single.proxyName, directOutbound);
      expect(sweeps.single.names, ['bilibili']);
      expect(
        stateOf(scope).entryOf(ServiceTarget.bilibili).phase,
        ProbePhase.fresh,
      );
    },
    proxied: false,
    settings: const AppSettingProps(autoCheckActiveServices: false),
  );

  test('shows each answer as it lands', () async {
    final scope = container();
    final gates = <String, Completer<List<ServiceCheckItem>>>{};
    when(() => core.serviceCheck(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.single as ServiceCheckParams;
      return (gates[params.names.single] = Completer()).future;
    });
    notifierOf(scope).refresh(ServiceTarget.values);
    await pumpEventQueue();
    expect(gates.keys, [for (final target in ServiceTarget.values) target.id]);
    expect(stateOf(scope).isLoading(ServiceTarget.google), isTrue);
    gates['google']!.complete([_item('google')]);
    await pumpEventQueue();
    expect(
      stateOf(scope).entryOf(ServiceTarget.google).phase,
      ProbePhase.fresh,
    );
    expect(stateOf(scope).isLoading(ServiceTarget.github), isTrue);
    for (final entry in gates.entries) {
      if (entry.key != 'google') entry.value.complete([_item(entry.key)]);
    }
    await pumpEventQueue();
  });

  test(
    'will not queue a second check for a target already in flight',
    () async {
      final scope = container();
      final gate = Completer<List<ServiceCheckItem>>();
      when(() => core.serviceCheck(any())).thenAnswer((_) => gate.future);
      final notifier = notifierOf(scope);
      notifier.refresh([ServiceTarget.youtube]);
      await pumpEventQueue();
      notifier
        ..watch(ServiceTarget.youtube)
        ..refresh([ServiceTarget.youtube]);
      await pumpEventQueue();
      gate.complete([_item('youtube')]);
      await pumpEventQueue();
      verify(() => core.serviceCheck(any())).called(1);
      expect(stateOf(scope).isLoading(ServiceTarget.youtube), isFalse);
    },
  );

  for (final status in ['timeout', 'failed']) {
    test(
      'a $status answer remains a visible failure until refreshed',
      () async {
        when(
          () => core.serviceCheck(any()),
        ).thenAnswer((_) async => [_item('youtube', status: status)]);
        final scope = container();
        notifierOf(scope).refresh([ServiceTarget.youtube]);
        await pumpEventQueue();
        final entry = stateOf(scope).entryOf(ServiceTarget.youtube);
        expect(entry.phase, ProbePhase.failed);
        expect(entry.value?.status, ServiceProbeStatus.byId(status));
        expect(entry.isLoading, isFalse);
      },
    );
  }

  test(
    'an exception settles loading and a manual refresh can recover',
    () async {
      final scope = container();
      when(() => core.serviceCheck(any())).thenThrow(StateError('offline'));
      notifierOf(scope).refresh([ServiceTarget.youtube]);
      await pumpEventQueue();
      expect(
        stateOf(scope).entryOf(ServiceTarget.youtube).phase,
        ProbePhase.failed,
      );
      expect(stateOf(scope).isLoading(ServiceTarget.youtube), isFalse);
      when(
        () => core.serviceCheck(any()),
      ).thenAnswer((_) async => [_item('youtube')]);
      notifierOf(scope).refresh([ServiceTarget.youtube]);
      await pumpEventQueue();
      expect(
        stateOf(scope).entryOf(ServiceTarget.youtube).phase,
        ProbePhase.fresh,
      );
    },
  );

  timerTest(
    'route invalidation clears stale values without immediate rechecks',
    (tester, scope) async {
      notifierOf(scope)
        ..watch(ServiceTarget.youtube)
        ..refresh([ServiceTarget.youtube]);
      await tester.pump();
      expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNotNull);
      scope.read(routeTrackerProvider.notifier).bumpHostEpoch();
      await tester.pump();
      expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNull);
      expect(stateOf(scope).isLoading(ServiceTarget.youtube), isFalse);
      await tester.pump(const Duration(milliseconds: 2999));
      expect(sweeps, hasLength(1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        sweeps.length,
        1 + scope.read(enabledServiceTargetsProvider).length,
      );
      expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNotNull);
    },
  );

  timerTest('late answers from an old route cannot bypass the new delay', (
    tester,
    scope,
  ) async {
    final gate = Completer<List<ServiceCheckItem>>();
    when(() => core.serviceCheck(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.single as ServiceCheckParams;
      sweeps.add(params);
      return sweeps.length == 1
          ? gate.future
          : Future.value([_item(params.names.single)]);
    });
    notifierOf(scope)
      ..watch(ServiceTarget.youtube)
      ..refresh([ServiceTarget.youtube]);
    await tester.pump();
    scope.read(routeTrackerProvider.notifier).bumpHostEpoch();
    gate.complete([_item('youtube')]);
    await tester.pump();
    expect(stateOf(scope).valueOf(ServiceTarget.youtube), isNull);
    await tester.pump(const Duration(milliseconds: 2999));
    expect(sweeps, hasLength(1));
    await tester.pump(const Duration(milliseconds: 1));
    expect(sweeps.length, greaterThan(1));
  });

  test(
    'enabled targets follow the saved order and skip turned-off services',
    () {
      final scope = container();
      scope.read(appSettingProvider.notifier).value = const AppSettingProps(
        serviceOrder: ['claude', 'google'],
        disabledServices: ['github', 'bilibili'],
      );

      expect(scope.read(enabledServiceTargetsProvider).map((t) => t.id), [
        'claude',
        'google',
        for (final target in ServiceTarget.values)
          if (!['claude', 'google', 'github', 'bilibili'].contains(target.id))
            target.id,
      ]);
    },
  );

  test(
    'region changes preserve explicit service choices without resurrecting defaults',
    () {
      final scope = container();
      scope.listen(appSettingProvider, (_, _) {});
      scope.listen(enabledServiceTargetsProvider, (_, _) {});
      final settings = scope.read(appSettingProvider.notifier);
      settings.value = const AppSettingProps(
        regionCode: 'RU',
        enabledServices: ['netflix'],
        disabledServices: ['youtube', 'discord', 'chatgpt', 'claude'],
      );
      expect(scope.read(enabledServiceTargetsProvider), [
        ServiceTarget.netflix,
      ]);
      settings.update((state) => state.copyWith(regionCode: 'IR'));
      expect(scope.read(enabledServiceTargetsProvider), [
        ServiceTarget.netflix,
      ]);
      settings.update((state) => state.copyWith(enabledServices: const []));
      expect(scope.read(enabledServiceTargetsProvider), isEmpty);
    },
  );

  test('a config that turns every service off keeps the list empty', () {
    final scope = container();
    scope.read(appSettingProvider.notifier).value = AppSettingProps(
      disabledServices: [for (final target in ServiceTarget.values) target.id],
    );

    expect(scope.read(enabledServiceTargetsProvider), isEmpty);
  });
}
