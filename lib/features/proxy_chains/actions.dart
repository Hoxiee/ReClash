import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/provider_chains.dart';

import 'providers.dart';
import 'reports.dart';

typedef ChainDelay = ({int? entry, int? chain});

final proxyChainsActionProvider = NotifierProvider<ProxyChainsAction, void>(
  ProxyChainsAction.new,
);

/// Every mutation re-applies the current profile through `SetupAction`, the
/// one serialized setup owner; chains of another profile wait for its apply.
class ProxyChainsAction extends Notifier<void> {
  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  bool _isCurrent(int profileId) =>
      ref.read(currentProfileIdProvider) == profileId;

  /// [name] null or blank names the chain after its hops.
  Future<ProxyChain> create({
    required int profileId,
    required List<String> hops,
    String? name,
    bool enabled = true,
    bool offered = true,
    String? targetGroup,
  }) async {
    final siblings = await database.proxyChainsDao.query(profileId).get();
    final typed = name?.trim() ?? '';
    return _save(
      ProxyChain(
        id: snowflake.id,
        profileId: profileId,
        name: typed,
        nameAuto: typed.isEmpty,
        hops: hops,
        enabled: enabled,
        offered: offered,
        targetGroup: targetGroup,
        sortIndex: siblings.isEmpty
            ? 0
            : siblings.map((chain) => chain.sortIndex).max + 1,
      ),
    );
  }

  /// Saves [chain] as given; an auto-named chain follows its hops.
  Future<ProxyChain> update(ProxyChain chain) => _save(chain);

  Future<void> delete(ProxyChain chain) async {
    _restoreTarget(await database.proxyChainsDao.get(chain.id) ?? chain);
    await database.proxyChainsDao.remove(chain.id);
    await _apply(chain.profileId);
  }

