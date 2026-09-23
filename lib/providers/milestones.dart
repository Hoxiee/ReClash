import 'package:reclash/common/milestones/milestone_rules.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/milestones.g.dart';

@riverpod
Future<List<RcxSwitchReport>> milestoneRoutingHistory(Ref ref) async {
  final settings = ref.watch(milestoneSettingProvider);
  final snapshot = ref.watch(milestonesProvider);
  if (!settings.findingsEnabled ||
      !settings.unlocked.contains('silentAutopilot') ||
      snapshot == null) {
    return const [];
  }
  final report = await ref.read(coreHandlerProvider).smartRoutingReport();
  if (report == null) return const [];
  final cutoff = report.at - const Duration(days: 1).inMilliseconds;
  return report.history.reversed
      .where((event) => event.at >= cutoff && event.at <= report.at)
      .take(24)
      .toList();
}

@Riverpod(keepAlive: true)
class Milestones extends _$Milestones {
  bool _revealedThisSession = false;
  bool _refreshing = false;
  int _refreshEpoch = 0;

  @override
  OdometerSnapshot? build() => null;

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    final epoch = _refreshEpoch;
    OdometerSnapshot? snapshot;
    try {
      snapshot = await ref.read(coreHandlerProvider).odometerReport();
    } finally {
      _refreshing = false;
    }
    if (snapshot == null || epoch != _refreshEpoch) return;
    state = snapshot;
    final settings = ref.read(milestoneSettingProvider);
    if (!settings.findingsEnabled) return;
    final known = settings.unlocked;
    final unlocked = unlockedMilestones(
      snapshot,
    ).map((item) => item.name).toSet();
    final added = unlocked.difference(known);
    if (added.isEmpty) return;
    ref
        .read(milestoneSettingProvider.notifier)
        .update(
          (current) => current.copyWith(
            unlocked: {...current.unlocked, ...added},
            revealQueue: [...current.revealQueue, ...added],
          ),
        );
  }

  void coreDisconnected() {
    _refreshEpoch++;
    state = null;
  }

  bool discover(String id) {
    final settings = ref.read(milestoneSettingProvider);
    if (!settings.findingsEnabled ||
        ref.read(findingPreviewProvider).enabled ||
        !findingIds.contains(id) ||
        settings.unlocked.contains(id)) {
      return false;
    }
    ref
        .read(milestoneSettingProvider.notifier)
        .update(
          (current) => current.copyWith(
            unlocked: {...current.unlocked, id},
            revealQueue: [...current.revealQueue, id],
          ),
        );
    return true;
  }

  void resetFindings() {
    _revealedThisSession = false;
    final current = ref.read(milestoneSettingProvider);
    final snapshot = state;
    final earned = {
      ...current.unlocked,
      if (snapshot != null)
        ...unlockedMilestones(snapshot).map((item) => item.name),
    };
    ref
        .read(milestoneSettingProvider.notifier)
        .update(
          (current) => current.copyWith(
            revealedAt: const {},
            revealQueue: [
              ...earned.where((id) => !current.revealQueue.contains(id)),
              ...current.revealQueue,
            ],
          ),
        );
  }

  String? takeReveal({required bool calm}) {
    final settings = ref.read(milestoneSettingProvider);
    if (_revealedThisSession ||
        !calm ||
        !settings.findingsEnabled ||
        settings.revealQueue.isEmpty) {
      return null;
    }
    final id = settings.revealQueue.first;
    final now = DateTime.now().millisecondsSinceEpoch;
    _revealedThisSession = true;
    ref
        .read(milestoneSettingProvider.notifier)
        .update(
          (current) => current.copyWith(
            revealQueue: current.revealQueue.skip(1).toList(),
            revealedAt: {...current.revealedAt, id: now},
          ),
        );
    return id;
  }
}
