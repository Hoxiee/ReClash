import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/route_state.g.dart';

/// What a probe answer is judged against. Nothing is fresh until the Core's
/// counters have been read, otherwise every answer would fail the epoch
/// check and be asked again forever.
@immutable
class RouteState {
  const RouteState({
    this.coreEpoch = 0,
    this.picksVersion = 0,
    this.picks = const {},
    this.hostEpoch = 0,
    this.proxied = false,
    this.synced = false,
    this.live = false,
    this.resumes = 0,
  });

  final int coreEpoch;
  final int picksVersion;
  final Map<String, String> picks;
  final int hostEpoch;
  final bool proxied;
  final bool synced;
  final bool live;
  final int resumes;

  RouteState copyWith({
    int? coreEpoch,
    int? picksVersion,
    Map<String, String>? picks,
    int? hostEpoch,
    bool? proxied,
    bool? synced,
    bool? live,
    int? resumes,
  }) {
    return RouteState(
      coreEpoch: coreEpoch ?? this.coreEpoch,
      picksVersion: picksVersion ?? this.picksVersion,
      picks: picks ?? this.picks,
      hostEpoch: hostEpoch ?? this.hostEpoch,
      proxied: proxied ?? this.proxied,
      synced: synced ?? this.synced,
      live: live ?? this.live,
      resumes: resumes ?? this.resumes,
    );
  }

  /// A chain stays fresh while every group on it still picks the hop below
  /// it; groups the picks do not name, load balancers among them, cannot
  /// contradict it. An answer with no chain is tied to the selection version
  /// it was made under instead.
  bool isFresh(RouteStamp stamp) {
    if (!synced ||
        stamp.coreEpoch != coreEpoch ||
        stamp.hostEpoch != hostEpoch ||
        stamp.proxied != proxied) {
      return false;
    }
    final chains = stamp.chains;
    if (chains.isEmpty) {
      return stamp.picksVersion == picksVersion;
    }
    for (var i = chains.length - 1; i >= 1; i--) {
      final next = picks[chains[i]];
      if (next != null && next != chains[i - 1]) {
        return false;
      }
    }
    return true;
  }

  bool isBehind(RouteStamp stamp) =>
      stamp.coreEpoch > coreEpoch || stamp.picksVersion > picksVersion;

  @override
  bool operator ==(Object other) =>
      other is RouteState &&
      other.coreEpoch == coreEpoch &&
      other.picksVersion == picksVersion &&
      mapEquals(other.picks, picks) &&
      other.hostEpoch == hostEpoch &&
      other.proxied == proxied &&
      other.synced == synced &&
      other.live == live &&
      other.resumes == resumes;

  @override
  int get hashCode => Object.hash(
    coreEpoch,
    picksVersion,
    Object.hashAllUnordered(
      picks.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    hostEpoch,
    proxied,
    synced,
    live,
    resumes,
  );
}

@immutable
class RouteStamp {
  const RouteStamp({
    required this.coreEpoch,
    required this.picksVersion,
    required this.hostEpoch,
    required this.proxied,
    this.chains = const [],
  });

  final int coreEpoch;
  final int picksVersion;
  final int hostEpoch;
  final bool proxied;
  final List<String> chains;

  @override
  bool operator ==(Object other) =>
      other is RouteStamp &&
      other.coreEpoch == coreEpoch &&
      other.picksVersion == picksVersion &&
      other.hostEpoch == hostEpoch &&
      other.proxied == proxied &&
      listEquals(other.chains, chains);

  @override
  int get hashCode => Object.hash(
    coreEpoch,
    picksVersion,
    hostEpoch,
    proxied,
    Object.hashAll(chains),
  );
}

@Riverpod(keepAlive: true)
class RouteTracker extends _$RouteTracker {
  int _watchers = 0;
  int _generation = 0;
  bool _syncing = false;
  bool _resubscribe = false;
  bool _active = true;

