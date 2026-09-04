part of '../action.dart';

@Riverpod(keepAlive: true)
class AppUpdateAction extends _$AppUpdateAction {
  _ApkInstallRetry? _installRetry;
  bool _isInstalling = false;

  @override
  void build() {
    ref.onDispose(() {
      _installRetry?.dispose();
      _installRetry = null;
    });
  }

  bool get isSupported => system.isAndroid && app != null;

  Future<void> install(Map<String, dynamic> release) async {
    if (_isInstalling) return;
    _isInstalling = true;
    try {
      await _install(release);
    } finally {
      _isInstalling = false;
    }
  }

  Future<void> _install(Map<String, dynamic> release) async {
    final asset = selectAndroidUpdateAsset(
      release['assets'],
      supportedAbis: await _supportedAbis(),
    );
    if (asset == null) {
      await _openReleasePage();
      return;
    }
    final apkPath = join(
      await appPath.homeDirPath,
      updateApkFileName(release['tag_name'] as String? ?? ''),
    );
    final apkFile = File(apkPath);
    if (!await matchesUpdateAsset(apkFile, asset)) {
      if (!await _download(asset, apkPath)) {
        return;
      }
      if (!await matchesUpdateAsset(apkFile, asset)) {
        await apkFile.safeDelete();
        _reportFailure(currentAppLocalizations.updateVerifyFailed);
        return;
      }
    }
    await removeStaleUpdateApks(apkPath);
    if (await app?.installApk(apkPath) == true) {
      return;
    }
    // The grant screen replaced this app, so the install has to be re-fired on
    // resume; the APK is already on disk, so that retry is just the intent.
    _installRetry?.dispose();
    _installRetry = _ApkInstallRetry(apkPath)..arm();
  }

  Future<bool> _download(AndroidUpdateAsset asset, String apkPath) async {
    final cancelToken = CancelToken();
    final progress = ValueNotifier<_DownloadProgress?>(null);
    NavigatorState? navigator;
    final dialog = dialogs.showCommonDialog<void>(
      dismissible: false,
      child: Builder(
        builder: (context) {
          // The dialog is closed from here rather than by the user, so its own
          // navigator has to be captured while the route is on screen.
          navigator = Navigator.of(context);
          return _UpdateProgressDialog(
            progress: progress,
            onCancel: cancelToken.cancel,
          );
        },
      ),
    );
    final error = await request.downloadFile(
      asset.url,
      apkPath,
      cancelToken: cancelToken,
      onProgress: (received, total) {
        progress.value = _DownloadProgress(received: received, total: total);
      },
    );
    if (navigator?.canPop() == true) {
      navigator!.pop();
    }
    await dialog;
    progress.dispose();
    if (error == null) {
      return true;
    }
    // An empty message is the user's own cancellation; nothing to report.
    if (error.isNotEmpty) {
      _reportFailure(currentAppLocalizations.updateDownloadFailed);
    }
    return false;
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

  Future<List<String>> _supportedAbis() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.supportedAbis;
    } catch (error) {
      commonPrint.log(
        'supportedAbis unavailable: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return const [];
    }
  }

  Future<void> _openReleasePage() async {
    await launchUrl(
      Uri.parse('https://github.com/$repository/releases/latest'),
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_DownloadProgress?>(
      valueListenable: progress,
      builder: (context, value, _) {
        return CommonDialog(
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
              LinearProgressIndicator(minHeight: 4, value: value?.value),
              const SizedBox(height: 12),
              Text(
                value?.show ?? '',
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The unknown-sources grant screen tears down the original flow, so the
/// install intent is fired once more when the app comes back with the grant.
class _ApkInstallRetry with WidgetsBindingObserver {
  _ApkInstallRetry(this._apkPath);

  final String _apkPath;
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
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed || !_armed) return;
    // One shot: retrying without the grant would bounce the user straight back
    // into settings, so a refusal waits for the next explicit check.
    dispose();
    if (await app?.canRequestPackageInstalls() != true) return;
    await app?.installApk(_apkPath);
  }
}
