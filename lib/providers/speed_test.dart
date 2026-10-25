import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/http.dart';

/// One run's cap: a steady rate on a fast link, cheap on a mobile plan.
const speedTestBytes = 25 * 1024 * 1024;

/// A slow link stops here and is rated by what arrived.
const speedTestLimit = Duration(seconds: 12);

final speedTestUrl = Uri.parse(
  'https://speed.cloudflare.com/__down?bytes=$speedTestBytes',
);

final speedTestViaVpnProvider = Provider<bool>(
  (ref) =>
      ReClashHttpOverrides.findProxyForReader(ref.watch, speedTestUrl) !=
      'DIRECT',
);

enum SpeedTestPhase { idle, running, done, failed }

@immutable
class SpeedTestState {
  const SpeedTestState({
    this.phase = SpeedTestPhase.idle,
    this.mbps,
    this.progress = 0,
    this.checkedAt,
    this.viaVpn = true,
  });

  final SpeedTestPhase phase;

  /// The live rate while running, else the last finished one.
  final double? mbps;
  final double progress;
  final DateTime? checkedAt;

  final bool viaVpn;

  bool get running => phase == SpeedTestPhase.running;
}

/// Downloads through the app's HTTP client: through the core's mixed port when
/// the tunnel is on, else straight, and the result remembers which. Only ever
/// started by hand.
class SpeedTest extends Notifier<SpeedTestState> {
  HttpClient? _client;
  int _run = 0;

  SpeedTestState _settled = const SpeedTestState();

  @override
  SpeedTestState build() {
    ref
      ..listen(speedTestViaVpnProvider, (_, _) => cancel())
      ..onDispose(() => _client?.close(force: true));
    return const SpeedTestState();
  }

  Future<void> start({@visibleForTesting Uri? url}) async {
    final target = url ?? speedTestUrl;
    if (state.running) return;
    final viaVpn = ref.read(speedTestViaVpnProvider);
    final run = ++_run;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    _client = client;
    state = SpeedTestState(phase: SpeedTestPhase.running, viaVpn: viaVpn);
    final watch = Stopwatch();
    var received = 0;
    var shown = 0;
    try {
      final request = await client.getUrl(target);
      final response = await request.close().timeout(speedTestLimit);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('status ${response.statusCode}', uri: target);
      }
      await for (final chunk in response.timeout(speedTestLimit)) {
        if (run != _run) return;
        watch.start();
        received += chunk.length;
        final elapsed = watch.elapsedMilliseconds;
        if (elapsed >= speedTestLimit.inMilliseconds) break;
        if (elapsed - shown >= 120) {
          shown = elapsed;
          state = SpeedTestState(
            phase: SpeedTestPhase.running,
            mbps: _mbps(received, watch.elapsed),
            progress: _progress(received, watch.elapsed),
            viaVpn: viaVpn,
          );
        }
      }
      if (run != _run) return;
      if (received == 0) throw const HttpException('empty body');
      state = _settled = SpeedTestState(
        phase: SpeedTestPhase.done,
        mbps: _mbps(received, watch.elapsed),
        progress: 1,
        checkedAt: DateTime.now(),
        viaVpn: viaVpn,
      );
    } on Object {
      if (run == _run) {
        state = SpeedTestState(
          phase: SpeedTestPhase.failed,
          mbps: _settled.mbps,
          checkedAt: _settled.checkedAt,
          viaVpn: _settled.viaVpn,
        );
      }
    } finally {
      client.close(force: true);
      if (identical(_client, client)) _client = null;
    }
  }

  void cancel() {
    if (!state.running) return;
    _run++;
    _client?.close(force: true);
    state = _settled;
  }

  static double _mbps(int bytes, Duration elapsed) =>
      elapsed.inMicroseconds == 0 ? 0 : bytes * 8 / elapsed.inMicroseconds;

  static double _progress(int bytes, Duration elapsed) {
    final byBytes = bytes / speedTestBytes;
    final byTime = elapsed.inMicroseconds / speedTestLimit.inMicroseconds;
    return byBytes > byTime ? byBytes : byTime;
  }
}

final speedTestProvider = NotifierProvider<SpeedTest, SpeedTestState>(
  SpeedTest.new,
);
