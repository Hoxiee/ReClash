import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/power/providers.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/widgets/profile_detail.dart';
import 'package:reclash/views/profiles/custom/custom.dart';
import 'package:reclash/widgets/widgets.dart';

import 'subscription_card_view.dart';

/// The current profile's plan, see [SubscriptionCardView].
class SubscriptionCard extends ConsumerWidget {
  const SubscriptionCard({super.key});

  void _open(BuildContext context, Profile? profile) {
    switch (profile) {
      case null:
        showProfilesSheet(context);
      case Profile(type: ProfileType.custom, :final id):
        showCustomProfileSheet(context, id);
      case _:
        showProfileDetailSheet(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final metadata =
        profile?.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
    final info = profile?.subscriptionInfo;
    return SubscriptionCardView(
      hasProfile: profile != null,
      title: metadata.name ?? profile?.realLabel ?? appLocalizations.addProfile,
      metadata: metadata,
      usage: info == null
          ? null
          : (
              used: info.upload + info.download,
              total: info.total,
              expire: info.expire,
            ),
      images: const AppProviderImages(),
      onTap: () => _open(context, profile),
      onOpenLink: (url) => unawaited(dialogs.openUrl(url.toString())),
      subtitle: switch (profile?.lastUpdateDate) {
        final updated? => TickBuilder(
          duration: const Duration(minutes: 1),
          builder: (context, _) => Text(
            appLocalizations.profileUpdatedAt(
              updated.getLastUpdateTimeDesc(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardText.label(context),
          ),
        ),
        null => null,
      },
      sync: profile != null && profile.type == ProfileType.url
          ? _SyncButton(profile: profile)
          : null,
      hideActions: ref.watch(powerOffersAccountActionProvider),
    );
  }
}

class _SyncButton extends ConsumerWidget {
  const _SyncButton({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isUpdatingProvider(profile.updatingKey))) {
      return const SizedBox.square(
        dimension: DashboardIconButton.size,
        child: Center(child: CommonCircleLoading(size: 18)),
      );
    }
    return DashboardIconButton(
      glyph: AppGlyphs.sync,
      tooltip: context.appLocalizations.update,
      onPressed: () => syncProfile(context, ref, profile),
    );
  }
}
