import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/lovense/controller.dart';
import 'package:reclash/features/lovense/engine.dart';
import 'package:reclash/features/lovense/models.dart';
import 'package:reclash/features/lovense/providers.dart';
import 'package:reclash/features/lovense/reactions.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

import 'fakes.dart';

const _up = LovenseLink(running: true, coreConnected: true);
const _idle = LovenseLink(running: false, coreConnected: true);
const _lost = LovenseLink(running: true, coreConnected: false);

class _Source implements LovenseReactionSource {
  @override
  LovenseLink link = _idle;
  @override
  bool visible = true;
  final links = <ValueChanged<LovenseLink>>[];
  final speeds = <ValueChanged<num>>[];
  final visibility = <ValueChanged<bool>>[];

  int get listeners => links.length + speeds.length + visibility.length;

  VoidCallback _add<T>(List<T> list, T listener) {
    list.add(listener);
    return () => list.remove(listener);
  }

  @override
  VoidCallback listenLink(ValueChanged<LovenseLink> listener) =>
      _add(links, listener);

  @override
  VoidCallback listenSpeed(ValueChanged<num> listener) =>
      _add(speeds, listener);

  @override
  VoidCallback listenVisible(ValueChanged<bool> listener) =>
      _add(visibility, listener);

  void setLink(LovenseLink next) {
    link = next;
    for (final listener in [...links]) {
      listener(next);
    }
  }
}

