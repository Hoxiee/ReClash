import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'src/fork/git.dart';
import 'src/fork/model.dart';
import 'src/fork/registry.dart';
import 'src/fork/report.dart';
import 'src/fork/sync.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('root', defaultsTo: Directory.current.path)
    ..addFlag('json', negatable: false)
    ..addFlag('markdown', negatable: false);
  parser.addCommand('check').addFlag('staged', negatable: false);
  parser.addCommand('context')
    ..addMultiOption('paths', splitCommas: false)
    ..addFlag('changed', negatable: false)
    ..addFlag('staged', negatable: false)
    ..addOption('id');
  parser.addCommand('impact')
    ..addOption('from', mandatory: true)
    ..addOption('to', mandatory: true);
  parser.addCommand('status').addOption('id', mandatory: true);
  parser.addCommand('lineage').addOption('id', mandatory: true);
  parser.addCommand('report')
    ..addFlag('changed', negatable: false)
    ..addOption('from')
    ..addOption('to')
    ..addOption('downstream-from')
    ..addOption('downstream-to');
  parser.addCommand('stats')
    ..addOption('vendor', mandatory: true)
    ..addOption('downstream', defaultsTo: 'HEAD');
  parser.addCommand('bootstrap')
    ..addFlag('inspect', negatable: false)
    ..addFlag('prepare', negatable: false)
    ..addOption('source', mandatory: true)
    ..addOption('id')
    ..addOption('audit');
  final sync = parser.addCommand('sync');
  sync.addCommand('prepare')
    ..addOption('id', mandatory: true)
    ..addOption('source')
    ..addFlag('recipe-migration', negatable: false)
    ..addOption('audit')
    ..addOption('after');
  sync.addCommand('status').addOption('id', mandatory: true);
  sync.addCommand('verify')
    ..addOption('id', mandatory: true)
    ..addMultiOption('reviewed')
    ..addMultiOption('waive-check');
  sync.addCommand('accept').addOption('id', mandatory: true);
  try {
    final options = parser.parse(arguments);
    final command = options.command;
    if (command == null) {
      reject(
        'Usage: dart run tool/fork.dart [--root PATH] [--json] <command>\n${parser.usage}',
      );
    }
    if (options.flag('markdown') &&
        (options.flag('json') ||
            !['report', 'status', 'lineage'].contains(command.name))) {
      reject(
        '--markdown is exclusive with --json and supports report/status/lineage',
      );
    }
    final git = ForkGit(options.option('root')!);
    final staged =
        (command.name == 'check' || command.name == 'context') &&
        command.flag('staged');
    final registry = Registry(git, staged: staged);
    final service = VendorSync(registry);
    Object output;
    switch (command.name) {
      case 'check':
        MaintenanceReport(registry).policy();
        output = {
          'status': 'valid',
          'meaning': 'schema-valid-only-not-ready-for-acceptance',
          'features': registry.features.length,
          'gaps': {
            for (final f in registry.features.values.where(
              (f) => f.state != 'retired' && f.uncovered.isNotEmpty,
            ))
              f.id: f.uncovered,
          },
        };
      case 'context':
        final sources = [
          command.flag('changed'),
          command.flag('staged'),
          command.option('id') != null,
          command.multiOption('paths').isNotEmpty,
        ].where((v) => v).length;
        if (sources != 1) {
          reject('Select exactly one of --paths, --changed, --staged, --id');
        }
        final paths = command.flag('changed')
            ? git.changedPaths
            : staged
            ? git.stagedPaths
            : command.multiOption('paths');
        for (final path in paths) {
          safePath(path);
        }
        if (!options.flag('json')) {
          stdout.write(registry.context(paths, id: command.option('id')));
          return;
        }
        output = command.option('id') == null
            ? registry.impact(paths)
            : registry.features[command.option('id')]?.data ??
                  reject('Unknown feature ID');
      case 'impact':
        final from = command.option('from')!;
        final to = command.option('to')!;
        final paths = git.changed(from, to);
        final report = registry.impact(paths);
        output = {
          ...report,
          'changes': git.changes(from, to),
          'clusters': clusters(registry, paths),
        };
      case 'lineage':
        output = MaintenanceReport(registry).lineage(command.option('id')!);
      case 'status':
        output = MaintenanceReport(registry).status(command.option('id')!);
      case 'report':
        final changed = command.flag('changed');
        final from = command.option('from');
        final to = command.option('to');
        if ((changed && (from != null || to != null)) ||
            (!changed && (from == null || to == null))) {
          reject('Choose --changed or both --from and --to');
        }
        final downstreamFrom = command.option('downstream-from');
        final downstreamTo = command.option('downstream-to');
        if ((downstreamFrom == null) != (downstreamTo == null) ||
            (changed && downstreamFrom != null)) {
          reject(
            'Overlap requires --from, --to, --downstream-from and --downstream-to',
          );
        }
        output = MaintenanceReport(registry).paths(
          changed ? git.changedPaths : git.changed(from!, to!),
          from: from,
          to: to,
          downstreamFrom: downstreamFrom,
          downstreamTo: downstreamTo,
        );
      case 'stats':
        final vendor = command.option('vendor')!;
        final downstream = command.option('downstream')!;
        final base = git.files(vendor).toSet();
        final changed = git.changed(vendor, downstream);
        final observed = git
            .run(['rev-list', '--first-parent', vendor])
            .trim()
            .split('\n');
        final activity = <String, int>{};
        for (var i = 0; i + 1 < observed.length && i < 20; i++) {
          for (final path in git.changed(observed[i + 1], observed[i])) {
            activity.update(path, (v) => v + 1, ifAbsent: () => 1);
          }
        }
        output = {
          'modifiedVendorFiles': changed.where(base.contains).length,
          'binaryOrGitlinkChanges': git
              .changes(vendor, downstream)
              .where((e) => ['binary', 'gitlink'].contains(e['kind']))
              .toList(),
          'downstreamOnlyFiles': changed
              .where((path) => !base.contains(path))
              .length,
          'numstat': git.run([
            'diff',
            '--numstat',
            '--no-renames',
            git.tree(vendor),
            git.tree(downstream),
          ]),
          'observedIntervals': observed.length > 21 ? 20 : observed.length - 1,
          'overlappingHotspots': {
            for (final path in changed.where(activity.containsKey))
              path: activity[path],
          },
        };
      case 'bootstrap':
        if (command.flag('inspect') == command.flag('prepare')) {
          reject('Select --inspect or --prepare');
        }
        if (command.flag('inspect')) {
          final report = service.inspect(command.option('source')!);
          output = {...report, 'auditDigest': digest(report)};
        } else {
          output = service.prepare(
            command.option('id') ?? reject('--id is required'),
            source: command.option('source'),
            bootstrap: true,
            audit: command.option('audit'),
          );
        }
      case 'sync':
        final action =
            command.command ??
            reject('sync requires prepare, status, verify, or accept');
        final id = action.option('id')!;
        output = switch (action.name) {
          'prepare' => service.prepare(
            id,
            source: action.option('source'),
            recipeMigration: action.flag('recipe-migration'),
            audit: action.option('audit'),
            after: action.option('after'),
          ),
          'status' => MaintenanceReport(registry).status(id),
          'verify' => service.verify(
            id,
            reviews: action.multiOption('reviewed'),
            waivers: action.multiOption('waive-check'),
          ),
          'accept' => service.accept(id),
          _ => reject('Unknown sync command'),
        };
      default:
        reject('Unknown command');
    }
    if (options.flag('markdown')) {
      stdout.writeln(renderMaintenanceMarkdown(output as Map<String, dynamic>));
      return;
    }
    final rendered = const JsonEncoder.withIndent('  ').convert(output);
    if (!options.flag('json') &&
        utf8.encode(rendered).length > registry.config['budget']) {
      stdout.writeln(
        'FORK/1 partial report (${utf8.encode(rendered).length} bytes). Repeat with --json before the command for the complete report; no audit approval is implied.',
      );
      if (output is Map) {
        for (final entry in output.entries) {
          final value = entry.value;
          stdout.writeln(
            '${entry.key}: ${value is List
                ? '${value.length} entries'
                : value is Map
                ? '${value.length} fields'
                : value}',
          );
        }
      }
    } else {
      stdout.writeln(rendered);
    }
  } on ForkException catch (e) {
    stderr.writeln('fork: $e');
    exitCode = e.code;
  } on FormatException catch (e) {
    stderr.writeln('fork: ${e.message}');
    exitCode = 2;
  } on FileSystemException catch (e) {
    stderr.writeln('fork: ${e.message}: ${e.path}');
    exitCode = 3;
  }
}

List<List<String>> clusters(Registry registry, List<String> paths) {
  final groups = <Set<String>>[];
  for (final path in paths) {
    final ids = registry.affected([path]).keys.toSet();
    if (ids.isEmpty) ids.add('unclassified');
    final overlapping = groups
        .where((group) => group.intersection(ids).isNotEmpty)
        .toList();
    for (final group in overlapping) {
      ids.addAll(group);
      groups.remove(group);
    }
    groups.add(ids);
  }
  return groups.map((group) => group.toList()..sort()).toList()
    ..sort((a, b) => a.first.compareTo(b.first));
}
