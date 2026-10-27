import 'dart:async';
import 'dart:math' as math;

import 'package:reclash/models/speed_test.dart';

import 'backend.dart';
import 'types.dart';

class SpeedTestPlan {
  const SpeedTestPlan({
    this.latencyCount = 20,
    this.probeInterval = const Duration(milliseconds: 200),
    this.directionDuration = const Duration(seconds: 8),
    this.minimumDuration = const Duration(seconds: 2),
    this.runTimeout = const Duration(seconds: 70),
    this.sampleInterval = const Duration(milliseconds: 250),
  });

  final int latencyCount;
  final Duration probeInterval;
  final Duration directionDuration;
  final Duration minimumDuration;
  final Duration runTimeout;
  final Duration sampleInterval;
}

class SpeedTestEngine {
  SpeedTestEngine({
    required this.session,
    required this.settings,
    required this.onUpdate,
    required this.viaVpn,
    this.plan = const SpeedTestPlan(),
    this.streams = 4,
  });

  final SpeedTestSession session;
  final SpeedTestSettings settings;
  final void Function(SpeedTestState state) onUpdate;
  final bool viaVpn;
  final SpeedTestPlan plan;

  /// Parallel connections per direction; one TCP stream rarely fills a link
  /// with a long round trip, which every proxied route has.
  final int streams;
  static const _laneAttempts = 3;

  /// Upload bytes count only when a request completes, so uploads stay short.
  static const _uploadRequest = 500000;
  static const _downloadRequest = 2000000;
  final _watch = Stopwatch();
  final _stop = Completer<void>();
  final _errors = <SpeedTestStage>{};
  final _idle = <double>[];
  SpeedTestPhase _phase = SpeedTestPhase.idle;
  SpeedTestStage _stage = SpeedTestStage.warmup;
  double? _down;
  double? _up;
  double? _live;
  double _fraction = 0;
  int _spent = 0;
  bool _limited = false;
  String? _failure;

  Future<void> run() async {
    if (_phase != SpeedTestPhase.idle) return;
    _phase = SpeedTestPhase.running;
    _watch.start();
    _emit();
    final deadline = Timer(plan.runTimeout, () => cancel(failure: 'timeout'));
    try {
      await _warmup();
      _stage = SpeedTestStage.latency;
      _emit();
      for (var i = 0; i < plan.latencyCount; i++) {
        await _probe();
        _fraction = (i + 1) / plan.latencyCount;
        _emit();
        if (i + 1 < plan.latencyCount) await _wait(plan.probeInterval);
      }
      if (_idle.length < 2) _errors.add(SpeedTestStage.latency);
      if (settings.mode == SpeedTestMode.complete) {
        await _transfer(
          SpeedTestStage.download,
          (settings.byteLimit - _spent) ~/ 2,
        );
        await _wait(plan.probeInterval);
        await _transfer(SpeedTestStage.upload, settings.byteLimit - _spent);
      }
      _ensureActive();
      _phase = _down == null && _up == null && _idle.isEmpty
          ? SpeedTestPhase.failed
          : SpeedTestPhase.done;
      if (_phase == SpeedTestPhase.failed) _failure = 'unavailable';
    } on _Stopped {
      return;
    } on Object {
      _phase = SpeedTestPhase.failed;
      _failure = 'unavailable';
    } finally {
      deadline.cancel();
      session.close();
      _watch.stop();
      _emit();
    }
  }

  Future<void> _warmup() async {
    for (var i = 0; i < 2; i++) {
      await _probe(record: false);
    }
    if (settings.mode == SpeedTestMode.latencyOnly) return;
    for (final upload in [false, true]) {
      _ensureActive();
      try {
        final bytes = math.min(64 * 1024, settings.byteLimit - _spent);
        if (bytes <= 0) return;
        await _untilStopped(
          upload
              ? session.upload(bytes, _consume)
              : session.download(bytes, _consume),
        );
      } on _Stopped {
        rethrow;
      } on Object {
        _ensureActive();
      }
    }
  }

