import 'dart:io';

Future<void> main(List<String> arguments) async {
  final root = File.fromUri(Platform.script).parent.parent.path;
  final prepare = await Process.run(Platform.resolvedExecutable, [
    'tool/mihomo.dart',
    'apply',
  ], workingDirectory: root);
  stdout.write(prepare.stdout);
  stderr.write(prepare.stderr);
  if (prepare.exitCode != 0) {
    exitCode = prepare.exitCode;
    return;
  }
  final test = await Process.run('go', [
    'test',
    if (arguments.isEmpty) './...' else ...arguments,
  ], workingDirectory: '$root${Platform.pathSeparator}core');
  stdout.write(test.stdout);
  stderr.write(test.stderr);
  exitCode = test.exitCode;
}
