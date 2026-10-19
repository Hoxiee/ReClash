import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/launcher.dart';
import 'package:reclash/core/desktop/linux_helper.dart';
import 'package:reclash/core/desktop/macos_helper.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';

import 'fakes.dart';

class _WindowsPort implements WindowsCorePort {
  bool elevated = false;

  @override
  Future<bool> isElevated() async => elevated;

  @override
  void prepare(String sessionId) {}

  @override
  Stream<List<String>> launch({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  }) => const Stream.empty();

  @override
  bool cancel(String sessionId) => true;

  @override
  Future<bool> stop(String sessionId, Duration timeout) async => true;
}

class _MacPort implements MacOSHelperPort {
  MacOSHelperReadiness ready = const MacOSHelperReadiness(
    status: MacOSHelperStatus.notRegistered,
  );
  int registrations = 0;

  @override
  Future<MacOSHelperReadiness> readiness() async => ready;

  @override
  Future<MacOSHelperReadiness> register() async {
    registrations++;
    return ready;
  }

  @override
  Future<MacOSHelperReadiness> unregister() async => ready;

  @override
  Future<MacOSHelperStartResult> start({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  }) async => MacOSHelperStartResult(sessionId: sessionId, pid: 100);

  @override
  Future<CoreProcessStopResult> stop({
    required String sessionId,
    required Duration timeout,
  }) async => const CoreProcessStopResult(stopped: true, exitConfirmed: true);
}

