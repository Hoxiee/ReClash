import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/options.dart';
import 'package:test/test.dart';

void main() {
  test('core_version is the upstream tag the mihomo fork is based on', () {
    final root = p.normalize(p.join(Directory.current.path, '../../..'));
    final config = BuildConfig.load(rootDir: root);
    final submodule = p.join(root, config.coreDir, 'mihomo');
    // Git searches upward for a repository, so an unchecked-out submodule
    // answers with the tag of the enclosing checkout instead of failing.
    if (!_isRepositoryRoot(submodule)) {
      markTestSkipped('core/mihomo is not checked out');
      return;
    }
    final describe = Process.runSync('git', [
      'describe',
      '--tags',
      '--abbrev=0',
    ], workingDirectory: submodule);
    if (describe.exitCode != 0) {
      markTestSkipped('core/mihomo has no tag history: ${describe.stderr}');
      return;
    }
    expect(config.coreVersion, (describe.stdout as String).trim());
  });
}

bool _isRepositoryRoot(String directory) {
  final toplevel = Process.runSync('git', [
    'rev-parse',
    '--show-toplevel',
  ], workingDirectory: directory);
  if (toplevel.exitCode != 0) return false;
  final reported = (toplevel.stdout as String).trim();
  if (reported.isEmpty) return false;
  return p.equals(p.normalize(Directory(reported).absolute.path), directory);
}
