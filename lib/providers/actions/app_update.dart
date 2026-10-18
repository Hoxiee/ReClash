part of '../action.dart';

const _pendingUpdateInstallFile = 'pending-install.json';

@Riverpod(keepAlive: true)
class AppUpdateAction extends _$AppUpdateAction {
  _PendingInstallObserver? _observer;
  bool _isInstalling = false;
  bool _permissionReminderShown = false;

  @override
  void build() {
    ref.onDispose(() {
      _observer?.dispose();
      _observer = null;
    });
  }

  bool get isSupported => system.isAndroid && app != null;

  Future<void> install(AppUpdateRelease release) async {
    if (!isSupported || _isInstalling) return;
    _isInstalling = true;
    try {
      await _install(release);
    } catch (error) {
      commonPrint.log(
        'app update install failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      _reportFailure(
        error is PlatformException && error.code == 'APK_INVALID'
            ? currentAppLocalizations.updateVerifyFailed
            : currentAppLocalizations.updateInstallFailed,
      );
    } finally {
      _isInstalling = false;
    }
  }

  Future<bool> restorePendingInstall() async {
    if (!isSupported) return false;
    try {
      final directory = await _updateDirectory();
      final pending = await _readPending(directory);
      if (pending == null) {
        await removeStaleUpdateApks(directory);
        return false;
      }
      final apk = File(join(directory.path, pending.fileName));
      final asset = AndroidUpdateAsset(
        name: pending.fileName,
        url: '',
        sha256: pending.sha256,
      );
      if (!await matchesUpdateAsset(apk, asset)) {
        await _clearPending(directory);
        await apk.safeDelete();
        _reportFailure(currentAppLocalizations.updateVerifyFailed);
        return true;
      }
      if (compareVersions(globalState.packageInfo.version, pending.version) >=
          0) {
        await _clearPending(directory);
        await apk.safeDelete();
        await removeStaleUpdateApks(directory);
        return false;
      }
      if (pending.state == _PendingInstallState.awaitingPermission) {
        _armObserver(directory);
        await _resumePendingInstall(directory, pending);
      } else if (WidgetsBinding.instance.lifecycleState ==
          AppLifecycleState.resumed) {
        await _clearPending(directory);
        await removeStaleUpdateApks(directory);
        return false;
      } else {
        _armObserver(directory);
      }
      await removeStaleUpdateApks(directory, keep: {pending.fileName});
      return true;
    } catch (error) {
      commonPrint.log(
        'could not restore pending APK install: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<void> _install(AppUpdateRelease release) async {
    final asset = selectAndroidUpdateAsset(
      release.assets,
      supportedAbis: await _supportedAbis(),
    );
    if (asset == null) {
      await dialogs.openUrl(release.source.releasePage(release.tag).toString());
      return;
    }
    if (asset.sha256 == null) {
      _reportFailure(currentAppLocalizations.updateVerifyFailed);
      return;
    }
    final directory = await _updateDirectory();
    final fileName = updateApkFileName(release.tag);
    final apk = File(join(directory.path, fileName));
    final pending = _PendingUpdateInstall(
      fileName: fileName,
      version: release.tag,
      sha256: asset.sha256!,
      state: _PendingInstallState.awaitingPermission,
    );
    final reuseCached = await matchesUpdateAsset(apk, asset);
    await removeStaleUpdateApks(directory, keep: {fileName});
    if (!reuseCached) {
      await apk.safeDelete();
      if (!await _download(release.source.assetUri(asset.url), apk.path)) {
        return;
      }
      if (!await matchesUpdateAsset(apk, asset)) {
        await apk.safeDelete();
        _reportFailure(currentAppLocalizations.updateVerifyFailed);
        return;
      }
    }
    _permissionReminderShown = false;
    await _savePending(directory, pending);
    _armObserver(directory);
    await _dispatchInstall(directory, pending);
  }

  Future<bool> _download(Uri uri, String apkPath) async {
    final cancelToken = CancelToken();
    final progress = ValueNotifier<_DownloadProgress?>(null);
    NavigatorState? navigator;
    final dialog = dialogs.showCommonDialog<void>(
      dismissible: false,
      child: Builder(
        builder: (context) {
          navigator = Navigator.of(context);
          return _UpdateProgressDialog(
            progress: progress,
            onCancel: cancelToken.cancel,
          );
        },
      ),
    );
    String? error;
    try {
      error = await request.downloadUpdateFile(
        uri,
        apkPath,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          progress.value = _DownloadProgress(received: received, total: total);
        },
      );
    } finally {
      if (navigator?.canPop() == true) navigator!.pop();
      await dialog;
      progress.dispose();
    }
    if (error == null) return true;
    if (error.isNotEmpty) {
      _reportFailure(currentAppLocalizations.updateDownloadFailed);
    }
    return false;
  }

  Future<void> _dispatchInstall(
    Directory directory,
    _PendingUpdateInstall pending,
  ) async {
    final install = app;
    if (install == null) return;
    final state = await install.canRequestPackageInstalls()
        ? _PendingInstallState.waitingForInstaller
        : _PendingInstallState.awaitingPermission;
    final next = pending.copyWith(state: state);
    await _savePending(directory, next);
    final result = await install.installApk(
      join(directory.path, pending.fileName),
      expectedVersion: pending.version,
    );
    if (result == ApkInstallResult.permissionRequired) {
      await _savePending(
        directory,
        pending.copyWith(state: _PendingInstallState.awaitingPermission),
      );
      _armObserver(directory);
      return;
    }
    _armObserver(directory);
  }

  Future<void> _resumePendingInstall(
    Directory directory,
    _PendingUpdateInstall pending,
  ) async {
    if (_isInstalling) return;
    _isInstalling = true;
    try {
      if (await app?.canRequestPackageInstalls() != true) {
        if (!_permissionReminderShown) {
          _permissionReminderShown = true;
          _reportFailure(currentAppLocalizations.updatePermissionRequired);
        }
        return;
      }
      _permissionReminderShown = false;
      await _dispatchInstall(directory, pending);
    } catch (error) {
      commonPrint.log(
        'resume pending APK install failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      _reportFailure(currentAppLocalizations.updateInstallFailed);
    } finally {
      _isInstalling = false;
    }
  }

  void _armObserver(Directory directory) {
    _observer?.dispose();
    _observer = _PendingInstallObserver(() async {
      if (_isInstalling) return;
      final pending = await _readPending(directory);
      if (pending == null) {
        _observer?.dispose();
        _observer = null;
        return;
      }
      if (pending.state == _PendingInstallState.awaitingPermission) {
        await _resumePendingInstall(directory, pending);
        return;
      }
      try {
        final installed = await PackageInfo.fromPlatform();
        if (compareVersions(installed.version, pending.version) >= 0) {
          await _clearPending(directory);
          await File(join(directory.path, pending.fileName)).safeDelete();
          _observer?.dispose();
          _observer = null;
          await removeStaleUpdateApks(directory);
        } else {
          await _clearPending(directory);
          _observer?.dispose();
          _observer = null;
        }
      } catch (error) {
        commonPrint.log(
          'could not verify installed app version: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
      }
    })..arm();
  }

  Future<Directory> _updateDirectory() async {
    final directory = Directory(join(await appPath.homeDirPath, 'app-updates'));
    await directory.create(recursive: true);
    return directory;
  }

  Future<_PendingUpdateInstall?> _readPending(Directory directory) async {
    final file = File(join(directory.path, _pendingUpdateInstallFile));
    try {
      if (!await file.exists()) return null;
      return _PendingUpdateInstall.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
    } on Object catch (error) {
      commonPrint.log(
        'pending update state is invalid: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      await file.safeDelete();
      return null;
    }
  }

  Future<void> _savePending(
    Directory directory,
    _PendingUpdateInstall pending,
  ) async {
    final file = File(join(directory.path, _pendingUpdateInstallFile));
    await file.writeAsString(jsonEncode(pending.toJson()), flush: true);
  }

  Future<void> _clearPending(Directory directory) async {
    await File(join(directory.path, _pendingUpdateInstallFile)).safeDelete();
  }

  Future<List<String>> _supportedAbis() async {
    try {
      return (await DeviceInfoPlugin().androidInfo).supportedAbis;
    } catch (error) {
      commonPrint.log(
        'supported ABIs unavailable: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return const [];
    }
  }

  void _reportFailure(String message) {
    unawaited(
      dialogs.showMessage(
        title: currentAppLocalizations.checkUpdate,
        message: TextSpan(text: message),
        cancelable: false,
      ),
    );
  }
}

class _DownloadProgress {
  const _DownloadProgress({required this.received, required this.total});

  final int received;
  final int total;

  double? get value => total > 0 ? received / total : null;

  String get show {
    final receivedShow = received.traffic.show;
    return total > 0 ? '$receivedShow / ${total.traffic.show}' : receivedShow;
  }
}

class _UpdateProgressDialog extends StatelessWidget {
  const _UpdateProgressDialog({required this.progress, required this.onCancel});

  final ValueNotifier<_DownloadProgress?> progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<_DownloadProgress?>(
        valueListenable: progress,
        builder: (context, value, _) => CommonDialog(
          title: context.appLocalizations.downloadingUpdate,
          actions: [
            TextButton(
              onPressed: onCancel,
              child: Text(context.appLocalizations.cancel),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value?.value),
              const SizedBox(height: 12),
              Text(
                value?.show ?? '',
                style: AppTextStyle.subheadline.of(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

enum _PendingInstallState { awaitingPermission, waitingForInstaller }

class _PendingUpdateInstall {
  const _PendingUpdateInstall({
    required this.fileName,
    required this.version,
    required this.sha256,
    required this.state,
  });

  final String fileName;
  final String version;
  final String sha256;
  final _PendingInstallState state;

  _PendingUpdateInstall copyWith({_PendingInstallState? state}) =>
      _PendingUpdateInstall(
        fileName: fileName,
        version: version,
        sha256: sha256,
        state: state ?? this.state,
      );

  Map<String, Object> toJson() => {
    'fileName': fileName,
    'version': version,
    'sha256': sha256,
    'state': state.name,
  };

  factory _PendingUpdateInstall.fromJson(Map<String, dynamic> json) {
    final fileName = json['fileName'];
    final version = json['version'];
    final sha256 = json['sha256'];
    final state = json['state'];
    if (fileName is! String ||
        !RegExp(r'^update-[A-Za-z0-9._-]+\.apk$').hasMatch(fileName) ||
        version is! String ||
        tryParseAppVersion(version) == null ||
        sha256 is! String ||
        parseAssetSha256('sha256:$sha256') == null ||
        state is! String) {
      throw const FormatException('Invalid pending update install');
    }
    return _PendingUpdateInstall(
      fileName: fileName,
      version: version,
      sha256: sha256,
      state: _PendingInstallState.values.byName(state),
    );
  }
}

class _PendingInstallObserver with WidgetsBindingObserver {
  _PendingInstallObserver(this._onResume);

  final Future<void> Function() _onResume;
  bool _armed = false;

  void arm() {
    if (_armed) return;
    _armed = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    if (!_armed) return;
    _armed = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _armed) {
      unawaited(_onResume());
    }
  }
}
