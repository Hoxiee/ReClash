import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_words.dart';
import 'package:reclash/views/profiles/edit.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionOverviewView extends ConsumerWidget {
  const SubscriptionOverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return CommonScaffold(
        title: appLocalizations.metaInfo,
        body: CustomScrollView(
          slivers: [
            _sliver(
              _NoticeCard(
                icon: Icons.folder_off_rounded,
                text: appLocalizations.nullProfileDesc,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      );
    }

    final panelMeta = profile.panelMeta;
    final subscriptionInfo = profile.subscriptionInfo;
    final hasDetails = subscriptionInfo != null && subscriptionInfo.hasFacts;
    final offers = _offersOf(context, panelMeta);
    return CommonScaffold(
      title: appLocalizations.metaInfo,
      body: CustomScrollView(
        slivers: [
          if (profile.undialableNodes)
            _sliver(
              _NoticeCard(
                icon: Icons.wifi_off_rounded,
                text: appLocalizations.subscriptionUndialable,
                tone: context.colorScheme.error,
                onTap: () => _handleShowEditExtendPage(context, profile),
              ),
            ),
          for (final notice in _notices(context, panelMeta)) _sliver(notice),
          if (hasDetails)
            _sliver(_UsageDetailsCard(subscriptionInfo: subscriptionInfo))
          else
            _sliver(
              _NoticeCard(
                icon: Icons.data_usage_rounded,
                text: appLocalizations.subscriptionNoQuota,
              ),
            ),
          _sliver(_AccountDetailsCard(profile: profile)),
          _sliver(_RefreshCard(profile: profile)),
          if (offers.isNotEmpty) _sliver(_OffersCard(offers: offers)),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

void _handleShowEditExtendPage(BuildContext context, Profile profile) {
  showExtend(
    context,
    builder: (context) => AdaptiveSheetScaffold(
      title: context.appLocalizations.edit,
      body: EditProfileView(profile: profile, context: context),
    ),
  );
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: child,
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.text,
    this.tone,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Color? tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final tone = this.tone ?? context.colorScheme.onSurfaceVariant;
    final card = _Card(
      tone: this.tone,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: tone),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: tone),
          ],
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(customBorder: AppShape.xl, onTap: onTap, child: card);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
  );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: ShapeDecoration(
        shape: AppShape.md,
        color: tone.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tone),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.jetBrainsMono.value,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageDetailsCard extends StatelessWidget {
  const _UsageDetailsCard({required this.subscriptionInfo});

  final SubscriptionInfo subscriptionInfo;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final used = subscriptionInfo.upload + subscriptionInfo.download;
    final total = subscriptionInfo.total;
    final remaining = total > 0 ? (total - used).clamp(0, total) : null;
    final expireDate = subscriptionExpireDate(subscriptionInfo.expire);
    final perpetual = subscriptionInfo.expire > 0 && expireDate == null;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.data_usage_rounded,
            label: appLocalizations.trafficUsage,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.north_rounded,
                  label: appLocalizations.upload,
                  value: subscriptionInfo.upload.traffic.show,
                  tone: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 14),
          const _Divider(),
          const SizedBox(height: 12),
          _DetailRow(
            label: appLocalizations.usedTraffic,
            value: used.traffic.show,
          ),
          if (remaining != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              label: appLocalizations.remainingTraffic,
              value: remaining.traffic.show,
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: appLocalizations.totalTraffic,
              value: total.traffic.show,
            ),
          ],
          if (subscriptionInfo.expire > 0) ...[
            const SizedBox(height: 10),
            _DetailRow(
              label: appLocalizations.expireTime,
              value: perpetual
                  ? appLocalizations.perpetualSubscription
                  : expireDate!.showFull,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final panelMeta = profile.panelMeta;
    final username = panelMeta?.accountUsername?.trim();
    final host = Uri.tryParse(profile.url)?.host ?? '';
    final client = profile.effectiveClient ?? SubscriptionClient.auto;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.badge_outlined,
            label: appLocalizations.account,
          ),
          const SizedBox(height: 14),
          if (panelMeta?.serviceName?.trim().isNotEmpty ?? false) ...[
            _DetailRow(
              label: appLocalizations.serviceInfo,
              value: panelMeta!.serviceName!.trim(),
            ),
            const SizedBox(height: 10),
          ],
          _DetailRow(label: appLocalizations.profile, value: profile.realLabel),
          if (username != null && username.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(label: appLocalizations.account, value: username),
          ],
          if (host.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(label: appLocalizations.domain, value: host),
            const SizedBox(height: 10),
            _DetailRow(
              label: appLocalizations.subscriptionClientLabel,
              value: subscriptionClientLabel(client, context.appLocalizations),
            ),
          ],
          if (client == SubscriptionClient.custom &&
              profile.customUserAgent.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(
              label: appLocalizations.customUserAgentLabel,
              value: profile.customUserAgent,
            ),
          ],
        ],
      ),
    );
  }
}

class _RefreshCard extends ConsumerWidget {
  const _RefreshCard({required this.profile});

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
          _SectionTitle(
            icon: Icons.sync_rounded,
            label: appLocalizations.autoUpdate,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: appLocalizations.subscriptionUpdated,
            value: lastUpdateDate?.showFull ?? appLocalizations.noData,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: appLocalizations.autoUpdate,
            value: profile.realAutoUpdate
                ? heroDurationWords(ownMinutes)
                : appLocalizations.off,
          ),
          if (showPanelInterval) ...[
            const SizedBox(height: 8),
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
            const SizedBox(height: 14),
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
