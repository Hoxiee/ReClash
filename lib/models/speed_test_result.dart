import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reclash/models/speed_test.dart';

part 'generated/speed_test_result.freezed.dart';
part 'generated/speed_test_result.g.dart';

enum SpeedTestPhase { idle, running, done, cancelled, failed }

enum SpeedTestStage { warmup, latency, download, upload }

@immutable
class LatencySummary {
  const LatencySummary({
    required this.medianMs,
    required this.jitterMs,
    required this.count,
  });

  factory LatencySummary.fromJson(Map<String, dynamic> json) => LatencySummary(
    medianMs: (json['medianMs'] as num).toDouble(),
    jitterMs: (json['jitterMs'] as num?)?.toDouble(),
    count: (json['count'] as num).toInt(),
  );

  static LatencySummary? of(List<double> samples) {
    if (samples.isEmpty) return null;
    final sorted = [...samples]..sort();
    final middle = sorted.length ~/ 2;
    var differences = 0.0;
    for (var i = 1; i < samples.length; i++) {
      differences += (samples[i] - samples[i - 1]).abs();
    }
    return LatencySummary(
      medianMs: sorted.length.isOdd
          ? sorted[middle]
          : (sorted[middle - 1] + sorted[middle]) / 2,
      jitterMs: samples.length > 1 ? differences / (samples.length - 1) : null,
      count: samples.length,
    );
  }

  final double medianMs;
  final double? jitterMs;
  final int count;

  Map<String, Object?> toJson() => {
    'medianMs': medianMs,
    'jitterMs': jitterMs,
    'count': count,
  };
}

@immutable
class SpeedTestSample {
  const SpeedTestSample({required this.elapsedMs, required this.mbps});

  factory SpeedTestSample.fromJson(Map<String, dynamic> json) =>
      SpeedTestSample(
        elapsedMs: (json['elapsedMs'] as num).toInt(),
        mbps: (json['mbps'] as num).toDouble(),
      );

  final int elapsedMs;
  final double mbps;

  Map<String, Object?> toJson() => {'elapsedMs': elapsedMs, 'mbps': mbps};
}

@freezed
abstract class SpeedTestState with _$SpeedTestState {
  const SpeedTestState._();

  const factory SpeedTestState({
    @Default('') String requestId,
    @Default(SpeedTestPhase.idle) SpeedTestPhase phase,
    @Default(SpeedTestStage.warmup) SpeedTestStage stage,
    double? downloadMbps,
    double? uploadMbps,
    double? liveMbps,
    LatencySummary? latency,
    LatencySummary? downloadLatency,
    LatencySummary? uploadLatency,
    int? rpm,
    @Default(0) int transferredBytes,
    @Default(0) int byteLimit,
    @JsonKey(
      name: 'elapsedMs',
      fromJson: _durationFromMilliseconds,
      toJson: _durationToMilliseconds,
    )
    @Default(Duration.zero)
    Duration elapsed,
    @Default(0) double progress,
    DateTime? checkedAt,
    @Default(false) bool viaVpn,
    @Default('cloudflare') String backendId,
    @Default('') String proxyName,
    @Default([]) List<String> chains,
    SpeedTestServer? server,
    @Default('h2') String protocol,
    @Default(false) bool protocolFallback,
    @Default(false) bool limited,
    @Default({}) Set<SpeedTestStage> errors,
    String? failure,
    @Default([]) List<SpeedTestSample> downloadSamples,
    @Default([]) List<SpeedTestSample> uploadSamples,
    @Default(0) int coreEpoch,
    @Default(0) int routeVersion,
    @Default(false) bool historySaveFailed,
  }) = _SpeedTestState;

  factory SpeedTestState.fromJson(Map<String, dynamic> json) =>
      _$SpeedTestStateFromJson(json);

  bool get running => phase == SpeedTestPhase.running;
  bool get latencyOnly => byteLimit == 0;
  String get platformName =>
      SpeedTestSettings.platforms[backendId] ?? backendId;
  String get protocolLabel => switch (protocol) {
    'h3' => 'HTTP/3',
    'h2' => 'HTTP/2',
    _ => 'HTTP/1.1',
  };
  double? get mbps =>
      downloadMbps ?? (stage == SpeedTestStage.download ? liveMbps : null);

  Map<String, Object?> toRecord() => {
    ...toJson(),
    'downloadSamples': const <Object>[],
    'uploadSamples': const <Object>[],
    'liveMbps': null,
    'requestId': '',
    'historySaveFailed': false,
  };
}

Duration _durationFromMilliseconds(num? value) =>
    Duration(milliseconds: value?.toInt() ?? 0);

int _durationToMilliseconds(Duration value) => value.inMilliseconds;
