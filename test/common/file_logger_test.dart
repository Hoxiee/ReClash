import 'dart:io';

import 'package:reclash/common/storage/file_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

Future<List<File>> _logFiles(Directory logsDir) async {
  if (!await logsDir.exists()) {
    return <File>[];
  }
  return logsDir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.log'))
      .cast<File>()
      .toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late Directory logsDir;
  late File oldest;

  setUpAll(() {
    FileLogger.enabledInTests = true;
    root = Directory.systemTemp.createTempSync('file_logger_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    logsDir = Directory(join(root.path, 'logs'))..createSync(recursive: true);
    for (var i = 0; i < 10; i++) {
      final file = File(join(logsDir.path, 'ReClash_2020-01-${i + 10}.log'))
        ..writeAsStringSync('stale $i\n');
      file.setLastModifiedSync(DateTime(2020, 1, 1).add(Duration(days: i)));
      if (i == 0) {
        oldest = file;
      }
    }
  });

  tearDownAll(() {
    FileLogger.enabledInTests = false;
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('first write prunes stale files down to the retention cap', () async {
    fileLogger.log('first line');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(await oldest.exists(), isFalse);
    final remaining = await _logFiles(logsDir);
    expect(remaining.length, lessThanOrEqualTo(8));
  });

  test('logged lines land in a dated file on disk', () async {
    fileLogger.log('needle-payload');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final today = DateTime.now().toString().substring(0, 10);
    final todayFile = File(join(logsDir.path, 'ReClash_$today.log'));
    expect(await todayFile.exists(), isTrue);
    expect(await todayFile.readAsString(), contains('needle-payload'));
  });

  test('dispose flushes and closes the sink', () async {
    fileLogger.log('before dispose');
    await fileLogger.dispose();

    final today = DateTime.now().toString().substring(0, 10);
    final todayFile = File(join(logsDir.path, 'ReClash_$today.log'));
    expect(await todayFile.readAsString(), contains('before dispose'));
  });
}
