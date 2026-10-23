import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/web_dashboard/installation.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:path/path.dart' as p;

Future<void> clearAppData({bool all = false}) async {
  await preferences.clearPreferences(preventWrites: all);
  if (!all) await clearWebDashboardFiles(await appPath.homeDirPath);
  try {
    await database.close();
  } catch (error) {
    // Drift rethrows a failed open from close; that file still has to go.
    commonPrint.log(
      'close database failed: $error',
      logLevel: LogLevel.warning,
    );
  }
  if (!all) await File(await appPath.databasePath).safeDelete(recursive: true);
  if (all) {
    final roots = {
      await appPath.homeDirPath,
      // Desktop temporary storage may be the shared system /tmp directory.
      if (!system.isDesktop) await appPath.tempPath,
      (await appPath.cacheDir.future).path,
    };
    for (final root in roots) {
      await _clearExceptBackups(Directory(root));
    }
  } else {
    await Directory(await appPath.profilesPath).safeDelete(recursive: true);
  }
}

Future<void> _clearExceptBackups(Directory directory) async {
  if (!await directory.exists()) return;
  await for (final entity in directory.list(followLinks: false)) {
    if (entity is Directory) {
      await _clearExceptBackups(entity);
      if (await entity.list(followLinks: false).isEmpty) {
        await entity.delete();
      }
    } else if (p.extension(entity.path).toLowerCase() != '.zip' &&
        p.basename(entity.path) != 'ReClash.lock') {
      await entity.delete();
    }
  }
}
