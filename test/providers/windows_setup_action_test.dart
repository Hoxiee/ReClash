import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/desktop/windows_launcher.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _Core extends Mock implements CoreHandlerInterface {}

class _WindowsSetup extends SetupAction {
  bool guiElevated = false;
  bool consent = true;
  int confirmations = 0;
  Completer<bool>? consentGate;
  final confirmationStarted = Completer<void>();
  final messages = <String>[];

  @override
  bool get usesWindowsElevation => true;

  @override
  bool get supportsTunElevation => true;

  @override
  Future<bool> checkGuiElevation() async => guiElevated;

  @override
  Future<bool> confirmTunAuthorization() async {
    confirmations++;
    if (!confirmationStarted.isCompleted) confirmationStarted.complete();
    return await consentGate?.future ?? consent;
  }

  @override
  void showTunAuthorizationError(String message) => messages.add(message);
}

class _FailingWindowsSetup extends _WindowsSetup {
  Completer<void>? launchGate;
  final launchStarted = Completer<void>();
  Object? launchError = const WindowsLaunchException(
    'windows_launch_cancelled',
  );

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    if (!launchStarted.isCompleted) launchStarted.complete();
    await launchGate?.future;
    if (launchError case final Object error) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    await preloadInvoke?.call();
    return true;
  }
}

class _FailedInitController extends CoreController {
  _FailedInitController(super.handler) : super.scoped();

  @override
  Future<bool> init(int version) async => false;
}

class _UnverifiedWindowsSetup extends _WindowsSetup {
  @override
  Future<bool?> requestAdmin(bool enableTun) async => true;
}

