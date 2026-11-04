import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/report/archive.dart';
import 'package:reclash/features/doctor/report/builder.dart';
import 'package:reclash/features/doctor/report/collector.dart';
import 'package:reclash/features/doctor/report/redact.dart';
import 'package:reclash/features/doctor/report/registry.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/features/doctor/report/sources.dart';

final _now = DateTime.utc(2026, 11, 3, 18, 42);
const _token = 'f3a9c1e07b2d4e58';

SweepRow _row(int i, SweepStatus status) => SweepRow(
  node: 'Node $i',
  group: 'Auto',
  type: 'vless',
  server: 'n$i.edge.example.net',
  port: 443,
  status: status,
  delayMs: status == SweepStatus.ok ? 100 + i : null,
);

class _Sweeper implements NodeSweeper {
  _Sweeper(this.rows);

  final List<SweepRow> rows;

  @override
  Future<List<SweepRow>> sweep({
    required void Function(int done, int total) onProgress,
    required bool Function() cancelled,
  }) async {
    final done = <SweepRow>[];
    onProgress(0, rows.length);
    for (final row in rows) {
      if (cancelled()) break;
      await Future<void>.delayed(Duration.zero);
      done.add(row);
      onProgress(done.length, rows.length);
    }
    return done;
  }
}

class _Recorder implements PassiveRecorder {
  bool flushed = false;

  @override
  Future<void> flush() async => flushed = true;

  @override
  Future<List<String>> logLines() async => [
    '2026-11-03T18:40:00.000Z INFO [TCP] dial n1.edge.example.net:443',
    '2026-11-03T18:40:01.000Z INFO [APP] profile update https://sub.example.net/s/$_token',
    '2026-11-03T18:40:02.000Z ERROR [DNS] resolve failed',
  ];

  @override
  Future<List<PassiveEvent>> events({required DateTime since}) async => [
    PassiveEvent(
      time: _now.subtract(const Duration(days: 9)),
      kind: 'coreCrash',
    ),
    PassiveEvent(
      time: _now.subtract(const Duration(hours: 1)),
      kind: 'profileUpdate',
      data: const {'profile': 3, 'ok': false, 'error': 'HTTP 403'},
    ),
    PassiveEvent(
      time: _now.subtract(const Duration(hours: 2)),
      kind: 'coreCrash',
      data: const {'exitCode': 2},
    ),
  ].where((e) => !e.time.isBefore(since)).toList();
}

class _Sources implements ReportSources {
  _Sources({this.connected = true});

  @override
  final bool connected;
  final _Recorder _recorder = _Recorder();
  final List<String> calls = [];
  final sweepRows = [
    for (var i = 0; i < 6; i++)
      _row(i, i.isEven ? SweepStatus.ok : SweepStatus.timeout),
  ];

  PathResult _path({required bool failed}) => PathResult(
    scope: PathScope.full,
    steps: [
      for (final step in PathScope.full.steps)
        PathStepResult(
          step,
          status: step == PathStep.server && failed
              ? PathStepStatus.fail
              : PathStepStatus.pass,
          duration: const Duration(milliseconds: 10),
          cause: step == PathStep.server && failed
              ? FailureCause.timeout
              : null,
        ),
    ],
    startedAt: _now,
  ).finish(_now);

  @override
  Future<Map<String, Object?>> device() async => {
    'app': {
      'name': 'ReClash',
      'version': '0.1.0',
      'build': '1',
      'flavor': 'stable',
    },
    'safeMode': false,
    'platform': 'linux',
    'os': 'Arch Linux',
    'device': 'desktop',
    'abi': 'linux_x64',
  };

  @override
  Future<Map<String, Object?>> environment() async {
    calls.add('environment');
    return {'takenAt': _now.toIso8601String(), 'facts': {}};
  }

  @override
  List<Finding> findings() => const [
    Finding(
      id: 'server.unreachable',
      severity: CheckSeverity.critical,
      cause: FailureCause.timeout,
      evidence: ['path.server'],
      titleKey: 't',
      detailKey: 'd',
      remedyIds: ['node.switch'],
    ),
  ];

