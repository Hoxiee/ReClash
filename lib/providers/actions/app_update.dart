part of '../action.dart';

const _pendingUpdateInstallFile = 'pending-install.json';
const _updateCheckInterval = Duration(hours: 6);

@Riverpod(keepAlive: true)
class AppUpdateAction extends _$AppUpdateAction with WidgetsBindingObserver {
  CancelToken? _downloadToken;
  Future<void>? _downloadTask;
  Future<void> _persistTail = Future.value();
  Future<void> _statusTail = Future.value();
  StreamSubscription<bool>? _wifiSubscription;
  StreamSubscription<ApkInstallStatus>? _installSubscription;
  Timer? _checkTimer;
  _PendingUpdate? _pending;
  bool _installing = false;
  bool _checking = false;
  bool _cancelling = false;
  bool _restoring = false;
  bool _openingPermission = false;
  bool _restored = false;
  bool _permissionOpened = false;
  bool _observerAttached = false;
  int _revision = 0;

  AppUpdateRuntime get _runtime => ref.read(appUpdateRuntimeProvider);

  bool get isSupported => _runtime.supported;

  @override
  AppUpdateState build() {
    ref.listen(initProvider, (_, ready) {
      if (ready) unawaited(Future<void>.microtask(_afterReady));
    }, fireImmediately: true);
    ref.listen(appSettingProvider, (previous, next) {
      if (previous?.autoDownloadUpdate != next.autoDownloadUpdate ||
          previous?.autoInstallUpdate != next.autoInstallUpdate ||
          previous?.autoCheckUpdate != next.autoCheckUpdate) {
        unawaited(_applyPolicy());
      }
    });
    ref.listen(isStartProvider, (_, running) {
      if (!running) unawaited(_tryAutomaticInstall());
    });
    ref.onDispose(() {
      _revision++;
      _downloadToken?.cancel();
      unawaited(_wifiSubscription?.cancel());
      unawaited(_installSubscription?.cancel());
      _checkTimer?.cancel();
      if (_observerAttached) WidgetsBinding.instance.removeObserver(this);
    });
    return const AppUpdateState();
  }

  Future<void> _afterReady() async {
    if (!ref.mounted || _restoring) return;
    _checkTimer ??= Timer.periodic(_updateCheckInterval, (_) {
      if (ref.mounted && ref.read(appSettingProvider).autoCheckUpdate) {
        unawaited(check(automatic: true));
      }
    });
    await _applyPolicy();
    if (_permissionOpened) await _onResume();
  }

  Future<void> check({bool automatic = false}) async {
    if (_checking ||
        _restoring ||
        state.busy ||
        _installing ||
        (_pending != null && state.hasUpdate)) {
      return;
    }
    final setting = ref.read(appSettingProvider);
    if (automatic && !setting.autoCheckUpdate) return;
    _checking = true;
    final revision = ++_revision;
    if (!state.hasUpdate) {
      state = const AppUpdateState(phase: UpdatePhase.checking);
    }
    try {
      final release = await _runtime.check(
        effectiveUpdateChannel(
          configured: setting.updateChannel,
          isPreBuild: globalState.isPre,
        ),
      );
      if (!_current(revision)) return;
      if (release == null) {
        if (!state.hasUpdate) {
          state = AppUpdateState(
            phase: automatic ? UpdatePhase.idle : UpdatePhase.upToDate,
          );
        }
        return;
      }
      await offer(release, automatic: automatic);
    } catch (error) {
      commonPrint.log(
        'update check failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      if (_current(revision) && !state.hasUpdate) {
        state = AppUpdateState(
          phase: automatic ? UpdatePhase.idle : UpdatePhase.checkFailed,
        );
      }
    } finally {
      _checking = false;
    }
  }

