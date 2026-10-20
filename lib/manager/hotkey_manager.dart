import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rust_api/rust_api.dart';

extension KeyboardModifierExt on KeyboardModifier {
  HotKeyModifier toHotKeyModifier() {
    return switch (this) {
      KeyboardModifier.alt => HotKeyModifier.alt,
      KeyboardModifier.capsLock => HotKeyModifier.capsLock,
      KeyboardModifier.control => HotKeyModifier.control,
      KeyboardModifier.fn => HotKeyModifier.fn,
      KeyboardModifier.meta => HotKeyModifier.meta,
      KeyboardModifier.shift => HotKeyModifier.shift,
    };
  }
}

extension HotKeyActionExt on HotKeyAction {
  HotKeySpec? toHotKeySpec() {
    final key = this.key;
    if (key == null || modifiers.isEmpty) {
      return null;
    }
    return HotKeySpec(
      id: action.index,
      key: key,
      modifiers: [
        for (final modifier in modifiers) modifier.toHotKeyModifier(),
      ],
    );
  }
}

typedef HotKeyRegistrar =
    Future<List<HotKeyFailure>> Function({required List<HotKeySpec> specs});

class HotKeyManager extends ConsumerStatefulWidget {
  final HotKeyRegistrar? registerHotKeys;
  final Stream<int> Function()? hotKeyEventSource;
  final Future<Directory> Function()? exportDirectory;
  final HotkeyPlatformState? platformState;
  final Widget child;

  const HotKeyManager({
    super.key,
    this.registerHotKeys,
    this.hotKeyEventSource,
    this.exportDirectory,
    this.platformState,
    required this.child,
  });

  @override
  ConsumerState<HotKeyManager> createState() => _HotKeyManagerState();
}

class _HotKeyManagerState extends ConsumerState<HotKeyManager> {
  StreamSubscription<int>? _eventSubscription;
  Future<void> _pendingUpdate = Future.value();
  LinuxHotkeys? _linuxHotkeys;
  Future<HotkeyPlatformState>? _platform;
  bool _registered = false;
  late final HotKeyRegistrar _registerHotKeys =
      widget.registerHotKeys ?? setHotKeys;
  late final Stream<int> Function() _hotKeyEvents =
      widget.hotKeyEventSource ?? hotKeyEvents;

  @override
  void initState() {
    super.initState();
    final safeMode = ref.read(safeModeProvider);
    if (!safeMode) {
      _subscribeHotKeyEvents();
    }
    ref.listenManual(hotKeyActionsProvider, (prev, next) {
      if (!hotKeyActionListEquality.equals(prev, next)) {
        _scheduleUpdate();
      }
    }, fireImmediately: true);
    ref.listenManual(hotKeyRecordingProvider, (prev, next) {
      if (prev != next) {
        _scheduleUpdate();
      }
    });
    ref.listenManual(setupSessionProvider.select((state) => state.active), (
      prev,
      next,
    ) {
      if (prev != next) {
        _scheduleUpdate();
      }
    });
  }

  void _scheduleUpdate() {
    _pendingUpdate = _pendingUpdate.then((_) => _updateHotKeys());
  }

  Future<HotkeyPlatformState> _initializePlatform() async {
    if (widget.platformState case final platformState?) {
      return platformState;
    }
    if (widget.registerHotKeys != null || !system.isLinux) {
      return const HotkeyPlatformState();
    }
    _linuxHotkeys = LinuxHotkeys(
      onAction: (action) => unawaited(_handleHotKeyAction(action)),
    );
    try {
      return await _linuxHotkeys!.initialize();
    } catch (error) {
      commonPrint.log(
        'Desktop hotkey commands unavailable: $error',
        logLevel: LogLevel.warning,
      );
      return const HotkeyPlatformState(systemSupported: false);
    }
  }

