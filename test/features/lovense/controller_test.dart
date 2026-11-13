import 'dart:async';

import 'package:reclash/common/preferences.dart';
import 'package:reclash/features/lovense/controller.dart';
import 'package:reclash/features/lovense/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  late FakeLovenseApi api;
  late FakeLovenseStore store;
  late LovenseController controller;
  setUp(() {
    api = FakeLovenseApi();
    store = FakeLovenseStore();
    controller = LovenseController(clientFactory: (_) => api, store: store);
  });
  tearDown(() async {
    controller.dispose();
    await controller.shutdown;
  });

  Future<void> connect() => controller.connect('localhost');
  Future<void> run({String id = 'toy1', int duration = 10}) => controller.run(
    toyId: id,
    function: LovenseFunction.vibrate,
    strength: 1,
    duration: duration,
  );

  test('restoring the address never connects or moves toys', () async {
    store.address = 'http://192.168.1.10:20010';
    expect(
      await controller.restoreAddress(),
      'http://192-168-1-10.lovense.club:20010',
    );
    expect(api.commands, isEmpty);
    expect(controller.connected, isFalse);
    store.address = 'https://example.com';
    expect(await controller.restoreAddress(), lovenseDefaultAddress);
  });

  test('Connect reads toys and saves only the normalized endpoint', () async {
    await connect();
    expect(controller.connected, isTrue);
    expect(controller.toys, hasLength(2));
    expect(api.commands, [
      {'command': 'GetToys'},
    ]);
    expect(store.saved, [lovenseDefaultAddress]);
    expect(controller.canStart, isTrue);
  });

  test('invalid address never creates a remote request', () async {
    await controller.connect('https://example.com');
    expect(controller.error!.kind, LovenseErrorKind.invalidAddress);
    expect(api.commands, isEmpty);
    expect(controller.busy, isFalse);
  });

  test(
    'permission is requested only for explicit Connect and denial blocks I/O',
    () async {
      var permissions = 0;
      controller.dispose();
      controller = LovenseController(
        clientFactory: (_) => api,
        store: store,
        requestPermission: () async {
          permissions++;
          return false;
        },
      );
      await controller.restoreAddress();
      expect(permissions, 0);
      await connect();
      expect(permissions, 1);
      expect(api.commands, isEmpty);
      expect(controller.error!.kind, LovenseErrorKind.unavailable);
    },
  );

  test('failed persistence does not discard a working connection', () async {
    store.saveResult = false;
    await connect();
    expect(controller.connected, isTrue);
    expect(controller.saveFailed, isTrue);
  });

  test('refresh is read-only and reports disconnections', () async {
    await connect();
    api.toys = [fakeLovenseToy(connected: false)];
    await controller.refresh();
    expect(api.commands.map((command) => command['command']), [
      'GetToys',
      'GetToys',
    ]);
    expect(controller.toys.single.connected, isFalse);
  });

  test('offline, unknown and indefinite commands cannot actuate', () async {
    api.toys = [fakeLovenseToy(connected: false), fakeLovenseToy(id: 'toy2')];
    await connect();
    await run();
    await run(id: 'missing');
    await run(id: 'toy2', duration: 0);
    await controller.run(
      toyId: 'toy2',
      function: LovenseFunction.rotate,
      strength: 1,
      duration: 10,
    );
    expect(api.commands, [
      {'command': 'GetToys'},
    ]);
    expect(controller.error!.kind, LovenseErrorKind.invalidCommand);
  });

  test('a user command is finite and disconnect stops only that toy', () async {
    await connect();
    await run();
    expect(api.commands[1]['timeSec'], 10);
    expect(controller.notice, LovenseNotice.commandSent);
    await controller.disconnect();
    expect(api.commands.last, {
      'command': 'Function',
      'action': 'Stop',
      'toy': 'toy1',
    });
    expect(api.commands.where((c) => c['toy'] == 'toy2'), isEmpty);
    expect(api.closed, isTrue);
    expect(controller.connected, isFalse);
  });

  test(
    'Stop all remains available during a command and wins over its late reply',
    () async {
      await connect();
      final pending = Completer<void>();
      api.pendingFunction = pending.future;
      final running = run();
      expect(controller.busy, isTrue);
      await controller.stopAll();
      expect(api.commands.last, {'command': 'Function', 'action': 'Stop'});
      expect(controller.notice, LovenseNotice.stopSent);
      pending.complete();
      await running;
      expect(controller.notice, LovenseNotice.stopSent);
      expect(controller.busy, isFalse);
    },
  );

  test('failed Stop is never represented as a successful stop', () async {
    await connect();
    await run();
    api.stopError = LovenseError(LovenseErrorKind.timeout);
    await controller.stopAll();
    expect(controller.stopFailed, isTrue);
    expect(controller.notice, isNull);
    expect(controller.error!.kind, LovenseErrorKind.timeout);
    api.stopError = null;
    await controller.stopAll();
    expect(controller.stopFailed, isFalse);
    expect(controller.notice, LovenseNotice.stopSent);
  });

  test(
    'pause stops started toys once and resume never restarts them',
    () async {
      await connect();
      await run();
      await controller.pause();
      await controller.pause();
      expect(controller.canStart, isFalse);
      expect(api.commands.where((c) => c['action'] == 'Stop'), hasLength(1));
      controller.resume();
      expect(controller.canStart, isTrue);
      expect(
        api.commands.where((c) => c['action'] == 'Vibrate:1'),
        hasLength(1),
      );
    },
  );

  test('closing a read-only session never sends an unsolicited Stop', () async {
    await connect();
    controller.dispose();
    await controller.shutdown;
    expect(api.commands, [
      {'command': 'GetToys'},
    ]);
    expect(api.closed, isTrue);
  });

  test(
    'dispose stops activated toys and never notifies after disposal',
    () async {
      await connect();
      await run();
      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.dispose();
      await controller.shutdown;
      expect(notifications, 0);
      expect(api.commands.last['action'], 'Stop');
      expect(api.commands.last['toy'], 'toy1');
      expect(api.closed, isTrue);
    },
  );

  test(
    'a late Connect reply is discarded and the transport is closed',
    () async {
      final pending = Completer<List<LovenseToy>>();
      api.pendingToys = pending.future;
      final connecting = connect();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();
      pending.complete(api.toys);
      await connecting;
      expect(api.closed, isTrue);
      expect(controller.connected, isFalse);
      expect(store.saved, isEmpty);
    },
  );

  test(
    'a timed-out start is still stopped because it may have reached the toy',
    () async {
      await connect();
      api.functionError = LovenseError(LovenseErrorKind.timeout);
      await run();
      await controller.disconnect();
      expect(api.commands.last['action'], 'Stop');
      expect(api.commands.last['toy'], 'toy1');
    },
  );

  test('SharedPreferences stores no toy IDs or control state', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await preferences.rebind();
    final store = LovensePreferences();
    expect(await store.load(), isNull);
    expect(await store.save(lovenseDefaultAddress), isTrue);
    expect(await store.load(), lovenseDefaultAddress);
    expect((await SharedPreferences.getInstance()).getKeys(), {
      lovenseEndpointKey,
    });
  });
}
