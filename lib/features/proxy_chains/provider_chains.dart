import 'package:reclash/models/proxy_chain.dart';
import 'package:reclash/subscriptions/metadata/provider_chains.dart';

extension ProviderChainSpec on ProviderChain {
  List<HopFingerprint?> get hopFingerprints => [
    for (final fingerprint in fingerprints)
      fingerprint == null
          ? null
          : HopFingerprint(
              type: fingerprint.type,
              server: fingerprint.server,
              port: fingerprint.port,
            ),
  ];

  /// A fingerprinted chain heals a missing hop in the Core, since nobody on
  /// the device can repair a chain the provider owns.
  ChainSpec toSpec(int id) => ChainSpec(
    id: id,
    name: name,
    hops: hops,
    offered: offered,
    targetGroup: targetGroup,
    fingerprints: fingerprints.isEmpty ? null : hopFingerprints,
    heal: fingerprints.isEmpty ? null : true,
  );
}
