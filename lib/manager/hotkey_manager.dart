import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

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
  final Widget child;

  const HotKeyManager({super.key, required this.child});

  @override
  ConsumerState<HotKeyManager> createState() => _HotKeyManagerState();
}

class _HotKeyManagerState extends ConsumerState<HotKeyManager> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(hotKeyActionsProvider, (prev, next) {
      if (!hotKeyActionListEquality.equals(prev, next)) {
        _updateHotKeys(hotKeyActions: next);
      }
    }, fireImmediately: true);
  }

  Future<void> _handleHotKeyAction(HotAction action) async {
    final commonAction = ref.read(commonActionProvider.notifier);
    final systemAction = ref.read(systemActionProvider.notifier);
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
    }
  }

  Future<void>? _updating;

  Future<void> _updateHotKeys({required List<HotKeyAction> hotKeyActions}) {
    final run = (_updating ?? Future<void>.value()).then(
      (_) => _applyHotKeys(hotKeyActions: hotKeyActions),
    );
    _updating = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<void> _applyHotKeys({
    required List<HotKeyAction> hotKeyActions,
  }) async {
    await hotKeyManager.unregisterAll();
    final hotkeyActionHandles = hotKeyActions
        .where((hotKeyAction) {
          return hotKeyAction.key != null && hotKeyAction.modifiers.isNotEmpty;
        })
        .map<Future>((hotKeyAction) async {
          final modifiers = hotKeyAction.modifiers
              .map((item) => item.toHotKeyModifier())
              .toList();
          final hotKey = HotKey(
            key: PhysicalKeyboardKey(hotKeyAction.key!),
            modifiers: modifiers,
          );
          return hotKeyManager.register(
            hotKey,
            keyDownHandler: (_) {
              _handleHotKeyAction(hotKeyAction.action);
            },
          );
        });
    await Future.wait(hotkeyActionHandles);
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
    return _buildCloseShortcuts(widget.child);
  }
}
