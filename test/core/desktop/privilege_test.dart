import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/launcher.dart';
import 'package:reclash/core/desktop/linux_helper.dart';
import 'package:reclash/core/desktop/macos_helper.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';
import 'package:reclash/core/desktop/windows_service.dart';

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

const _sessionId = '0123456789abcdef0123456789abcdef';

void main() {
  late FakeLauncher direct;
  late FakeLauncher helper;
  late FakeLauncher service;
  late _WindowsPort windows;
  late _MacPort macos;
  late List<String> elevatedRuns;
  int? elevatedExit;
  var serviceInstalled = false;
  HelperException? failure;
  CoreProcessOwner? owner;

  setUp(() {
    direct = FakeLauncher(owner: CoreProcessOwner.direct, pid: 10);
    helper = FakeLauncher(owner: CoreProcessOwner.helper, pid: 20);
    service = FakeLauncher(owner: CoreProcessOwner.helper, pid: 30);
    windows = _WindowsPort();
    macos = _MacPort();
    elevatedRuns = [];
    elevatedExit = 0;
    serviceInstalled = false;
    failure = null;
    owner = null;
  });

  DesktopPrivilegeCoordinator coordinator({
    String platform = 'linux',
    bool safeMode = false,
    HelperReadinessProbe? ready,
  }) {
    final probe = ready ?? () async => HelperReadiness.notReady;
    return DesktopPrivilegeCoordinator(
      direct: direct,
      linux: helper,
      windows: WindowsGuiElevation(WindowsCoreLauncher(port: windows)),
      windowsService: service,
      windowsServiceReady: probe,
      windowsInstaller: WindowsServiceInstaller(
        readiness: probe,
        servicePath: () => r'C:\ReClash\ReClashService.exe',
        ownerPid: () => 4242,
        readyTimeout: Duration.zero,
        runElevated: (executable, arguments) async {
          elevatedRuns.add('$executable $arguments');
          serviceInstalled = elevatedExit == 0;
          return elevatedExit;
        },
      ),
      macos: MacOSHelperLauncher(port: macos),
      linuxInstaller: LinuxHelperInstaller(
        isLinux: true,
        hasSystemd: () => true,
        helperReadiness: probe,
      ),
      linuxReady: probe,
      readinessFailure: () => failure,
      currentOwner: () => owner,
      platform: platform,
      safeMode: safeMode,
    );
  }

  Future<CoreProcessLease> attempt(CoreProcessLauncher launcher) =>
      launcher.start(sessionId: _sessionId, address: 'test-address');

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
    'background starts run an unprivileged Core instead of failing',
    () async {
      final privileges = coordinator();
      expect(
        await privileges.prepare(tunEnabled: true),
        DesktopPrivilegeDecision.authorizationRequired,
      );
      final lease = await attempt(await privileges.resolve());
      expect(lease.owner, CoreProcessOwner.direct);
      expect(helper.startCount, 0);
    },
  );

  test('a prompt grant alone never installs the Linux Helper', () async {
    final privileges = coordinator();
    expect(
      await privileges.prepare(tunEnabled: true, allowPrompt: true),
      DesktopPrivilegeDecision.authorizationRequired,
    );
    privileges.configure(tunEnabled: true, allowPrompt: true);
    final lease = await attempt(await privileges.resolve());
    expect(lease.owner, CoreProcessOwner.direct);
  });

  test('an install grant is one-shot and revocable', () async {
    final privileges = coordinator()..configure(tunEnabled: true);
    privileges.allowInstall();
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.restartRequired,
    );
    privileges.revokePrompt();
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.authorizationRequired,
    );
    privileges.allowInstall();
    await privileges.resolve();
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.authorizationRequired,
    );
  });

  test('a failed launch suspends elevation until an explicit grant', () async {
    final privileges = coordinator(ready: () async => HelperReadiness.ready)
      ..configure(tunEnabled: true)
      ..suspend();
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.authorizationRequired,
    );
    expect(await privileges.resolve(), same(direct));
    expect(
      await privileges.prepare(tunEnabled: true, allowPrompt: true),
      DesktopPrivilegeDecision.restartRequired,
    );
  });

  test('inspection tells an install from an update', () async {
    final privileges = coordinator();
    failure = const HelperException(code: 'unreachable', message: '');
    expect(
      await privileges.inspect(tunEnabled: true),
      DesktopPrivilegeSetup.install,
    );
    failure = const HelperException(code: 'coreSha256Mismatch', message: '');
    expect(
      await privileges.inspect(tunEnabled: true),
      DesktopPrivilegeSetup.update,
    );
    expect(
      await privileges.inspect(tunEnabled: false),
      DesktopPrivilegeSetup.notRequired,
    );
    owner = CoreProcessOwner.helper;
    expect(
      await privileges.inspect(tunEnabled: true),
      DesktopPrivilegeSetup.active,
    );
  });

  test('a ready Windows service runs TUN without any prompt', () async {
    final privileges = coordinator(
      platform: 'windows',
      ready: () async => HelperReadiness.ready,
    )..configure(tunEnabled: true);
    final lease = await attempt(await privileges.resolve());
    expect(lease.owner, CoreProcessOwner.helper);
    expect(service.startCount, 1);
    expect(elevatedRuns, isEmpty);
  });

  test('Windows installs the service only on an install grant', () async {
    final privileges = coordinator(
      platform: 'windows',
      ready: () async =>
          serviceInstalled ? HelperReadiness.ready : HelperReadiness.notReady,
    )..configure(tunEnabled: true, allowPrompt: true);
    final unprivileged = await attempt(await privileges.resolve());
    expect(unprivileged.owner, CoreProcessOwner.direct);
    expect(elevatedRuns, isEmpty);

    privileges.allowInstall();
    final lease = await attempt(await privileges.resolve());
    expect(lease.owner, CoreProcessOwner.helper);
    expect(elevatedRuns, [
      r'C:\ReClash\ReClashService.exe install --owner-pid 4242',
    ]);
  });

  test('a declined UAC prompt fails typed for the fallback', () async {
    elevatedExit = null;
    final privileges = coordinator(platform: 'windows')
      ..configure(tunEnabled: true)
      ..allowInstall();
    await expectLater(
      attempt(await privileges.resolve()),
      throwsA(
        isA<DesktopPrivilegeException>().having(
          (error) => error.code,
          'code',
          'windows_cancelled',
        ),
      ),
    );
    expect(service.startCount, 0);
  });

  test('an elevated Windows GUI keeps the managed launch', () async {
    windows.elevated = true;
    final privileges = coordinator(platform: 'windows');
    expect(await privileges.resolve(), isA<WindowsCoreLauncher>());
    expect(
      await privileges.prepare(tunEnabled: true),
      DesktopPrivilegeDecision.restartRequired,
    );
  });

  test('only privileged start failures are worth an unprivileged retry', () {
    DesktopCoreFailure failed(Object? cause, {CoreProcessOwner? owner}) =>
        DesktopCoreFailure(
          code: 'start_failed',
          phase: DesktopCorePhase.starting,
          revision: 1,
          owner: owner,
          cause: cause,
        );
    expect(
      isPrivilegedLaunchFailure(
        failed(const DesktopPrivilegeException('linux_cancelled')),
      ),
      isTrue,
    );
    expect(
      isPrivilegedLaunchFailure(
        failed(
          const HelperException(code: 'coreVerificationFailed', message: ''),
        ),
      ),
      isTrue,
    );
    expect(
      isPrivilegedLaunchFailure(
        failed(const DesktopPrivilegeException('launch_cancelled')),
      ),
      isFalse,
    );
    expect(isPrivilegedLaunchFailure(failed(StateError('spawn'))), isFalse);
    expect(
      isPrivilegedLaunchFailure(
        failed(StateError('peer'), owner: CoreProcessOwner.helper),
      ),
      isTrue,
    );
    expect(isPrivilegedLaunchFailure(StateError('other')), isFalse);
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
