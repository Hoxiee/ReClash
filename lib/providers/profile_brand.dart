import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/branding/brand.dart';
import 'package:reclash/subscriptions/branding/resolver.dart';
import 'package:reclash/subscriptions/branding/store.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'database.dart';

part 'generated/profile_brand.g.dart';

/// The stored brand of a subscription profile; null until one is resolved,
/// and always null for local and custom profiles.
@Riverpod(keepAlive: true)
Future<ProviderBrand?> profileBrand(Ref ref, int profileId) =>
    readProfileBrand(profileId);

/// Resolves a profile's logo once and keeps it: later updates only follow a
/// changed manifest logo, never the provider's pages. Only the latest
/// request per profile writes; a deleted profile drops one in flight.
@Riverpod(keepAlive: true)
class ProfileBrandAction extends _$ProfileBrandAction {
  final _generations = <int, int>{};
  final _cancellations = <int, SubscriptionCancellation>{};
  final _ensured = <int>{};

  @override
  void build() {}

  int _advance(int profileId) {
    final generation = (_generations[profileId] ?? 0) + 1;
    _generations[profileId] = generation;
    _cancellations.remove(profileId)?.cancel();
    return generation;
  }

  Future<void> refresh(
    Profile profile, {
    required SubscriptionTransport transport,
  }) async {
    if (profile.type != ProfileType.url) return;
    final generation = _advance(profile.id);
    final cancellation = SubscriptionCancellation();
    _cancellations[profile.id] = cancellation;
    bool current() =>
        _generations[profile.id] == generation &&
        !cancellation.cancelled &&
        ref.read(profilesProvider).getProfile(profile.id) != null;
    final metadata =
        profile.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
    try {
      final stored = await readProfileBrand(profile.id);
      final resolver = ProviderBrandResolver(transport: transport);
      final ProviderBrand? brand;
      if (stored == null) {
        brand = await resolver.resolve(
          name: profile.realLabel,
          subscriptionUrl: profile.url,
          metadata: metadata,
          cancellation: cancellation,
        );
      } else {
        final links = manifestLogoLinks(metadata);
        if (links == null || links == stored.manifestLogos) return;
        brand = await resolver.resolveManifest(
          metadata,
          cancellation: cancellation,
        );
      }
      if (brand == null || !current()) return;
      await writeProfileBrand(profile.id, brand);
      ref.invalidate(profileBrandProvider(profile.id));
    } on Object catch (error) {
      if (!cancellation.cancelled) {
        commonPrint.log(
          'Could not resolve the profile logo: $error',
          logLevel: LogLevel.warning,
        );
      }
    } finally {
      if (identical(_cancellations[profile.id], cancellation)) {
        _cancellations.remove(profile.id);
      }
    }
  }

  /// Resolves once per session a brand for a profile saved before branding
  /// existed or whose first resolve failed.
  Future<void> ensure(
    Profile profile, {
    required SubscriptionTransport transport,
  }) async {
    if (profile.type != ProfileType.url ||
        _cancellations.containsKey(profile.id) ||
        !_ensured.add(profile.id)) {
      return;
    }
    if (await readProfileBrand(profile.id) != null) return;
    await refresh(profile, transport: transport);
  }

  Future<void> forget(int profileId) async {
    _advance(profileId);
    await deleteProfileBrand(profileId);
    ref.invalidate(profileBrandProvider(profileId));
  }
}
