import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:setup_hooks/src/options.dart';
import 'package:test/test.dart';

void main() {
  test(
    'core_version is the upstream tag the mihomo submodule is pinned to',
    () {
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

      final baseFile = File(
        p.join(root, config.coreDir, 'mihomo-patches', 'base.env'),
      );
      if (!baseFile.existsSync()) {
        markTestSkipped('core/mihomo-patches is not checked out');
        return;
      }
      final base = {
        for (final line in baseFile.readAsLinesSync())
          if (line.contains('=') && !line.trim().startsWith('#'))
            line.substring(0, line.indexOf('=')).trim(): line
                .substring(line.indexOf('=') + 1)
                .trim(),
      };
      final head = Process.runSync('git', [
        'rev-parse',
        'HEAD',
      ], workingDirectory: submodule);
      expect(head.exitCode, 0, reason: '${head.stderr}');
      expect((head.stdout as String).trim(), base['MIHOMO_COMMIT']);
    },
  );
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
