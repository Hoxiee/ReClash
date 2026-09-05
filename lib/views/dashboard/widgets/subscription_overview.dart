import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_offers.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _warnRatio = 0.7;
const _criticalRatio = 0.9;

/// Everything a subscription can say about itself, in the order it gets asked:
/// whose it is, what is left, when it last refreshed, where to buy more.
class SubscriptionOverviewView extends ConsumerWidget {
  const SubscriptionOverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final panelMeta = profile?.panelMeta;
    final subscriptionInfo = profile?.subscriptionInfo;
    final hasQuota =
        subscriptionInfo != null &&
        (subscriptionInfo.total > 0 || subscriptionInfo.expire > 0);
    final offers = _offersOf(context, panelMeta);
    return CommonScaffold(
      title: appLocalizations.metaInfo,
      body: CustomScrollView(
        slivers: [
          if (profile == null)
            _sliver(
              _NoticeCard(
                icon: Icons.folder_off_rounded,
                text: appLocalizations.nullProfileDesc,
              ),
            )
          else ...[
            _sliver(_ServiceCard(profile: profile, panelMeta: panelMeta)),
            for (final notice in _notices(context, panelMeta)) _sliver(notice),
            if (hasQuota)
              _sliver(_BalanceCard(subscriptionInfo: subscriptionInfo))
            else
              _sliver(
                _NoticeCard(
                  icon: Icons.data_usage_rounded,
                  text: appLocalizations.subscriptionNoQuota,
                ),
              ),
            _sliver(_RefreshCard(profile: profile)),
            if (offers.isNotEmpty) _sliver(_OffersCard(offers: offers)),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

Widget _sliver(Widget child) => SliverPadding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
  sliver: SliverToBoxAdapter(child: child),
);

List<Widget> _notices(BuildContext context, PanelMeta? panelMeta) {
  if (panelMeta == null) return const [];
  final appLocalizations = context.appLocalizations;
  final colorScheme = context.colorScheme;
  final announce = panelMeta.announce?.trim();
  final newDomain = panelMeta.newDomain?.trim();
  return [
    if (panelMeta.hwidMaxDevicesReached)
      _NoticeCard(
        icon: Icons.devices_other_rounded,
        text: appLocalizations.deviceLimitReached,
        tone: colorScheme.error,
      ),
    if (panelMeta.hwidNotSupported)
      _NoticeCard(
        icon: Icons.report_gmailerrorred_rounded,
        text: appLocalizations.clientNotSupported,
        tone: colorScheme.tertiary,
      ),
    if (announce != null && announce.isNotEmpty)
      _NoticeCard(
        icon: Icons.campaign_rounded,
        text: announce,
        tone: colorScheme.primary,
      ),
    if (newDomain != null && newDomain.isNotEmpty)
      _NoticeCard(
        icon: Icons.swap_horiz_rounded,
        text: appLocalizations.subscriptionDomainMoved(newDomain),
      ),
  ];
}

List<(IconData, String, String)> _offersOf(
  BuildContext context,
  PanelMeta? panelMeta,
) {
  if (panelMeta == null) return const [];
  final appLocalizations = context.appLocalizations;
  final buyPlanUrl = panelMeta.buyPlanUrl;
  final buyTrafficUrl = panelMeta.buyTrafficUrl;
  final supportUrl = panelMeta.supportUrl;
  return [
    if (buyPlanUrl != null && buyPlanUrl.isNotEmpty)
      (Icons.autorenew_rounded, appLocalizations.renewSubscription, buyPlanUrl),
    if (buyTrafficUrl != null && buyTrafficUrl.isNotEmpty)
      (
        Icons.add_shopping_cart_rounded,
        appLocalizations.topUpTraffic,
        buyTrafficUrl,
      ),
    if (supportUrl != null && supportUrl.isNotEmpty)
      (Icons.support_agent_rounded, appLocalizations.support, supportUrl),
  ];
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.tone});

  final Widget child;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final tone = this.tone;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.xl,
        color: tone == null
            ? context.colorScheme.surfaceContainerHigh
            : tone.withValues(alpha: 0.10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: child,
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.text, this.tone});

  final IconData icon;
  final String text;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final tone = this.tone ?? context.colorScheme.onSurfaceVariant;
    return _Card(
      tone: this.tone,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.tone});

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tone.withValues(alpha: 0.14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
  );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.profile, this.panelMeta});

  final Profile profile;
  final PanelMeta? panelMeta;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final logo = panelMeta?.serviceLogo;
    final name = panelMeta?.serviceName.takeFirstValid([
      panelMeta?.profileTitle,
      profile.realLabel,
    ]);
    final host = Uri.tryParse(profile.url)?.host ?? '';
    final fallbackIcon = Icon(
      Icons.cloud_outlined,
      size: 22,
      color: colorScheme.primary,
    );
    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              shape: AppShape.lg,
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: logo == null
                ? fallbackIcon
                : ClipPath(
                    clipper: const ShapeBorderClipper(shape: AppShape.lg),
                    child: ImageCacheWidget(
                      src: logo,
                      defaultWidget: fallbackIcon,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? profile.realLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  host.isNotEmpty ? host : context.appLocalizations.file,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: tone),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.jetBrainsMono.value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.subscriptionInfo});

  final SubscriptionInfo subscriptionInfo;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final used = subscriptionInfo.upload + subscriptionInfo.download;
    final total = subscriptionInfo.total;
    final unlimited = total <= 0;
    final ratio = unlimited ? 0.0 : (used / total).clamp(0.0, 1.0);
    final barColor = ratio > _criticalRatio
        ? colorScheme.error
        : ratio > _warnRatio
        ? const Color(0xFFC57F0A)
        : colorScheme.primary;
    final free = unlimited ? 0 : (total - used).clamp(0, total);
    final expireDate = subscriptionExpireDate(subscriptionInfo.expire);
    final perpetual = subscriptionInfo.expire > 0 && expireDate == null;
    final pill = _expirePill(context, expireDate, perpetual);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.trafficUsage,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (pill != null) ...[const SizedBox(width: 10), pill],
            ],
          ),
          const SizedBox(height: 8),
          if (unlimited) ...[
            Text(
              used.traffic.show,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.jetBrainsMono.value,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              appLocalizations.usedTraffic,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ] else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: free.traffic.show,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.jetBrainsMono.value,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: appLocalizations.trafficFreeOfTotal(
                      total.traffic.show,
                    ),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (!unlimited) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppCorner.sm),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio <= 0 ? 0.0 : ratio,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppCorner.sm),
                        gradient: LinearGradient(
                          colors: [barColor.withValues(alpha: 0.7), barColor],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.north_rounded,
                  label: appLocalizations.upload,
                  value: subscriptionInfo.upload.traffic.show,
                  tone: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  icon: Icons.south_rounded,
                  label: appLocalizations.download,
                  value: subscriptionInfo.download.traffic.show,
                  tone: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (expireDate != null) ...[
            const SizedBox(height: 12),
            const _Hairline(),
            const SizedBox(height: 10),
            _Row(label: appLocalizations.expireTime, value: expireDate.show),
          ],
        ],
      ),
    );
  }
}

