import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _expiringSoonDays = 3;

class MetaInfo extends ConsumerWidget {
  const MetaInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return DashboardInfoCard(
      height: getWidgetHeight(2),
      icon: Icons.event_available_rounded,
      label: context.appLocalizations.metaInfo,
      action: profile != null && profile.type == ProfileType.url
          ? _UpdateAction(profile: profile)
          : const Icon(Icons.chevron_right_rounded, size: 20),
      onPressed: () =>
          showExtend(context, builder: (_) => const SubscriptionOverviewView()),
      child: _MetaInfoBody(
        profileLabel: profile?.realLabel ?? '',
        subscriptionInfo: profile?.subscriptionInfo,
      ),
    );
  }
}

class _MetaInfoBody extends StatelessWidget {
  const _MetaInfoBody({
    required this.profileLabel,
    required this.subscriptionInfo,
  });

  final String profileLabel;
  final SubscriptionInfo? subscriptionInfo;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final info = subscriptionInfo;
    final expire = info?.expire ?? 0;
    final expireDate = expire == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expire * 1000);
    final isPerpetual =
        expire == 0 || (expireDate?.year ?? 0) >= perpetualExpireYear;
    var daysLeft = expireDate?.difference(DateTime.now()).inDays;
    if (daysLeft != null && daysLeft < 0) daysLeft = 0;
    final status = isPerpetual
        ? appLocalizations.perpetualSubscription
        : daysLeft == null
        ? appLocalizations.infiniteTime
        : appLocalizations.daysLeft(daysLeft);
    final statusColor =
        !isPerpetual && daysLeft != null && daysLeft <= _expiringSoonDays
        ? context.colorScheme.error
        : context.colorScheme.onSurface;
    final hasQuota = info != null && info.total > 0;
    final used = hasQuota ? info.upload + info.download : 0;
    final progress = hasQuota
        ? (used / info.total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profileLabel.isEmpty ? appLocalizations.unknown : profileLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (hasQuota) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.remainingTraffic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(info.total - used).clamp(0, info.total).traffic.show} / '
                '${info.total.traffic.show}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, minHeight: 4),
        ] else
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.remainingTraffic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                appLocalizations.infiniteTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _UpdateAction extends ConsumerWidget {
  const _UpdateAction({required this.profile});

  final Profile profile;

  Future<void> _handleUpdate(WidgetRef ref) async {
    try {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    } catch (error) {
      dialogs.showNotifier(
        userFacingErrorMessage(error, currentAppLocalizations),
        level: MessageLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    return FadeThroughBox(
      child: isUpdating
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 36,
              height: 36,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CommonCircleLoading(),
              ),
            )
          : IconButton(
              key: const ValueKey('update'),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              tooltip: context.appLocalizations.update,
              onPressed: () => _handleUpdate(ref),
              icon: const Icon(Icons.sync),
            ),
    );
  }
}
