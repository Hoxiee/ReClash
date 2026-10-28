import 'dart:io';

const _usage = '''
Prepares dependencies, localization, models, and providers.

Usage: dart tool/prepare.dart [--no-pub] [-- <flutter command>]

  --no-pub  Skip flutter pub get.
  --help    Show help without generating files.

Examples:
  dart tool/prepare.dart
  dart tool/prepare.dart -- analyze --no-fatal-infos
  dart tool/prepare.dart -- run --dart-define=SAFE_MODE=true
''';

typedef PrepareRunner =
    Future<int> Function(
      String executable,
      List<String> arguments, {
      required String workingDirectory,
      required bool quiet,
    });

Future<void> main(List<String> arguments) async {
  final split = arguments.indexOf('--');
  final options = split < 0 ? arguments : arguments.sublist(0, split);
  if (options.contains('--help') || options.contains('-h')) {
    stdout.write(_usage);
    return;
  }
  if (options.any((option) => option != '--no-pub')) {
    stderr.write(_usage);
    exitCode = 64;
    return;
  }
  final root = File.fromUri(Platform.script).parent.parent.path;
  exitCode = await prepareProject(root, pubGet: !options.contains('--no-pub'));
  if (exitCode != 0 || split < 0 || split == arguments.length - 1) return;
  exitCode = await runPreparationCommand(
    'flutter',
    arguments.sublist(split + 1),
    workingDirectory: root,
    quiet: false,
  );
}

Future<int> prepareProject(
  String root, {
  bool pubGet = true,
  bool quiet = false,
  PrepareRunner run = runPreparationCommand,
}) async {
  final commands = [
    if (pubGet) ('flutter', ['pub', 'get']),
    (Platform.resolvedExecutable, ['run', 'tool/assemble_l10n.dart']),
    (Platform.resolvedExecutable, ['run', 'intl_utils:generate']),
    (Platform.resolvedExecutable, ['run', 'build_runner', 'build']),
  ];
  for (final (executable, arguments) in commands) {
    final code = await run(
      executable,
      arguments,
      workingDirectory: root,
      quiet: quiet,
    );
    if (code != 0) return code;
  }
  return 0;
}

Future<int> runPreparationCommand(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  required bool quiet,
}) async {
  try {
    if (quiet) {
      final result = await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        runInShell: Platform.isWindows,
      );
      if (result.exitCode != 0) {
        stdout.write(result.stdout);
        stderr.write(result.stderr);
      }
      return result.exitCode;
    }
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: Platform.isWindows,
      mode: ProcessStartMode.inheritStdio,
    );
    return await process.exitCode;
  } on ProcessException catch (error) {
    stderr.writeln(error);
    return 127;
  }
}
