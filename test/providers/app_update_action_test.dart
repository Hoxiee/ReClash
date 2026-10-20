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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late TestUpdateRuntime runtime;
  late ProviderContainer container;
  late AppUpdateAction action;
  late String previousEnv;

  void recreate() {
    container = ProviderContainer(
      overrides: [appUpdateRuntimeProvider.overrideWithValue(runtime)],
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
    await directory.delete(recursive: true);
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
}