  Future<void> _probe({bool record = true}) async {
    _ensureActive();
    try {
      final value = await _untilStopped(session.latency());
      _ensureActive();
      if (record && value.isFinite && value >= 0) _idle.add(value);
    } on _Stopped {
      rethrow;
    } on Object {
      _ensureActive();
    }
  }

  Future<void> _transfer(SpeedTestStage stage, int budget) async {
    _ensureActive();
    _stage = stage;
    _fraction = 0;
    _live = null;
    _emit();
    if (budget <= 0) {
      _limited = true;
      _errors.add(stage);
      return;
    }
    final upload = stage == SpeedTestStage.upload;
    final bin = plan.sampleInterval.inMicroseconds;
    // Upload bytes count once the server acknowledges them: flushed bytes
    // only reach local socket buffers, which hold megabytes behind a proxy.
    final measured = SpeedTestThroughput(bin);
    final shown = upload ? SpeedTestThroughput(bin) : measured;
    final clock = Stopwatch()..start();
    final deadline = Completer<void>();
    final timer = Timer(plan.directionDuration, () {
      deadline.complete();
      session.abortTransfer();
    });
    var reserved = 0;
    var failed = false;
    final ticker = Timer.periodic(plan.sampleInterval, (_) {
      if (_stop.isCompleted) return;
      _live = shown.recent(clock.elapsedMicroseconds);
      _fraction = math
          .max(
            reserved / budget,
            clock.elapsedMicroseconds / plan.directionDuration.inMicroseconds,
          )
          .clamp(0, 1);
      _emit();
    });

    Future<void> lane(int index) async {
      var block = math.min(
        upload ? 64 * 1024 : 1024 * 1024,
        math.max(budget ~/ streams, 1),
      );
      var failures = 0;
      while (reserved < budget && !deadline.isCompleted) {
        _ensureActive();
        final bytes = math.min(block, budget - reserved);
        reserved += bytes;
        final start = clock.elapsedMicroseconds;
        var delivered = 0;
        void consume(int count) {
          delivered += count;
          _consume(count);
          if (!deadline.isCompleted) {
            shown.add(clock.elapsedMicroseconds, count);
          }
        }

        try {
          await _untilStopped(
            Future.any([
              upload
                  ? session.upload(bytes, consume, lane: index)
                  : session.download(bytes, consume, lane: index),
              deadline.future.then<void>(
                (_) => throw const _DirectionFinished(),
              ),
            ]),
          );
        } on _DirectionFinished {
          return;
        } on _Stopped {
          rethrow;
        } on Object {
          reserved -= bytes - math.min(delivered, bytes);
          if (deadline.isCompleted) return;
          // Long routes drop single connections; losing a lane skews the rate.
          if (++failures < _laneAttempts) continue;
          failed = true;
          return;
        }
        failures = 0;
        final end = clock.elapsedMicroseconds;
        if (upload) measured.spread(start, end, bytes);
        // Whole-chunk backends may serve less than reserved.
        reserved -= bytes - math.min(delivered, bytes);
        if (end > start) {
          block =
              (math.max(delivered, 1) *
                      (upload ? _uploadRequest : _downloadRequest) /
                      (end - start))
                  .round()
                  .clamp(64 * 1024, 16 * 1024 * 1024);
        }
      }
    }

    try {
      await Future.wait([for (var i = 0; i < streams; i++) lane(i)]);
    } finally {
      timer.cancel();
      ticker.cancel();
      clock.stop();
    }
    final rate = measured.result(
      math.min(
        clock.elapsedMicroseconds,
        plan.directionDuration.inMicroseconds,
      ),
    );
    if (rate != null) {
      if (upload) {
        _up = rate;
      } else {
        _down = rate;
      }
      _live = rate;
    }
    if (rate == null || failed) _errors.add(stage);
    if (reserved >= budget && clock.elapsed < plan.minimumDuration) {
      _limited = true;
    }
    _emit();
  }

  void _consume(int count) {
    _ensureActive();
    if (count < 0 || count > settings.byteLimit - _spent) {
      throw StateError('payload budget exceeded');
    }
    _spent += count;
  }

  Future<T> _untilStopped<T>(Future<T> operation) => Future.any([
    operation,
    _stop.future.then<T>((_) => throw const _Stopped()),
  ]);