void main() {
  late FakeLauncher direct;
  late FakeLauncher helper;
  late _WindowsPort windows;
  late _MacPort macos;
  CoreProcessOwner? owner;

  setUp(() {
    direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 10);
    helper = FakeLauncher(owner: CoreProcessOwner.helper, pid: 20);
    windows = _WindowsPort();
    macos = _MacPort();
    owner = null;
  });

  DesktopPrivilegeCoordinator coordinator({
    String platform = 'linux',
    bool safeMode = false,
    HelperReadinessProbe? ready,
  }) => DesktopPrivilegeCoordinator(
    direct: direct,
    linux: helper,
    windows: WindowsLauncherResolver(
      direct: direct,
      elevated: WindowsCoreLauncher(port: windows),
    ),
    macos: MacOSHelperLauncher(port: macos),
    linuxInstaller: LinuxHelperInstaller(isLinux: false),
    linuxReady: ready ?? () async => HelperReadiness.notReady,
    currentOwner: () => owner,
    platform: platform,
    safeMode: safeMode,
  );

  Future<CoreProcessLease> launch(CoreProcessLauncher launcher) =>
      launcher.start(
        sessionId: '0123456789abcdef0123456789abcdef',
        address: 'test-address',
      );

  test('ordinary launches and Safe Mode never need authorization', () async {
    final ordinary = coordinator();
    expect(
      await ordinary.prepare(tunEnabled: false, allowPrompt: true),
      DesktopPrivilegeDecision.notRequired,
    );
    expect(await ordinary.resolve(), same(direct));
    final safe = coordinator(safeMode: true);
    expect(
      await safe.prepare(tunEnabled: true, allowPrompt: true),
      DesktopPrivilegeDecision.notRequired,
    );
    expect(await safe.resolve(), same(direct));
  });

  test('only an active privileged lease marks authorization active', () async {
    for (final privileged in [
      CoreProcessOwner.helper,
      CoreProcessOwner.windowsElevated,
      CoreProcessOwner.macosHelper,
    ]) {
      owner = privileged;
      final privileges = coordinator();
      expect(
        await privileges.prepare(tunEnabled: true),
        DesktopPrivilegeDecision.active,
      );
      expect(privileges.status, DesktopPrivilegeStatus.active);
    }
  });

  test('an installed Helper needs a lease handoff, not a new prompt', () async {
    final privileges = coordinator(ready: () async => HelperReadiness.ready);
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.restartRequired,
    );
    final lease = await launch(await privileges.resolve());
    expect(lease.owner, CoreProcessOwner.helper);
    expect(helper.startCount, 1);
    expect(direct.startCount, 0);
  });

  test(
    'background starts fail typed instead of prompting or falling back',
    () async {
      final privileges = coordinator();
      expect(
        await privileges.prepare(tunEnabled: true),
        DesktopPrivilegeDecision.authorizationRequired,
      );
      final launcher = await privileges.resolve();
      final attempt = (launcher as CancellableCoreProcessLauncher).begin(
        sessionId: '0123456789abcdef0123456789abcdef',
        address: 'test-address',
      );
      final spawned = expectLater(
        attempt.spawned,
        throwsA(isA<DesktopPrivilegeException>()),
      );
      await expectLater(
        attempt.result,
        throwsA(isA<DesktopPrivilegeException>()),
      );
      await spawned;
      await attempt.settled;
      expect(helper.startCount, 0);
      expect(direct.startCount, 0);
    },
  );

  test('Windows prompt grants are one-shot and revocable', () async {
    final privileges = coordinator(platform: 'windows');
    privileges.configure(tunEnabled: true, allowPrompt: true);
    expect(await privileges.resolve(), isA<WindowsCoreLauncher>());
    await expectLater(
      privileges.resolve(),
      throwsA(isA<WindowsLaunchException>()),
    );
    privileges.configure(tunEnabled: true, allowPrompt: true);
    privileges.revokePrompt();
    await expectLater(
      privileges.resolve(),
      throwsA(isA<WindowsLaunchException>()),
    );
  });

  test('macOS approval and registration are not process readiness', () async {
    macos.ready = const MacOSHelperReadiness(
      status: MacOSHelperStatus.requiresApproval,
    );
    final privileges = coordinator(platform: 'macos');
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.authorizationRequired,
    );
    expect(privileges.status, DesktopPrivilegeStatus.requiresApproval);
    expect(macos.registrations, 0);
  });

  test('cancel before readiness settles cannot start a Helper lease', () async {
    final gate = Completer<HelperReadiness>();
    final privileges = coordinator(ready: () => gate.future)
      ..configure(tunEnabled: true, allowPrompt: true);
    final launcher = await privileges.resolve();
    final attempt = (launcher as CancellableCoreProcessLauncher).begin(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );
    final spawned = expectLater(
      attempt.spawned,
      throwsA(isA<DesktopPrivilegeException>()),
    );
    final result = expectLater(
      attempt.result,
      throwsA(isA<DesktopPrivilegeException>()),
    );
    attempt.cancel();
    gate.complete(HelperReadiness.ready);
    await Future.wait([spawned, result]);
    await attempt.settled;
    expect(helper.startCount, 0);
    expect(attempt.lease, isNull);
  });

  test('cancel stops a late lease and retains an unconfirmed exit', () async {
    for (final confirmed in [true, false]) {
      helper = FakeLauncher(owner: CoreProcessOwner.helper, pid: 20);
      helper.startGate = Completer<void>();
      helper.lease.stopResult = CoreProcessStopResult(
        stopped: true,
        exitConfirmed: confirmed,
      );
      final privileges = coordinator(ready: () async => HelperReadiness.ready)
        ..configure(tunEnabled: true);
      final launcher = await privileges.resolve();
      final attempt = (launcher as CancellableCoreProcessLauncher).begin(
        sessionId: '0123456789abcdef0123456789abcdef',
        address: 'test-address',
      );
      final spawned = expectLater(
        attempt.spawned,
        throwsA(isA<DesktopPrivilegeException>()),
      );
      final result = expectLater(
        attempt.result,
        throwsA(isA<DesktopPrivilegeException>()),
      );
      await helper.started;
      attempt.cancel();
      helper.startGate!.complete();
      await Future.wait([spawned, result]);
      await attempt.settled;
      expect(attempt.lease, confirmed ? isNull : same(helper.lease));
      expect(helper.lease.stopCount, 1);
    }
  });
}
