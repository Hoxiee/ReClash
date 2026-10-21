import 'dart:io';

import 'src/l10n/cli.dart';

Future<void> main(List<String> args) async {
  exitCode = await L10nCli(
    root: Directory.current,
    out: stdout,
    err: stderr,
    generate: _runIntlUtils,
  ).run(args);
}

Future<String?> _runIntlUtils(Directory root) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'run',
    'intl_utils:generate',
  ], workingDirectory: root.path);
  if (result.exitCode == 0) return null;
  return '${result.stdout}${result.stderr}';
}
