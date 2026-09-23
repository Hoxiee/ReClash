import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../desktop/system.dart';

/// `:focus-visible` semantics: a mouse counts as `traditional` in Flutter's
/// highlight mode, so a pointer here hides the ring and a nav key shows it.
class FocusHighlightVisibility {
  FocusHighlightVisibility._();

  static final ValueNotifier<bool> _visible = ValueNotifier<bool>(system.isTV);

  static ValueListenable<bool> get visible => _visible;

  static set visibleForTesting(bool value) => _visible.value = value;

  static bool _installed = false;

  static void ensureInstalled() {
    if (_installed) {
      return;
    }
    _installed = true;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointer);
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  static void _handlePointer(PointerEvent event) {
    if (event is PointerDownEvent || event is PointerSignalEvent) {
      _visible.value = false;
    }
  }

  static bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && _navigationKeys.contains(event.logicalKey)) {
      _visible.value = true;
    }
    return false;
  }

  static final Set<LogicalKeyboardKey> _navigationKeys = {
    LogicalKeyboardKey.tab,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.select,
    LogicalKeyboardKey.gameButtonA,
  };
}
