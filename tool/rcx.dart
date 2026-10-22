import 'dart:io';

const _usage = 'Usage: dart run tool/rcx.dart lint <profile-or-bundle.yaml>...';

Future<void> main(List<String> arguments) async {
  if (arguments.length < 2 || arguments.first != 'lint') {
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }
  final files = [
    for (final path in arguments.skip(1)) File(path).absolute.path,
  ];
  final process = await Process.start(
    'go',
    ['run', './rcx/cmd/rcxlint', ...files],
    workingDirectory: 'core',
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
