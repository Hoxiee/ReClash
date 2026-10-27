import 'package:flutter/foundation.dart';

enum SpeedTestPhase { idle, running, done, cancelled, failed }

enum SpeedTestStage { warmup, latency, download, upload }

@immutable
class LatencySummary {
  const LatencySummary({
    required this.medianMs,
    required this.jitterMs,
    required this.count,
  });

  static LatencySummary? of(List<double> samples) {
    if (samples.isEmpty) return null;
    final sorted = [...samples]..sort();
    double percentile(double p) {
      final index = (sorted.length - 1) * p;
      final low = index.floor();
      final high = index.ceil();
      return sorted[low] + (sorted[high] - sorted[low]) * (index - low);
    }

    var differences = 0.0;
    for (var i = 1; i < samples.length; i++) {
      differences += (samples[i] - samples[i - 1]).abs();
    }
    return LatencySummary(
      medianMs: percentile(0.5),
      jitterMs: samples.length > 1 ? differences / (samples.length - 1) : null,
      count: samples.length,
    );
  }

  final double medianMs;
  final double? jitterMs;
  final int count;
}

@immutable
class SpeedTestState {
  const SpeedTestState({
    this.phase = SpeedTestPhase.idle,
    this.stage = SpeedTestStage.warmup,
    this.downloadMbps,
    this.uploadMbps,
    this.liveMbps,
    this.latency,
    this.transferredBytes = 0,
    this.byteLimit = 0,
    this.elapsed = Duration.zero,
    this.progress = 0,
    this.checkedAt,
    this.viaVpn = false,
    this.backendId = 'cloudflare',
    this.limited = false,
    this.errors = const {},
    this.failure,
  });

  final SpeedTestPhase phase;
  final SpeedTestStage stage;
  final double? downloadMbps;
  final double? uploadMbps;
  final double? liveMbps;
  final LatencySummary? latency;
  final int transferredBytes;
  final int byteLimit;
  final Duration elapsed;
  final double progress;
  final DateTime? checkedAt;
  final bool viaVpn;
  final String backendId;
  final bool limited;
  final Set<SpeedTestStage> errors;
  final String? failure;

  bool get running => phase == SpeedTestPhase.running;
  double? get mbps =>
      downloadMbps ?? (stage == SpeedTestStage.download ? liveMbps : null);
}
