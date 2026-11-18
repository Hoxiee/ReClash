import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/provider_chains.dart';

import 'provider_chains.dart';
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

final providerChainsOffProvider =
    NotifierProvider<ProviderChainsOff, Set<String>>(ProviderChainsOff.new);

class ProviderChainsOff extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    unawaited(
      preferences.getProviderChainsOff().then((stored) {
        if (ref.mounted) state = {...stored, ...state};
      }),
    );
    return const {};
  }

  void set(String key, {required bool off}) {
    if (state.contains(key) == off) return;
    state = off ? {...state, key} : ({...state}..remove(key));
    unawaited(preferences.saveProviderChainsOff(state));
  }
}

/// The chains the current profile's provider offers, in the manifest's order.
/// Their ids are negative, so they never meet a stored chain's.
final currentProviderChainsProvider = Provider.autoDispose<List<ProxyChain>>((
  ref,
) {
  final profileId = ref.watch(currentProfileIdProvider);
  if (profileId == null) return const [];
  final provided = ref.watch(
    providerHintsProvider.select((hints) => hints?.chains ?? const []),
  );
  final off = ref.watch(providerChainsOffProvider);
  return [
    for (final (index, chain) in provided.indexed)
      ProxyChain(
        id: providerChainId(index),
        profileId: profileId,
        name: chain.name,
        hops: chain.hops,
        nameAuto: false,
        enabled: !off.contains(providerChainKey(profileId, chain.name)),
        offered: chain.offered,
        targetGroup: chain.targetGroup,
        fingerprints: chain.hopFingerprints,
        sortIndex: index,
      ),
  ];
});

/// Reports of the current profile's chains by chain id; a chain without one
/// is disabled or was saved after the last apply.
final currentChainReportsProvider = Provider.autoDispose<Map<int, ChainReport>>(
  (ref) {
    final reports = ref.watch(chainReportsProvider) ?? const {};
    final chains = ref.watch(currentProfileChainsProvider).value;
    if (chains == null || reports.isEmpty) return const {};
    return {
      for (final chain in [
        ...chains,
        ...ref.watch(currentProviderChainsProvider),
      ])
        chain.id: ?reports[chain.id],
    };
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
