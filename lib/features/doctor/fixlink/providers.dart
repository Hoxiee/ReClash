import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';
import '../report/registry.dart';
import '../report/sources.dart';
import 'apply.dart';
import 'link.dart';
import 'nonces.dart';
import 'verifier.dart';

/// The reports a fix link may name.
final fixLinkReportsProvider = Provider<ReportRegistry>(
  (ref) => ref.watch(reportRegistryProvider),
);

final fixLinkNoncesProvider = Provider<NonceStore>(
  (ref) => PersistedNonceStore(
    load: preferences.getFixLinkNonces,
    save: preferences.saveFixLinkNonces,
  ),
);

class _RefFixActions implements FixActions {
  const _RefFixActions(this._ref);

  final Ref _ref;

  Profile _profile(int profileId) =>
      _ref.read(profilesProvider).getProfile(profileId) ??
      (throw StateError('profile $profileId is gone'));

  @override
  Future<void> updateProfile(int profileId) async {
    final updated = await _ref
        .read(profilesActionProvider.notifier)
        .updateProfile(_profile(profileId));
    if (updated == null) throw StateError('update failed');
  }

  @override
  Future<void> activateProfile(int profileId) async {
    _profile(profileId);
    _ref.read(currentProfileIdProvider.notifier).value = profileId;
  }

  @override
  Future<void> selectProxy(int profileId, String group, String node) async {
    final live =
        _ref.read(currentProfileIdProvider) == profileId &&
        _ref.read(groupsProvider).any((item) => item.name == group);
    if (live) {
      await _ref
          .read(proxiesActionProvider.notifier)
          .changeProxy(groupName: group, proxyName: node, silence: true);
      return;
    }
    final profile = _profile(profileId);
    await _ref
        .read(profilesProvider.notifier)
        .putAndWait(
          profile.copyWith(selectedMap: {...profile.selectedMap, group: node}),
        );
  }

  @override
  Future<void> resetConnections() async {
    final core = _ref.read(coreHandlerProvider);
    if (!await core.clearDnsCache()) throw StateError('DNS flush failed');
    await core.closeConnections();
  }

  @override
  Future<void> restartCore() async {
    final restarted = await _ref
        .read(coreActionProvider.notifier)
        .restartCore(silence: true);
    if (!restarted) throw StateError('restart failed');
  }
}

/// A group the link may select in: one the running profile shows, or, for
/// another profile, one its user already picked in.
bool _hasGroup(Ref ref, int profileId, String group) {
  if (ref.read(currentProfileIdProvider) == profileId) {
    return ref.read(groupsProvider).any((item) => item.name == group);
  }
  final profile = ref.read(profilesProvider).getProfile(profileId);
  return profile?.selectedMap.containsKey(group) ?? false;
}

List<TrustedKey> _trustedKeys(Ref ref) => [
  for (final profile in ref.read(profilesProvider))
    for (final value
        in profile.subscriptionSnapshot?.metadata.supportKeys ??
            const <String>[])
      if (parseSupportKey(value) case final key?)
        TrustedKey(profileId: profile.id, key: key),
];

final fixLinkServiceProvider = Provider<FixLinkService>(
  (ref) => FixLinkService(
    verifier: FixLinkVerifier(
      keys: () => _trustedKeys(ref),
      nonces: ref.watch(fixLinkNoncesProvider),
      findReport: (id) => ref.read(fixLinkReportsProvider).find(id),
      remedyReach: (id) => ref
          .read(diagnosticRemediesProvider)
          .where((remedy) => remedy.id == id)
          .firstOrNull
          ?.reach,
      hasGroup: (profileId, group) => _hasGroup(ref, profileId, group),
    ),
    kernel: ref.watch(diagnosticKernelProvider),
    actions: _RefFixActions(ref),
  ),
);
