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
import 'desktop_update.dart';
import 'update.dart';

class AppUpdateRuntime {
  late final DesktopUpdater? _desktop = system.isDesktop
      ? detectDesktopUpdater()
      : null;

  /// Replaces itself in the background rather than asking the OS to install a
  /// package; a package-managed or portable desktop build has no such path.
  bool get desktop => _desktop != null;

  bool get supported => desktop || (system.isAndroid && app != null);

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

  UpdateAsset? desktopAsset(AppUpdateRelease release) =>
      _desktop?.selectAsset(release.assets, release.tag);

  String packageFileName(String tag) =>
      updateFileName(tag, suffix: _desktop?.fileSuffix ?? '.apk');

  Duration? systemIdle() => _desktop?.systemIdle();

  Future<bool> windowHidden() async => !(await windowPort?.isVisible() ?? true);

  Future<bool> onWifi() async =>
      desktop ||
      (await Connectivity().checkConnectivity()).contains(
        ConnectivityResult.wifi,
      );

  Stream<bool> get wifiChanges => desktop
      ? const Stream.empty()
      : Connectivity().onConnectivityChanged
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

  Future<bool> verify(File file, UpdateAsset asset, String version) async {
    if (!await matchesUpdateAsset(file, asset)) return false;
    if (desktop) return true;
    await app!.verifyUpdateApk(
      file.path,
      expectedVersion: version,
      expectedSha256: asset.sha256!,
    );
    return true;
  }

  Future<bool> vpnActive() async =>
      !desktop && await app!.updateInstallBlockedByVpn();

  Future<bool> installPermission() async =>
      desktop || await app!.canRequestPackageInstalls();

  Future<bool> openPermission() => app!.openUpdateInstallPermission();

  Future<ApkInstallResult> install(
    String path, {
    required String version,
    required String sha256,
    required bool automatic,
    bool relaunch = true,
  }) async {
    final desktop = _desktop;
    if (desktop == null) {
      return app!.installApk(
        path,
        expectedVersion: version,
        expectedSha256: sha256,
        automatic: automatic,
      );
    }
    await desktop.launch(
      path,
      relaunch: relaunch,
      logPath: join(dirname(path), 'install.log'),
    );
    return ApkInstallResult.started;
  }

  Future<ApkInstallStatus> installStatus() => app!.updateInstallStatus();

  Future<bool> confirmInstall() => app!.continueUpdateInstall();

  Future<String> actualInstalledVersion() => app!.updateInstalledVersion();

  AppUpdateSource? source(String id) =>
      request.updateSources.where((source) => source.id == id).firstOrNull;
}
