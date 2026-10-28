import 'dart:async';

import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/lib.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/service.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_profiles.dart';

class _FakeService implements Service {
  _FakeService();

  final calls = <String>[];

  String initError = '';
  String syncError = '';
  bool shutdownResult = true;
  bool startResult = true;
  bool stopResult = true;
  Completer<void>? initGate;
  Completer<void>? syncGate;
  Completer<void>? shutdownGate;
  Completer<void>? startGate;
  Completer<void>? stopGate;
  FutureOr<String> Function()? onInit;
  FutureOr<String> Function()? onSyncState;
  FutureOr<CoreMethodResponse?> Function(CoreMethodCall call)? onInvokeMethod;

  final invokedCalls = <CoreMethodCall>[];

  @override
  Future<String> init() async {
    calls.add('init');
    await initGate?.future;
    return onInit?.call() ?? initError;
  }

  @override
  Future<String> syncState(SharedState state) async {
    calls.add('syncState');
    await syncGate?.future;
    return onSyncState?.call() ?? syncError;
  }

  @override
  Future<bool> shutdown() async {
    calls.add('shutdown');
    await shutdownGate?.future;
    return shutdownResult;
  }

  @override
  Future<bool> start() async {
    calls.add('start');
    await startGate?.future;
    return startResult;
  }

  @override
  Future<bool> stop() async {
    calls.add('stop');
    await stopGate?.future;
    return stopResult;
  }

  @override
  Future<CoreMethodResponse?> invokeMethod(CoreMethodCall call) async {
    calls.add('invokeMethod:${call.method.name}');
    invokedCalls.add(call);
    return onInvokeMethod?.call(call);
  }