  @override
  Future<List<DiagnosticEvent>> incidents() async => [
    DiagnosticEvent(
      kind: DiagnosticEventKind.remedyApplied,
      at: _now.subtract(const Duration(minutes: 5)),
      subject: 'node.switch',
      outcome: 'failed',
    ),
    DiagnosticEvent(
      kind: DiagnosticEventKind.pathFailed,
      at: _now.subtract(const Duration(days: 10)),
      subject: 'server',
    ),
  ];

  @override
  PathResult? get lastPath => _path(failed: false);

  @override
  Future<PathResult> runPath() async {
    calls.add('runPath');
    return _path(failed: true);
  }

  @override
  NodeSweeper get sweeper => _Sweeper(sweepRows);

  @override
  Future<Map<String, Object?>> services() async {
    calls.add('services');
    return {'checks': []};
  }

  @override
  ReportProfile? profile() => (
    id: 3,
    label: 'Example VPN',
    json: {'id': 3, 'source': urlOrigin('https://sub.example.net/s/$_token')},
    secrets: urlSecrets('https://sub.example.net/s/$_token').toList(),
  );

  @override
  Future<String?> config() async {
    calls.add('config');
    throw StateError('no config');
  }

  @override
  PassiveRecorder get recorder => _recorder;
}

Future<CollectedReport> _collect(
  _Sources sources, {
  ReportOptions options = const ReportOptions(),
  ReportControl? control,
  List<ReportProgress>? progress,
  void Function(ReportProgress progress)? onProgress,
}) => ReportCollector(sources).collect(
  id: 'RC-0000-0001',
  createdAt: _now,
  options: options,
  onProgress: (p) {
    progress?.add(p);
    onProgress?.call(p);
  },
  control: control,
);

