import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:uni_platform/uni_platform.dart';

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

class HotKeyManager extends ConsumerStatefulWidget {
  final Future<Directory> Function()? exportDirectory;
  final Widget child;

  const HotKeyManager({super.key, this.exportDirectory, required this.child});

  @override
  ConsumerState<HotKeyManager> createState() => _HotKeyManagerState();
}

class _HotKeyManagerState extends ConsumerState<HotKeyManager> {
  Future<void> _updates = Future<void>.value();
  LinuxHotkeys? _linuxHotkeys;
  Future<HotkeyPlatformState>? _platform;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
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
  }

  void _enqueue(Future<void> Function() operation) {
    _updates = _updates
        .then((_) => operation())
        .then(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            commonPrint.log('Hotkey update failed: $error');
          },
        );
  }

  void _scheduleUpdate() => _enqueue(_applyHotKeys);

  Future<HotkeyPlatformState> _initializePlatform() async {
    if (!system.isLinux) return const HotkeyPlatformState();
    _linuxHotkeys = LinuxHotkeys(
      onAction: (action) => unawaited(_handleHotKeyAction(action)),
    );
    try {
      return await _linuxHotkeys!.initialize();
    } catch (error) {
      if (mounted) {
        commonPrint.log('Desktop hotkey commands unavailable: $error');
      }
      return const HotkeyPlatformState(systemSupported: false);
    }
  }

  Future<void> _unregisterAll() async {
    try {
      await hotKeyManager.unregisterAll();
    } on MissingPluginException {
      return;
    }
  }

  @override
  void dispose() {
    _linuxHotkeys?.stopListening();
    _enqueue(() async {
      try {
        if (_registered) await _unregisterAll();
      } finally {
        await _linuxHotkeys?.dispose();
      }
    });
    super.dispose();
  }

  Future<void> _handleHotKeyAction(HotAction action) async {
    if (!mounted || ref.read(hotKeyRecordingProvider)) return;
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
        systemAction.updateTun();
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

  Future<void> _applyHotKeys() async {
    if (!mounted) return;
    final platform = await (_platform ??= _initializePlatform());
    if (!mounted) return;
    ref.read(hotKeyPlatformProvider.notifier).value = platform;
    if (_registered ||
        (platform.systemSupported &&
            ref.read(hotKeyActionsProvider).isNotEmpty)) {
      await _unregisterAll();
      _registered = false;
    }
    if (!mounted) return;
    final recording = ref.read(hotKeyRecordingProvider);
    if (platform.applicationId != null) {
      await _linuxHotkeys!.setEnabled(!recording);
    }
    if (!mounted) return;
    final bindings = ref.read(hotKeyActionsProvider);
    final failures = <HotAction, String>{};
    if (platform.systemSupported && !recording) {
      for (final binding in bindings) {
        if (binding.key == null || binding.modifiers.isEmpty) continue;
        try {
          _registered = true;
          await hotKeyManager.register(
            HotKey(
              key: PhysicalKeyboardKey(binding.key!),
              modifiers: binding.modifiers
                  .map((item) => item.toHotKeyModifier())
                  .toList(),
            ),
            keyDownHandler: (_) =>
                unawaited(_handleHotKeyAction(binding.action)),
          );
        } catch (error) {
          failures[binding.action] = '$error';
        }
        if (!mounted) return;
      }
    }
    ref.read(hotKeyFailuresProvider.notifier).value = failures;
    if (platform.applicationId == null) return;
    try {
      final keys = bindings.map((item) => item.key).nonNulls.toSet().toList();
      final names = await _linuxHotkeys!.keyNames([
        for (final key in keys) PhysicalKeyboardKey(key).keyCode ?? 0,
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
            bindings: recording ? const [] : bindings,
            keyNames: keyNames,
          ),
      };
      final directory =
          await (widget.exportDirectory?.call() ??
              appPath.dataDir.future.then(
                (dir) => Directory('${dir.path}/hotkeys'),
              ));
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
      commonPrint.log('Desktop hotkey export failed: $error');
    }
  }

  Widget _buildLocalShortcuts(Widget child) {
    final platform = ref.watch(hotKeyPlatformProvider);
    final recording = ref.watch(hotKeyRecordingProvider);
    final bindings = ref.watch(hotKeyActionsProvider);
    if (platform.systemSupported || recording) return child;
    return Shortcuts(
      shortcuts: {
        for (final binding in bindings)
          if (isValidHotKey(binding.modifiers, binding.key))
            PhysicalHotkeyActivator(binding.key!, binding.modifiers):
                _HotActionIntent(binding.action),
        for (final binding in bindings)
          if (isValidHotKey(binding.modifiers, binding.key))
            PhysicalHotkeyActivator(
              binding.key!,
              binding.modifiers,
              repeatOnly: true,
            ): const DoNothingIntent(),
      },
      child: Actions(
        actions: {
          _HotActionIntent: CallbackAction<_HotActionIntent>(
            onInvoke: (intent) {
              unawaited(_handleHotKeyAction(intent.action));
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }

  Shortcuts _buildCloseShortcuts(Widget child) {
    return Shortcuts(
      shortcuts: {
        controlSingleActivator(LogicalKeyboardKey.keyW):
            const CloseWindowIntent(),
        controlSingleActivator(LogicalKeyboardKey.digit1): const ToPageIntent(
          0,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit2): const ToPageIntent(
          1,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit3): const ToPageIntent(
          2,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit4): const ToPageIntent(
          3,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit5): const ToPageIntent(
          4,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit6): const ToPageIntent(
          5,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit7): const ToPageIntent(
          6,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit8): const ToPageIntent(
          7,
        ),
        controlSingleActivator(LogicalKeyboardKey.digit9): const ToPageIntent(
          8,
        ),
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
            onInvoke: (_) {
              final navigator = globalState.navigatorKey.currentState;
              if (navigator == null) {
                return null;
              }
              globalState.escapeBackDepth++;
              unawaited(
                navigator.maybePop().whenComplete(
                  () => globalState.escapeBackDepth--,
                ),
              );
              return null;
            },
          ),
          ToPageIntent: CallbackAction<ToPageIntent>(
            onInvoke: (intent) {
              final items = ref.read(currentNavigationItemsStateProvider).value;
              if (intent.index >= items.length) return null;
              ref
                  .read(currentPageLabelProvider.notifier)
                  .toPage(items[intent.index].label);
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
  Widget build(BuildContext context) {
    return _buildCloseShortcuts(_buildLocalShortcuts(widget.child));
  }
}

class _HotActionIntent extends Intent {
  const _HotActionIntent(this.action);

  final HotAction action;
}