  @override
  RouteState build() {
    ref.listen(isStartProvider, (_, _) => _syncProxied());
    ref.listen(initProvider, (_, _) => _subscribe());
    ref.listen(coreStatusProvider, (_, status) {
      if (status == CoreStatus.connected) {
        _subscribe();
      } else {
        _dropSync();
      }
    });
    return RouteState(proxied: _proxied);
  }

  bool get _proxied => ref.read(isStartProvider);

  bool get _ready =>
      _watchers > 0 &&
      _active &&
      ref.read(initProvider) &&
      ref.read(coreStatusProvider) == CoreStatus.connected;

  void attach() {
    if (++_watchers == 1) {
      _subscribe();
    }
  }

  void detach() {
    if (_watchers == 0) {
      return;
    }
    if (--_watchers == 0) {
      _unsubscribe();
    }
  }

  /// Reads the Core's counters again; a cache asks for this when an answer
  /// carries a newer epoch than the state, which means an event was missed.
  void resync() => _subscribe();

  /// The host pushes lifecycle here instead of a visibility provider: while
  /// backgrounded on Android the watch is released and picked up on return.
  /// A desktop window reports visibility through [setVisible] instead, since
  /// its lifecycle events do not track a minimized window.
  void updateActivity({
    required AppLifecycleState? lifecycleState,
    required bool isAndroid,
  }) {
    if (!isAndroid) {
      return;
    }
    final active =
        lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed ||
        lifecycleState == AppLifecycleState.inactive;
    _setActive(active);
  }

  /// A minimized desktop window has nothing to probe for; the window manager
  /// toggles this so the route watch sleeps until the window comes back.
  void setVisible(bool visible) => _setActive(visible);

  void _setActive(bool active) {
    if (active == _active) {
      return;
    }
    _active = active;
    if (_watchers == 0) {
      return;
    }
    if (active) {
      _subscribe();
    } else {
      _unsubscribe();
    }
  }

  void applySnapshot(RouteSnapshot snapshot) {
    state = state.copyWith(
      coreEpoch: snapshot.coreEpoch,
      picksVersion: snapshot.picksVersion,
      picks: snapshot.picks,
      hostEpoch: state.synced ? state.hostEpoch : state.hostEpoch + 1,
      synced: true,
      live: true,
    );
  }

  void bumpHostEpoch() {
    state = state.copyWith(hostEpoch: state.hostEpoch + 1);
  }

  void markResumed() {
    state = state.copyWith(resumes: state.resumes + 1);
  }

  void _syncProxied() {
    final proxied = _proxied;
    if (proxied != state.proxied) {
      state = state.copyWith(proxied: proxied);
    }
  }

  Future<void> _subscribe() async {
    if (!_ready) {
      return;
    }
    if (_syncing) {
      _resubscribe = true;
      return;
    }
    _syncing = true;
    _resubscribe = false;
    final generation = ++_generation;
    RouteSnapshot? snapshot;
    try {
      snapshot = await ref.read(coreHandlerProvider).watchRoute(true);
    } catch (error) {
      commonPrint.log(
        'watchRoute failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    } finally {
      _syncing = false;
    }
    if (!ref.mounted) {
      return;
    }
    if (generation == _generation && snapshot != null) {
      applySnapshot(snapshot);
    }
    if (_resubscribe) {
      unawaited(_subscribe());
    }
  }

  /// Deferred because a widget releases its target from dispose.
  void _unsubscribe() {
    final generation = ++_generation;
    scheduleMicrotask(() {
      if (ref.mounted && generation == _generation && state.live) {
        state = state.copyWith(live: false);
      }
    });
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    unawaited(
      ref.read(coreHandlerProvider).watchRoute(false).catchError((
        Object error,
      ) {
        commonPrint.log(
          'watchRoute release failed: $error',
          logLevel: coreFailureLogLevel(error),
        );
        return null;
      }),
    );
  }

  void _dropSync() {
    _generation++;
    if (state.synced || state.live) {
      state = state.copyWith(synced: false, live: false);
    }
  }
}
