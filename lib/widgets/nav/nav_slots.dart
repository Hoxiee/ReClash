import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:reclash/widgets/nav/nav_motion.dart';

/// One entry in an animated navigation strip. [weight] runs 0..1: it grows
/// from 0 as the entry enters and falls back to 0 as it leaves, so neighbours
/// slide into or out of the room it takes rather than popping.
class NavSlot<T> {
  NavSlot(this.key, this.weight);

  final T key;
  final NavSpring weight;

  /// A leaving slot keeps its place among the live ones while it collapses,
  /// then drops out once its weight settles at zero.
  bool leaving = false;

  /// The nearest live predecessor when the slot began leaving, so it stays
  /// anchored between the same neighbours while it shrinks. Null parks it at
  /// the strip's head.
  T? anchor;
}

/// Keeps a navigation strip's membership animating: new keys grow in and
/// removed keys collapse out, both on a spring, while the controller notifies
/// every frame so a strip can re-lay itself by the live weights.
///
/// Shared by the mobile dock ([weight] as a horizontal share) and the desktop
/// rail ([weight] as a vertical height factor).
class NavSlots<T> extends ChangeNotifier {
  NavSlots({
    required TickerProvider vsync,
    required SpringDescription spring,
    bool reduceMotion = false,
  }) : _vsync = vsync,
       _spring = spring,
       _reduceMotion = reduceMotion;

  final TickerProvider _vsync;
  final SpringDescription _spring;
  bool _reduceMotion;

  final List<NavSlot<T>> _slots = [];

  /// The live and still-collapsing slots, in display order.
  List<NavSlot<T>> get slots => _slots;

  set reduceMotion(bool value) => _reduceMotion = value;

  void _settle(NavSpring spring, double target) {
    if (_reduceMotion) {
      spring.jumpTo(target);
    } else {
      spring.springTo(target, _spring);
    }
  }

  /// Primes the strip to [keys] with no animation, for the first build.
  void seed(List<T> keys) {
    for (final slot in _slots) {
      slot.weight.dispose();
    }
    _slots
      ..clear()
      ..addAll([
        for (final key in keys)
          NavSlot<T>(key, NavSpring(_vsync, 1))..weight.addListener(_onTick),
      ]);
  }

  /// Reconciles the live set to [keys] in their given order: absent keys
  /// collapse out, new keys grow in, and a key that returns before it finished
  /// leaving simply grows back.
  void sync(List<T> keys) {
    final present = keys.toSet();
    for (final slot in _slots) {
      if (!present.contains(slot.key) && !slot.leaving) {
        slot.leaving = true;
        slot.anchor = _livePredecessor(slot);
        _settle(slot.weight, 0);
      }
    }

    final byKey = {for (final slot in _slots) slot.key: slot};
    // A leaving slot whose key returns in [keys] is revived at its own
    // position in the loop below; anchoring it as an orphan too would add the
    // same slot twice. Only genuinely-gone keys ride the anchor map.
    final leaving = <T?, List<NavSlot<T>>>{};
    for (final slot in _slots) {
      if (slot.leaving && !present.contains(slot.key)) {
        (leaving[slot.anchor] ??= []).add(slot);
      }
    }

    final merged = <NavSlot<T>>[...?leaving[null]];
    for (final key in keys) {
      final existing = byKey[key];
      if (existing != null) {
        if (existing.leaving) {
          existing.leaving = false;
          existing.anchor = null;
          _settle(existing.weight, 1);
        }
        merged.add(existing);
      } else {
        final slot = NavSlot<T>(key, NavSpring(_vsync, 0))
          ..weight.addListener(_onTick);
        merged.add(slot);
        _settle(slot.weight, 1);
      }
      final anchored = leaving[key];
      if (anchored != null) {
        merged.addAll(anchored.where((slot) => slot.leaving));
      }
    }

    _slots
      ..clear()
      ..addAll(merged);
    notifyListeners();
  }

  T? _livePredecessor(NavSlot<T> slot) {
    final index = _slots.indexOf(slot);
    for (var i = index - 1; i >= 0; i--) {
      if (!_slots[i].leaving) {
        return _slots[i].key;
      }
    }
    return null;
  }

  bool _sweepScheduled = false;

  void _onTick() {
    notifyListeners();
    final hasCollapsed = _slots.any(
      (slot) => slot.leaving && slot.weight.value <= 0.001,
    );
    if (hasCollapsed && !_sweepScheduled) {
      // Drop collapsed slots after the frame: disposing a spring inside its
      // own tick, while it is still notifying, is unsafe.
      _sweepScheduled = true;
      scheduleMicrotask(_sweepCollapsed);
    }
  }

  void _sweepCollapsed() {
    _sweepScheduled = false;
    final collapsed = _slots
        .where((slot) => slot.leaving && slot.weight.value <= 0.001)
        .toList();
    if (collapsed.isEmpty) {
      return;
    }
    for (final slot in collapsed) {
      _slots.remove(slot);
      slot.weight.dispose();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final slot in _slots) {
      slot.weight.dispose();
    }
    _slots.clear();
    super.dispose();
  }
}
