import 'dart:math' as math;

import 'models.dart';

/// Levels are on the Vibrate scale and are scaled to each toy's function.
const lovenseReactionSteps = 20;
const lovenseTrafficFloor = 10 * 1024;
const lovenseTrafficCeiling = 10 * 1024 * 1024;
const lovenseTrafficDuration = 3;
const lovenseTrafficInterval = Duration(seconds: 1);
const lovenseTrafficKeepAlive = Duration(seconds: 2);
const lovenseTrafficStale = Duration(seconds: 3);
const lovenseStartSettle = Duration(seconds: 1);

enum LovenseReaction { started, stopped, lost }

class LovensePulse {
  const LovensePulse(this.level, this.on, {this.off = Duration.zero});

  final int level;
  final Duration on;
  final Duration off;
}

/// Pulses are shorter than [lovenseMinDuration], so a lost Stop still ends.
List<LovensePulse> lovenseReactionPattern(LovenseReaction reaction) =>
    switch (reaction) {
      LovenseReaction.started => const [
        LovensePulse(10, Duration(milliseconds: 400)),
      ],
      LovenseReaction.stopped => const [
        LovensePulse(
          10,
          Duration(milliseconds: 250),
          off: Duration(milliseconds: 250),
        ),
        LovensePulse(10, Duration(milliseconds: 250)),
      ],
      LovenseReaction.lost => const [
        LovensePulse(20, Duration(milliseconds: 1500)),
      ],
    };

LovenseFunction? lovenseReactionFunction(LovenseToy toy) {
  if (toy.functions.contains(LovenseFunction.vibrate)) {
    return LovenseFunction.vibrate;
  }
  return toy.functions.firstOrNull;
}

int lovenseScaledStrength(int level, LovenseFunction function) {
  if (level <= 0) return 0;
  final scaled = (level * function.maxStrength / lovenseReactionSteps).round();
  return scaled.clamp(1, function.maxStrength);
}

int lovenseTrafficLevel(num bytesPerSecond) {
  if (bytesPerSecond < lovenseTrafficFloor) return 0;
  if (bytesPerSecond >= lovenseTrafficCeiling) return lovenseReactionSteps;
  final ratio =
      (math.log(bytesPerSecond) - math.log(lovenseTrafficFloor)) /
      (math.log(lovenseTrafficCeiling) - math.log(lovenseTrafficFloor));
  return math.max(1, (ratio * lovenseReactionSteps).round());
}

class LovenseLink {
  const LovenseLink({required this.running, required this.coreConnected});

  final bool running;
  final bool coreConnected;

  bool get up => running && coreConnected;
}

/// The run state flips before a start completes, so a start counts only
/// after staying up for [lovenseStartSettle]; an earlier rollback is silent.
class LovenseLinkTracker {
  LovenseLinkTracker(this._link);

  LovenseLink _link;
  bool _pendingStart = false;

  bool get pendingStart => _pendingStart;

  LovenseReaction? update(LovenseLink next) {
    final previous = _link;
    _link = next;
    if (previous.running && !next.running) {
      if (_pendingStart) {
        _pendingStart = false;
        return null;
      }
      return previous.up ? LovenseReaction.stopped : null;
    }
    if (previous.up && next.running && !next.coreConnected) {
      final settled = !_pendingStart;
      _pendingStart = false;
      return settled ? LovenseReaction.lost : null;
    }
    if (!previous.up && next.up) _pendingStart = true;
    return null;
  }

  LovenseReaction? confirm() {
    if (!_pendingStart) return null;
    _pendingStart = false;
    return _link.up ? LovenseReaction.started : null;
  }
}

/// Sends a changed level or a keep-alive, once per interval; 0 means Stop.
class LovenseTrafficGovernor {
  int _sent = 0;
  Duration? _sentAt;

  int? next(int level, Duration now) {
    final sentAt = _sentAt;
    if (sentAt != null && now - sentAt < lovenseTrafficInterval) return null;
    if (level == _sent &&
        (level == 0 ||
            sentAt == null ||
            now - sentAt < lovenseTrafficKeepAlive)) {
      return null;
    }
    _sent = level;
    _sentAt = now;
    return level;
  }

  void reset() {
    _sent = 0;
    _sentAt = null;
  }
}
