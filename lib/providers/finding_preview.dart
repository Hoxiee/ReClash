import 'dart:async';

import 'package:reclash/common/milestone_rules.dart';
import 'package:reclash/common/seasonal.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/finding_preview.g.dart';

const findingIds = [
  'vigil',
  'auscultation',
  'fullLadder',
  'silentAutopilot',
  'odometer',
  'meridian',
  'porcelain',
  'crown',
  'oscilloscope',
  'singularity',
  'marks',
  'pi',
  'turn',
];

class FindingPreviewState {
  const FindingPreviewState({
    this.unlocked = const {},
    this.season,
    this.patinaDays,
    this.pending,
    this.active,
  });

  final Set<String> unlocked;
  final SeasonalMotif? season;
  final int? patinaDays;
  final String? pending;
  final String? active;

  bool get enabled =>
      unlocked.isNotEmpty || season != null || patinaDays != null;
}

@Riverpod(keepAlive: true)
class FindingPreview extends _$FindingPreview {
  Timer? _expiry;

  @override
  FindingPreviewState build() {
    ref.watch(appSettingProvider.select((state) => state.developerMode));
    ref.onDispose(() => _expiry?.cancel());
    return const FindingPreviewState();
  }

  bool get _allowed => ref.read(appSettingProvider).developerMode;

  void showFinding(String id) {
    if (!_allowed || !findingIds.contains(id)) return;
    _expiry?.cancel();
    state = FindingPreviewState(
      unlocked: {...state.unlocked, id},
      season: state.season,
      patinaDays: state.patinaDays,
      pending: id,
    );
  }

  void showAllRewards() {
    if (!_allowed) return;
    state = FindingPreviewState(
      unlocked: {...state.unlocked, ...MilestoneId.values.map((id) => id.name)},
      season: state.season,
      patinaDays: state.patinaDays,
      pending: state.pending,
      active: state.active,
    );
  }

  void setSeason(SeasonalMotif? season) {
    if (!_allowed) return;
    state = FindingPreviewState(
      unlocked: state.unlocked,
      season: season,
      patinaDays: state.patinaDays,
      pending: state.pending,
      active: state.active,
    );
  }

  void setPatinaDays(int? days) {
    if (!_allowed || (days != null && (days < 0 || days > 365))) return;
    state = FindingPreviewState(
      unlocked: state.unlocked,
      season: state.season,
      patinaDays: days,
      pending: state.pending,
      active: state.active,
    );
  }

  bool activate({required bool calm}) {
    if (!_allowed ||
        !calm ||
        state.pending == null ||
        !ref.read(milestoneSettingProvider).findingsEnabled) {
      return false;
    }
    final id = state.pending;
    _expiry?.cancel();
    state = FindingPreviewState(
      unlocked: state.unlocked,
      season: state.season,
      patinaDays: state.patinaDays,
      active: id,
    );
    _expiry = Timer(Duration(seconds: id == 'pi' ? 4 : 6), () {
      state = FindingPreviewState(
        unlocked: state.unlocked,
        season: state.season,
        patinaDays: state.patinaDays,
      );
    });
    return true;
  }

  void reset() {
    _expiry?.cancel();
    state = const FindingPreviewState();
  }
}

@riverpod
MilestoneProps visibleMilestones(Ref ref) {
  final actual = ref.watch(milestoneSettingProvider);
  final preview = ref.watch(findingPreviewProvider);
  if (!actual.findingsEnabled) {
    return actual.copyWith(unlocked: const {});
  }
  if (preview.unlocked.isEmpty) return actual;
  final now = DateTime.now().millisecondsSinceEpoch;
  return actual.copyWith(
    unlocked: {...actual.unlocked, ...preview.unlocked},
    revealedAt: {
      ...actual.revealedAt,
      for (final id in preview.unlocked) id: actual.revealedAt[id] ?? now,
    },
  );
}

@riverpod
OdometerSnapshot? visibleOdometer(Ref ref) {
  final actual = ref.watch(milestonesProvider);
  final preview = ref.watch(findingPreviewProvider);
  if (!preview.unlocked.contains('crown')) return actual;
  final now = DateTime.now();
  return OdometerSnapshot(
    firstRunMillis: now
        .subtract(const Duration(days: 365))
        .millisecondsSinceEpoch,
    totalCoveredMillis: const Duration(days: 360).inMilliseconds,
  );
}

@riverpod
SeasonalMotif visibleSeason(Ref ref) {
  final preview = ref.watch(findingPreviewProvider);
  if (preview.season != null) return preview.season!;
  final snapshot = ref.watch(milestonesProvider);
  return seasonalMotifAt(
    DateTime.now(),
    firstRun: snapshot == null || snapshot.firstRunMillis <= 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(snapshot.firstRunMillis),
  );
}
