import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/announce.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_centered_scroll_view.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderSummaryPage extends ConsumerWidget {
  const ProviderSummaryPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return DashboardCenteredScrollView(
      controller: scrollController,
      alignment: Alignment.topCenter,
      child: profile == null
          ? const _ProviderEmptyState()
          : _ProviderSummary(profile: profile),
    );
  }
}

/// The provider page and the right column of the split board show the same
/// stack; only the spacing follows the board the cards land on.
List<Widget> providerSummaryCards(
  BuildContext context,
  Profile profile, {
  double gap = 12,
  bool showQuota = true,
}) {
  final notices = _notices(context, profile);
  return [
    _PlanCard(
      key: const ValueKey('provider-plan-card'),
      profile: profile,
      showQuota: showQuota,
    ),
    if (notices.isNotEmpty) ...[
      SizedBox(height: gap),
      _NoticesCard(notices: notices),
    ],
    SizedBox(height: gap),
    _AnnounceCard(text: profile.panelMeta?.announce?.trim()),
    if (_hasPurchaseActions(profile)) ...[
      SizedBox(height: gap),
      _ActionsCard(profile: profile),
    ],
  ];
}

class _ProviderSummary extends StatelessWidget {
  const _ProviderSummary({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: providerSummaryCards(context, profile),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({super.key, required this.profile, required this.showQuota});

  final Profile profile;
  final bool showQuota;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final panelMeta = profile.panelMeta;
    final serviceName = panelMeta?.serviceName?.trim();
    final displayName = serviceName == null || serviceName.isEmpty
        ? profile.realLabel
        : serviceName;
    final accountUsername = panelMeta?.accountUsername?.trim();
    final info = profile.subscriptionInfo;
    final total = info?.total ?? 0;
    final used = info == null ? 0 : info.upload + info.download;
    final hasQuota = total > 0;
    final remaining = hasQuota ? (total - used).clamp(0, total) : 0;
    final progress = hasQuota ? (used / total).clamp(0.0, 1.0).toDouble() : 0.0;
    final expire = info?.expire ?? 0;
    final expireDate = subscriptionExpireDate(expire);
    final perpetual = expire > 0 && expireDate == null;
    final daysLeft = _daysLeft(expireDate);
    final hasPlanFacts = info != null && info.hasFacts;

    return FocusableTap(
      borderRadius: heroCardRadius,
      onTap: () =>
          showExtend(context, builder: (_) => const SubscriptionOverviewView()),
      child: HeroSurface(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 48,
                  child: panelMeta?.serviceLogo?.isNotEmpty ?? false
                      ? ImageCacheWidget(
                          src: panelMeta!.serviceLogo!,
                          defaultWidget: const Icon(
                            Icons.cloud_outlined,
                            size: 30,
                          ),
                        )
                      : const Icon(Icons.cloud_outlined, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (displayName != profile.realLabel) ...[
                        const SizedBox(height: 2),
                        Text(
                          profile.realLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (showQuota && hasQuota) ...[
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: remaining.traffic.show,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.jetBrainsMono.value,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: localizations.trafficFreeOfTotal(
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
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress, minHeight: 6),
            ] else if (showQuota && used > 0) ...[
              const SizedBox(height: 20),
              _FactRow(
                label: localizations.usedTraffic,
                value: used.traffic.show,
              ),
            ],
            const SizedBox(height: 20),
            if (!hasPlanFacts)
              Text(
                localizations.subscriptionNoQuota,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else if (expire > 0) ...[
              _FactRow(
                label: localizations.expireTime,
                value: perpetual
                    ? localizations.perpetualSubscription
                    : expireDate!.showFull,
              ),
              if (daysLeft != null) ...[
                const SizedBox(height: 12),
                _FactRow(
                  label: localizations.remaining,
                  value: localizations.daysLeft(daysLeft),
                ),
              ],
            ] else
              _FactRow(
                label: localizations.expireTime,
                value: localizations.infiniteTime,
              ),
            if (accountUsername != null && accountUsername.isNotEmpty) ...[
              const SizedBox(height: 12),
              _CopyFactRow(
                label: localizations.account,
                value: accountUsername,
              ),
            ],
            const SizedBox(height: 12),
            _FactRow(
              label: localizations.subscriptionUpdated,
              value: profile.lastUpdateDate?.showFull ?? localizations.noData,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticesCard extends StatelessWidget {
  const _NoticesCard({required this.notices});

  final List<_Notice> notices;

  @override
  Widget build(BuildContext context) {
    return HeroSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final notice in notices) ...[
            if (notice != notices.first) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(notice.icon, size: 20, color: notice.tone),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(notice.text, style: context.textTheme.bodyMedium),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AnnounceCard extends StatelessWidget {
  const _AnnounceCard({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final text = this.text;
    final hasAnnouncement = text != null && text.isNotEmpty;
    return HeroSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.campaign_rounded,
                color: hasAnnouncement
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  localizations.announce,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectionArea(
            child: AnnounceText(
              text: hasAnnouncement ? text : localizations.noAnnouncements,
              links: hasAnnouncement,
              style: context.textTheme.bodyMedium?.copyWith(
                color: hasAnnouncement
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hero board carries update and support, the overview carries the facts;
/// this card is left with what only the panel can sell.
bool _hasPurchaseActions(Profile profile) {
  final panelMeta = profile.panelMeta;
  return (panelMeta?.buyPlanUrl?.isNotEmpty ?? false) ||
      (panelMeta?.buyTrafficUrl?.isNotEmpty ?? false);
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final localizations = context.appLocalizations;
    final panelMeta = profile.panelMeta;
    final buyPlanUrl = panelMeta?.buyPlanUrl;
    final buyTrafficUrl = panelMeta?.buyTrafficUrl;
    final hasPlan = buyPlanUrl != null && buyPlanUrl.isNotEmpty;
    final hasTraffic = buyTrafficUrl != null && buyTrafficUrl.isNotEmpty;
    return HeroSurface(
      padding: const EdgeInsets.all(20),
      child: CommonMinFilledButtonTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasPlan)
              FilledButton.icon(
                onPressed: () => unawaited(dialogs.openUrl(buyPlanUrl)),
                icon: const Icon(Icons.autorenew_rounded),
                label: _ButtonLabel(localizations.renewSubscription),
              ),
            if (hasPlan && hasTraffic) const SizedBox(height: 10),
            if (hasTraffic)
              FilledButton.tonalIcon(
                onPressed: () => unawaited(dialogs.openUrl(buyTrafficUrl)),
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: _ButtonLabel(localizations.topUpTraffic),
              ),
          ],
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
}

class _ProviderEmptyState extends ConsumerWidget {
  const _ProviderEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: HeroSurface(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_rounded,
              size: 44,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Semantics(
              header: true,
              child: Text(
                context.appLocalizations.dashboardNoActiveProfileTitle,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.appLocalizations.dashboardNoActiveProfileDesc,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(currentPageLabelProvider.notifier).toProfiles(),
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(context.appLocalizations.dashboardSelectProfile),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 6), trailing],
      ],
    );
  }
}

class _CopyFactRow extends StatelessWidget {
  const _CopyFactRow({required this.label, required this.value});

  final String label;
  final String value;

  Future<void> _handleCopy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: AppShape.sm,
      onTap: () => unawaited(_handleCopy(context)),
      child: _FactRow(
        label: label,
        value: value,
        trailing: Icon(
          Icons.copy_rounded,
          size: 14,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

typedef _Notice = ({IconData icon, String text, Color tone});

List<_Notice> _notices(BuildContext context, Profile profile) {
  final localizations = context.appLocalizations;
  final colorScheme = context.colorScheme;
  final panelMeta = profile.panelMeta;
  final newDomain = panelMeta?.newDomain?.trim();
  return [
    if (profile.undialableNodes)
      (
        icon: Icons.wifi_off_rounded,
        text: localizations.subscriptionUndialable,
        tone: colorScheme.error,
      ),
    if (panelMeta?.hwidMaxDevicesReached ?? false)
      (
        icon: Icons.devices_other_rounded,
        text: localizations.deviceLimitReached,
        tone: colorScheme.error,
      ),
    if (panelMeta?.hwidNotSupported ?? false)
      (
        icon: Icons.report_gmailerrorred_rounded,
        text: localizations.clientNotSupported,
        tone: colorScheme.tertiary,
      ),
    if (newDomain != null && newDomain.isNotEmpty)
      (
        icon: Icons.swap_horiz_rounded,
        text: localizations.subscriptionDomainMoved(newDomain),
        tone: colorScheme.onSurfaceVariant,
      ),
  ];
}

int? _daysLeft(DateTime? expireDate) {
  if (expireDate == null) return null;
  final days = expireDate.difference(DateTime.now()).inDays;
  return days < 0 ? 0 : days;
}
