import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/app_update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_update_runtime.dart';

Future<void> settleUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 200 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(condition(), isTrue);
}

/// Removes [directory] once the background writes of a finished test have
/// landed: an automatic install keeps persisting its state after the test
/// returns, so the first attempt can find the directory non-empty.
Future<void> deleteDirectory(Directory directory) async {
  for (var attempt = 1; ; attempt++) {
    try {
      await directory.delete(recursive: true);
      return;
    } on FileSystemException {
      if (attempt == 100) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }
}

class _FakeSystemAction extends SystemAction {
  int exits = 0;

  @override
  Future<void> handleExit([bool needSave = true]) async => exits++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late TestUpdateRuntime runtime;
  late ProviderContainer container;
  late AppUpdateAction action;
  late String previousEnv;

  void recreate() {
    container = ProviderContainer(
      overrides: [
        appUpdateRuntimeProvider.overrideWithValue(runtime),
        if (runtime.desktopMode)
          systemActionProvider.overrideWith(_FakeSystemAction.new),
      ],
    );
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    action = container.read(appUpdateActionProvider.notifier);
  }

  AppUpdateState current() => container.read(appUpdateActionProvider);
  void settings(AppSettingProps value) =>
      container.read(appSettingProvider.notifier).update((_) => value);

  setUp(() async {
    previousEnv = globalState.appEnv;
    globalState.appEnv = 'stable';
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '0.8.95',
      buildNumber: '1',
    );
    directory = await Directory.systemTemp.createTemp('reclash-update-action-');
    runtime = TestUpdateRuntime(directory);
    recreate();
  });

  tearDown(() async {
    container.dispose();
    await runtime.dispose();
    await deleteDirectory(directory);
    globalState.appEnv = previousEnv;
  });

  test(
    'a real check publishes an offer, no-update and failure separately',
    () async {
      runtime.available = testUpdateRelease();
      await action.check();
      expect(current().phase, UpdatePhase.offered);
      expect(current().asset!.sha256, isNotNull);
      runtime.available = null;
      container.dispose();
      recreate();
      await action.check();
      expect(current().phase, UpdatePhase.upToDate);
      runtime.checkFailure = const FormatException('offline');
      await action.check();
      expect(current().phase, UpdatePhase.checkFailed);
      await action.check(automatic: true);
      expect(current().phase, UpdatePhase.idle);
    },
  );

  test(
    'a download verifies before ready and retains its pending record',
    () async {
      await action.offer(testUpdateRelease());
      await action.download();
      expect(current().phase, UpdatePhase.ready);
      expect(current().verified, isTrue);
      expect(runtime.installations, 0);
      expect(runtime.downloads, 1);
      final pending = jsonDecode(
        await File('${directory.path}/pending-install.json').readAsString(),
      );
      expect(pending['verified'], isTrue);
      expect(pending['phase'], 'ready');
      await action.download();
      expect(runtime.downloads, 1);
    },
  );

  test(
    'missing digest and invalid identity never invoke the installer',
    () async {
      await action.offer(testUpdateRelease(digest: false));
      await action.download();
      expect(current().phase, UpdatePhase.verifyFailed);
      expect(runtime.downloads, 0);
      runtime.validPackage = false;
      await action.offer(testUpdateRelease(tag: 'v0.8.97'));
      await action.download();
      expect(current().phase, UpdatePhase.verifyFailed);
      await action.installNow();
      expect(runtime.installations, 0);
    },
  );

  test('native signature rejection stays a verification failure', () async {
    runtime.verifyOperation = () async =>
        throw PlatformException(code: 'APK_INVALID');
    await action.offer(testUpdateRelease());
    await action.download();
    expect(current().phase, UpdatePhase.verifyFailed);
    expect(current().verified, isFalse);
    expect(runtime.installations, 0);
  });

  test(
    'transport integrity rejection cannot be shown as a network retry',
    () async {
      runtime.downloadOperation = (_, _, _) async =>
          throw const UpdateDownloadVerificationException('Digest mismatch');
      await action.offer(testUpdateRelease());
      await action.download();
      expect(current().phase, UpdatePhase.verifyFailed);
      expect(current().verified, isFalse);
      expect(runtime.installations, 0);
    },
  );

  test('network failure preserves a resumable partial download', () async {
    runtime.downloadOperation = (path, token, progress) async {
      await File('$path.tmp').writeAsBytes(updateTestBytes.take(8).toList());
      progress(8, updateTestBytes.length);
      return 'offline';
    };
    await action.offer(testUpdateRelease());
    await action.download();
    expect(current().phase, UpdatePhase.downloadFailed);
    expect(await File('${directory.path}/update-v0.8.96.apk.tmp').length(), 8);
    runtime.downloadOperation = null;
    await action.download();
    expect(current().phase, UpdatePhase.ready);
  });

  test(
    'user pause keeps bytes and does not resume when Wi-Fi returns',
    () async {
      runtime.downloadOperation = (path, token, progress) async {
        await File('$path.tmp').writeAsBytes(updateTestBytes.take(8).toList());
        progress(8, updateTestBytes.length);
        await token.whenCancel;
        return '';
      };
      settings(const AppSettingProps(autoDownloadUpdate: true));
      await action.offer(testUpdateRelease());
      final task = action.download(automatic: true);
      await settleUntil(() => current().received == 8);
      expect(identical(action.download(), action.download()), isTrue);
      action.pause();
      await task;
      expect(current().phase, UpdatePhase.paused);
      expect(current().automaticDownload, isFalse);
      runtime.setWifi(true);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(runtime.downloads, 1);
      expect(current().phase, UpdatePhase.paused);
    },
  );

  test('Wi-Fi pause resumes only while preloading remains enabled', () async {
    runtime.downloadOperation = (path, token, progress) async {
      await File('$path.tmp').writeAsBytes(updateTestBytes.take(8).toList());
      progress(8, updateTestBytes.length);
      await token.whenCancel;
      return '';
    };
    settings(
      const AppSettingProps(autoCheckUpdate: false, autoDownloadUpdate: true),
    );
    await action.offer(testUpdateRelease());
    final task = action.download(automatic: true);
    await settleUntil(() => current().received == 8);
    runtime.setWifi(false);
    await task;
    expect(current().automaticDownload, isTrue);
    runtime.downloadOperation = null;
    runtime.setWifi(true);
    await settleUntil(() => current().phase == UpdatePhase.ready);
    expect(runtime.downloads, 2);
  });

  test(
    'cancel removes the owned pending transfer but preserves unrelated files',
    () async {
      runtime.downloadOperation = (path, token, progress) async {
        await File('$path.tmp').writeAsBytes([1, 2]);
        progress(2, updateTestBytes.length);
        await token.whenCancel;
        return '';
      };
      await action.offer(testUpdateRelease());
      final task = action.download();
      await settleUntil(() => current().received == 2);
      final unrelated = File('${directory.path}/keep.txt');
      await unrelated.writeAsString('keep');
      await action.cancelDownload();
      await task;
      expect(current().phase, UpdatePhase.offered);
      expect(
        await File('${directory.path}/pending-install.json').exists(),
        isFalse,
      );
      expect(
        await File('${directory.path}/update-v0.8.96.apk.tmp').exists(),
        isFalse,
      );
      expect(await unrelated.readAsString(), 'keep');
    },
  );

  test('a retained package restores without downloading again', () async {
    await action.offer(testUpdateRelease());
    await action.download();
    container.dispose();
    recreate();
    expect(await action.restorePendingInstall(), isTrue);
    expect(current().phase, UpdatePhase.ready);
    expect(current().verified, isTrue);
    expect(runtime.downloads, 1);
    expect(runtime.verifies, 2);
  });

  test('a paused transfer restores its actual saved byte count', () async {
    runtime.downloadOperation = (path, token, progress) async {
      await File('$path.tmp').writeAsBytes([1, 2, 3]);
      progress(3, updateTestBytes.length);
      return '';
    };
    await action.offer(testUpdateRelease());
    await action.download();
    container.dispose();
    recreate();
    expect(await action.restorePendingInstall(), isTrue);
    expect(current().phase, UpdatePhase.paused);
    expect(current().received, 3);
    expect(current().verified, isFalse);
  });

  test('permission is offered without opening settings on its own', () async {
    runtime.permission = false;
    await action.offer(testUpdateRelease());
    await action.download();
    await action.installNow();
    expect(current().phase, UpdatePhase.permission);
    expect(runtime.permissionRequests, 0);
    await action.openPermission();
    expect(runtime.permissionRequests, 1);
    runtime.permission = true;
    container.read(initProvider.notifier).value = true;
    action.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settleUntil(() => runtime.installations == 1);
    expect(runtime.lastAutomatic, isFalse);
  });

  test('a grant that restarts the process resumes the install once', () async {
    runtime.permission = false;
    await action.offer(testUpdateRelease());
    await action.download();
    await action.installNow();
    await action.openPermission();
    container.dispose();
    recreate();
    runtime.permission = true;
    expect(await action.restorePendingInstall(), isTrue);
    expect(current().phase, UpdatePhase.permission);
    container.read(initProvider.notifier).value = true;
    await settleUntil(() => runtime.installations == 1);
    expect(runtime.downloads, 1);
    action.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(runtime.installations, 1);
  });

  test('returning without the permission keeps the step offered', () async {
    runtime.permission = false;
    await action.offer(testUpdateRelease());
    await action.download();
    await action.installNow();
    await action.openPermission();
    container.read(initProvider.notifier).value = true;
    action.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(current().phase, UpdatePhase.permission);
    runtime.permission = true;
    action.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(runtime.installations, 0);
  });

  test('active native VPN and Flutter run intent block installation', () async {
    await action.offer(testUpdateRelease());
    await action.download();
    runtime.vpn = true;
    await action.installNow();
    expect(current().phase, UpdatePhase.vpnActive);
    expect(runtime.installations, 0);
    runtime.vpn = false;
    container.read(runTimeProvider.notifier).value = 0;
    await action.installNow();
    expect(current().phase, UpdatePhase.vpnActive);
    expect(runtime.installations, 0);
  });

  test(
    'new VPN intent during verification is checked again before installation',
    () async {
      await action.offer(testUpdateRelease());
      await action.download();
      final verified = Completer<bool>();
      runtime.verifyOperation = () => verified.future;
      final installing = action.installNow();
      await settleUntil(() => runtime.verifies == 2);
      container.read(runTimeProvider.notifier).value = 0;
      verified.complete(true);
      await installing;
      expect(current().phase, UpdatePhase.vpnActive);
      expect(runtime.installations, 0);
    },
  );

  test(
    'automatic install requires readiness and independent durable consent',
    () async {
      settings(
        const AppSettingProps(autoCheckUpdate: false, autoInstallUpdate: true),
      );
      await action.offer(testUpdateRelease());
      await action.download();
      expect(runtime.installations, 0);
      container.read(initProvider.notifier).value = true;
      await settleUntil(() => runtime.installations == 1);
      expect(runtime.lastAutomatic, isTrue);
    },
  );

  for (final (name, release) in [
    ('un-authored', testUpdateRelease(authored: false)),
    ('not opted in by author', testUpdateRelease(automatic: false)),
    ('breaking', testUpdateRelease(breaking: true)),
    ('warning', testUpdateRelease(warning: true)),
    ('prerelease', testUpdateRelease(prerelease: true, tag: 'v0.8.96-pre.1')),
  ]) {
    test('$name releases never install automatically', () async {
      settings(const AppSettingProps(autoInstallUpdate: true));
      container.read(initProvider.notifier).value = true;
      await action.offer(release);
      await action.download();
      expect(current().phase, UpdatePhase.ready);
      expect(runtime.installations, 0);
    });
  }

  test(
    'native confirmation never opens itself and repeated taps are coalesced',
    () async {
      runtime.nativeStatus = ApkInstallStatus.awaitingConfirmation;
      await action.offer(testUpdateRelease());
      await action.download();
      await action.installNow();
      expect(current().phase, UpdatePhase.confirmation);
      expect(runtime.confirmations, 0);
      final confirmation = Completer<bool>();
      runtime.confirmOperation = () => confirmation.future;
      final first = action.confirmInstall();
      await action.confirmInstall();
      await settleUntil(() => runtime.confirmations == 1);
      confirmation.complete(true);
      await first;
      expect(current().phase, UpdatePhase.installing);
      expect(runtime.confirmations, 1);
    },
  );

  test(
    'native success is not accepted without the actual installed version',
    () async {
      await action.offer(testUpdateRelease());
      await action.download();
      await action.installNow();
      runtime.installEvents.add(ApkInstallStatus.success);
      await settleUntil(() => current().phase == UpdatePhase.installFailed);
      expect(
        await File('${directory.path}/pending-install.json').exists(),
        isTrue,
      );
      runtime.actualVersion = '0.8.96';
      runtime.installEvents.add(ApkInstallStatus.success);
      await settleUntil(() => current().phase == UpdatePhase.installed);
      expect(current().hasUpdate, isFalse);
      expect(
        await File('${directory.path}/pending-install.json').exists(),
        isFalse,
      );
    },
  );

  test('native cancellation retains a verified package for retry', () async {
    await action.offer(testUpdateRelease());
    await action.download();
    await action.installNow();
    runtime.installEvents.add(ApkInstallStatus.cancelled);
    await settleUntil(() => current().phase == UpdatePhase.ready);
    expect(current().verified, isTrue);
  });

  test(
    'a failed preference save does not enable automatic installation',
    () async {
      runtime.saved = false;
      final saved = await action.savePreferences(
        check: false,
        preload: true,
        install: true,
        channel: UpdateChannel.release,
      );
      expect(saved, isFalse);
      expect(container.read(appSettingProvider).autoInstallUpdate, isFalse);
      expect(container.read(appSettingProvider).autoDownloadUpdate, isFalse);
      expect(runtime.savedConfig!.appSettingProps.autoInstallUpdate, isTrue);
    },
  );

  test(
    'automatic policy starts only after the consent save has finished',
    () async {
      await action.offer(testUpdateRelease());
      await action.download();
      container.read(initProvider.notifier).value = true;
      final save = Completer<bool>();
      runtime.saveOperation = () => save.future;
      final saving = action.savePreferences(
        check: true,
        preload: false,
        install: true,
        channel: UpdateChannel.release,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(runtime.installations, 0);
      expect(container.read(appSettingProvider).autoInstallUpdate, isFalse);
      save.complete(true);
      expect(await saving, isTrue);
      await settleUntil(() => runtime.installations == 1);
    },
  );

  group('desktop self-update', () {
    int exits() =>
        (container.read(systemActionProvider.notifier) as _FakeSystemAction)
            .exits;
    void setProxy(bool running) =>
        container.read(runTimeProvider.notifier).value = running ? 1 : null;
    void markInitialized() =>
        container.read(initProvider.notifier).value = true;

    /// download() hands back the task in flight, which ends with the install check.
    Future<void> finishDownload() => action.download();

    setUp(() {
      container.dispose();
      runtime.desktopMode = true;
      recreate();
    });

    test(
      'a prerelease downloads but waits while the window is visible',
      () async {
        settings(const AppSettingProps(desktopAutoUpdate: true));
        markInitialized();
        runtime.available = testUpdateRelease(
          tag: 'v0.8.96-pre.1',
          prerelease: true,
          automatic: false,
        );
        await action.check(automatic: true);
        await finishDownload();
        expect(current().phase, UpdatePhase.ready);
        expect(current().verified, isTrue);
        expect(runtime.installations, 0);
        expect(exits(), 0);
      },
    );

    test('a hidden window with the proxy off applies at once', () async {
      markInitialized();
      runtime.hidden = true;
      runtime.available = testUpdateRelease();
      await action.check(automatic: true);
      await finishDownload();
      expect(runtime.relaunches, [true]);
      expect(exits(), 1);
    });

    test(
      'a running proxy holds the install until the machine is idle for 15 minutes',
      () async {
        markInitialized();
        setProxy(true);
        runtime.hidden = true;
        runtime.idle = const Duration(minutes: 14);
        final phases = <UpdatePhase>[];
        container.listen(
          appUpdateActionProvider,
          (_, next) => phases.add(next.phase),
        );
        runtime.available = testUpdateRelease();
        await action.check(automatic: true);
        await finishDownload();
        await action.check(automatic: true);
        expect(current().phase, UpdatePhase.ready);
        expect(runtime.installations, 0);
        expect(phases, isNot(contains(UpdatePhase.vpnActive)));
        runtime.idle = const Duration(minutes: 15);
        await action.check(automatic: true);
        expect(runtime.installations, 1);
        expect(runtime.relaunches, [true]);
        expect(exits(), 1);
        expect(phases, isNot(contains(UpdatePhase.vpnActive)));
        final pending = jsonDecode(
          await File('${directory.path}/pending-install.json').readAsString(),
        );
        expect(pending['resumeProxy'], isTrue);
      },
    );

    test(
      'a running TUN holds the idle install until an explicit restart',
      () async {
        markInitialized();
        setProxy(true);
        container.read(tunAppliedProvider.notifier).value = true;
        runtime.idle = const Duration(minutes: 30);
        runtime.available = testUpdateRelease();
        await action.check(automatic: true);
        await finishDownload();
        await action.check(automatic: true);
        expect(current().phase, UpdatePhase.ready);
        expect(runtime.installations, 0);
        await action.installNow();
        expect(runtime.installations, 1);
        expect(runtime.relaunches, [true]);
      },
    );

    for (final (name, release) in [
      ('warning', testUpdateRelease(warning: true)),
      ('breaking', testUpdateRelease(breaking: true)),
    ]) {
      test(
        'a $name release waits for an explicit click even when idle',
        () async {
          markInitialized();
          setProxy(true);
          runtime.idle = const Duration(minutes: 20);
          runtime.available = release;
          await action.check(automatic: true);
          await finishDownload();
          await action.check(automatic: true);
          expect(current().phase, UpdatePhase.ready);
          expect(runtime.installations, 0);
          await action.installNow();
          expect(runtime.installations, 1);
          expect(runtime.relaunches, [true]);
          expect(exits(), 1);
        },
      );
    }

    test(
      'disabled desktop updates stay offered and download nothing',
      () async {
        settings(const AppSettingProps(desktopAutoUpdate: false));
        markInitialized();
        runtime.hidden = true;
        runtime.available = testUpdateRelease();
        await action.check(automatic: true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(current().phase, UpdatePhase.offered);
        expect(runtime.downloads, 0);
      },
    );

    test('a release without a desktop package stays offered', () async {
      runtime.desktopAssetMissing = true;
      runtime.available = testUpdateRelease();
      await action.check(automatic: true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(current().phase, UpdatePhase.offered);
      expect(current().asset, isNull);
      expect(runtime.downloads, 0);
    });

    test('applyOnExit installs from ready without relaunching', () async {
      await action.offer(testUpdateRelease());
      await finishDownload();
      expect(current().phase, UpdatePhase.ready);
      await action.applyOnExit();
      expect(runtime.relaunches, [false]);
      expect(exits(), 0);
      await action.applyOnExit();
      expect(runtime.relaunches, [false]);
      expect(runtime.installations, 1);
    });

    test(
      'applyOnExit leaves a ready update when the setting is turned off',
      () async {
        await action.offer(testUpdateRelease());
        await finishDownload();
        settings(const AppSettingProps(desktopAutoUpdate: false));
        await action.applyOnExit();
        expect(current().phase, UpdatePhase.ready);
        expect(runtime.relaunches, isEmpty);
      },
    );

    test(
      'an install cut short by exit restores as failed and is retried only by a newer release',
      () async {
        await action.offer(testUpdateRelease());
        await finishDownload();
        await action.installNow();
        expect(runtime.relaunches, [true]);
        expect(exits(), 1);
        container.dispose();
        recreate();
        expect(await action.restorePendingInstall(), isTrue);
        expect(current().phase, UpdatePhase.installFailed);
        expect(await action.applyAtLaunch(), isFalse);
        expect(exits(), 0);
        markInitialized();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(runtime.installations, 1);
        runtime.available = testUpdateRelease(tag: 'v0.8.97');
        await action.check(automatic: true);
        await finishDownload();
        expect(current().release?.tag, 'v0.8.97');
        expect(current().phase, UpdatePhase.ready);
        expect(runtime.downloads, 2);
        expect(runtime.installations, 1);
      },
    );

    test(
      'a ready update restored at launch applies before the window opens',
      () async {
        await action.offer(testUpdateRelease());
        await finishDownload();
        container.dispose();
        recreate();
        expect(await action.restorePendingInstall(), isTrue);
        expect(current().phase, UpdatePhase.ready);
        expect(await action.applyAtLaunch(), isTrue);
        expect(runtime.relaunches, [true]);
        expect(exits(), 1);
      },
    );

    test(
      'an update installed by launch clears its record and package',
      () async {
        await action.offer(testUpdateRelease());
        await finishDownload();
        expect(
          await File('${directory.path}/update-v0.8.96.apk').exists(),
          isTrue,
        );
        container.dispose();
        recreate();
        runtime.version = '0.8.96';
        expect(await action.restorePendingInstall(), isFalse);
        expect(current().phase, UpdatePhase.installed);
        expect(current().hasUpdate, isFalse);
        expect(
          await File('${directory.path}/pending-install.json').exists(),
          isFalse,
        );
        expect(
          await File('${directory.path}/update-v0.8.96.apk').exists(),
          isFalse,
        );
        expect(runtime.installations, 0);
      },
    );
  });
}
