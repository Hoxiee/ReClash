import 'dart:math';

import 'package:flutter/foundation.dart';

/// Public also hashes the hosts and IPs that provider keeps.
enum ReportRedaction { provider, public }

/// The parts of a report a user can leave out; the manifest, README and
/// summary are always there.
enum ReportSection {
  findings,
  path,
  servers,
  services,
  environment,
  profile,
  history,
  config,
  logs,
}

@immutable
final class ReportOptions {
  const ReportOptions({
    this.note,
    this.redaction = ReportRedaction.provider,
    this.sections = const {...ReportSection.values},
    this.captureLines,
  });

  final String? note;
  final ReportRedaction redaction;
  final Set<ReportSection> sections;
  final List<String>? captureLines;

  bool includes(ReportSection section) => sections.contains(section);
}

enum ReportPhase { snapshot, path, sweep, services, packing }

@immutable
final class ReportProgress {
  const ReportProgress(this.phase, {this.done = 0, this.total = 0});

  final ReportPhase phase;
  final int done;
  final int total;

  @override
  bool operator ==(Object other) =>
      other is ReportProgress &&
      other.phase == phase &&
      other.done == done &&
      other.total == total;

  @override
  int get hashCode => Object.hash(phase, done, total);

  @override
  String toString() => 'ReportProgress(${phase.name}, $done/$total)';
}

typedef ReportProgressCallback = void Function(ReportProgress progress);

final class ReportCancelled implements Exception {
  const ReportCancelled();

  @override
  String toString() => 'ReportCancelled';
}

const _crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// `RC-XXXX-XXXX`: 40 random bits in Crockford base32, which has no I, L, O
/// or U to misread when the id is typed back.
String newReportId([Random? random]) {
  final source = random ?? Random.secure();
  final chars = [
    for (var i = 0; i < 8; i++) _crockford[source.nextInt(_crockford.length)],
  ].join();
  return 'RC-${chars.substring(0, 4)}-${chars.substring(4)}';
}

final reportIdPattern = RegExp(
  r'^RC-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$',
);

abstract final class ReportSchema {
  static const version = 1;
  static const data = 'reclash.report@1';
  static const manifest = 'reclash.report.manifest@1';
  static const findings = 'reclash.report.findings@1';
  static const path = 'reclash.report.path@1';
  static const services = 'reclash.report.services@1';
  static const environment = 'reclash.report.environment@1';
  static const profile = 'reclash.report.profile@1';
  static const history = 'reclash.report.history@1';
}

/// Plain JSON-able data, so it crosses into the redaction isolate and the
/// viewer unchanged. A null section was left out or has no source.
@immutable
final class ReportData {
  const ReportData({
    required this.manifest,
    required this.summary,
    this.findings,
    this.path,
    this.services,
    this.environment,
    this.profile,
    this.history,
    this.servers,
    this.config,
    this.logs,
  });

  factory ReportData.fromJson(Map<String, Object?> json) {
    Map<String, Object?>? map(String key) => switch (json[key]) {
      final Map<Object?, Object?> value => value.cast<String, Object?>(),
      _ => null,
    };
    List<Map<String, Object?>>? rows(String key) => switch (json[key]) {
      final List<Object?> value => [
        for (final row in value) (row! as Map).cast<String, Object?>(),
      ],
      _ => null,
    };
    return ReportData(
      manifest: map('manifest') ?? const {},
      summary: map('summary') ?? const {},
      findings: rows('findings'),
      path: map('path'),
      services: map('services'),
      environment: map('environment'),
      profile: map('profile'),
      history: map('history'),
      servers: rows('servers'),
      config: json['config'] as String?,
      logs: switch (json['logs']) {
        final Map<Object?, Object?> logs => {
          for (final MapEntry(:key, :value) in logs.entries)
            key! as String: [for (final line in value! as List) line as String],
        },
        _ => null,
      },
    );
  }

  final Map<String, Object?> manifest;
  final Map<String, Object?> summary;
  final List<Map<String, Object?>>? findings;
  final Map<String, Object?>? path;
  final Map<String, Object?>? services;
  final Map<String, Object?>? environment;
  final Map<String, Object?>? profile;
  final Map<String, Object?>? history;
  final List<Map<String, Object?>>? servers;
  final String? config;

  /// Keyed by [ReportLogs] names, oldest line first.
  final Map<String, List<String>>? logs;

  String get id => manifest['id']! as String;

  /// The viewer skips the config: it has its own file and can be megabytes.
  Map<String, Object?> toJson({bool withConfig = true}) => {
    'schema': ReportSchema.data,
    'manifest': manifest,
    'summary': summary,
    if (findings != null) 'findings': findings,
    if (path != null) 'path': path,
    if (services != null) 'services': services,
    if (environment != null) 'environment': environment,
    if (profile != null) 'profile': profile,
    if (history != null) 'history': history,
    if (servers != null) 'servers': servers,
    if (config != null && withConfig) 'config': config,
    if (logs != null) 'logs': logs,
  };

  ReportData copyWith({
    Map<String, Object?>? manifest,
    String? config,
    Map<String, List<String>>? logs,
  }) => ReportData(
    manifest: manifest ?? this.manifest,
    summary: summary,
    findings: findings,
    path: path,
    services: services,
    environment: environment,
    profile: profile,
    history: history,
    servers: servers,
    config: config ?? this.config,
    logs: logs ?? this.logs,
  );
}

abstract final class ReportLogs {
  static const core = 'core';
  static const app = 'app';
  static const logcat = 'logcat';
  static const capture = 'capture';
}

@immutable
final class ReportResult {
  const ReportResult({
    required this.id,
    required this.path,
    required this.summary,
    required this.sizes,
    required this.createdAt,
    required this.redaction,
  });

  final String id;
  final String path;

  /// The "Copy summary" text.
  final String summary;

  /// Archive entry name to its uncompressed size in bytes, in archive order.
  final Map<String, int> sizes;
  final DateTime createdAt;
  final ReportRedaction redaction;
}