  Future<void> offer(AppUpdateRelease release, {bool automatic = false}) async {
    if (state.release?.tag == release.tag && state.hasUpdate) {
      if (automatic) await _applyPolicy();
      return;
    }
    if (_restoring ||
        _cancelling ||
        (state.busy && state.phase != UpdatePhase.checking) ||
        _installing ||
        _downloadTask != null ||
        (_pending != null && state.hasUpdate)) {
      return;
    }
    final revision = ++_revision;
    AndroidUpdateAsset? asset;
    if (isSupported) {
      try {
        asset = selectAndroidUpdateAsset(
          release.assets,
          supportedAbis: await _runtime.supportedAbis(),
        );
      } catch (error) {
        commonPrint.log(
          'update ABI selection failed: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
        asset = selectAndroidUpdateAsset(
          release.assets,
          supportedAbis: const [],
        );
      }
    }
    if (!ref.mounted || revision != _revision) return;
    _pending = null;
    _permissionOpened = false;
    state = AppUpdateState(
      phase: UpdatePhase.offered,
      release: release,
      asset: asset,
      total: asset?.size ?? 0,
    );
    await _applyPolicy();
  }

  bool _current(int revision) => ref.mounted && revision == _revision;

  Future<bool> savePreferences({
    required bool check,
    required bool preload,
    required bool install,
    required UpdateChannel channel,
  }) async {
    final settings = ref
        .read(appSettingProvider)
        .copyWith(
          autoCheckUpdate: check,
          autoDownloadUpdate: preload,
          autoInstallUpdate: install,
          updateChannel: channel,
        );
    final saved = await _runtime.saveConfig(
      ref.read(configProvider).copyWith(appSettingProps: settings),
    );
    if (saved && ref.mounted) {
      ref
          .read(appSettingProvider.notifier)
          .update(
            (value) => value.copyWith(
              autoCheckUpdate: check,
              autoDownloadUpdate: preload,
              autoInstallUpdate: install,
              updateChannel: channel,
            ),
          );
    }
    return saved;
  }

  void noUpdates() {
    if (!state.hasUpdate && !state.busy) {
      state = const AppUpdateState(phase: UpdatePhase.upToDate);
    }
  }

  Future<void> download({bool automatic = false, bool restart = false}) {
    final task = _downloadTask;
    if (task != null) return task;
    if (!isSupported ||
        state.release == null ||
        _installing ||
        _restoring ||
        _cancelling ||
        state.verified) {
      return Future.value();
    }
    final future = _download(automatic: automatic, restart: restart);
    _downloadTask = future;
    return future.whenComplete(() {
      if (identical(_downloadTask, future)) {
        _downloadTask = null;
        if (ref.mounted &&
            state.phase == UpdatePhase.paused &&
            state.automaticDownload) {
          unawaited(_applyPolicy());
        }
      }
    });
  }

  Future<void> _download({
    required bool automatic,
    required bool restart,
  }) async {
    final release = state.release!;
    final asset = state.asset;
    if (asset?.sha256 == null) {
      state = state.copyWith(phase: UpdatePhase.verifyFailed, verified: false);
      return;
    }
    final revision = _revision;
    final cancel = CancelToken();
    _downloadToken = cancel;
    state = state.copyWith(
      phase: UpdatePhase.downloading,
      verified: false,
      automaticDownload: automatic,
      bytesPerSecond: 0,
    );
    try {
      final directory = await _runtime.directory();
      final name = updateApkFileName(release.tag);
      final file = File(join(directory.path, name));
      if (restart) {
        await file.safeDelete();
        await File('${file.path}.tmp').safeDelete();
        await File('${file.path}.tmp.json').safeDelete();
      }
      _pending = _PendingUpdate(
        release: release,
        asset: asset!,
        fileName: name,
        phase: UpdatePhase.downloading,
        automaticDownload: automatic,
      );
      await _savePending(directory);
      if (!_current(revision)) return;
      await removeStaleUpdateApks(directory, keep: {name}, keepPartial: {name});
      if (!_current(revision)) return;
      if (cancel.isCancelled) {
        await _recordPhase(directory);
        return;
      }
      if (!await matchesUpdateAsset(file, asset)) {
        final watch = Stopwatch()..start();
        var lastEmit = Duration.zero;
        var lastBytes = 0;
        var emitted = false;
        final error = await _runtime.download(
          release.source.assetUri(asset.url),
          file.path,
          cancelToken: cancel,
          sha256: asset.sha256!,
          size: asset.size,
          onProgress: (received, total) {
            if (!ref.mounted || revision != _revision || cancel.isCancelled) {
              return;
            }
            final elapsed = watch.elapsed;
            if (emitted &&
                elapsed - lastEmit < const Duration(milliseconds: 160) &&
                received < total) {
              return;
            }
            final seconds = (elapsed - lastEmit).inMicroseconds / 1000000;
            final speed = seconds > 0 && lastBytes > 0
                ? (received - lastBytes) / seconds
                : 0.0;
            lastEmit = elapsed;
            lastBytes = received;
            emitted = true;
            state = state.copyWith(
              received: received,
              total: total > 0 ? total : asset.size,
              bytesPerSecond: speed,
            );
          },
        );
        if (!ref.mounted || revision != _revision) return;
        if (cancel.isCancelled || error == '') {
          state = state.copyWith(phase: UpdatePhase.paused, bytesPerSecond: 0);
          await _recordPhase(directory);
          return;
        }
        if (error != null) {
          state = state.copyWith(
            phase: UpdatePhase.downloadFailed,
            bytesPerSecond: 0,
          );
          await _recordPhase(directory);
          return;
        }
      }
      if (!_current(revision)) return;
      if (cancel.isCancelled) {
        await _recordPhase(directory);
        return;
      }
      state = state.copyWith(phase: UpdatePhase.verifying, bytesPerSecond: 0);
      await _recordPhase(directory);
      final verified = await _runtime.verify(file, asset, release.tag);
      if (!_current(revision)) return;
      if (!verified) {
        await file.safeDelete();
        state = state.copyWith(
          phase: UpdatePhase.verifyFailed,
          verified: false,
        );
        await _recordPhase(directory);
        return;
      }
      final length = await file.length();
      if (!_current(revision)) return;
      state = state.copyWith(
        phase: UpdatePhase.ready,
        verified: true,
        received: length,
        total: length,
      );
      await _recordPhase(directory);
      _attachObservers();
      await _tryAutomaticInstall();
    } catch (error) {
      if (!ref.mounted || revision != _revision) return;
      commonPrint.log(
        'update preparation failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      state = state.copyWith(
        phase:
            error is UpdateDownloadVerificationException ||
                error is PlatformException && error.code == 'APK_INVALID'
            ? UpdatePhase.verifyFailed
            : UpdatePhase.downloadFailed,
        verified: false,
        bytesPerSecond: 0,
      );
      try {
        await _recordPhase(await _runtime.directory());
      } catch (error) {
        commonPrint.log('update recovery save failed: ${compactError(error)}');
      }
    } finally {
      if (identical(_downloadToken, cancel)) _downloadToken = null;
    }
  }

  void pause({bool forWifi = false}) {
    if (state.phase != UpdatePhase.downloading) return;
    _downloadToken?.cancel();
    state = state.copyWith(
      phase: UpdatePhase.paused,
      bytesPerSecond: 0,
      automaticDownload: forWifi && state.automaticDownload,
    );
  }

  Future<void> cancelDownload() async {
    if (_cancelling ||
        _installing ||
        state.busy && state.phase != UpdatePhase.downloading) {
      return;
    }
    _cancelling = true;
    try {
      _revision++;
      _downloadToken?.cancel();
      await _downloadTask;
      _downloadTask = null;
      final pending = _pending;
      _pending = null;
      if (pending != null) {
        final directory = await _runtime.directory();
        await _persistTail;
        await File(
          join(directory.path, _pendingUpdateInstallFile),
        ).safeDelete();
        final path = join(directory.path, pending.fileName);
        await File('$path.tmp').safeDelete();
        await File('$path.tmp.json').safeDelete();
        await File(path).safeDelete();
      }
      if (ref.mounted) {
        state = state.copyWith(
          phase: UpdatePhase.offered,
          received: 0,
          bytesPerSecond: 0,
          verified: false,
          automaticDownload: false,
        );
      }
    } catch (error) {
      commonPrint.log('update cancellation failed: ${compactError(error)}');
      if (ref.mounted) {
        state = state.copyWith(phase: UpdatePhase.downloadFailed);
      }
    } finally {
      _cancelling = false;
    }
  }

  Future<void> install(AppUpdateRelease release) async {
    await offer(release);
    if (!state.verified) await download();
    if (state.phase == UpdatePhase.ready) await installNow();
  }

  Future<void> installNow({
    bool disconnectVpn = false,
    bool automatic = false,
  }) async {
    if (!isSupported || !state.verified || _pending == null || _installing) {
      return;
    }
    if (automatic && !_automaticAllowed) return;
    _installing = true;
    final revision = _revision;
    try {
      if (ref.read(isStartProvider) || await _runtime.vpnActive()) {
        if (!disconnectVpn || automatic) {
          state = state.copyWith(phase: UpdatePhase.vpnActive);
          return;
        }
        final common = ref.read(commonActionProvider.notifier);
        final stopping = common.setRunning(false);
        final stopRevision = common._toggleRequestRevision;
        await stopping;
        if (!_current(revision)) return;
        if (common._toggleRequestRevision != stopRevision) {
          state = state.copyWith(phase: UpdatePhase.vpnActive);
          return;
        }
        final stopWait = Stopwatch()..start();
        while (await _runtime.vpnActive()) {
          if (!ref.mounted || revision != _revision) return;
          if (stopWait.elapsed > const Duration(seconds: 8) ||
              common._toggleRequestRevision != stopRevision) {
            state = state.copyWith(phase: UpdatePhase.vpnActive);
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
      }
      if (!ref.mounted || revision != _revision) return;
      if (automatic && !_automaticAllowed) return;
      final directory = await _runtime.directory();
      if (!_current(revision)) return;
      final pending = _pending!;
      // Hashing the package takes seconds; the phase says so meanwhile, rather
      // than leaving the step that was tapped on screen and unresponsive.
      state = state.copyWith(phase: UpdatePhase.verifying);
      final verified = await _runtime.verify(
        File(join(directory.path, pending.fileName)),
        pending.asset,
        pending.release.tag,
      );
      if (!_current(revision)) return;
      if (!verified) {
        state = state.copyWith(
          phase: UpdatePhase.verifyFailed,
          verified: false,
        );
        await _recordPhase(directory);
        return;
      }
      final permission = await _runtime.installPermission();
      if (!_current(revision)) return;
      if (!permission) {
        state = state.copyWith(phase: UpdatePhase.permission);
        await _recordPhase(directory);
        return;
      }
      if (ref.read(isStartProvider) || await _runtime.vpnActive()) {
        if (_current(revision)) {
          state = state.copyWith(phase: UpdatePhase.vpnActive);
        }
        return;
      }
      if (!_current(revision)) return;
      if (automatic && !_automaticAllowed) {
        state = state.copyWith(phase: UpdatePhase.ready);
        return;
      }
      state = state.copyWith(phase: UpdatePhase.installing);
      await _recordPhase(directory);
      if (!_current(revision)) return;
      if (automatic && !_automaticAllowed) {
        state = state.copyWith(phase: UpdatePhase.ready);
        await _recordPhase(directory);
        return;
      }
      final result = await _runtime.install(
        join(directory.path, pending.fileName),
        version: pending.release.tag,
        sha256: pending.asset.sha256!,
        automatic: automatic,
      );
      if (!ref.mounted || revision != _revision) return;
      switch (result) {
        case ApkInstallResult.permissionRequired:
          state = state.copyWith(phase: UpdatePhase.permission);
        case ApkInstallResult.vpnActive:
          state = state.copyWith(phase: UpdatePhase.vpnActive);
        case ApkInstallResult.started:
          _attachObservers();
          await _queueInstallStatus(await _runtime.installStatus());
      }
      await _recordPhase(directory);
    } catch (error) {
      commonPrint.log(
        'update install failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      if (ref.mounted && revision == _revision) {
        state = state.copyWith(
          phase: error is PlatformException && error.code == 'APK_INVALID'
              ? UpdatePhase.verifyFailed
              : UpdatePhase.installFailed,
          verified:
              !(error is PlatformException && error.code == 'APK_INVALID'),
        );
        await _recordPhase(await _runtime.directory());
      }
    } finally {
      _installing = false;
    }
  }

  Future<void> openPermission() async {
    if (state.phase != UpdatePhase.permission ||
        _installing ||
        _openingPermission) {
      return;
    }
    _openingPermission = true;
    final revision = _revision;
    try {
      _permissionOpened = true;
      _attachObservers();
      // Android ends the process once the permission is granted, so the record
      // only has to land before the reader gets there, not before settings open.
      final recorded = _recordPhase(await _runtime.directory());
      final opened = await _runtime.openPermission();
      await recorded;
      if (!_current(revision)) return;
      if (!opened) {
        _permissionOpened = false;
        state = state.copyWith(phase: UpdatePhase.installFailed);
      }
    } catch (error) {
      _permissionOpened = false;
      commonPrint.log('update permission failed: ${compactError(error)}');
      if (_current(revision)) {
        state = state.copyWith(phase: UpdatePhase.installFailed);
      }
    } finally {
      _openingPermission = false;
    }
  }

  Future<void> confirmInstall() async {
    if (state.phase != UpdatePhase.confirmation || _installing) return;
    _installing = true;
    final revision = _revision;
    try {
      if (ref.read(isStartProvider) || await _runtime.vpnActive()) {
        state = state.copyWith(phase: UpdatePhase.vpnActive);
        return;
      }
      final continued = await _runtime.confirmInstall();
      if (!_current(revision)) return;
      state = state.copyWith(
        phase: continued ? UpdatePhase.installing : UpdatePhase.ready,
      );
      await _recordPhase(await _runtime.directory());
    } catch (error) {
      commonPrint.log('update confirmation failed: ${compactError(error)}');
      if (_current(revision)) {
        state = state.copyWith(phase: UpdatePhase.installFailed);
      }
    } finally {
      _installing = false;
    }
  }

  bool get _automaticAllowed {
    final release = state.release;
    final setting = ref.read(appSettingProvider);
    if (!ref.read(initProvider) ||
        !setting.autoInstallUpdate ||
        release == null ||
        release.prerelease ||
        release.summary?.permitsAutomaticInstall != true) {
      return false;
    }
    final changelog = parseReleaseChangelog(release.body);
    return changelog != null &&
        changelog.tag == release.tag &&
        !changelog.groups.any(
          (group) =>
              group.type == ChangelogType.breaking && group.entries.isNotEmpty,
        );
  }

  Future<void> _tryAutomaticInstall() async {
    if (!ref.mounted || !_automaticAllowed || !state.verified || _installing) {
      return;
    }
    if (!const {
      UpdatePhase.ready,
      UpdatePhase.vpnActive,
    }.contains(state.phase)) {
      return;
    }
    if (ref.read(isStartProvider) || await _runtime.vpnActive()) return;
    await installNow(automatic: true);
  }

  Future<void> _applyPolicy() async {
    if (!ref.mounted || !isSupported || _cancelling) return;
    final setting = ref.read(appSettingProvider);
    if (state.phase == UpdatePhase.downloading &&
        state.automaticDownload &&
        !setting.autoDownloadUpdate) {
      pause();
    }
    _attachObservers();
    if ((state.phase == UpdatePhase.offered ||
            (state.phase == UpdatePhase.paused && state.automaticDownload)) &&
        setting.autoDownloadUpdate) {
      try {
        if (await _runtime.onWifi() &&
            ref.mounted &&
            ref.read(appSettingProvider).autoDownloadUpdate) {
          unawaited(download(automatic: true));
        }
      } catch (error) {
        commonPrint.log('update Wi-Fi check failed: ${compactError(error)}');
      }
    }
    await _tryAutomaticInstall();
  }

  void _attachObservers() {
    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }
    _installSubscription ??= _runtime.installChanges.listen(
      (status) {
        unawaited(_queueInstallStatus(status));
      },
      onError: (Object error) {
        commonPrint.log(
          'update installer observer failed: ${compactError(error)}',
        );
      },
    );
    _wifiSubscription ??= _runtime.wifiChanges.listen(
      (wifi) {
        if (!ref.mounted) return;
        if (!wifi &&
            state.automaticDownload &&
            state.phase == UpdatePhase.downloading) {
          pause(forWifi: true);
        } else if (wifi && ref.read(appSettingProvider).autoDownloadUpdate) {
          if (state.phase == UpdatePhase.offered ||
              (state.phase == UpdatePhase.paused && state.automaticDownload)) {
            unawaited(download(automatic: true));
          }
        }
      },
      onError: (Object error) {
        commonPrint.log('update Wi-Fi observer failed: ${compactError(error)}');
      },
    );
  }

  Future<void> _queueInstallStatus(ApkInstallStatus status) {
    _statusTail = _statusTail
        .then((_) => _handleInstallStatus(status))
        .catchError((Object error) {
          commonPrint.log(
            'update installer status failed: ${compactError(error)}',
          );
        });
    return _statusTail;
  }

  Future<void> _handleInstallStatus(ApkInstallStatus status) async {
    if (!ref.mounted || _pending == null || !state.verified) return;
    final pending = _pending!;
    final revision = _revision;
    switch (status) {
      case ApkInstallStatus.awaitingConfirmation:
        state = state.copyWith(phase: UpdatePhase.confirmation);
      case ApkInstallStatus.preparing:
      case ApkInstallStatus.installing:
        state = state.copyWith(phase: UpdatePhase.installing);
      case ApkInstallStatus.success:
        final version = await _runtime.actualInstalledVersion();
        if (!_current(revision) || _pending?.fileName != pending.fileName) {
          return;
        }
        if (compareVersions(version, pending.release.tag) >= 0) {
          await _finishInstalled(await _runtime.directory());
          return;
        }
        state = state.copyWith(phase: UpdatePhase.installFailed);
      case ApkInstallStatus.cancelled:
        state = state.copyWith(phase: UpdatePhase.ready);
      case ApkInstallStatus.failed:
        state = state.copyWith(phase: UpdatePhase.installFailed);
      case ApkInstallStatus.none:
        if (state.phase == UpdatePhase.installing ||
            state.phase == UpdatePhase.confirmation) {
          state = state.copyWith(phase: UpdatePhase.ready);
        }
    }
    await _recordPhase(await _runtime.directory());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ref.mounted) {
      unawaited(_onResume());
    }
  }

  Future<void> _onResume() async {
    try {
      if (!ref.read(initProvider) || _installing) return;
      if (_permissionOpened) {
        await _resumePermission();
      } else if (_pending != null &&
          const {
            UpdatePhase.installing,
            UpdatePhase.confirmation,
          }.contains(state.phase)) {
        await _queueInstallStatus(await _runtime.installStatus());
      }
      await _tryAutomaticInstall();
    } catch (error) {
      commonPrint.log('update resume failed: ${compactError(error)}');
    }
  }

  /// Back from Android's settings, possibly in a process Android restarted
  /// to apply the grant: the sheet the reader left from comes back either
  /// way, and the install goes on only once the permission is there.
  Future<void> _resumePermission() async {
    if (!_permissionOpened || !ref.mounted) return;
    _permissionOpened = false;
    _revealSheet();
    if (await _runtime.installPermission()) {
      await installNow();
    } else {
      await _recordPhase(await _runtime.directory());
    }
  }

  void _revealSheet() {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        final context = globalState.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          unawaited(UpdateSheet.show(context));
        }
      })
      ..ensureVisualUpdate();
  }

  Future<bool> restorePendingInstall() async {
    if (!isSupported || _restored) return state.hasUpdate;
    _restored = true;
    _restoring = true;
    final revision = _revision;
    try {
      final directory = await _runtime.directory();
      final file = File(join(directory.path, _pendingUpdateInstallFile));
      if (!await file.exists()) {
        await removeStaleUpdateApks(directory);
        return false;
      }
      if (await file.length() > 512 * 1024) {
        throw const FormatException('Pending update state is too large');
      }
      final pending = _PendingUpdate.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
        source: _runtime.source,
      );
      if (!_current(revision)) return false;
      _pending = pending;
      if (compareVersions(_runtime.installedVersion, pending.release.tag) >=
          0) {
        state = AppUpdateState(release: pending.release);
        await _finishInstalled(directory);
        return false;
      }
      final apk = File(join(directory.path, pending.fileName));
      state = AppUpdateState(
        phase: pending.phase,
        release: pending.release,
        asset: pending.asset,
        total: pending.asset.size ?? 0,
        automaticDownload: pending.automaticDownload,
      );
      _permissionOpened = pending.permissionOpened;
      if (pending.verified) {
        state = state.copyWith(phase: UpdatePhase.verifying);
        final verified = await _runtime.verify(
          apk,
          pending.asset,
          pending.release.tag,
        );
        if (!_current(revision)) return false;
        if (!verified) {
          await apk.safeDelete();
          state = state.copyWith(phase: UpdatePhase.verifyFailed);
        } else {
          state = state.copyWith(
            phase: pending.phase == UpdatePhase.permission
                ? UpdatePhase.permission
                : UpdatePhase.ready,
            verified: true,
            received: await apk.length(),
            total: await apk.length(),
          );
          if (const {
            UpdatePhase.installing,
            UpdatePhase.confirmation,
          }.contains(pending.phase)) {
            await _queueInstallStatus(await _runtime.installStatus());
          }
        }
      } else {
        final partial = File('${apk.path}.tmp');
        state = state.copyWith(
          phase: pending.phase == UpdatePhase.verifyFailed
              ? UpdatePhase.verifyFailed
              : UpdatePhase.paused,
          received: await partial.exists() ? await partial.length() : 0,
        );
      }
      await removeStaleUpdateApks(
        directory,
        keep: {pending.fileName},
        keepPartial: {pending.fileName},
      );
      _attachObservers();
      await _recordPhase(directory);
      return true;
    } catch (error) {
      commonPrint.log(
        'pending update restore failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      if (ref.mounted && state.release != null) {
        state = state.copyWith(
          phase: UpdatePhase.verifyFailed,
          verified: false,
        );
        return true;
      }
      try {
        final directory = await _runtime.directory();
        await File(
          join(directory.path, _pendingUpdateInstallFile),
        ).safeDelete();
        await removeStaleUpdateApks(directory);
      } catch (_) {}
      return false;
    } finally {
      _restoring = false;
      if (ref.mounted && ref.read(initProvider)) unawaited(_afterReady());
    }
  }

  Future<void> _finishInstalled(Directory directory) async {
    final pending = _pending;
    _pending = null;
    _permissionOpened = false;
    await _persistTail;
    await File(join(directory.path, _pendingUpdateInstallFile)).safeDelete();
    if (pending != null) {
      await File(join(directory.path, pending.fileName)).safeDelete();
    }
    await removeStaleUpdateApks(directory);
    if (ref.mounted) state = state.copyWith(phase: UpdatePhase.installed);
  }

  Future<void> _recordPhase(Directory directory) async {
    if (_pending == null) return;
    _pending = _pending!.copyWith(
      phase: state.phase,
      verified: state.verified,
      permissionOpened: _permissionOpened,
      automaticDownload: state.automaticDownload,
    );
    await _savePending(directory);
  }

  Future<void> _savePending(Directory directory) {
    final pending = _pending;
    if (pending == null) return Future.value();
    final encoded = jsonEncode(pending.toJson());
    final next = _persistTail.then(
      (_) => File(
        join(directory.path, _pendingUpdateInstallFile),
      ).writeAsStringAtomically(encoded),
    );
    _persistTail = next.catchError((Object error) {
      commonPrint.log('pending update save failed: ${compactError(error)}');
    });
    return next;
  }
}