  void _subscribeHotKeyEvents() {
    void warn(Object error) {
      commonPrint.log(
        'hotkey events unavailable: $error',
        logLevel: LogLevel.warning,
      );
    }

    try {
      _eventSubscription = _hotKeyEvents().listen(
        _handleHotKeyEvent,
        onError: warn,
      );
    } on StateError catch (error) {
      warn(error);
    }
  }

  void _handleHotKeyEvent(int id) {
    if (id < 0 || id >= HotAction.values.length) {
      return;
    }
    _handleHotKeyAction(HotAction.values[id]);
  }

  bool _allowsAction(HotAction action) =>
      !ref.read(setupSessionProvider).active ||
      action == HotAction.view ||
      action == HotAction.exit;

  Future<void> _handleHotKeyAction(HotAction action) async {
    if (!mounted ||
        ref.read(safeModeProvider) ||
        ref.read(hotKeyRecordingProvider) ||
        !_allowsAction(action)) {
      return;
    }
    final commonAction = ref.read(commonActionProvider.notifier);
    final systemAction = ref.read(systemActionProvider.notifier);
    final setupAction = ref.read(setupActionProvider.notifier);
    switch (action) {
      case HotAction.mode:
        commonAction.updateMode();
      case HotAction.start:
        commonAction.toggleRunning();
      case HotAction.view:
        unawaited(systemAction.updateVisible());
      case HotAction.proxy:
        systemAction.updateSystemProxy();
      case HotAction.tun:
        await systemAction.updateTun();
      case HotAction.ruleMode:
        setupAction.changeMode(Mode.rule);
      case HotAction.globalMode:
        setupAction.changeMode(Mode.global);
      case HotAction.directMode:
        setupAction.changeMode(Mode.direct);
      case HotAction.delayTest:
        unawaited(
          ref
              .read(proxiesActionProvider.notifier)
              .delayTestGroups(ref.read(currentGroupsStateProvider).value),
        );
      case HotAction.updateProfiles:
        unawaited(
          globalState.safeRun(
            ref.read(profilesActionProvider.notifier).updateProfiles,
          ),
        );
      case HotAction.copyEnv:
        unawaited(systemAction.copyProxyEnv());
      case HotAction.exit:
        unawaited(systemAction.handleExit());
    }
  }