Widget? _expirePill(
  BuildContext context,
  DateTime? expireDate,
  bool perpetual,
) {
  final appLocalizations = context.appLocalizations;
  final colorScheme = context.colorScheme;
  if (perpetual) {
    return _Pill(
      icon: Icons.all_inclusive_rounded,
      label: appLocalizations.infiniteTime,
      tone: colorScheme.primary,
    );
  }
  if (expireDate == null) return null;
  final daysLeft = expireDate.difference(DateTime.now()).inDays;
  if (daysLeft < 0) {
    return _Pill(
      icon: Icons.event_busy_rounded,
      label: appLocalizations.subscriptionExpired,
      tone: colorScheme.error,
    );
  }
  return _Pill(
    icon: Icons.event_rounded,
    label: '${appLocalizations.remaining} $daysLeft ${heroDaysWord(daysLeft)}',
    tone: daysLeft <= heroRenewDaysThreshold
        ? colorScheme.error
        : colorScheme.primary,
  );
}

class _RefreshCard extends ConsumerWidget {
  const _RefreshCard({required this.profile});

  final Profile profile;

  Future<void> _handleUpdate(WidgetRef ref) async {
    try {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    } catch (e) {
      dialogs.showNotifier(
        userFacingErrorMessage(e, currentAppLocalizations),
        level: MessageLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final lastUpdateDate = profile.lastUpdateDate;
    final ownMinutes = profile.autoUpdateDuration.inMinutes;
    final panelMinutes = profile.panelMeta?.updateIntervalMinutes;
    final showPanelInterval =
        panelMinutes != null && panelMinutes > 0 && panelMinutes != ownMinutes;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(
            label: appLocalizations.subscriptionUpdated,
            value:
                lastUpdateDate?.getLastUpdateTimeDesc(context) ??
                appLocalizations.noData,
          ),
          const SizedBox(height: 8),
          _Row(
            label: appLocalizations.autoUpdate,
            value: profile.realAutoUpdate
                ? heroDurationWords(ownMinutes)
                : appLocalizations.off,
          ),
          if (showPanelInterval) ...[
            const SizedBox(height: 6),
            Text(
              appLocalizations.subscriptionProviderInterval(
                heroDurationWords(panelMinutes),
              ),
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (profile.type == ProfileType.url) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CommonMinFilledButtonTheme(
                child: FilledButton.tonalIcon(
                  onPressed: isUpdating
                      ? null
                      : () => unawaited(_handleUpdate(ref)),
                  icon: isUpdating
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(appLocalizations.update),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OffersCard extends StatelessWidget {
  const _OffersCard({required this.offers});

  final List<(IconData, String, String)> offers;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, offer) in offers.indexed) ...[
            if (index > 0) const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CommonMinFilledButtonTheme(
                child: index == 0
                    ? FilledButton.icon(
                        onPressed: () => unawaited(dialogs.openUrl(offer.$3)),
                        icon: Icon(offer.$1),
                        label: Text(offer.$2),
                      )
                    : FilledButton.tonalIcon(
                        onPressed: () => unawaited(dialogs.openUrl(offer.$3)),
                        icon: Icon(offer.$1),
                        label: Text(offer.$2),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
