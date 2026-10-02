import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/util/constant.dart';
import 'package:reclash/plugins/companion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const receiverChannel = MethodChannel('$packageName/companion_receiver');
  const clientChannel = MethodChannel('$packageName/companion_client');
  final receiver = CompanionReceiver.instance;
  final client = CompanionClient.instance;
  late List<MethodCall> calls;

  void stub(MethodChannel channel, Object? Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return handler(call);
        });
  }

  setUp(() {
    calls = [];
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(receiverChannel, null);
    messenger.setMockMethodCallHandler(clientChannel, null);
  });

  group('receiver', () {
    test('decodes the endpoint returned by enable', () async {
      stub(
        receiverChannel,
        (_) => {'deviceId': 'device-a', 'host': '192.0.2.10', 'port': 8443},
      );

      final endpoint = await receiver.enable();

      expect(endpoint.deviceId, 'device-a');
      expect(endpoint.host, '192.0.2.10');
      expect(endpoint.port, 8443);
      expect(calls.single.method, 'enable');
    });

    test(
      'decodes the pending phone and forwards approval and revocation',
      () async {
        stub(
          receiverChannel,
          (call) => switch (call.method) {
            'pendingPairing' => {
              'clientId': 'phone-a',
              'clientName': 'Test phone',
              'confirmationCode': '123456',
            },
            'approvePending' || 'revokeClient' => true,
            _ => null,
          },
        );

        final phone = await receiver.pendingPairing();
        expect(phone?.clientId, 'phone-a');
        expect(phone?.clientName, 'Test phone');
        expect(phone?.confirmationCode, '123456');
        expect(await receiver.approvePending(), isTrue);
        expect(await receiver.revokeClient('phone-a'), isTrue);
        expect(calls.map((call) => call.method), [
          'pendingPairing',
          'approvePending',
          'revokeClient',
        ]);
        expect(calls.last.arguments, {'clientId': 'phone-a'});
      },
    );

    test(
      'missing native replies never imply a running or trusted receiver',
      () async {
        stub(receiverChannel, (_) => null);

        expect(await receiver.isRunning(), isFalse);
        expect(await receiver.openPairingWindow(), isNull);
        expect(await receiver.pendingPairing(), isNull);
        expect(await receiver.approvePending(), isFalse);
        expect(await receiver.revokeClient('phone-a'), isFalse);
        expect(await receiver.trustedClients(), isEmpty);
      },
    );

    test(
      'forwards receiver cleanup commands to the receiver channel',
      () async {
        stub(receiverChannel, (_) => null);

        await receiver.disable();
        await receiver.cancelPairingWindow();
        await receiver.rejectPending();
        await receiver.resetIdentity();

        expect(calls.map((call) => call.method), [
          'disable',
          'cancelPairingWindow',
          'rejectPending',
          'resetIdentity',
        ]);
        expect(calls.every((call) => call.arguments == null), isTrue);
      },
    );
  });

  group('client', () {
    test(
      'passes pairing input unchanged and decodes the confirmation',
      () async {
        stub(
          clientChannel,
          (_) => {
            'ok': true,
            'deviceId': 'device-a',
            'pairingId': 'pairing-a',
            'confirmationCode': '123456',
          },
        );

        final outcome = await client.pair(
          'test-offer',
          clientName: 'Test phone',
        );

        expect(outcome.ok, isTrue);
        expect(outcome.deviceId, 'device-a');
        expect(outcome.pairingId, 'pairing-a');
        expect(outcome.confirmationCode, '123456');
        expect(outcome.code, isNull);
        expect(calls.single.method, 'pair');
        expect(calls.single.arguments, {
          'raw': 'test-offer',
          'clientName': 'Test phone',
        });
      },
    );

    test(
      'keeps rejection codes and treats missing pairing replies as unknown',
      () async {
        stub(clientChannel, (_) => {'ok': false, 'code': 'pairingClosed'});
        final rejected = await client.pair('test-offer');
        expect(rejected.ok, isFalse);
        expect(rejected.code, 'pairingClosed');
        expect(rejected.deviceId, isNull);

        stub(clientChannel, (_) => null);
        final missing = await client.pair('test-offer');
        expect(missing.ok, isFalse);
        expect(missing.code, 'outcomeUnknown');
        expect(calls.last.arguments, {'raw': 'test-offer', 'clientName': null});
      },
    );

    test(
      'polling distinguishes a pending phase from transport failures',
      () async {
        for (final (reply, expected) in <(Map<String, Object?>?, String)>[
          ({'ok': true, 'phase': 'approved'}, 'approved'),
          ({'ok': true}, 'pending'),
          ({'ok': false, 'code': 'unreachable'}, 'unreachable'),
          ({'ok': false}, 'outcomeUnknown'),
          (null, 'outcomeUnknown'),
        ]) {
          stub(clientChannel, (_) => reply);
          expect(await client.pollPairing('device-a'), expected);
          expect(calls.last.method, 'pollPairing');
          expect(calls.last.arguments, {'deviceId': 'device-a'});
        }
      },
    );

    test(
      'rename reports false for a missing reply or platform failure',
      () async {
        stub(clientChannel, (_) => null);
        expect(await client.rename('device-a', 'Living room'), isFalse);
        stub(
          clientChannel,
          (_) => throw PlatformException(code: 'unavailable'),
        );
        expect(await client.rename('device-a', 'Living room'), isFalse);
        expect(calls.map((call) => call.method), ['rename', 'rename']);
        for (final call in calls) {
          expect(call.arguments, {
            'deviceId': 'device-a',
            'name': 'Living room',
          });
        }
      },
    );
  });
}
