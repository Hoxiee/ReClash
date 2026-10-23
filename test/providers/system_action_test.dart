import 'dart:async';
import 'dart:ui' show Brightness, Color;

import 'package:reclash/common/app_ports.dart';
import 'package:reclash/common/preferences.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/models/config.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/web_dashboard.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/actions/system_exit.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/preferences.dart';

class TestSystemAction extends SystemAction {
  final List<String> calls = [];
  final List<bool> cleanupNeedSave = [];
  Completer<void>? closeCoreGate;
  Object? cleanupError;
  Duration watchdog = const Duration(hours: 1);

  @override
  Duration get exitWatchdogDuration => watchdog;

  @override
  Future<void> cleanupExitResources(bool needSave) async {
    calls.add('cleanup');
    cleanupNeedSave.add(needSave);
    final error = cleanupError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }

  @override
  Future<void> closeWindow() async => calls.add('window');

  @override
  Future<void> closeCore() async {
    calls.add('core');
    final gate = closeCoreGate;
    if (gate != null) {
      await gate.future;
    }
  }

  @override
  Future<void> exitApplication() async => calls.add('exit');
}

class _ResetSystemAction extends TestSystemAction {
  Object? deleteError;

  @override
  Future<void> disableAutoLaunch() async => calls.add('disable autolaunch');

  @override
  Future<void> deleteAllData() async {
    calls.add('delete');
    if (deleteError case final error?) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }
}

class _TunCore extends Mock implements CoreHandlerInterface {
  int revocations = 0;

  @override
  void revokePrivilegePrompt() => revocations++;
}

class _TunSetupAction extends SetupAction {
  final prompts = <bool>[];
  int updates = 0;

  @override
  Future<void> updateConfig() async => updates++;

  @override
  Future<DesktopPrivilegeDecision> preparePrivilege({
    required bool tunEnabled,
    required bool allowPrompt,
  }) async {
    prompts.add(allowPrompt);
    return allowPrompt
        ? DesktopPrivilegeDecision.restartRequired
        : DesktopPrivilegeDecision.authorizationRequired;
  }
}

class _PersistenceSystemAction extends SystemAction {
  Future<void> persist() => savePreferences();
}

class _GeometryWindowPort implements WindowPort {
  final WindowProps geometry;
  final Error? error;

  _GeometryWindowPort(this.geometry, {this.error});

  @override
  Future<WindowProps?> captureNormalGeometry(WindowProps current) async {
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return geometry;
  }

  @override
  Future<bool> setBlur({
    required bool enabled,
    required Brightness brightness,
    required Color tint,
  }) async => false;

  @override
  Future<void> close() async {}

  @override
  void forceExit() {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> toggle() async {}

  @override
  Future<void> show() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'full reset stops Core before deletion and exits without saving',
    () async {
      final core = _TunCore();
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          systemActionProvider.overrideWith(_ResetSystemAction.new),
        ],
      );
      addTearDown(container.dispose);
      final action =
          container.read(systemActionProvider.notifier) as _ResetSystemAction;
      when(() => core.stop()).thenAnswer((_) async {
        action.calls.add('stop');
        return const CoreLifecycleResult(
          revision: 1,
          outcome: CoreLifecycleOutcome.applied,
        );
      });

      await action.resetAllDataAndExit();