  Future<void> _updateHotKeys() async {
    if (!mounted) return;
    final platform = await (_platform ??= _initializePlatform());
    if (!mounted) return;
    ref.read(hotKeyPlatformProvider.notifier).value = platform;
    final isRecording = ref.read(hotKeyRecordingProvider);
    final safeMode = ref.read(safeModeProvider);
    final specs = [
      if (platform.systemSupported && !isRecording && !safeMode)
        for (final action in ref.read(hotKeyActionsProvider))
          if (_allowsAction(action.action)) ?action.toHotKeySpec(),
    ];
    final failed = platform.systemSupported && !safeMode
        ? await _register(specs)
        : <HotAction, String>{};
    _registered = platform.systemSupported && !safeMode && specs.isNotEmpty;
    if (!isRecording && mounted) {
      ref.read(hotKeyFailuresProvider.notifier).value = failed;
    }
    final linuxHotkeys = _linuxHotkeys;
    if (platform.applicationId == null || linuxHotkeys == null) return;
    try {
      await linuxHotkeys.setEnabled(!isRecording && !safeMode);
      final bindings = ref
          .read(hotKeyActionsProvider)
          .where((binding) => _allowsAction(binding.action))
          .toList();
      final keys = bindings.map((item) => item.key).nonNulls.toSet().toList();
      final names = await linuxHotkeys.keyNames([
        for (final key in keys) linuxKeyvalForUsage(key) ?? 0,
      ]);
      final keyNames = <int, String>{
        for (var i = 0; i < keys.length; i++)
          if (names[i] != null) keys[i]: names[i]!,
      };
      final exports = {
        for (final format in HotkeyExportFormat.values)
          format: exportHotkeys(
            format: format,
            applicationId: platform.applicationId!,
            bindings: isRecording ? const [] : bindings,
            keyNames: keyNames,
          ),
      };
      final directory =
          await (widget.exportDirectory?.call() ??
              appPath.homeDirPath.then((path) => Directory('$path/hotkeys')));
      if (!mounted) return;
      await writeHotkeyExports(directory, exports);
      if (!mounted) return;
      ref.read(hotKeyPlatformProvider.notifier).value = HotkeyPlatformState(
        systemSupported: platform.systemSupported,
        applicationId: platform.applicationId,
        exportDirectory: directory.path,
        exports: exports,
      );
    } catch (error) {
      commonPrint.log(
        'Desktop hotkey export failed: $error',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<Map<HotAction, String>> _register(List<HotKeySpec> specs) async {
    try {
      final failures = await _registerHotKeys(specs: specs);
      final failed = {
        for (final failure in failures)
          if (failure.id >= 0 && failure.id < HotAction.values.length)
            HotAction.values[failure.id]: failure.reason,
      };
      for (final MapEntry(:key, :value) in failed.entries) {
        commonPrint.log(
          'hotkey ${key.name} not registered: $value',
          logLevel: LogLevel.warning,
        );
      }
      return failed;
    } catch (error) {
      commonPrint.log(
        'update hotkeys failed: $error',
        logLevel: LogLevel.warning,
      );
      return {for (final spec in specs) HotAction.values[spec.id]: '$error'};
    }
  }

  Widget _buildLocalShortcuts(Widget child) {
    final platform = ref.watch(hotKeyPlatformProvider);
    final isRecording = ref.watch(hotKeyRecordingProvider);
    final bindings = ref.watch(hotKeyActionsProvider);
    if (ref.watch(safeModeProvider) ||
        platform.systemSupported ||
        isRecording) {
      return child;
    }
    return Shortcuts(
      shortcuts: {
        for (final binding in bindings)
          if (_allowsAction(binding.action) &&
              isValidHotKey(binding.modifiers, binding.key))
            PhysicalHotkeyActivator(binding.key!, binding.modifiers):
                _HotActionIntent(binding.action),
        for (final binding in bindings)
          if (_allowsAction(binding.action) &&
              isValidHotKey(binding.modifiers, binding.key))
            PhysicalHotkeyActivator(
              binding.key!,
              binding.modifiers,
              repeatOnly: true,
            ): const DoNothingIntent(),
      },
      child: child,
    );
  }

  Shortcuts _buildCloseShortcuts(Widget child) {
    return Shortcuts(
      shortcuts: {
        controlSingleActivator(LogicalKeyboardKey.keyW):
            const CloseWindowIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const EscapeBackIntent(),
      },
      child: Actions(
        actions: {
          CloseWindowIntent: CallbackAction<CloseWindowIntent>(
            onInvoke: (_) =>
                ref.read(systemActionProvider.notifier).handleClose(false),
          ),
          EscapeBackIntent: CallbackAction<EscapeBackIntent>(
            onInvoke: (_) => globalState.navigatorKey.currentState?.maybePop(),
          ),
          _HotActionIntent: CallbackAction<_HotActionIntent>(
            onInvoke: (intent) {
              unawaited(_handleHotKeyAction(intent.action));
              return null;
            },
          ),
          DoNothingIntent: CallbackAction<DoNothingIntent>(
            onInvoke: (_) => null,
          ),
        },
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    final linuxHotkeys = _linuxHotkeys;
    linuxHotkeys?.stopListening();
    unawaited(
      _pendingUpdate.then((_) async {
        if (_registered) {
          await _register(const []);
        }
        await linuxHotkeys?.dispose();
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(setupSessionProvider.select((state) => state.active));
    return _buildCloseShortcuts(_buildLocalShortcuts(widget.child));
  }
}

class _HotActionIntent extends Intent {
  const _HotActionIntent(this.action);

  final HotAction action;
}