  Future<ProxyChain> setEnabled(ProxyChain chain, bool enabled) {
    if (!isProviderChainId(chain.id)) {
      return _save(chain.copyWith(enabled: enabled));
    }
    ref
        .read(providerChainsOffProvider.notifier)
        .set(providerChainKey(chain.profileId, chain.name), off: !enabled);
    if (_isCurrent(chain.profileId)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
    return Future.value(chain.copyWith(enabled: enabled));
  }

  /// The user's own, editable chain over a provider chain's hops, off until
  /// the user turns it on.
  Future<ProxyChain> copyProviderChain(ProxyChain chain) => create(
    profileId: chain.profileId,
    hops: chain.hops,
    enabled: false,
    offered: chain.offered,
    targetGroup: chain.targetGroup,
  );

  Future<ProxyChain> setOffered(ProxyChain chain, bool offered) =>
      _save(chain.copyWith(offered: offered));

  /// Null offers the chain in the resolved main group; this is also the
  /// one-tap fix of `mainGroupAutomatic` with the issue's suggestion.
  Future<ProxyChain> setTargetGroup(ProxyChain chain, String? group) =>
      _save(chain.copyWith(targetGroup: group, offered: true));

  /// A blank [name] returns the chain to its automatic name. Rules, the MATCH
  /// target and picks that named the old name follow.
  Future<ProxyChain> rename(ProxyChain chain, String name) {
    final typed = name.trim();
    return _save(chain.copyWith(name: typed, nameAuto: typed.isEmpty));
  }

  /// Fills [hop] with [replacement], such as a `missingHop` suggestion.
  Future<ProxyChain> replaceHop(ProxyChain chain, int hop, String replacement) {
    final hops = [...chain.hops]..[hop] = replacement;
    return _save(chain.copyWith(hops: hops));
  }

  Future<void> reorder(int profileId, List<int> chainIds) async {
    await database.proxyChainsDao.reorder(chainIds);
    if (_isCurrent(profileId)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  /// Validates [hops] against the running config; with [slot], also which
  /// candidates for that hop would fail.
  Future<ChainInspection> inspect(
    List<String> hops, {
    int? slot,
    String? targetGroup,
  }) {
    return _core.inspectChain(
      InspectChainParams(
        hops: hops,
        slot: slot,
        targetGroup: targetGroup,
        mainGroupHint: ref.read(providerHintsProvider)?.serverGroup,
      ),
    );
  }

  /// Tests the chain group and its entry together under the chain's test
  /// URL, so the pair tells a dead entry from a dead path past it.
  Future<ChainDelay> testDelay(ProxyChain chain) async {
    if (!_isCurrent(chain.profileId)) return (entry: null, chain: null);
    final group =
        ref.read(chainReportsProvider)?[chain.id]?.group ?? chain.name;
    final testUrl = ref.read(
      realTestUrlProvider(ref.read(groupsProvider).getGroup(group)?.testUrl),
    );
    await ref.read(proxiesActionProvider.notifier).delayTestAt([
      Proxy(name: group, type: ''),
      Proxy(name: chain.entry, type: ''),
    ], testUrl);
    if (!ref.mounted) return (entry: null, chain: null);
    final delays = ref.read(delayDataSourceProvider)[testUrl] ?? const {};
    int? delayOf(String name) =>
        delays[ref.read(realSelectedProxyStateProvider(name)).proxyName];
    return (entry: delayOf(chain.entry), chain: delayOf(group));
  }

  Future<ProxyChain> _save(ProxyChain chain) async {
    if (chain.hops.length < minChainHops ||
        chain.hops.length > maxChainHops ||
        chain.hops.any((hop) => hop.isEmpty)) {
      throw ArgumentError.value(chain.hops, 'hops');
    }
    final dao = database.proxyChainsDao;
    final previous = await dao.get(chain.id);
    var next = chain.copyWith(
      fingerprints: await _fingerprints(chain, previous),
    );
    if (next.nameAuto || next.name.isEmpty) {
      final siblings = await dao.query(chain.profileId).get();
      next = next.copyWith(
        nameAuto: true,
        name: _uniqueName(autoChainName(next.hops), {
          for (final sibling in siblings)
            if (sibling.id != chain.id) sibling.name,
          ...?_runningNames(chain.profileId, except: previous?.name),
        }),
      );
    }
    if (previous != null && _leaves(previous, next)) _restoreTarget(previous);
    if (_joins(next, previous)) {
      next = next.copyWith(restorePick: _pinTarget(next));
    }
    await dao.put(next);
    if (previous != null && previous.name != next.name) {
      await _renameReferences(
        next.profileId,
        oldName: previous.name,
        newName: next.name,
      );
    }
    await _apply(next.profileId);
    return next;
  }

  /// Hops the running config no longer has keep the fingerprint saved
  /// before, which is what a `missingHop` suggestion matches against.
  Future<List<HopFingerprint?>> _fingerprints(
    ProxyChain chain,
    ProxyChain? previous,
  ) async {
    final running = _isCurrent(chain.profileId);
    return [
      for (final (index, hop) in chain.hops.indexed)
        (running
                ? _fingerprintOf(await _core.getProxyDefinition(hop))
                : null) ??
            (previous != null &&
                    index < previous.hops.length &&
                    index < previous.fingerprints.length &&
                    previous.hops[index] == hop
                ? previous.fingerprints[index]
                : null),
    ];
  }

  HopFingerprint? _fingerprintOf(Map<String, dynamic>? definition) {
    if (definition == null) return null;
    final type = definition['type'];
    final server = definition['server'];
    final port = switch (definition['port']) {
      final int port => port,
      final String port => int.tryParse(port),
      _ => null,
    };
    if (type is! String || server is! String || port == null) return null;
    return HopFingerprint(type: type, server: server, port: port);
  }

  Set<String>? _runningNames(int profileId, {String? except}) {
    if (!_isCurrent(profileId)) return null;
    return {
      for (final group in ref.read(groupsProvider)) ...[
        group.name,
        for (final proxy in group.all) proxy.name,
      ],
    }..remove(except);
  }

  String _uniqueName(String base, Set<String> taken) {
    if (!taken.contains(base)) return base;
    for (var n = 2; ; n++) {
      final name = '$base $n';
      if (!taken.contains(name)) return name;
    }
  }

  bool _joins(ProxyChain chain, ProxyChain? previous) =>
      chain.enabled &&
      chain.offered &&
      (previous == null ||
          !previous.enabled ||
          !previous.offered ||
          previous.targetGroup != chain.targetGroup);

  bool _leaves(ProxyChain previous, ProxyChain chain) =>
      previous.enabled &&
      previous.offered &&
      (!chain.enabled ||
          !chain.offered ||
          previous.targetGroup != chain.targetGroup);

  /// Pins the target group's current pick before a chain joins it: a select
  /// group without a stored pick routes through its first member, and a
  /// group with no static members would otherwise start using the chain.
  /// Returns the pick, which the chain gives back when it leaves.
  String? _pinTarget(ProxyChain chain) {
    if (!_isCurrent(chain.profileId)) return null;
    final groups = ref.read(groupsProvider);
    final target = switch (chain.targetGroup) {
      final name? => groups.getGroup(name),
      null => resolveChainMainGroup(
        groups,
        ref.read(providerHintsProvider)?.serverGroup,
      ),
    };
    if (target == null || target.type != GroupType.Selector) return null;
    final stored = ref.read(selectedMapProvider)[target.name] ?? '';
    if (stored.isNotEmpty) return stored == chain.name ? null : stored;
    final now = target.now ?? '';
    if (now.isEmpty) return null;
    ref.read(profilesActionProvider.notifier).mergeCurrentSelectedMap({
      target.name: now,
    });
    return now;
  }

  /// A chain leaving the group it is selected in hands the pick back, so the
  /// group does not fall to its first member.
  void _restoreTarget(ProxyChain chain) {
    final pick = chain.restorePick;
    if (pick == null || !_isCurrent(chain.profileId)) return;
    final target = ref.read(chainReportsProvider)?[chain.id]?.target;
    if (target == null || ref.read(selectedMapProvider)[target] != chain.name) {
      return;
    }
    ref.read(profilesActionProvider.notifier).mergeCurrentSelectedMap({
      target: pick,
    });
  }

  Future<void> _renameReferences(
    int profileId, {
    required String oldName,
    required String newName,
  }) async {
    final names = {oldName: newName};
    await database.rulesDao.renameRuleTarget(
      profileId,
      oldName: oldName,
      newName: newName,
    );
    await database.proxyGroupsDao.rewrite(
      await database.proxyGroupsDao.query(profileId).get(),
      (group) => group.renamedProxies(names),
    );
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (profile) => profile.copyWith(
            matchTarget: profile.matchTarget == oldName
                ? newName
                : profile.matchTarget,
            selectedMap: {
              for (final MapEntry(:key, :value) in profile.selectedMap.entries)
                key: names[value] ?? value,
            },
          ),
        );
  }

  Future<bool> _apply(int profileId) async {
    if (!_isCurrent(profileId)) return true;
    return ref.read(setupActionProvider.notifier).applyProfile();
  }
}