      expect(action.calls, [
        'stop',
        'cleanup',
        'core',
        'disable autolaunch',
        'delete',
        'cleanup',
        'window',
        'core',
        'exit',
      ]);
      expect(action.cleanupNeedSave, [false, false]);
    },
  );

  test('reset never deletes files when stopping Core fails', () async {
    final core = _TunCore();
    when(() => core.stop()).thenThrow(StateError('Core still running'));
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        systemActionProvider.overrideWith(_ResetSystemAction.new),
      ],
    );
    addTearDown(container.dispose);
    final action =
        container.read(systemActionProvider.notifier) as _ResetSystemAction;

    await expectLater(action.resetAllDataAndExit(), throwsStateError);
    expect(action.calls, isEmpty);
  });

  test(
    'failed deletion is reported without claiming reset or exiting',
    () async {
      final core = _TunCore();
      when(() => core.stop()).thenAnswer(
        (_) async => const CoreLifecycleResult(
          revision: 1,
          outcome: CoreLifecycleOutcome.applied,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          systemActionProvider.overrideWith(_ResetSystemAction.new),
        ],
      );
      addTearDown(container.dispose);
      final action =
          container.read(systemActionProvider.notifier) as _ResetSystemAction;
      action.deleteError = StateError('permission denied');

      await expectLater(action.resetAllDataAndExit(), throwsStateError);
      expect(action.calls, ['cleanup', 'core', 'disable autolaunch', 'delete']);
    },
  );

  test(
    'reset retries deletion without stopping a terminally closed Core',
    () async {
      final core = _TunCore();
      when(() => core.stop()).thenAnswer(
        (_) async => const CoreLifecycleResult(
          revision: 1,
          outcome: CoreLifecycleOutcome.applied,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          systemActionProvider.overrideWith(_ResetSystemAction.new),
        ],
      );
      addTearDown(container.dispose);
      final action =
          container.read(systemActionProvider.notifier) as _ResetSystemAction;
      action.deleteError = StateError('permission denied');
      await expectLater(action.resetAllDataAndExit(), throwsStateError);
      action.deleteError = null;

      await action.resetAllDataAndExit();

      verify(() => core.stop()).called(1);
      expect(action.calls.where((call) => call == 'delete'), hasLength(2));
      expect(action.calls.last, 'exit');
    },
  );

  test('coalesces repeated exit requests and runs cleanup once', () async {
    final closeCoreCompleter = Completer<void>();
    final calls = <String>[];
    final coordinator = SystemExitCoordinator(
      watchdogDuration: const Duration(hours: 1),
      closeWindow: () async => calls.add('window'),
      closeCore: () async {
        calls.add('core');
        await closeCoreCompleter.future;
      },
      exitApplication: () async => calls.add('exit'),
    );

    final first = coordinator.exit(cleanup: () async => calls.add('cleanup'));
    final second = coordinator.exit(
      cleanup: () async => calls.add('unexpected cleanup'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(identical(first, second), isTrue);
    expect(calls, ['cleanup', 'window', 'core']);

    closeCoreCompleter.complete();
    await Future.wait([first, second]);

    expect(calls, ['cleanup', 'window', 'core', 'exit']);
  });

  test('watchdog and normal completion share one application exit', () async {
    final closeCoreCompleter = Completer<void>();
    var exitCount = 0;
    final coordinator = SystemExitCoordinator(
      watchdogDuration: const Duration(milliseconds: 1),
      closeWindow: () async {},
      closeCore: () => closeCoreCompleter.future,
      exitApplication: () async => exitCount++,
    );

    final operation = coordinator.exit(cleanup: () async {});
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(exitCount, 1);
    closeCoreCompleter.complete();
    await operation;
    expect(exitCount, 1);
  });

  test('cleanup failure does not skip window or Core shutdown', () async {
    final calls = <String>[];
    final coordinator = SystemExitCoordinator(
      watchdogDuration: const Duration(hours: 1),
      closeWindow: () async => calls.add('window'),
      closeCore: () async => calls.add('core'),
      exitApplication: () async => calls.add('exit'),
    );

    await expectLater(
      coordinator.exit(
        cleanup: () async {
          calls.add('cleanup');
          throw StateError('cleanup failed');
        },
      ),
      throwsStateError,
    );

    expect(calls, ['cleanup', 'window', 'core', 'exit']);
  });

  group('SystemAction exit orchestration', () {
    late TestSystemAction action;
    late ProviderContainer container;

    setUp(() {
      action = TestSystemAction();
      container = ProviderContainer(
        overrides: [systemActionProvider.overrideWith(() => action)],
      );
      globalState.container = container;
      container.read(systemActionProvider.notifier);
    });

    tearDown(() {
      final gate = action.closeCoreGate;
      if (gate != null && !gate.isCompleted) {
        gate.complete();
      }
      container.dispose();
    });

    SystemAction notifier() => container.read(systemActionProvider.notifier);

    test('runs cleanup, window, Core and application exit in order', () async {
      await notifier().handleExit();

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
      expect(action.cleanupNeedSave, [true]);
    });

    test(
      'application exit revokes browser access without persisting it',
      () async {
        container.listen(configProvider, (_, _) {}, fireImmediately: true);
        final saved = container.read(configProvider);
        final access = container.read(webDashboardAccessProvider.notifier);
        final owner = access.acquire(WebDashboardFlavor.zashboard);
        access.keepForBrowser(owner);
        expect(container.read(webDashboardAccessProvider).browser, isTrue);

        await notifier().handleExit();

        expect(access.contains(owner), isFalse);
        expect(
          container.read(webDashboardAccessProvider).temporarySecret,
          isEmpty,
        );
        expect(container.read(configProvider), saved);
        expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
      },
    );

    test('forwards an explicit save opt-out to resource cleanup', () async {
      await notifier().handleExit(false);

      expect(action.cleanupNeedSave, [false]);
    });

    test('concurrent exit requests share one shutdown', () async {
      action.closeCoreGate = Completer<void>();

      final first = notifier().handleExit();
      final second = notifier().handleExit(true);
      await Future<void>.delayed(Duration.zero);

      expect(action.calls, ['cleanup', 'window', 'core']);

      action.closeCoreGate!.complete();
      await Future.wait([first, second]);

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
      expect(action.cleanupNeedSave, [true]);
    });

    test('a later exit request never restarts a finished shutdown', () async {
      await notifier().handleExit();
      await notifier().handleExit();

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
    });

    test(
      'the watchdog exits the application when Core shutdown hangs',
      () async {
        action.watchdog = const Duration(milliseconds: 1);
        action.closeCoreGate = Completer<void>();

        final operation = notifier().handleExit();
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(action.calls, ['cleanup', 'window', 'core', 'exit']);

        action.closeCoreGate!.complete();
        await operation;

        expect(
          action.calls.where((call) => call == 'exit').length,
          1,
          reason: 'the watchdog and normal completion share one exit',
        );
      },
    );

    test('a cleanup failure still closes the window, Core and app', () async {
      action.cleanupError = StateError('cleanup failed');

      await expectLater(notifier().handleExit(), throwsStateError);

      expect(action.calls, ['cleanup', 'window', 'core', 'exit']);
    });
  });

  test(
    'saving preferences captures the latest normal window geometry',
    () async {
      await mockPreferences();
      const geometry = WindowProps(width: 1180, height: 760, left: 72, top: 48);
      windowPort = _GeometryWindowPort(geometry);
      final action = _PersistenceSystemAction();
      final container = ProviderContainer(
        overrides: [systemActionProvider.overrideWith(() => action)],
      );
      globalState.container = container;
      addTearDown(() {
        windowPort = null;
        container.dispose();
      });

      container.read(systemActionProvider.notifier);
      await action.persist();

      expect(container.read(windowSettingProvider), geometry);
      expect((await preferences.getConfig())?.windowProps, geometry);
    },
  );

  test(
    'a geometry failure does not prevent saving the current config',
    () async {
      await mockPreferences();
      const current = WindowProps(width: 900, height: 640, left: 24, top: 16);
      windowPort = _GeometryWindowPort(
        const WindowProps(),
        error: StateError('window unavailable'),
      );
      final action = _PersistenceSystemAction();
      final container = ProviderContainer(
        overrides: [
          windowSettingProvider.overrideWithBuild((_, _) => current),
          systemActionProvider.overrideWith(() => action),
        ],
      );
      globalState.container = container;
      addTearDown(() {
        windowPort = null;
        container.dispose();
      });

      container.read(systemActionProvider.notifier);
      await action.persist();

      expect((await preferences.getConfig())?.windowProps, current);
    },
  );

  group('SystemAction setting toggles', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      globalState.container = container;
    });

    tearDown(() => container.dispose());

    test('TUN commands grant one prompt through the setup owner', () async {
      final core = _TunCore();
      final scoped = ProviderContainer(
        overrides: [
          safeModeProvider.overrideWithValue(false),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          setupActionProvider.overrideWith(_TunSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      scoped
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith.tun(enable: false));
      final setup =
          scoped.read(setupActionProvider.notifier) as _TunSetupAction;
      await scoped.read(systemActionProvider.notifier).updateTun();
      expect(scoped.read(patchClashConfigProvider).tun.enable, isTrue);
      expect(setup.updates, 1);
      expect(await setup.requestAdmin(true), isFalse);
      await expectLater(
        setup.requestAdmin(true),
        throwsA(
          isA<DesktopPrivilegeException>().having(
            (error) => error.code,
            'code',
            'authorization_required',
          ),
        ),
      );
      expect(setup.prompts, [true, false]);
    });

    test('disabling TUN by command revokes a pending prompt', () async {
      final core = _TunCore();
      final scoped = ProviderContainer(
        overrides: [
          safeModeProvider.overrideWithValue(false),
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          setupActionProvider.overrideWith(_TunSetupAction.new),
        ],
      );
      addTearDown(scoped.dispose);
      scoped
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith.tun(enable: false));
      final system = scoped.read(systemActionProvider.notifier);
      await system.updateTun();
      await system.updateTun();
      expect(scoped.read(patchClashConfigProvider).tun.enable, isFalse);
      expect(core.revocations, 1);
      final setup =
          scoped.read(setupActionProvider.notifier) as _TunSetupAction;
      await expectLater(
        setup.requestAdmin(true),
        throwsA(isA<DesktopPrivilegeException>()),
      );
      expect(setup.prompts, [false]);
      expect(setup.updates, 2);
    });

    test('updateSystemProxy flips the system proxy flag', () {
      final before = container.read(networkSettingProvider).systemProxy;

      container.read(systemActionProvider.notifier).updateSystemProxy();

      expect(container.read(networkSettingProvider).systemProxy, !before);
    });

    test('updateAutoLaunch flips the auto launch flag', () {
      final before = container.read(appSettingProvider).autoLaunch;

      container.read(systemActionProvider.notifier).updateAutoLaunch();

      expect(container.read(appSettingProvider).autoLaunch, !before);
    });
  });
}
