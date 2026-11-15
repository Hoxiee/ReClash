import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

import 'reports.dart';

/// Chains of a profile in `sortIndex` order, live from the database.
final profileChainsProvider = StreamProvider.autoDispose
    .family<List<ProxyChain>, int>(
      (ref, profileId) => database.proxyChainsDao.query(profileId).watch(),
    );

final currentProfileChainsProvider =
    Provider.autoDispose<AsyncValue<List<ProxyChain>>>((ref) {
      final profileId = ref.watch(currentProfileIdProvider);
      if (profileId == null) return const AsyncData([]);
      return ref.watch(profileChainsProvider(profileId));
    });

/// Reports of the current profile's chains by chain id; a chain without one
/// is disabled or was saved after the last apply.
final currentChainReportsProvider = Provider.autoDispose<Map<int, ChainReport>>(
  (ref) {
    final reports = ref.watch(chainReportsProvider) ?? const {};
    final chains = ref.watch(currentProfileChainsProvider).value;
    if (chains == null || reports.isEmpty) return const {};
    return {for (final chain in chains) chain.id: ?reports[chain.id]};
  },
);

final chainReportProvider = Provider.autoDispose.family<ChainReport?, int>(
  (ref, chainId) => ref.watch(
    currentChainReportsProvider.select((reports) => reports[chainId]),
  ),
);

/// The group a new chain is offered in when it names none, resolved the way
/// the Core resolves it from the running groups.
final chainMainGroupProvider = Provider.autoDispose<Group?>((ref) {
  final groups = ref.watch(groupsProvider);
  final hint = ref.watch(
    providerHintsProvider.select((hints) => hints?.serverGroup),
  );
  return resolveChainMainGroup(groups, hint);
});

Group? resolveChainMainGroup(List<Group> groups, String? hint) =>
    pickMainGroup(groups.where((group) => group.hidden != true), hint);

/// A broken chain that a group currently routes through: that group sends
/// everything into the chain's REJECT stub, so the connection is down.
final selectedBrokenChainProvider = Provider.autoDispose<ChainReport?>((ref) {
  final reports = ref.watch(currentChainReportsProvider);
  for (final report in reports.values) {
    final target = report.target;
    if (!report.isBroken || target == null) continue;
    if (ref.watch(selectedProxyNameProvider(target)) == report.group) {
      return report;
    }
  }
  return null;
});

final chainsHintDismissedProvider =
    NotifierProvider<ChainsHintDismissed, Set<int>>(ChainsHintDismissed.new);

class ChainsHintDismissed extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    unawaited(
      preferences.getChainsHintDismissed().then((stored) {
        if (ref.mounted) state = {...stored, ...state};
      }),
    );
    return const {};
  }

  void dismiss(int profileId) {
    if (state.contains(profileId)) return;
    state = {...state, profileId};
    unawaited(preferences.saveChainsHintDismissed(state));
  }
}

final currentChainsHintDismissedProvider = Provider.autoDispose<bool>((ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  return profileId == null ||
      ref.watch(
        chainsHintDismissedProvider.select((ids) => ids.contains(profileId)),
      );
});
