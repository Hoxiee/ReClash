import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:reclash/common/finding_events.dart';
import 'package:reclash/providers/milestones.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/connection_doctor.g.dart';

const unsupportedDoctorSnapshot = DoctorSnapshot(
  state: DoctorExamState.observing,
  health: DoctorHealth.unknown,
  confidence: DoctorConfidence.insufficient,
  severity: DoctorSeverity.info,
);

@Riverpod(keepAlive: true)
class ConnectionDoctor extends _$ConnectionDoctor {
  Future<DoctorSnapshot>? _refreshing;
  Timer? _freshnessTimer;
  DoctorSnapshot _freshnessSnapshot = unsupportedDoctorSnapshot;
  int _minimumRevision = 0;
  int _connectionEpoch = 0;
  bool _updatesEnabled = true;
  bool _statusRefreshPending = false;

  @override
  DoctorSnapshot build() {
    ref.onCancel(() {
      _freshnessTimer?.cancel();
      _freshnessTimer = null;
    });
    ref.onResume(_resumeFreshness);
    ref.onDispose(() => _freshnessTimer?.cancel());
    return unsupportedDoctorSnapshot;
  }

  Future<DoctorSnapshot> updateActivity({
    required AppLifecycleState? lifecycleState,
    required bool isAndroid,
  }) {
    final enabled =
        !isAndroid ||
        lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed ||
        lifecycleState == AppLifecycleState.inactive;
    final resumed = !_updatesEnabled && enabled;
    _updatesEnabled = enabled;
    if (resumed && _statusRefreshPending) {
      return refresh();
    }
    return Future.value(state);
  }

  Future<DoctorSnapshot> refreshFromStatus({int minimumRevision = 0}) {
    if (minimumRevision > 0 &&
        minimumRevision <= state.revision &&
        state.supported) {
      return Future.value(state);
    }
    if (minimumRevision > _minimumRevision) {
      _minimumRevision = minimumRevision;
    }
    _statusRefreshPending = true;
    if (!_updatesEnabled) {
      return Future.value(state);
    }
    return refresh(minimumRevision: minimumRevision);
  }

  Future<DoctorSnapshot> refresh({int minimumRevision = 0}) {
    if (minimumRevision > 0 &&
        minimumRevision <= state.revision &&
        state.supported) {
      return Future.value(state);
    }
    if (minimumRevision > _minimumRevision) {
      _minimumRevision = minimumRevision;
    }
    final activeRefresh = _refreshing;
    if (activeRefresh != null) {
      return activeRefresh;
    }
    final refresh = _refreshUntilCurrent();
    _refreshing = refresh;
    refresh.then<void>(
      (_) {
        if (identical(_refreshing, refresh)) {
          _refreshing = null;
        }
      },
      onError: (Object _, StackTrace _) {
        if (identical(_refreshing, refresh)) {
          _refreshing = null;
        }
      },
    );
    return refresh;
  }

  Future<DoctorSnapshot> _refreshUntilCurrent() async {
    final epoch = _connectionEpoch;
    int? previousRevision;
    for (var attempt = 0; attempt < 3 && epoch == _connectionEpoch; attempt++) {
      final snapshot = await _refresh();
      if (epoch != _connectionEpoch) {
        return state;
      }
      if (!_updatesEnabled) {
        _statusRefreshPending = true;
        return snapshot;
      }
      if (!snapshot.supported ||
          snapshot.revision >= _minimumRevision ||
          snapshot.revision == previousRevision) {
        if (epoch == _connectionEpoch) {
          _minimumRevision = 0;
          _statusRefreshPending = false;
        }
        return snapshot;
      }
      previousRevision = snapshot.revision;
    }
    if (epoch == _connectionEpoch) {
      _minimumRevision = 0;
      _statusRefreshPending = false;
    }
    return state;
  }

  Future<DoctorSnapshot> _refresh() async {
    final epoch = _connectionEpoch;
    try {
      return _accept(
        await ref.read(coreHandlerProvider).doctorSnapshot(),
        epoch,
      );
    } on CoreMethodException catch (error) {
      if (error.code == 'not_implemented') {
        if (epoch == _connectionEpoch) {
          _freshnessTimer?.cancel();
          _freshnessTimer = null;
          _freshnessSnapshot = unsupportedDoctorSnapshot;
          state = unsupportedDoctorSnapshot;
        }
        return state;
      }
      rethrow;
    }
  }

  Future<DoctorSnapshot> start(DoctorExamMode mode) async {
    final epoch = _connectionEpoch;
    return _accept(
      await ref
          .read(coreHandlerProvider)
          .startDoctor(DoctorStartParams(mode: mode)),
      epoch,
    );
  }

  Future<DoctorSnapshot> cancel() async {
    final examId = state.examId;
    if (examId.isEmpty) {
      return state;
    }
    final epoch = _connectionEpoch;
    return _accept(
      await ref
          .read(coreHandlerProvider)
          .cancelDoctor(DoctorCancelParams(examId: examId)),
      epoch,
    );
  }

  Future<DoctorSnapshot> flushDns() async {
    final snapshot = state;
    if (!snapshot.isFresh ||
        snapshot.action('flushDns')?.eligible != true ||
        snapshot.examId.isEmpty) {
      return snapshot;
    }
    final epoch = _connectionEpoch;
    return _accept(
      await ref
          .read(coreHandlerProvider)
          .flushDoctorDns(
            DoctorHealParams(
              examId: snapshot.examId,
              revision: snapshot.revision,
            ),
          ),
      epoch,
    );
  }

  Future<DoctorReport> exportRedacted() {
    return ref.read(coreHandlerProvider).exportDoctorReport();
  }

  void resetForCoreConnection() {
    _reset();
  }

  void resetForTunnelSession() {
    _reset();
  }

  void _reset() {
    _connectionEpoch++;
    _refreshing = null;
    _freshnessTimer?.cancel();
    _freshnessTimer = null;
    _freshnessSnapshot = unsupportedDoctorSnapshot;
    _minimumRevision = 0;
    _statusRefreshPending = false;
    state = unsupportedDoctorSnapshot;
  }

  void _resumeFreshness() {
    final snapshot = _freshnessSnapshot;
    if (snapshot.freshUntil == 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > snapshot.freshUntil) {
      Future<void>.microtask(() {
        if (ref.mounted && state.revision == snapshot.revision) {
          state = state.copyWith(freshUntil: now - 1);
        }
      });
      return;
    }
    _scheduleFreshness(snapshot);
  }

  void _scheduleFreshness(DoctorSnapshot snapshot) {
    _freshnessSnapshot = snapshot;
    _freshnessTimer?.cancel();
    _freshnessTimer = null;
    if (snapshot.freshUntil == 0) return;
    final delay = Duration(
      milliseconds:
          snapshot.freshUntil - DateTime.now().millisecondsSinceEpoch + 1,
    );
    if (delay <= Duration.zero) return;
    final revision = snapshot.revision;
    _freshnessTimer = Timer(delay, () {
      if (ref.mounted && state.revision == revision) {
        state = state.copyWith(
          freshUntil: DateTime.now().millisecondsSinceEpoch - 1,
        );
      }
    });
  }

  DoctorSnapshot _accept(DoctorSnapshot snapshot, int epoch) {
    if (epoch != _connectionEpoch) {
      return state;
    }
    if (snapshot.revision >= state.revision || !state.supported) {
      state = snapshot;
      _scheduleFreshness(snapshot);
      if (allDoctorLayersFailed(snapshot)) {
        ref.read(milestonesProvider.notifier).discover('storm');
      }
    }
    return state;
  }
}
