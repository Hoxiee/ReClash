import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/state.dart';
import 'package:reclash/enum/enum.dart';

import 'common.dart';
import 'update.dart';

class AppUpdateRuntime {
  bool get supported => system.isAndroid && app != null;

  String get installedVersion => globalState.packageInfo.version;

  Future<AppUpdateRelease?> check(UpdateChannel channel) =>
      request.checkForUpdate(channel: channel);

  Future<Directory> directory() async {
    final value = Directory(join(await appPath.homeDirPath, 'app-updates'));
    await value.create(recursive: true);
    return value;
  }

  Future<bool> saveConfig(Config config) => preferences.saveConfig(config);

  Future<List<String>> supportedAbis() async =>
      (await DeviceInfoPlugin().androidInfo).supportedAbis;

  Future<bool> onWifi() async => (await Connectivity().checkConnectivity())
      .contains(ConnectivityResult.wifi);

  Stream<bool> get wifiChanges => Connectivity().onConnectivityChanged
      .map((results) => results.contains(ConnectivityResult.wifi))
      .distinct();

  Stream<ApkInstallStatus> get installChanges =>
      app?.updateInstallChanges ?? const Stream.empty();

  Future<String?> download(
    Uri uri,
    String path, {
    required CancelToken cancelToken,
    required ProgressCallback onProgress,
    required String sha256,
    int? size,
  }) => request.downloadUpdateFile(
    uri,
    path,
    cancelToken: cancelToken,
    onProgress: onProgress,
    resume: true,
    expectedSha256: sha256,
    expectedSize: size,
  );

  Future<bool> verify(
    File file,
    AndroidUpdateAsset asset,
    String version,
  ) async {
    if (!await matchesUpdateAsset(file, asset)) return false;
    await app!.verifyUpdateApk(
      file.path,
      expectedVersion: version,
      expectedSha256: asset.sha256!,
    );
    return true;
  }

  Future<bool> vpnActive() => app!.updateInstallBlockedByVpn();

  Future<bool> installPermission() => app!.canRequestPackageInstalls();

  Future<bool> openPermission() => app!.openUpdateInstallPermission();

  Future<ApkInstallResult> install(
    String path, {
    required String version,
    required String sha256,
    required bool automatic,
  }) => app!.installApk(
    path,
    expectedVersion: version,
    expectedSha256: sha256,
    automatic: automatic,
  );

  Future<ApkInstallStatus> installStatus() => app!.updateInstallStatus();

  Future<bool> confirmInstall() => app!.continueUpdateInstall();

  Future<String> actualInstalledVersion() => app!.updateInstalledVersion();

  AppUpdateSource? source(String id) =>
      request.updateSources.where((source) => source.id == id).firstOrNull;
}
