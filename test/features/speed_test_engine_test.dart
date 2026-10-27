import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/speed_test/cloudflare.dart';
import 'package:reclash/features/speed_test/engine.dart';
import 'package:reclash/features/speed_test/types.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/speed_test.dart';

import 'speed_test_fakes.dart';

const _plan = SpeedTestPlan(
  latencyCount: 4,
  probeInterval: Duration(milliseconds: 1),
  directionDuration: Duration(milliseconds: 300),
  minimumDuration: Duration(milliseconds: 250),
  runTimeout: Duration(seconds: 3),
);

void main() {
  group('LatencySummary', () {
    test('computes median and consecutive-sample jitter', () {
      final summary = LatencySummary.of([10, 20, 30, 100])!;
      expect(summary.medianMs, 25);
      expect(summary.jitterMs, 30);
      expect(summary.count, 4);
    });

    test('missing samples and missing jitter remain unavailable', () {
      expect(LatencySummary.of([]), isNull);
      expect(LatencySummary.of([12])!.jitterMs, isNull);
    });
  });

  group('SpeedTestThroughput', () {
    const bin = 250000;

    test('leaves out a slow start and short bursts', () {
      final meter = SpeedTestThroughput(bin);
      final rates = [1, 1, 1, 10, 10, 10, 10, 10, 10, 50];
      for (final (index, mbps) in rates.indexed) {
        meter.add(index * bin, mbps * bin ~/ 8);
      }
      expect(meter.result(10 * bin), 10);
      expect(meter.recent(10 * bin), 20);
    });

    test('credits an acknowledged request over its whole duration', () {
      final meter = SpeedTestThroughput(bin)..spread(0, 4 * bin, 1000000);
      expect(meter.recent(bin), 8);
      expect(meter.result(4 * bin), 8);
    });

    test('short transfers fall back to the overall average', () {
      final meter = SpeedTestThroughput(bin)..add(100, 125000);
      expect(meter.result(2 * bin), 2);
      expect(SpeedTestThroughput(bin).result(2 * bin), isNull);
    });
  });

  group('SpeedTestSettings', () {
    test(
      'survives app settings persistence with an independent backend id',
      () {
        const settings = SpeedTestSettings(
          backendId: 'another-service',
          mode: SpeedTestMode.latencyOnly,
          budgetMiB: 250,
          alwaysConfirm: true,
        );
        const app = AppSettingProps(speedTest: settings);
        expect(
          AppSettingProps.fromJson(
            jsonDecode(jsonEncode(app)) as Map<String, dynamic>,
          ).speedTest,
          settings,
        );
      },
    );

    test('salvages invalid settings without an unsafe data budget', () {
      final value = SpeedTestSettings.safeFromJson({
        'budgetMiB': -1,
        'mode': 'future',
        'alwaysConfirm': true,
      });
      expect(value.budgetMiB, 100);
      expect(value.mode, SpeedTestMode.complete);
      expect(value.alwaysConfirm, isTrue);
      expect(
        SpeedTestSettings.safeFromJson('invalid'),
        const SpeedTestSettings(),
      );
      expect(
        AppSettingProps.safeFromJson({
          'speedTest': 'invalid',
          'hideIp': true,
        }).hideIp,
        isTrue,
      );
    });
  });

  group('SpeedTestEngine', () {
    test('does not start any measurement in its constructor', () {
      final session = FakeSpeedSession();
      SpeedTestEngine(
        session: session,
        settings: const SpeedTestSettings(),
        onUpdate: (_) {},
        viaVpn: false,
      );
      expect(session.probes + session.downloads + session.uploads, 0);
    });

    test('shares the payload cap across warmup, download and upload', () async {
      final session = FakeSpeedSession();
      final states = <SpeedTestState>[];
      const settings = SpeedTestSettings(budgetMiB: 25);
      final engine = SpeedTestEngine(
        session: session,
        settings: settings,
        onUpdate: states.add,
        viaVpn: true,
        plan: _plan,
      );
      await engine.run();
      final result = states.last;
      expect(result.phase, SpeedTestPhase.done);
      expect(result.downloadMbps, greaterThan(0));
      expect(result.uploadMbps, greaterThan(0));
      expect(result.latency?.count, 4);
      expect(session.lanes, {0, 1, 2, 3});
      expect(result.transferredBytes, session.bytes);
      expect(result.transferredBytes, settings.byteLimit);
      expect(
        states.every((value) => value.transferredBytes <= settings.byteLimit),
        isTrue,
      );
      expect(
        states.every((value) => value.progress >= 0 && value.progress <= 1),
        isTrue,
      );
      expect(result.limited, isTrue);
      expect(session.closed, isTrue);
    });

    test('latency-only mode never starts bulk transfers', () async {
      final session = FakeSpeedSession();
      final states = <SpeedTestState>[];
      final engine = SpeedTestEngine(
        session: session,
        settings: const SpeedTestSettings(mode: SpeedTestMode.latencyOnly),
        onUpdate: states.add,
        viaVpn: false,
        plan: _plan,
      );
      await engine.run();
      expect(session.probes, 6);
      expect(session.downloads, 0);
      expect(session.uploads, 0);
      expect(states.last.downloadMbps, isNull);
      expect(states.last.uploadMbps, isNull);
      expect(states.last.latency, isNotNull);
      expect(states.last.byteLimit, 0);
    });

    test(
      'a failed upload retains successful results without a fake zero',
      () async {
        final session = FakeSpeedSession(failUpload: true);
        final states = <SpeedTestState>[];
        final engine = SpeedTestEngine(
          session: session,
          settings: const SpeedTestSettings(budgetMiB: 25),
          onUpdate: states.add,
          viaVpn: false,
          plan: _plan,
        );
        await engine.run();
        expect(states.last.phase, SpeedTestPhase.done);
        expect(states.last.downloadMbps, greaterThan(0));
        expect(states.last.uploadMbps, isNull);
        expect(states.last.errors, contains(SpeedTestStage.upload));
        expect(states.last.latency, isNotNull);
      },
    );

    test(
      'cancellation closes a stalled session and ignores late completion',
      () async {
        final session = FakeSpeedSession(holdDownload: true);
        final states = <SpeedTestState>[];
        final engine = SpeedTestEngine(
          session: session,
          settings: const SpeedTestSettings(),
          onUpdate: states.add,
          viaVpn: false,
          plan: _plan,
        );
        final running = engine.run();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        engine.cancel();
        await running;
        expect(session.closed, isTrue);
        expect(states.last.phase, SpeedTestPhase.cancelled);
        final count = states.length;
        session.held.complete();
        await Future<void>.delayed(Duration.zero);
        expect(states.length, count);
      },
    );

    test('the absolute deadline ends a probe that never yields', () async {
      final session = FakeSpeedSession(holdLatency: true);
      final states = <SpeedTestState>[];
      final engine = SpeedTestEngine(
        session: session,
        settings: const SpeedTestSettings(mode: SpeedTestMode.latencyOnly),
        onUpdate: states.add,
        viaVpn: false,
        plan: const SpeedTestPlan(runTimeout: Duration(milliseconds: 30)),
      );
      await engine.run();
      expect(states.last.phase, SpeedTestPhase.failed);
      expect(states.last.failure, 'timeout');
      expect(session.closed, isTrue);
      session.held.complete();
    });
  });

  group('Cloudflare adapter with a local server', () {
    late HttpServer server;
    late CloudflareSpeedTestBackend backend;
    HttpOverrides? overrides;

    setUp(() async {
      overrides = HttpOverrides.current;
      HttpOverrides.global = null;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      backend = CloudflareSpeedTestBackend(
        baseUri: Uri.parse('http://127.0.0.1:${server.port}'),
        timeout: const Duration(milliseconds: 300),
      );
    });

    tearDown(() async {
      await server.close(force: true);
      HttpOverrides.global = overrides;
    });

    test(
      'downloads the requested payload and waits for upload acknowledgement',
      () async {
        var uploaded = 0;
        final paths = <String>[];
        server.listen((request) async {
          paths.add(request.uri.path);
          expect(
            request.headers.value(HttpHeaders.acceptEncodingHeader),
            'identity',
          );
          if (request.method == 'POST') {
            await for (final chunk in request) {
              uploaded += chunk.length;
            }
            request.response.contentLength = 0;
          } else {
            final bytes = int.parse(request.uri.queryParameters['bytes']!);
            request.response.headers.contentType = ContentType.binary;
            request.response.add(List.filled(bytes, 1));
          }
          await request.response.close();
        });
        final session = backend.open(HttpClient.new);
        addTearDown(session.close);
        expect(await session.latency(), greaterThanOrEqualTo(0));
        var downloaded = 0;
        await session.download(4096, (value) => downloaded += value);
        var sent = 0;
        await session.upload(8192, (value) => sent += value);
        expect(downloaded, 4096);
        expect(sent, 8192);
        expect(uploaded, 8192);
        expect(paths, ['/__down', '/__down', '/__up']);
      },
    );

    test('subtracts the edge processing time from latency', () async {
      server.listen((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        request.response.headers.set(
          'server-timing',
          'cfRequestDuration;dur=110.5',
        );
        await request.response.close();
      });
      final session = backend.open(HttpClient.new);
      addTearDown(session.close);
      expect(await session.latency(), lessThan(100));
    });

    test('does not follow redirects to a different endpoint', () async {
      var requests = 0;
      server.listen((request) async {
        requests++;
        request.response.statusCode = HttpStatus.found;
        request.response.headers.set(HttpHeaders.locationHeader, '/elsewhere');
        await request.response.close();
      });
      final session = backend.open(HttpClient.new);
      addTearDown(session.close);
      await expectLater(
        session.download(1024, (_) {}),
        throwsA(isA<HttpException>()),
      );
      expect(requests, 1);
    });

    test(
      'rejects a truncated response instead of reporting its speed',
      () async {
        server.listen((request) async {
          request.response.add([1, 2, 3]);
          await request.response.close();
        });
        final session = backend.open(HttpClient.new);
        addTearDown(session.close);
        await expectLater(
          session.download(1024, (_) {}),
          throwsA(isA<HttpException>()),
        );
      },
    );

    test(
      'times out while waiting for headers, not only between body chunks',
      () async {
        server.listen((request) {});
        final session = backend.open(HttpClient.new);
        addTearDown(session.close);
        await expectLater(session.latency(), throwsA(isA<TimeoutException>()));
      },
    );
  });
}