  Future<void> _wait(Duration duration) async {
    await _untilStopped(Future<void>.delayed(duration));
    _ensureActive();
  }

  void _ensureActive() {
    if (_stop.isCompleted) throw const _Stopped();
  }

  void cancel({String? failure}) {
    if (_stop.isCompleted || _phase != SpeedTestPhase.running) return;
    _failure = failure;
    _phase = failure == null ? SpeedTestPhase.cancelled : SpeedTestPhase.failed;
    _stop.complete();
    session.close();
    _watch.stop();
    _emit();
  }

  void _emit() {
    final complete = _phase == SpeedTestPhase.done;
    final progress = settings.mode == SpeedTestMode.latencyOnly
        ? (_stage == SpeedTestStage.warmup ? 0.05 : 0.15 + _fraction * 0.8)
        : switch (_stage) {
            SpeedTestStage.warmup => 0.03,
            SpeedTestStage.latency => 0.1 + _fraction * 0.2,
            SpeedTestStage.download => 0.3 + _fraction * 0.35,
            SpeedTestStage.upload => 0.65 + _fraction * 0.35,
          };
    onUpdate(
      SpeedTestState(
        phase: _phase,
        stage: _stage,
        downloadMbps: _down,
        uploadMbps: _up,
        liveMbps: _live,
        latency: LatencySummary.of(_idle),
        transferredBytes: _spent,
        byteLimit: settings.mode == SpeedTestMode.complete
            ? settings.byteLimit
            : 0,
        elapsed: _watch.elapsed,
        progress: complete ? 1 : progress.clamp(0, 1),
        checkedAt: _phase == SpeedTestPhase.running ? null : DateTime.now(),
        viaVpn: viaVpn,
        backendId: settings.backendId,
        limited: _limited,
        errors: Set.unmodifiable(_errors),
        failure: _failure,
      ),
    );
  }
}

/// Bytes per fixed time bin of one transfer direction.
class SpeedTestThroughput {
  SpeedTestThroughput(this.bin);

  final int bin;
  final _bins = <int>[];
  var _total = 0;

  void add(int at, int bytes) {
    final index = at ~/ bin;
    while (_bins.length <= index) {
      _bins.add(0);
    }
    _bins[index] += bytes;
    _total += bytes;
  }

  /// Credits a request acknowledged at [end] evenly over its whole duration.
  void spread(int start, int end, int bytes) {
    if (end <= start) return add(end, bytes);
    var credited = 0;
    for (var index = start ~/ bin; index * bin < end; index++) {
      final overlap =
          math.min(end, (index + 1) * bin) - math.max(start, index * bin);
      final share = index * bin + bin >= end
          ? bytes - credited
          : (bytes * overlap / (end - start)).round();
      add(math.max(start, index * bin), share);
      credited += share;
    }
  }

  /// Mbit/s over the last second of complete bins.
  double? recent(int now) {
    final complete = math.min(now ~/ bin, _bins.length);
    if (complete == 0) return null;
    final count = math.min(complete, (1000000 / bin).ceil());
    var bytes = 0;
    for (var i = complete - count; i < complete; i++) {
      bytes += _bins[i];
    }
    return bytes * 8 / (count * bin);
  }

  /// Mean of the bins between the slowest 30% and the fastest 10%, which
  /// leaves out TCP ramp-up, the cut-off tail and short bursts.
  double? result(int end) {
    if (_total == 0 || end <= 0) return null;
    final complete = math.min(end ~/ bin, _bins.length);
    if (complete < 4) return _total * 8 / end;
    final rates = [for (var i = 0; i < complete; i++) _bins[i] * 8 / bin]
      ..sort();
    final kept = rates.sublist(
      (complete * 0.3).floor(),
      complete - (complete * 0.1).floor(),
    );
    final mean = kept.reduce((a, b) => a + b) / kept.length;
    return mean > 0 ? mean : null;
  }
}

class _Stopped implements Exception {
  const _Stopped();
}

class _DirectionFinished implements Exception {
  const _DirectionFinished();
}
