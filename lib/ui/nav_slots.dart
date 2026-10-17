import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

import 'spring.dart';

class NavSlot<T> {
  NavSlot(this.key, this.weight);

  final T key;
  final NavSpring weight;
  bool leaving = false;
  T? anchor;
}

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
  final List<NavSlot<T>> _slots = [];
  bool _reduceMotion;
  bool _disposed = false;
  bool _sweepScheduled = false;

  List<NavSlot<T>> get slots => _slots;

  set reduceMotion(bool value) {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    if (!value) return;
    for (final slot in _slots) {
      slot.weight.jumpTo(slot.leaving ? 0 : 1);
    }
  }

  void _settle(NavSpring weight, double target) {
    if (_reduceMotion) {
      weight.jumpTo(target);
    } else {
      weight.springTo(target, _spring);
    }
  }

  void seed(List<T> keys) {
    for (final slot in _slots) {
      slot.weight.dispose();
    }
    _slots
      ..clear()
      ..addAll([
        for (final key in _unique(keys))
          NavSlot<T>(key, NavSpring(_vsync, 1))..weight.addListener(_onTick),
      ]);
  }

  void sync(List<T> keys) {
    final orderedKeys = _unique(keys);
    if (_slots.length == orderedKeys.length) {
      var sameOrder = true;
      for (var i = 0; i < orderedKeys.length; i++) {
        if (_slots[i].leaving || _slots[i].key != orderedKeys[i]) {
          sameOrder = false;
          break;
        }
      }
      if (sameOrder) return;
    }
    final present = orderedKeys.toSet();
    final byKey = {for (final slot in _slots) slot.key: slot};

    for (final slot in _slots) {
      if (!present.contains(slot.key) && !slot.leaving) {
        slot
          ..leaving = true
          ..anchor = _livePredecessor(slot);
        _settle(slot.weight, 0);
      }
    }

    for (final slot in _slots) {
      if (slot.leaving && !present.contains(slot.key)) {
        slot.anchor = _resolveAnchor(slot, byKey);
      }
    }

    final leaving = <T?, List<NavSlot<T>>>{};
    for (final slot in _slots) {
      if (slot.leaving && !present.contains(slot.key)) {
        (leaving[slot.anchor] ??= []).add(slot);
      }
    }

    final merged = <NavSlot<T>>[...?leaving[null]];
    for (final key in orderedKeys) {
      final existing = byKey[key];
      if (existing == null) {
        final slot = NavSlot<T>(key, NavSpring(_vsync, 0))
          ..weight.addListener(_onTick);
        merged.add(slot);
        _settle(slot.weight, 1);
      } else {
        if (existing.leaving) {
          existing
            ..leaving = false
            ..anchor = null;
          _settle(existing.weight, 1);
        }
        merged.add(existing);
      }
      final anchored = leaving[key];
      if (anchored != null) {
        merged.addAll(anchored.where((slot) => slot.leaving));
      }
    }

    final retained = merged.toSet();
    for (final slot in _slots) {
      if (!retained.contains(slot)) {
        slot.weight
          ..removeListener(_onTick)
          ..dispose();
      }
    }
    _slots
      ..clear()
      ..addAll(merged);
    notifyListeners();
  }

  List<T> _unique(List<T> keys) {
    final seen = <T>{};
    return [
      for (final key in keys)
        if (seen.add(key)) key,
    ];
  }

  T? _resolveAnchor(NavSlot<T> slot, Map<T, NavSlot<T>> byKey) {
    var anchor = slot.anchor;
    final seen = <T>{slot.key};
    while (anchor != null) {
      if (!seen.add(anchor)) return null;
      final predecessor = byKey[anchor];
      if (predecessor == null) return null;
      if (!predecessor.leaving) return anchor;
      anchor = predecessor.anchor;
    }
    return null;
  }

  T? _livePredecessor(NavSlot<T> slot) {
    final index = _slots.indexOf(slot);
    for (var i = index - 1; i >= 0; i--) {
      if (!_slots[i].leaving) return _slots[i].key;
    }
    return null;
  }

  void _onTick() {
    if (_disposed) return;
    notifyListeners();
    final hasCollapsed = _slots.any(
      (slot) => slot.leaving && slot.weight.value <= 0.001,
    );
    if (hasCollapsed && !_sweepScheduled) {
      _sweepScheduled = true;
      scheduleMicrotask(_sweepCollapsed);
    }
  }

  void _sweepCollapsed() {
    _sweepScheduled = false;
    if (_disposed) return;
    final collapsed = _slots
        .where((slot) => slot.leaving && slot.weight.value <= 0.001)
        .toList();
    if (collapsed.isEmpty) return;

    final byKey = {for (final slot in _slots) slot.key: slot};
    for (final slot in _slots) {
      if (!slot.leaving || collapsed.contains(slot)) continue;
      slot.anchor = _resolveAnchor(slot, byKey);
    }
    final removed = collapsed.toSet();
    _slots.removeWhere(removed.contains);
    for (final slot in collapsed) {
      slot.weight
        ..removeListener(_onTick)
        ..dispose();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final slot in _slots) {
      slot.weight
        ..removeListener(_onTick)
        ..dispose();
    }
    _slots.clear();
    super.dispose();
  }
}
