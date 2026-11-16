import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/options.dart';
import 'package:test/test.dart';

void main() {
  test('core_version is the upstream tag the mihomo fork is based on', () {
    final root = p.normalize(p.join(Directory.current.path, '../../..'));
    final config = BuildConfig.load(rootDir: root);
    final describe = Process.runSync('git', [
      'describe',
      '--tags',
      '--abbrev=0',
    ], workingDirectory: p.join(root, config.coreDir, 'mihomo'));
    if (describe.exitCode != 0) {
      markTestSkipped('core/mihomo has no tag history: ${describe.stderr}');
      return;
    }
    expect(config.coreVersion, (describe.stdout as String).trim());
  });
}
