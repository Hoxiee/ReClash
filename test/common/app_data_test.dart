import 'dart:io';

import 'package:drift/drift.dart';
import 'package:reclash/common/app_data.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/dashboard.dart';
import 'package:reclash/database/database.dart' as db;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

import '../helpers/app_paths.dart';
import '../helpers/preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('reclash-app-data-');
    await useAppPaths(home);
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  test('clears what a startup failure left behind without the Core', () async {
    await mockPreferences();
    await preferences.setVersion(7);
    final databaseFile = File(await appPath.databasePath)
      ..writeAsStringSync('not a database');
    final profilesDir = Directory(join(await appPath.profilesPath, '1'))
      ..createSync(recursive: true);
    final broken = db.Database(
      LazyDatabase(() async => throw const FileSystemException('corrupt')),
    );
    final previous = db.database;
    db.database = broken;
    addTearDown(() => db.database = previous);
    await expectLater(broken.profilesDao.query().get(), throwsA(anything));

    final dashboard = Directory(join(home.path, webDashboardDirectoryName))
      ..createSync();
    File(join(dashboard.path, 'index.html')).writeAsStringSync('dashboard');
    final work = Directory(join(home.path, webDashboardWorkDirectoryName))
      ..createSync();
    File(join(work.path, 'download')).writeAsStringSync('partial');
    final unrelated = File(join(home.path, 'keep'))..writeAsStringSync('keep');

    await clearAppData();

    expect(dashboard.existsSync(), isFalse);
    expect(work.existsSync(), isFalse);
    expect(unrelated.readAsStringSync(), 'keep');

    expect(await preferences.getVersion(), 0);
    expect(
      databaseFile.existsSync(),
      isFalse,
      reason:
          'a database that failed to open rethrows from close, and it is '
          'the file most likely to be why startup failed',
    );
    expect(profilesDir.parent.existsSync(), isFalse);
  });
}