void main() {
  group('traffic level', () {
    test('is silent below the floor and full at the ceiling', () {
      expect(lovenseTrafficLevel(0), 0);
      expect(lovenseTrafficLevel(lovenseTrafficFloor - 1), 0);
      expect(lovenseTrafficLevel(lovenseTrafficFloor), 1);
      expect(lovenseTrafficLevel(lovenseTrafficCeiling), 20);
      expect(lovenseTrafficLevel(lovenseTrafficCeiling * 100), 20);
    });

    test('grows on a log scale', () {
      expect(lovenseTrafficLevel(320 * 1024), 10);
      var previous = 0;
      for (var speed = 8 * 1024; speed < 20 << 20; speed = speed * 3 ~/ 2) {
        final level = lovenseTrafficLevel(speed);
        expect(level, greaterThanOrEqualTo(previous));
        previous = level;
      }
    });

    test('scales to the function and keeps a non-zero level audible', () {
      expect(lovenseScaledStrength(0, LovenseFunction.pump), 0);
      expect(lovenseScaledStrength(1, LovenseFunction.pump), 1);
      expect(lovenseScaledStrength(20, LovenseFunction.pump), 3);
      expect(lovenseScaledStrength(7, LovenseFunction.vibrate), 7);
    });
  });

  test('targets Vibrate, else the first function', () {
    expect(lovenseReactionFunction(fakeLovenseToy()), LovenseFunction.vibrate);
    expect(
      lovenseReactionFunction(
        fakeLovenseToy(
          functions: [LovenseFunction.rotate, LovenseFunction.vibrate],
        ),
      ),
      LovenseFunction.vibrate,
    );
    expect(
      lovenseReactionFunction(
        fakeLovenseToy(functions: [LovenseFunction.pump]),
      ),
      LovenseFunction.pump,
    );
    expect(lovenseReactionFunction(fakeLovenseToy(functions: [])), isNull);
  });

  test('governor throttles, keeps alive and stops once', () {
    final governor = LovenseTrafficGovernor();
    Duration at(int ms) => Duration(milliseconds: ms);
    expect(governor.next(0, at(0)), isNull);
    expect(governor.next(5, at(0)), 5);
    expect(governor.next(9, at(500)), isNull);
    expect(governor.next(9, at(1000)), 9);
    expect(governor.next(9, at(2500)), isNull);
    expect(governor.next(9, at(3000)), 9);
    expect(governor.next(0, at(4000)), 0);
    expect(governor.next(0, at(9000)), isNull);
    governor.reset();
    expect(governor.next(4, at(9100)), 4);
  });

  group('link tracker', () {
    test('reports a start only once it settles', () {
      final tracker = LovenseLinkTracker(_idle);
      expect(tracker.update(_up), isNull);
      expect(tracker.pendingStart, isTrue);
      expect(tracker.confirm(), LovenseReaction.started);
      expect(tracker.confirm(), isNull);
    });

    test('ignores a start rolled back before it settles', () {
      final tracker = LovenseLinkTracker(_idle);
      tracker.update(_up);
      expect(tracker.update(_idle), isNull);
      expect(tracker.confirm(), isNull);
    });

    test('tells a user stop from a lost connection', () {
      final tracker = LovenseLinkTracker(_up);
      expect(tracker.update(_lost), LovenseReaction.lost);
      expect(tracker.update(_up), isNull);
      expect(tracker.confirm(), LovenseReaction.started);
      expect(tracker.update(_idle), LovenseReaction.stopped);
      expect(
        LovenseLinkTracker(
          const LovenseLink(running: true, coreConnected: false),
        ).update(const LovenseLink(running: false, coreConnected: false)),
        isNull,
      );
    });
  });

  test('patterns differ and every pulse ends before the toy timer', () {
    final shapes = {
      for (final reaction in LovenseReaction.values)
        lovenseReactionPattern(
          reaction,
        ).map((pulse) => '${pulse.level}/${pulse.on.inMilliseconds}').join(','),
    };
    expect(shapes, hasLength(LovenseReaction.values.length));
    for (final reaction in LovenseReaction.values) {
      for (final pulse in lovenseReactionPattern(reaction)) {
        expect(pulse.on, lessThan(const Duration(seconds: lovenseMinDuration)));
      }
    }
  });

  group('with a connected controller', () {
    late FakeLovenseApi api;
    late DateTime now;
    late LovenseController controller;

    setUp(() {
      api = FakeLovenseApi();
      now = DateTime(2026);
      controller = LovenseController(
        clientFactory: (_) => api,
        store: FakeLovenseStore(),
        now: () => now,
      );
    });

    tearDown(() => controller.dispose());

    List<Map<String, Object>> after(int start) => api.commands.sublist(start);

    test('a manual command wins over reactions until it ends', () async {
      await controller.connect('localhost');
      await controller.run(
        toyId: 'toy1',
        function: LovenseFunction.vibrate,
        strength: 3,
        duration: 5,
      );
      final start = api.commands.length;
      for (final id in ['toy1', 'toy2']) {
        await controller.sendReaction(
          toyId: id,
          function: LovenseFunction.vibrate,
          strength: 9,
          duration: 2,
        );
        await controller.stopReaction(id);
      }
      expect(after(start), [
        {
          'command': 'Function',
          'action': 'Vibrate:9',
          'toy': 'toy2',
          'timeSec': 2,
        },
        {'command': 'Function', 'action': 'Stop', 'toy': 'toy2'},
      ]);
      now = now.add(const Duration(seconds: 5));
      expect(controller.manualActive('toy1'), isFalse);
      await controller.sendReaction(
        toyId: 'toy1',
        function: LovenseFunction.vibrate,
        strength: 9,
        duration: 2,
      );
      expect(api.commands.last['toy'], 'toy1');
    });

    test('a connection burst always ends in Stop', () {
      fakeAsync((async) {
        controller.connect('localhost');
        async.flushMicrotasks();
        final source = _Source();
        final reactions = LovenseReactions(controller, source);
        reactions.setConnection(true);
        final start = api.commands.length;
        source.setLink(_up);
        async.elapse(const Duration(seconds: 3));
        final burst = after(start);
        expect(burst.map((command) => command['action']), [
          'Vibrate:10',
          'Vibrate:10',
          'Stop',
          'Stop',
        ]);
        expect(burst.first['timeSec'], lovenseMinDuration);
        reactions.dispose();
      });
    });

    test('traffic follows speed, pauses in the background, then idles', () {
      fakeAsync((async) {
        controller.connect('localhost');
        async.flushMicrotasks();
        final source = _Source();
        var elapsed = Duration.zero;
        final reactions = LovenseReactions(
          controller,
          source,
          now: () => elapsed,
        );
        void tick() {
          elapsed += lovenseTrafficInterval;
          async.elapse(lovenseTrafficInterval);
        }

        reactions.setTraffic(true);
        final start = api.commands.length;
        for (final listener in source.speeds) {
          listener(lovenseTrafficCeiling);
        }
        tick();
        expect(after(start).map((command) => command['action']), [
          'Vibrate:20',
          'Vibrate:20',
        ]);
        expect(api.commands.last['timeSec'], lovenseTrafficDuration);
        for (final listener in [...source.visibility]) {
          listener(false);
        }
        async.flushMicrotasks();
        expect(api.commands.last['action'], 'Stop');
        final paused = api.commands.length;
        tick();
        tick();
        expect(api.commands.length, paused);
        reactions.setTraffic(false);
        expect(source.listeners, 0);
        reactions.dispose();
      });
    });

    test('reactions turn off when the controller disconnects', () async {
      final source = _Source();
      final reactions = LovenseReactions(controller, source);
      reactions.setConnection(true);
      expect(reactions.connection, isFalse);
      await controller.connect('localhost');
      reactions
        ..setConnection(true)
        ..setTraffic(true);
      expect(source.listeners, 3);
      await controller.disconnect();
      expect(reactions.active, isFalse);
      expect(source.listeners, 0);
      reactions.dispose();
    });
  });

  test('provider wiring listens to the run state only while enabled', () {
    fakeAsync((async) {
      final api = FakeLovenseApi();
      final container = ProviderContainer(
        overrides: [
          lovenseControllerProvider.overrideWith(
            (ref) => LovenseController(
              clientFactory: (_) => api,
              store: FakeLovenseStore(),
            ),
          ),
        ],
      );
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      container.read(appVisibleProvider.notifier).value = true;
      container.read(lovenseControllerProvider).connect('localhost');
      async.flushMicrotasks();
      final reactions = container.read(lovenseReactionsProvider);
      final start = api.commands.length;
      container.read(runTimeProvider.notifier).value = 1;
      async.elapse(const Duration(seconds: 3));
      expect(api.commands.length, start);

      reactions.setConnection(true);
      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      async.elapse(const Duration(seconds: 3));
      expect(api.commands[start]['action'], 'Vibrate:20');

      reactions.setTraffic(true);
      container
          .read(trafficsProvider.notifier)
          .addTraffic(const Traffic(down: lovenseTrafficCeiling));
      async.elapse(lovenseTrafficInterval);
      expect(api.commands.last['action'], 'Vibrate:20');
      expect(api.commands.last['timeSec'], lovenseTrafficDuration);
      container.dispose();
      async.flushMicrotasks();
    });
  });
}
