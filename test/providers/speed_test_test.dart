import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/speed_test.dart';

ProviderContainer _container({
  bool running = true,
  bool suspended = false,
  bool secureNetwork = false,
  int mixedPort = 7890,
}) {
  final container = ProviderContainer(
    overrides: [
      isStartProvider.overrideWithValue(running),
      suspendProvider.overrideWithValue(suspended),
      providerSecureNetworkProvider.overrideWithValue(secureNetwork),
    ],
  );
  container.read(patchClashConfigProvider.notifier).value =
      const PatchClashConfig().copyWith(mixedPort: mixedPort);
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('speedTestViaVpnProvider', () {
    test('is true for a running core on its mixed port', () {
      expect(_container().read(speedTestViaVpnProvider), isTrue);
    });

    test('is false while the core is stopped', () {
      expect(_container(running: false).read(speedTestViaVpnProvider), isFalse);
    });

    test('is false while the tunnel is paused', () {
      expect(
        _container(suspended: true).read(speedTestViaVpnProvider),
        isFalse,
      );
    });

    test('is false without a mixed port', () {
      expect(_container(mixedPort: 0).read(speedTestViaVpnProvider), isFalse);
    });

    test('is false when the provider requires a secure network', () {
      expect(
        _container(secureNetwork: true).read(speedTestViaVpnProvider),
        isFalse,
      );
    });
  });

  group('SpeedTest', () {
    late HttpServer server;
    late Uri url;

    setUp(() async {
      // A widget binding left by another file in the isolate answers every
      // request with 400.
      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previousOverrides);
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      url = Uri.parse('http://127.0.0.1:${server.port}/');
    });

    tearDown(() => server.close(force: true));

    test(
      'a direct run is allowed and tagged as measured without VPN',
      () async {
        unawaited(
          server.first.then((request) async {
            request.response.add(List.filled(64 * 1024, 1));
            await request.response.close();
          }),
        );
        final container = _container(running: false);

        await container.read(speedTestProvider.notifier).start(url: url);

        final state = container.read(speedTestProvider);
        expect(state.phase, SpeedTestPhase.done);
        expect(state.mbps, isNotNull);
        expect(state.viaVpn, isFalse);
      },
    );

    test('a tunnel run is tagged as measured through the VPN', () async {
      unawaited(
        server.first.then((request) async {
          request.response.add(List.filled(64 * 1024, 1));
          await request.response.close();
        }),
      );
      final container = _container();
      container.read(speedTestProvider);

      expect(container.read(speedTestViaVpnProvider), isTrue);
      await container.read(speedTestProvider.notifier).start(url: url);

      expect(container.read(speedTestProvider).viaVpn, isTrue);
    });

    test('a run in progress is cancelled when the route flips', () async {
      final hold = Completer<void>();
      unawaited(
        server.first.then((request) async {
          request.response.add(List.filled(1024, 1));
          await request.response.flush();
          await hold.future;
          await request.response.close();
        }),
      );
      final running = ValueNotifier(true);
      final container = ProviderContainer(
        overrides: [
          isStartProvider.overrideWith((ref) => running.value),
          suspendProvider.overrideWithValue(false),
          providerSecureNetworkProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(() => hold.isCompleted ? null : hold.complete());
      container.read(patchClashConfigProvider.notifier).value =
          const PatchClashConfig().copyWith(mixedPort: 7890);
      final notifier = container.read(speedTestProvider.notifier);

      final run = notifier.start(url: url);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(container.read(speedTestProvider).running, isTrue);

      running.value = false;
      container.invalidate(isStartProvider);
      await container.pump();

      expect(container.read(speedTestProvider).running, isFalse);
      hold.complete();
      await run;
      expect(container.read(speedTestProvider).phase, SpeedTestPhase.idle);
    });

    test('cancel while idle leaves the state untouched', () {
      final container = _container();
      final before = container.read(speedTestProvider);

      container.read(speedTestProvider.notifier).cancel();

      expect(container.read(speedTestProvider), same(before));
    });
  });
}