  @override
  Future<DateTime?> getRunTime() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _FakeService service;
  late CoreLib lib;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    service = _FakeService();
    lib = CoreLib.scoped(service);
  });

  tearDown(() {
    container.dispose();
    CoreLib.resetInstance();
  });

  group('start', () {
    test('initializes, connects and syncs shared state', () async {
      final result = await lib.start();

      expect(result.outcome, CoreLifecycleOutcome.applied);
      expect(result.revision, 1);
      expect(service.calls, ['init', 'syncState']);
    });

    test('coalesces a second start while already connected', () async {
      await lib.start();
      service.calls.clear();

      final result = await lib.start();

      expect(result.outcome, CoreLifecycleOutcome.coalesced);
      expect(result.revision, 2);
      expect(service.calls, isEmpty);
    });

    test('coalesces starts while initialization is pending', () async {
      service.initGate = Completer<void>();
      final first = lib.start();
      final second = lib.start();
      final results = Future.wait([first, second]);
      await pumpEventQueue();
      service.initGate!.complete();

      expect((await results).map((result) => result.outcome), [
        CoreLifecycleOutcome.applied,
        CoreLifecycleOutcome.coalesced,
      ]);
      expect(service.calls, ['init', 'syncState']);
    });

    test('an initialization error leaves the handler unconnected', () async {
      service.initError = 'init boom';

      await expectLater(
        lib.start(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'init boom'),
        ),
      );
      expect(service.calls, ['init']);

      service.initError = '';
      final retry = await lib.start();
      expect(retry.outcome, CoreLifecycleOutcome.applied);
    });

    test('a sync error shuts the service down and reopens the gate', () async {
      service.syncError = 'sync boom';

      await expectLater(
        lib.start(),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'sync boom'),
        ),
      );
      expect(service.calls, ['init', 'syncState', 'shutdown']);

      service.syncError = '';
      service.calls.clear();
      final retry = await lib.start();

      expect(retry.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['init', 'syncState']);
    });
  });

  group('superseded start failures', () {
    for (final phase in ['init', 'syncState']) {
      test('a late $phase error preserves the next connection wait', () async {
        final response = Completer<String>();
        var attempts = 0;
        FutureOr<String> answer() => ++attempts == 1 ? response.future : '';
        if (phase == 'init') {
          service.onInit = answer;
        } else {
          service.onSyncState = answer;
        }
        final oldStart = expectLater(lib.start(), throwsStateError);
        await pumpEventQueue();
        expect(service.calls.last, phase);

        final stop = lib.stop();
        final nextStart = lib.start();
        service.onInvokeMethod = (call) =>
            CoreMethodResponse(id: call.id, result: 'new connection');
        final reply = lib.invokeMethod<String>(method: CoreMethod.getProxies);
        response.complete('obsolete start failed');

        await oldStart;
        await stop;
        expect((await nextStart).outcome, CoreLifecycleOutcome.applied);
        expect(await reply, 'new connection');
      });
    }
  });

  group('stop', () {
    test('coalesces when there is nothing connected', () async {
      final result = await lib.stop();

      expect(result.outcome, CoreLifecycleOutcome.coalesced);
      expect(service.calls, isEmpty);
    });

    test('shuts the service down once connected', () async {
      await lib.start();
      service.calls.clear();

      final result = await lib.stop();

      expect(result.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls, ['shutdown']);
    });

    test('a failed shutdown stays owned until a retry succeeds', () async {
      await lib.start();
      service.shutdownResult = false;

      await expectLater(lib.stop(), throwsA(isA<StateError>()));

      service.shutdownResult = true;
      final again = await lib.stop();
      expect(again.outcome, CoreLifecycleOutcome.applied);
      expect(service.calls.where((call) => call == 'shutdown'), hasLength(2));
    });

    test(
      'supersedes a pending initialization before accepting a new start',
      () async {
        service.initGate = Completer<void>();
        final start = lib.start();
        await pumpEventQueue();
        final stop = lib.stop();
        final restart = lib.start();
        final results = Future.wait([start, stop, restart]);
        service.initGate!.complete();

        final completed = await results;
        expect(completed.first.outcome, CoreLifecycleOutcome.superseded);
        expect(completed.last.outcome, CoreLifecycleOutcome.applied);
        expect(service.calls, ['init', 'shutdown', 'init', 'syncState']);
      },
    );
  });

  test('restart stops before starting again', () async {
    await lib.start();
    service.calls.clear();

    final result = await lib.restart();

    expect(result.outcome, CoreLifecycleOutcome.applied);
    expect(service.calls, ['shutdown', 'init', 'syncState']);
  });

  test('a newer stop supersedes a restart waiting for shutdown', () async {
    await lib.start();
    service.calls.clear();
    service.shutdownGate = Completer<void>();
    final restart = lib.restart();
    await pumpEventQueue();
    final stop = lib.stop();
    service.shutdownGate!.complete();

    expect((await restart).outcome, CoreLifecycleOutcome.superseded);
    await stop;
    expect(service.calls, ['shutdown']);
  });

  group('close', () {
    for (final phase in ['init', 'syncState']) {
      test('supersedes start while $phase is pending', () async {
        final gate = Completer<void>();
        if (phase == 'init') {
          service.initGate = gate;
        } else {
          service.syncGate = gate;
        }
        final start = lib.start();
        await pumpEventQueue();
        expect(service.calls, contains(phase));
        final close = lib.close();
        gate.complete();

        expect((await start).outcome, CoreLifecycleOutcome.superseded);
        await close;
        expect(service.calls, [
          'init',
          if (phase == 'syncState') 'syncState',
          'shutdown',
        ]);
      });
    }

    test('is terminal and rejects later lifecycle intents', () async {
      await lib.start();

      final result = await lib.close();
      expect(result.outcome, CoreLifecycleOutcome.applied);

      await expectLater(lib.start(), throwsA(isA<StateError>()));
      await expectLater(lib.stop(), throwsA(isA<StateError>()));
    });

    test('runs the shutdown once no matter how often it is called', () async {
      await lib.start();
      service.calls.clear();

      final first = lib.close();
      final second = lib.close();

      expect(identical(first, second), isTrue);
      await first;
      await second;

      expect(service.calls, ['shutdown']);
    });
  });

  group('listeners', () {
    test('a closed bridge rejects listener commands', () async {
      await lib.start();
      await lib.close();
      service.calls.clear();

      expect(await lib.startListener(), isFalse);
      expect(await lib.stopListener(), isFalse);
      expect(service.calls, isEmpty);
    });

    test('a listener start is answered by the service', () async {
      await lib.start();

      expect(await lib.startListener(), isTrue);

      service.startResult = false;
      expect(await lib.startListener(), isFalse);
      expect(service.invokedCalls, isEmpty);
    });

    test('a listener stop is answered by the service', () async {
      await lib.start();

      expect(await lib.stopListener(), isTrue);

      service.stopResult = false;
      expect(await lib.stopListener(), isFalse);
      expect(service.invokedCalls, isEmpty);
    });

    test('a stalled Core RPC cannot reorder native start and stop', () async {
      await lib.start();
      service.calls.clear();
      final response = Completer<CoreMethodResponse?>();
      service.onInvokeMethod = (_) => response.future;

      final start = lib.startListener();
      await pumpEventQueue();
      final stop = lib.stopListener();
      await pumpEventQueue();
      response.complete(const CoreMethodResponse(id: '1', result: true));
      await Future.wait([start, stop]);

      expect(service.calls, ['start', 'stop']);
      expect(service.invokedCalls, isEmpty);
    });

    test('a late stop acknowledgement cannot close a newer listener', () async {
      await lib.start();
      service.calls.clear();
      service.stopGate = Completer<void>();

      final stop = lib.stopListener();
      await pumpEventQueue();
      final start = lib.startListener();
      await pumpEventQueue();
      service.stopGate!.complete();
      await Future.wait([stop, start]);

      expect(service.calls, ['stop', 'start']);
      expect(service.invokedCalls, isEmpty);
    });

    test('a late start acknowledgement performs no work after close', () async {
      await lib.start();
      service.calls.clear();
      service.startGate = Completer<void>();

      final start = lib.startListener();
      await pumpEventQueue();
      await lib.close();
      service.startGate!.complete();
      expect(await start, isTrue);

      expect(service.calls, ['start', 'shutdown']);
      expect(service.invokedCalls, isEmpty);
    });
  });

  group('invokeMethod', () {
    test('close releases pending and future connection waits', () async {
      final replies = <String?>[];
      unawaited(
        lib
            .invokeMethod<String>(method: CoreMethod.getProxies)
            .then(replies.add),
      );
      await lib.close();
      unawaited(
        lib
            .invokeMethod<String>(method: CoreMethod.getProxies)
            .then(replies.add),
      );
      await pumpEventQueue();
      expect(replies, [null, null]);
      expect(service.invokedCalls, isEmpty);
    });

    test('assigns an increasing call id per request', () async {
      await lib.start();
      service.onInvokeMethod = (call) =>
          CoreMethodResponse(id: call.id, result: 'ok');

      await lib.invokeMethod<String>(method: CoreMethod.getProxies);
      await lib.invokeMethod<String>(method: CoreMethod.getProxies);

      expect(service.invokedCalls.map((call) => call.id), ['1', '2']);
    });

    test('unwraps the response payload', () async {
      await lib.start();
      service.onInvokeMethod = (call) =>
          CoreMethodResponse(id: call.id, result: 'payload');

      expect(
        await lib.invokeMethod<String>(method: CoreMethod.getProxies),
        'payload',
      );
    });

    test('resolves to null when the service answers nothing', () async {
      await lib.start();
      service.onInvokeMethod = (_) => null;

      expect(
        await lib.invokeMethod<String>(method: CoreMethod.getProxies),
        isNull,
      );
    });

    testWidgets('gives up instead of hanging when no connection arrives', (
      tester,
    ) async {
      Object? result = 'unset';
      final pending = lib
          .invokeMethod<String>(method: CoreMethod.getProxies)
          .then((value) => result = value);

      await tester.pump(const Duration(seconds: 11));
      await pending;

      expect(result, isNull);
      expect(service.calls, isEmpty);
    });
  });
}
