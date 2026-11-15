import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/providers/providers.dart';

import 'marks.dart';

typedef ChainEntry = ({ProxyChain chain, ChainReport report});

final chainOfGroupProvider = Provider.autoDispose.family<ChainEntry?, String>((
  ref,
  groupName,
) {
  final reports = ref.watch(currentChainReportsProvider);
  final report = reports.values
      .where((report) => report.group == groupName)
      .firstOrNull;
  if (report == null) return null;
  final chain = ref
      .watch(currentProfileChainsProvider)
      .value
      ?.where((chain) => chain.id == report.id)
      .firstOrNull;
  return chain == null ? null : (chain: chain, report: report);
});

/// Countries where foreign servers get blocked and a domestic entry helps.
const _hintRegions = {'RU'};

const _hintHome = 'ru';

/// Off for now: whether a subscription suits a chain is the provider's call.
const _hintShown = false;

/// The main group, while it has servers at home and abroad but no chains.
final chainHintGroupProvider = Provider.autoDispose<String?>((ref) {
  final region = ref.watch(
    appSettingProvider.select((setting) => setting.regionCode),
  );
  if (!_hintShown || !_hintRegions.contains(region)) return null;
  if (ref.watch(currentChainsHintDismissedProvider)) return null;
  final chains = ref.watch(currentProfileChainsProvider).value;
  if (chains == null || chains.isNotEmpty) return null;
  final group = ref.watch(chainMainGroupProvider);
  if (group == null) return null;
  var home = false;
  var abroad = false;
  for (final proxy in group.all) {
    switch (countryOfHopName(proxy.name)) {
      case null:
        break;
      case _hintHome:
        home = true;
      default:
        abroad = true;
    }
    if (home && abroad) return group.name;
  }
  return null;
});
