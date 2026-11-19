import 'dart:async';

import 'package:reclash/common/proxy.dart';
import 'package:reclash/models/models.dart' show ProxyState;
import 'package:flutter_test/flutter_test.dart';
import 'package:proxy/proxy.dart';

class _FakeProxy implements Proxy {
  final List<String> calls = [];
  Future<bool>? held;
  Error? failure;

  Future<bool> _call(String name) async {
    calls.add(name);
    final error = failure;
    failure = null;
    if (error != null) {
      throw error;
    }
    final result = held ?? Future.value(true);
    held = null;
    return result;
  }

  @override
  Future<bool> startProxy(int port, [List<String> bypassDomain = const []]) {
    return _call('start $port');
  }

  @override
  Future<bool> stopProxy() => _call('stop');
}

ProxyState _state({required bool isStart}) {
  return ProxyState(
    isStart: isStart,
    systemProxy: true,
    bassDomain: const [],
    port: 7890,
  );
}

class _FakeOwnProxyRecord implements OwnProxyRecord {
  _FakeOwnProxyRecord([this.port]);

  int? port;

  @override
  Future<int?> read() async => port;

  @override
  Future<void> write(int? value) async {
    port = value;
  }
}

void main() {
  test('applies changes in the order they come', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    unawaited(queue.apply(_state(isStart: true)));
    await queue.apply(_state(isStart: false));

    expect(proxy.calls, ['start 7890', 'stop']);
  });

  test('close stops last and drops the starts queued before it', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);
    final inFlight = Completer<bool>();
    proxy.held = inFlight.future;

    unawaited(queue.apply(_state(isStart: true)));
    await pumpEventQueue();
    unawaited(queue.apply(_state(isStart: true)));
    final closed = queue.close();
    await pumpEventQueue();
    expect(proxy.calls, ['start 7890']);

    inFlight.complete(true);
    await closed;
    await queue.apply(_state(isStart: true));

    expect(proxy.calls, ['start 7890', 'stop']);
  });

  test('apply reports whether the proxy was started', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    proxy.held = Future.value(false);
    expect(await queue.apply(_state(isStart: true)), isFalse);
    expect(await queue.apply(_state(isStart: true)), isTrue);
  });

  test('a failing call does not stall the queue', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);
    proxy.failure = StateError('channel gone');

    await queue.apply(_state(isStart: true));
    await queue.apply(_state(isStart: false));

    expect(proxy.calls, ['start 7890', 'stop']);
  });

  test('leaves a proxy it never set alone', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    await queue.apply(_state(isStart: false));
    await queue.close();

    expect(proxy.calls, isEmpty);
  });

  test('tries a failed stop again on close', () async {
    final proxy = _FakeProxy();
    final queue = SystemProxyQueue(proxy);

    await queue.apply(_state(isStart: true));
    proxy.held = Future.value(false);
    await queue.apply(_state(isStart: false));
    await queue.close();
    await queue.close();

    expect(proxy.calls, ['start 7890', 'stop', 'stop']);
  });

  group('releaseStale', () {
    test('stops a proxy still pointing at the recorded port', () async {
      final proxy = _FakeProxy();
      final record = _FakeOwnProxyRecord(7890);
      final queue = SystemProxyQueue(proxy, record: record);
      final ports = <int?>[];
      final sub = queue.ownPorts.listen(ports.add);
      addTearDown(sub.cancel);

      expect(await queue.releaseStale((_) async => true), isTrue);
      await pumpEventQueue();

      expect(proxy.calls, ['stop']);
      expect(record.port, isNull);
      expect(ports, [null]);
    });

    test('forgets a recorded port the system no longer points at', () async {
      final proxy = _FakeProxy();
      final record = _FakeOwnProxyRecord(7890);
      final queue = SystemProxyQueue(proxy, record: record);

      expect(await queue.releaseStale((_) async => false), isFalse);

      expect(proxy.calls, isEmpty);
      expect(record.port, isNull);
    });

    test('keeps the record when the OS gives no answer', () async {
      final proxy = _FakeProxy();
      final record = _FakeOwnProxyRecord(7890);
      final queue = SystemProxyQueue(proxy, record: record);

      expect(await queue.releaseStale((_) async => null), isFalse);

      expect(proxy.calls, isEmpty);
      expect(record.port, 7890);
    });

    test('does not ask the OS when nothing was recorded', () async {
      final proxy = _FakeProxy();
      final queue = SystemProxyQueue(proxy, record: _FakeOwnProxyRecord());
      var asked = false;

      expect(
        await queue.releaseStale((_) async {
          asked = true;
          return true;
        }),
        isFalse,
      );

      expect(asked, isFalse);
      expect(proxy.calls, isEmpty);
    });

    test('leaves a proxy this queue applied to its own stop', () async {
      final proxy = _FakeProxy();
      final queue = SystemProxyQueue(proxy, record: _FakeOwnProxyRecord());
      await queue.apply(_state(isStart: true));
      var asked = false;

      expect(
        await queue.releaseStale((_) async {
          asked = true;
          return true;
        }),
        isFalse,
      );

      expect(asked, isFalse);
      expect(proxy.calls, ['start 7890']);
    });

    test('asks the OS about the recorded port', () async {
      final proxy = _FakeProxy();
      final queue = SystemProxyQueue(proxy, record: _FakeOwnProxyRecord(7890));
      final asked = <int>[];

      await queue.releaseStale((port) async {
        asked.add(port);
        return false;
      });

      expect(asked, [7890]);
    });
  });
}
