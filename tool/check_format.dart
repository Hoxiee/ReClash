import 'dart:io';

bool isHandwrittenDart(String path) =>
    path.endsWith('.dart') &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !path.contains('/generated/') &&
    !path.contains('/build/') &&
    !path.startsWith('upstream_l10n/') &&
    !path.startsWith('lib/l10n/') &&
    !path.contains('frb_generated');

void main() {
  final listed = Process.runSync('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '-z',
    '--',
    'lib',
    'test',
    'tool',
    'plugins',
    'setup.dart',
  ]);
  if (listed.exitCode != 0) {
    stderr.write(listed.stderr);
    exitCode = listed.exitCode;
    return;
  }
  final paths =
      (listed.stdout as String)
          .split('\u0000')
          .where(isHandwrittenDart)
          .where((path) => File(path).existsSync())
          .toSet()
          .toList()
        ..sort();
  for (var i = 0; i < paths.length; i += 60) {
    final result = Process.runSync(Platform.resolvedExecutable, [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...paths.skip(i).take(60),
    ]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) exitCode = result.exitCode;
  }
}
