import 'dart:io';

import 'package:build_tool/src/options.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('loads the canonical package build configuration', () async {
    final root = await Directory.systemTemp.createTemp('build_config_test');
    addTearDown(() => root.delete(recursive: true));
    final configFile = File(
      p.join(
        root.path,
        'plugins',
        'setup',
        'buildkit',
        'build_tool',
        'build_config.yaml',
      ),
    );
    await configFile.create(recursive: true);
    await configFile.writeAsString('tags: canonical_tags\n');

    final config = BuildConfig.load(rootDir: root.path);

    expect(config.tags, 'canonical_tags');
  });
}
