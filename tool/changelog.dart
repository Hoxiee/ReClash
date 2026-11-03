import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' show isAbsolute, join;

import 'src/changelog/digest.dart';
import 'src/changelog/git.dart';
import 'src/changelog/notes.dart';
import 'src/changelog/render.dart';
import 'src/changelog/summary.dart';
import 'src/release_version.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('root', help: 'Repository root, defaults to the cwd.');

  parser
      .addCommand('digest')
      .addOption('tag', help: 'Tag being prepared, defaults to the pubspec.');

  parser.addCommand('render')
    ..addOption('tag', help: 'Tag to render, defaults to the pubspec.')
    ..addOption('out', help: 'Output file, defaults to stdout.');

  parser.addCommand('changelog');
  parser.addCommand('verify');

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (error) {
    _fail('${error.message}\n\n${_usage(parser)}');
  }

  final command = results.command;
  if (command == null) {
    _fail(_usage(parser));
  }

  final root = results.option('root') ?? Directory.current.path;
  try {
    exit(switch (command.name) {
      'digest' => _digest(root, command),
      'render' => _render(root, command),
      'changelog' => _changelog(root),
      'verify' => _verify(root),
      _ => _fail(_usage(parser)),
    });
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exit(1);
  }
}

int _digest(String root, ArgResults command) {
  final tag = _tag(root, command);
  stdout.write(
    renderDigest(buildDigest(Git(workingDirectory: root), root, tag)),
  );
  return 0;
}

int _render(String root, ArgResults command) {
  final rest = command.rest;
  if (rest.isEmpty) {
    _fail('render needs a target: release or telegram');
  }
  final tag = _tag(root, command).name;
  final summary = readReleaseSummary(root, tag);
  final output = switch (rest.first) {
    'release' => renderRelease(
      readReleaseNotes(root, tag) ??
          _fail('$releaseNotesDirectory/$tag.md is missing'),
      summary: summary,
    ),
    'telegram' => renderTelegram(
      summary ?? _fail('$releaseSummariesDirectory/$tag.json is missing'),
    ),
    _ => _fail('Unknown render target: ${rest.first}'),
  };

  final out = command.option('out');
  if (out == null) {
    stdout.write(output);
  } else {
    File(isAbsolute(out) ? out : join(root, out)).writeAsStringSync(output);
  }
  return 0;
}

int _changelog(String root) {
  File(
    join(root, changelogMarkdownPath),
  ).writeAsStringSync(renderChangelog(readAllReleaseNotes(root)));
  stdout.writeln('Wrote $changelogMarkdownPath');
  return 0;
}

int _verify(String root) {
  final problems = [
    ...verifyReleaseSummaries(root),
    ...verifyReleaseNotes(root),
  ];
  if (problems.isEmpty) {
    final file = File(join(root, changelogMarkdownPath));
    final expected = renderChangelog(readAllReleaseNotes(root));
    if (!file.existsSync() || file.readAsStringSync() != expected) {
      problems.add(
        '$changelogMarkdownPath is stale; run dart run tool/changelog.dart '
        'changelog',
      );
    }
  }
  if (problems.isEmpty) {
    stdout.writeln('Release notes, summaries and CHANGELOG.md are consistent.');
    return 0;
  }
  for (final problem in problems) {
    stderr.writeln('✗ $problem');
  }
  return 1;
}

VersionTag _tag(String root, ArgResults command) {
  final name = command.option('tag') ?? 'v${ReleaseVersion.read(root).name}';
  final tag = VersionTag.tryParse(name);
  if (tag == null || tag.name != name) {
    _fail('Not a release tag: $name');
  }
  return tag;
}

String _usage(ArgParser parser) => '''
Usage: dart run tool/changelog.dart <command> [options]

Commands:
  digest [--tag vX]     Commits and earlier notes to author the notes from.
  render <release|telegram> [--tag vX] [--out file]
  changelog             Rewrite CHANGELOG.md from release_notes/.
  verify                Check notes, summaries and CHANGELOG.md.

${parser.usage}''';

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
