import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
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

bool _isActuallyWritable(String path) {
  try {
    final probe = File(join(path, '.reclash-test-probe'));
    probe.writeAsStringSync('');
    probe.deleteSync();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('core_path_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  setUp(() {
    appPath.debugResetCoreOverride();
    appPath.dataDir = Completer<Directory>();
  });

  tearDown(() {
    AppPath.executableDirectory = () => dirname(Platform.resolvedExecutable);
    // Restore writability so tearDownAll can delete the tree.
    for (final entry in root.listSync()) {
      if (entry is Directory) {
        Process.runSync('chmod', ['755', entry.path]);
      }
    }
  });

  test('resolves the gate with no bundled core and no override', () async {
    AppPath.executableDirectory = () => root.path;

    await appPath.ensureWritableCore();
    await appPath.corePathReady.timeout(const Duration(seconds: 2));

    expect(appPath.corePath, join(root.path, 'ReClashCore'));
  });

  test('a writable bundle keeps the bundled path', () async {
    final bundle = Directory(join(root.path, 'bundle-writable'))..createSync();
    File(join(bundle.path, 'ReClashCore')).writeAsStringSync('core-binary');
    AppPath.executableDirectory = () => bundle.path;

    await appPath.ensureWritableCore();
    await appPath.corePathReady;

    expect(appPath.corePath, join(bundle.path, 'ReClashCore'));
  });

  test('a read-only bundle copies the core into the data dir', () async {
    final bundle = Directory(join(root.path, 'bundle-readonly'))..createSync();
    File(join(bundle.path, 'ReClashCore')).writeAsStringSync('core-binary');
    final data = Directory(join(root.path, 'data-readonly'))..createSync();
    appPath.dataDir.complete(data);
    await Process.run('chmod', ['555', bundle.path]);
    AppPath.executableDirectory = () => bundle.path;
    if (_isActuallyWritable(bundle.path)) {
      // Root test runners bypass directory permissions.
      return;
    }

    await appPath.ensureWritableCore();
    await appPath.corePathReady;

    expect(appPath.corePath, join(data.path, 'ReClashCore'));
    expect(
      File(join(data.path, 'ReClashCore')).readAsStringSync(),
      'core-binary',
    );
  });

  test('a matching copy is kept, preserving its setuid mode', () async {
    final bundle = Directory(join(root.path, 'bundle-match'))..createSync();
    File(join(bundle.path, 'ReClashCore')).writeAsStringSync('core-binary');
    final data = Directory(join(root.path, 'data-match'))..createSync();
    appPath.dataDir.complete(data);
    await Process.run('chmod', ['555', bundle.path]);
    AppPath.executableDirectory = () => bundle.path;
    if (_isActuallyWritable(bundle.path)) {
      return;
    }

    await appPath.ensureWritableCore();
    final target = File(join(data.path, 'ReClashCore'));
    await Process.run('chmod', ['4755', target.path]);

    await appPath.ensureWritableCore();

    final mode = await Process.run('stat', ['-c', '%a', target.path]);
    expect(mode.stdout.toString().trim(), '4755');
  });

  test('a missing data dir resolves the gate without an override', () async {
    final bundle = Directory(join(root.path, 'bundle-nodata'))..createSync();
    File(join(bundle.path, 'ReClashCore')).writeAsStringSync('core-binary');
    appPath.dataDir.completeError(Exception('no app support dir'));
    // ignore: unawaited_futures
    appPath.dataDir.future.catchError((_) => Directory.systemTemp);
    await Process.run('chmod', ['555', bundle.path]);
    AppPath.executableDirectory = () => bundle.path;
    if (_isActuallyWritable(bundle.path)) {
      return;
    }

    await appPath.ensureWritableCore();

    await appPath.corePathReady.timeout(const Duration(seconds: 2));
    expect(appPath.corePath, join(bundle.path, 'ReClashCore'));
  });
}