class _PendingUpdate {
  const _PendingUpdate({
    required this.release,
    required this.asset,
    required this.fileName,
    required this.phase,
    this.verified = false,
    this.automaticDownload = false,
    this.permissionOpened = false,
  });

  final AppUpdateRelease release;
  final AndroidUpdateAsset asset;
  final String fileName;
  final UpdatePhase phase;
  final bool verified;
  final bool automaticDownload;
  final bool permissionOpened;

  _PendingUpdate copyWith({
    UpdatePhase? phase,
    bool? verified,
    bool? permissionOpened,
    bool? automaticDownload,
  }) => _PendingUpdate(
    release: release,
    asset: asset,
    fileName: fileName,
    phase: phase ?? this.phase,
    verified: verified ?? this.verified,
    automaticDownload: automaticDownload ?? this.automaticDownload,
    permissionOpened: permissionOpened ?? this.permissionOpened,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'fileName': fileName,
    'source': release.source.id,
    'release': {
      'tag_name': release.tag,
      'body': release.body,
      'prerelease': release.prerelease,
      'published_at': release.data['published_at'],
    },
    'asset': {
      'name': asset.name,
      'url': asset.url,
      'sha256': asset.sha256,
      'size': asset.size,
    },
    'phase': phase.name,
    'verified': verified,
    'automaticDownload': automaticDownload,
    'permissionOpened': permissionOpened,
  };