void main() {
  test('phases run in order and the sweep reports each node', () async {
    final progress = <ReportProgress>[];
    final sources = _Sources();
    final report = await _collect(sources, progress: progress);

    expect(progress.map((p) => p.phase).toSet().toList(), [
      ReportPhase.snapshot,
      ReportPhase.path,
      ReportPhase.sweep,
      ReportPhase.services,
    ]);
    final sweep = [
      for (final p in progress)
        if (p.phase == ReportPhase.sweep && p.total > 0) p.done,
    ];
    expect(sweep, [0, 1, 2, 3, 4, 5, 6]);

    final data = report.data;
    expect(data.manifest['id'], 'RC-0000-0001');
    expect(data.manifest['redaction'], 'provider');
    expect(data.summary['verdict'], 'fail');
    expect(data.summary['failedStep'], 'server');
    expect(data.summary['cause'], 'timeout');
    expect(data.summary['servers'], {'total': 6, 'ok': 3, 'timeout': 3});
    expect(data.path!['fresh'], isTrue);
    expect(data.servers, hasLength(6));
    expect(data.config, isNull, reason: 'a failing source drops its section');
    expect(data.logs!['core'], hasLength(2));
    expect(data.logs!['app'], hasLength(1));
    expect((sources.recorder as _Recorder).flushed, isTrue);
    expect((data.history!['incidents']! as List), hasLength(1));
    expect((data.history!['coreCrashes']! as List), hasLength(1));
    expect(
      (data.profile!['updates']! as List).single,
      containsPair('ok', false),
    );
    expect(data.findings!.single['tried'], hasLength(1));
    expect(report.profileId, 3);
    expect(report.secrets, contains(_token));
  });

  test('stopping the sweep keeps the finished rows', () async {
    final control = ReportControl();
    final progress = <ReportProgress>[];
    final sources = _Sources();
    final report = await _collect(
      sources,
      control: control,
      progress: progress,
      onProgress: (p) {
        if (p.phase == ReportPhase.sweep && p.done == 2) control.stopSweep();
      },
    );

    expect(report.data.servers, hasLength(2));
    expect(report.data.summary['servers'], containsPair('total', 2));
    expect(progress.last.phase, ReportPhase.services);
  });

  test('cancelling abandons the report', () async {
    final control = ReportControl();
    final progress = <ReportProgress>[];
    final collecting = _collect(
      _Sources(),
      control: control,
      progress: progress,
      onProgress: (p) {
        if (p.phase == ReportPhase.sweep && p.done == 1) control.cancel();
      },
    );
    await expectLater(collecting, throwsA(isA<ReportCancelled>()));
    expect(progress.map((p) => p.phase), isNot(contains(ReportPhase.services)));
  });

  test('without a connection the live probes are skipped', () async {
    final sources = _Sources(connected: false);
    final report = await _collect(sources);
    expect(sources.calls, isNot(contains('runPath')));
    expect(sources.calls, isNot(contains('services')));
    expect(report.data.servers, isNull);
    expect(report.data.services, isNull);
    expect(report.data.path!['fresh'], isFalse);
    expect(report.data.summary['verdict'], 'fail', reason: 'critical finding');
  });

  test('sections left out are not read', () async {
    final sources = _Sources();
    final report = await _collect(
      sources,
      options: const ReportOptions(
        sections: {ReportSection.findings, ReportSection.path},
      ),
    );
    expect(sources.calls, ['runPath']);
    final data = report.data;
    expect(data.findings, isNotNull);
    expect(data.path, isNotNull);
    expect(data.servers, isNull);
    expect(data.environment, isNull);
    expect(data.profile, isNull);
    expect(data.history, isNull);
    expect(data.logs, isNull);
    expect(report.secrets, contains(_token), reason: 'still masked elsewhere');
  });

  test('build packs, redacts and records the report', () async {
    final dir = await Directory.systemTemp.createTemp('report_builder');
    addTearDown(() => dir.delete(recursive: true));
    final stale = File('${dir.path}/out/reclash-report-old.zip')
      ..createSync(recursive: true)
      ..setLastModifiedSync(_now.subtract(const Duration(days: 2)));
    final registry = FileReportRegistry(
      directory: () async => dir,
      now: () => _now,
    );
    final progress = <ReportProgress>[];
    final builder = ReportBuilder(
      collector: ReportCollector(_Sources()),
      registry: registry,
      directory: () async => Directory('${dir.path}/out'),
      now: () => _now,
      random: Random(4),
    );

    final result = await builder.build(
      const ReportOptions(note: 'broke after update'),
      onProgress: progress.add,
    );

    expect(result.id, matches(reportIdPattern));
    expect(progress.last.phase, ReportPhase.packing);
    expect(stale.existsSync(), isFalse);
    expect(File(result.path).existsSync(), isTrue);
    expect(result.path, endsWith('-${result.id}.zip'));
    expect(result.summary, contains('Note: broke after update'));
    expect(result.sizes.keys.first, 'README.md');
    expect((await registry.find(result.id))?.profileId, 3);

    final archive = ZipDecoder().decodeBytes(
      File(result.path).readAsBytesSync(),
    );
    for (final file in archive.files) {
      expect(
        String.fromCharCodes(file.content as List<int>),
        isNot(contains(_token)),
        reason: file.name,
      );
    }
  });

  test('a cancelled build leaves no archive and no record', () async {
    final dir = await Directory.systemTemp.createTemp('report_builder');
    addTearDown(() => dir.delete(recursive: true));
    final control = ReportControl();
    final registry = FileReportRegistry(
      directory: () async => dir,
      now: () => _now,
    );
    final builder = ReportBuilder(
      collector: ReportCollector(_Sources()),
      registry: registry,
      directory: () async => Directory('${dir.path}/out'),
      now: () => _now,
      pack: (request) async {
        control.cancel();
        return packReportSync(request);
      },
    );

    await expectLater(
      builder.build(const ReportOptions(), control: control),
      throwsA(isA<ReportCancelled>()),
    );
    expect(Directory('${dir.path}/out').listSync(), isEmpty);
    expect(await registry.list(), isEmpty);
  });
}
