import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

import 'interface.dart';

/// Core helpers that tests substitute wholesale: both are concrete members of
/// [CoreHandlerInterface], so a mock overrides them while real cores inherit
/// the filesystem-backed implementation.
mixin CoreHandlerActions on CoreInterface {
  Future<bool> initWithGeo(int version) async {
    await _ensureHomeDir();
    await _initGeo();
    final homeDirPath = await appPath.homeDirPath;
    return init(InitParams(homeDir: homeDirPath, version: version));
  }

  Future<String> getAppliedConfigContent() async {
    return File(await appPath.configFilePath).readAsString();
  }

  Future<void> _ensureHomeDir() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }
    await system.grantHomeDirAccess(homePath);
  }

  Future<void> _initGeo() async {
    final homePath = await appPath.homeDirPath;
    const geoFileNameList = [MMDB, GEOIP, GEOSITE, ASN];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        if (await geoFile.exists()) {
          continue;
        }
        final data = await rootBundle.load('assets/data/$geoFileName');
        await geoFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
    } catch (error) {
      commonPrint.log(
        'Failed to initialize geo data: $error',
        logLevel: LogLevel.error,
      );
      rethrow;
    }
  }
}

/// Composition over the raw protocol: these run their real body even on a mock
/// (static dispatch), delegating to the mockable primitives so tests stub
/// [CoreInterface.getProxies], [CoreInterface.setupConfig] and friends.
extension CoreHandlerComposition on CoreHandlerInterface {
  Future<String> validateConfigWithData(String data) async {
    final path = await appPath.tempFilePath;
    final file = File(path);
    try {
      await file.safeWriteAsString(data);
      return await validateConfig(path);
    } finally {
      await file.safeDelete();
    }
  }

  Future<String> setupConfigWithPreload({
    required SetupParams params,
    Future<void> Function()? preloadInvoke,
  }) async {
    if (preloadInvoke == null) {
      return setupConfig(params);
    }
    if (Platform.isLinux) {
      final result = await setupConfig(params);
      if (result.isEmpty) await preloadInvoke();
      return result;
    }
    final (result, _) = await (setupConfig(params), preloadInvoke()).wait;
    return result;
  }

  Future<List<Group>> getProxiesGroups({
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String defaultTestUrl,
  }) async {
    final proxiesData = await getProxies();
    return toGroupsTask(
      ComputeGroupsState(
        proxiesData: proxiesData,
        sortType: sortType,
        delayMap: delayMap,
        selectedMap: selectedMap,
        defaultTestUrl: defaultTestUrl,
      ),
    );
  }

  Future<Map<String, dynamic>> getProfileConfig(int id) async {
    return _readConfig(await appPath.getProfilePath(id.toString()));
  }

  Future<Map<String, dynamic>> getAppliedConfig() async {
    return _readConfig(await appPath.configFilePath);
  }

  Future<Map<String, dynamic>> _readConfig(String path) async {
    final data = Map<String, dynamic>.from(await getConfig(path));
    data['rules'] = data['rule'];
    data.remove('rule');
    return data;
  }
}