  factory _PendingUpdate.fromJson(
    Map<String, dynamic> json, {
    required AppUpdateSource? Function(String id) source,
  }) {
    if (json['schemaVersion'] != 1 ||
        json['fileName'] is! String ||
        !RegExp(
          r'^update-[A-Za-z0-9._-]+\.apk$',
        ).hasMatch(json['fileName'] as String) ||
        json['source'] is! String ||
        json['release'] is! Map<String, dynamic> ||
        json['asset'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid pending update');
    }
    final provider = source(json['source'] as String);
    if (provider == null) throw const FormatException('Unknown update source');
    final data = json['release'] as Map<String, dynamic>;
    if (data['tag_name'] is! String ||
        tryParseAppVersion(data['tag_name'] as String) == null) {
      throw const FormatException('Invalid pending update version');
    }
    final rawAsset = json['asset'] as Map<String, dynamic>;
    final digest = parseAssetSha256('sha256:${rawAsset['sha256']}');
    if (rawAsset['name'] is! String ||
        rawAsset['url'] is! String ||
        digest == null ||
        (rawAsset['size'] != null &&
            (rawAsset['size'] is! int || (rawAsset['size'] as int) <= 0))) {
      throw const FormatException('Invalid pending update asset');
    }
    provider.assetUri(rawAsset['url'] as String);
    final phase = UpdatePhase.values.byName(json['phase'] as String);
    return _PendingUpdate(
      release: AppUpdateRelease(data: data, source: provider),
      asset: AndroidUpdateAsset(
        name: rawAsset['name'] as String,
        url: rawAsset['url'] as String,
        sha256: digest,
        size: rawAsset['size'] as int?,
      ),
      fileName: json['fileName'] as String,
      phase: phase,
      verified: json['verified'] == true,
      automaticDownload: json['automaticDownload'] == true,
      permissionOpened: json['permissionOpened'] == true,
    );
  }
}
