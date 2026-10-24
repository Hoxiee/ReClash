import 'dart:io';

import 'package:reclash/common/path.dart';

/// Resolves every directory [appPath] hands out to [root].
Future<void> useAppPaths(Directory root) {
  Future<Directory> resolve() async => root;
  AppPath.supportDirectory = resolve;
  AppPath.temporaryDirectory = resolve;
  AppPath.cacheDirectory = resolve;
  AppPath.downloadDirectory = resolve;
  return appPath.rebind();
}