class _Common extends CommonAction {
  @override
  Future<void> updateTraffic() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Core core;
  late _WindowsSetup action;
  late ProviderContainer container;
  CoreProcessOwner? owner;
  var listenerAbsent = true;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
    registerFallbackValue(const OdometerSignal(OdometerSignalKind.prepareDown));
    registerFallbackValue(const SetupParams(selectedMap: {}, testUrl: ''));
  });

  void bind(_WindowsSetup setup, {CoreController? controller}) {
    action = setup;
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(
          controller ?? CoreController.scoped(core),
        ),
        setupActionProvider.overrideWith(() => setup),
        commonActionProvider.overrideWith(_Common.new),
      ],
    );
    globalState.container = container;
    container.read(setupActionProvider.notifier);
    container.read(initProvider.notifier).value = true;
    container
        .read(patchClashConfigProvider.notifier)
        .update((value) => value.copyWith.tun(enable: true));
  }

  setUp(() {
    owner = CoreProcessOwner.direct;
    listenerAbsent = true;
    core = _Core();
    when(() => core.processOwner).thenAnswer((_) => owner);
    when(
      () => core.requireTunElevation(
        any(),
        allowPrompt: any(named: 'allowPrompt'),
      ),
    ).thenAnswer(
      (call) async => call.positionalArguments.first == false && listenerAbsent,
    );
    when(() => core.startListener()).thenAnswer((_) async => true);
    when(() => core.stopListener()).thenAnswer((_) async => true);
    when(() => core.signalOdometer(any())).thenAnswer((_) async => true);
    when(() => core.resetTraffic()).thenReturn(null);
    bind(_WindowsSetup());
  });

  tearDown(() async {
    listenerAbsent = true;
    await action.setRunning(false);
    container.dispose();
  });

  test(
    'consent requests a managed restart but does not authorize TUN',
    () async {
      action.beginTunAuthorization();
      expect(await action.requestAdmin(true), isFalse);
      expect(action.confirmations, 1);
      expect(
        container.read(authorizedTunEnableProvider),
        TunAuthorizationState.unauthorized,
      );
      verify(() => core.requireTunElevation(true, allowPrompt: true)).called(1);
    },
  );

  test('only the active managed Core proves authorization', () async {
    owner = CoreProcessOwner.windowsElevated;
    expect(await action.requestAdmin(true), isTrue);
    expect(
      container.read(authorizedTunEnableProvider),
      TunAuthorizationState.authorized,
    );
    expect(action.confirmations, 0);
    verify(() => core.requireTunElevation(true, allowPrompt: false)).called(1);
    verifyNever(() => core.requireTunElevation(true, allowPrompt: true));
  });

  test('silent startup never opens consent or UAC', () async {
    action.beginTunAuthorization(allowPrompt: false);
    expect(await action.requestAdmin(true), isNull);
    expect(action.confirmations, 0);
    verifyNever(() => core.requireTunElevation(true, allowPrompt: true));
  });

  test('simultaneous requests share one consent dialog', () async {
    action.consentGate = Completer<bool>();
    action.beginTunAuthorization();
    final first = action.requestAdmin(true);
    final second = action.requestAdmin(true);
    await action.confirmationStarted.future;
    expect(action.confirmations, 1);
    action.consentGate!.complete(true);
    expect(await first, isFalse);
    expect(await second, isFalse);
    verify(() => core.requireTunElevation(true, allowPrompt: true)).called(1);
  });

  test('Stop invalidates consent before it can grant a launch', () async {
    action.consentGate = Completer<bool>();
    action.beginTunAuthorization();
    final pending = action.requestAdmin(true);
    await action.confirmationStarted.future;
    await action.setRunning(false);
    action.consentGate!.complete(true);
    expect(await pending, isNull);
    verifyNever(() => core.requireTunElevation(true, allowPrompt: true));
    verifyNever(() => core.stopListener());
  });

  test(
    'a declined consent requires a new explicit connection attempt',
    () async {
      action.consent = false;
      action.beginTunAuthorization();
      expect(await action.requestAdmin(true), isNull);
      expect(await action.requestAdmin(true), isNull);
      expect(action.confirmations, 1);
      action.consent = true;
      action.beginTunAuthorization();
      expect(await action.requestAdmin(true), isFalse);
      expect(action.confirmations, 2);
    },
  );

  test('TUN-off restarts an elevated Core for an ordinary GUI', () async {
    owner = CoreProcessOwner.windowsElevated;
    expect(await action.requestAdmin(false), isFalse);
    verify(() => core.requireTunElevation(false, allowPrompt: false)).called(1);
  });

  test('TUN-off does not loop restarts for a manually elevated GUI', () async {
    action.guiElevated = true;
    owner = CoreProcessOwner.windowsElevated;
    expect(await action.requestAdmin(false), isTrue);
    expect(action.confirmations, 0);
  });

  test('TUN-off reuses direct Core and restarts an absent Core', () async {
    expect(await action.requestAdmin(false), isTrue);
    owner = null;
    expect(await action.requestAdmin(false), isFalse);
  });

  test(
    'Stop after a cancelled launch never calls an absent listener',
    () async {
      owner = null;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      action.beginTunAuthorization(allowPrompt: false);
      await action.setRunning(false);
      expect(container.read(coreStatusProvider), CoreStatus.disconnected);
      verify(
        () => core.requireTunElevation(false, allowPrompt: false),
      ).called(1);
      verifyNever(() => core.stopListener());
      verifyNever(() => core.signalOdometer(any()));
      expect(container.read(runTimeProvider), isNull);
    },
  );

  test('a late Stop cannot overwrite the newer connection status', () async {
    container.dispose();
    bind(_FailingWindowsSetup()..launchError = null);
    final cancellation = Completer<bool>();
    when(
      () => core.requireTunElevation(false, allowPrompt: false),
    ).thenAnswer((_) => cancellation.future);
    final stop = action.setRunning(false);
    action.beginTunAuthorization();
    final start = action.setRunning(true);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    cancellation.complete(true);
    expect(await stop, isTrue);
    expect(await start, isTrue);
    expect(container.read(coreStatusProvider), CoreStatus.connected);
    verifyNever(() => core.stopListener());
    verify(() => core.startListener()).called(1);
  });

  test('Stop of a running session still stops the listener', () async {
    owner = CoreProcessOwner.windowsElevated;
    listenerAbsent = false;
    await action.setRunning(false);
    verify(() => core.stopListener()).called(1);
  });

  test('UAC refusal is surfaced once and retry may succeed', () async {
    container.dispose();
    final failing = _FailingWindowsSetup();
    bind(failing);
    expect(await action.setRunning(true), isFalse);
    expect(action.messages, [
      currentAppLocalizations.windowsElevationCancelled,
    ]);
    expect(container.read(runTimeProvider), isNull);
    verifyNever(() => core.startListener());
    failing.launchError = null;
    action.beginTunAuthorization();
    expect(await action.setRunning(true), isTrue);
    verify(() => core.startListener()).called(1);
  });

  test('an absent Core hands consent to the real restart path', () async {
    owner = null;
    when(
      () => core.restart(),
    ).thenThrow(const WindowsLaunchException('windows_launch_cancelled'));
    action.beginTunAuthorization();
    expect(await action.setRunning(true), isFalse);
    expect(action.confirmations, 1);
    expect(action.messages, [
      currentAppLocalizations.windowsElevationCancelled,
    ]);
    verify(() => core.requireTunElevation(true, allowPrompt: true)).called(1);
    verify(() => core.restart()).called(1);
    verifyNever(() => core.setupConfig(any()));
    verifyNever(() => core.startListener());
    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    expect(container.read(runTimeProvider), isNull);
  });

  test('failed elevated init is surfaced through the real handoff', () async {
    container.dispose();
    owner = null;
    bind(_WindowsSetup(), controller: _FailedInitController(core));
    when(() => core.isInit).thenAnswer((_) async => false);
    when(() => core.restart()).thenAnswer((_) async {
      owner = CoreProcessOwner.windowsElevated;
      return const CoreLifecycleResult(
        revision: 1,
        outcome: CoreLifecycleOutcome.applied,
      );
    });
    action.beginTunAuthorization();
    expect(await action.setRunning(true), isFalse);
    expect(action.messages, [currentAppLocalizations.windowsElevationFailed]);
    expect(container.read(coreStatusProvider), CoreStatus.disconnected);
    verify(() => core.restart()).called(1);
    verifyNever(() => core.setupConfig(any()));
    verifyNever(() => core.startListener());
  });

  test(
    'requested TUN cannot apply as an unprivileged proxy-only config',
    () async {
      container.dispose();
      bind(_UnverifiedWindowsSetup());
      expect(await action.setRunning(true), isFalse);
      expect(action.messages, [currentAppLocalizations.windowsElevationFailed]);
      expect(container.read(runTimeProvider), isNull);
      verifyNever(() => core.setupConfig(any()));
      verifyNever(() => core.startListener());
    },
  );

  test('a false listener response cannot report TUN success', () async {
    container.dispose();
    bind(_FailingWindowsSetup()..launchError = null);
    when(() => core.startListener()).thenAnswer((_) async => false);
    expect(await action.setRunning(true), isFalse);
    expect(container.read(runTimeProvider), isNull);
    expect(
      container.read(runRequestStateProvider).fault,
      RunRequestFault.ingressBlocked,
    );
    verify(() => core.startListener()).called(1);
  });

  test('a late UAC failure after Stop cannot re-open error UI', () async {
    container.dispose();
    final failing = _FailingWindowsSetup()..launchGate = Completer<void>();
    bind(failing);
    final start = action.setRunning(true);
    await failing.launchStarted.future;
    await action.setRunning(false);
    failing.launchGate!.complete();
    expect(await start, isFalse);
    expect(action.messages, isEmpty);
    expect(container.read(runTimeProvider), isNull);
    verifyNever(() => core.startListener());
  });
}
