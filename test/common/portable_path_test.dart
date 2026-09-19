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
  Future<String?> getTemporaryPath() async => join(root, 'os-temp');

  @override
  Future<String?> getApplicationSupportPath() async => join(root, 'os-support');

  @override
  Future<String?> getApplicationCachePath() async => join(root, 'os-cache');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('portable_path_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  tearDown(() {
    AppPath.executableDirectory = () => dirname(Platform.resolvedExecutable);
  });

  test('isPortableModeFor is true only when a config dir sits by the exe', () {
    final withConfig = Directory(join(root.path, 'with-config'))..createSync();
    Directory(join(withConfig.path, 'config')).createSync();
    final withoutConfig = Directory(join(root.path, 'plain'))..createSync();

    expect(system.isDesktop, isTrue);
    expect(isPortableModeFor(withConfig.path), isTrue);
    expect(isPortableModeFor(withoutConfig.path), isFalse);
  });

  test('portable base routes data, temp and cache under config/', () async {
    final exeDir = Directory(join(root.path, 'usb'))..createSync();
    Directory(join(exeDir.path, 'config')).createSync();
    AppPath.executableDirectory = () => exeDir.path;
    appPath.dataDir = Completer<Directory>();
    appPath.tempDir = Completer<Directory>();
    appPath.cacheDir = Completer<Directory>();

    await appPath.reinitDirsForTesting();

    final configDir = join(exeDir.path, 'config');
    expect(await appPath.homeDirPath, configDir);
    expect(await appPath.databasePath, join(configDir, 'database.sqlite'));
    expect(
      await appPath.sharedPreferencesPath,
      join(configDir, 'shared_preferences.json'),
    );
    expect(await appPath.tempPath, join(configDir, 'tmp'));
    expect(Directory(join(configDir, 'tmp')).existsSync(), isTrue);
    expect(Directory(join(configDir, '.cache')).existsSync(), isTrue);
  });

  test('non-portable base falls back to the OS support directory', () async {
    final exeDir = Directory(join(root.path, 'installed'))..createSync();
    AppPath.executableDirectory = () => exeDir.path;
    appPath.dataDir = Completer<Directory>();
    appPath.tempDir = Completer<Directory>();
    appPath.cacheDir = Completer<Directory>();

    await appPath.reinitDirsForTesting();

    expect(await appPath.homeDirPath, join(root.path, 'os-support'));
    expect(await appPath.tempPath, join(root.path, 'os-temp'));
  });
}
