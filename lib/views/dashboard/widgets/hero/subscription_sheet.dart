import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/profiles/subscription_report.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showSubscriptionSheet(BuildContext context) {
  return showSheet<void>(
    context: context,
    props: const SheetProps(isScrollControlled: true),
    builder: (_) => const _SubscriptionSheet(),
  );
}

class _SubscriptionSheet extends ConsumerWidget {
  const _SubscriptionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return AdaptiveSheetScaffold(
        title: l10n.metaInfo,
        body: Center(child: Text(l10n.nullProfileDesc)),
      );
    }
    final panelMeta = profile.panelMeta;
    final account = panelMeta?.accountUsername?.trim();
    final serviceName = panelMeta?.serviceName?.trim();
    final displayName = serviceName == null || serviceName.isEmpty
        ? profile.realLabel
        : serviceName;
    final title = account != null && account.isNotEmpty ? account : displayName;
    return AdaptiveSheetScaffold(
      title: title,
      body: _Body(profile: profile, displayName: displayName),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.profile, required this.displayName});

  final Profile profile;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final info = profile.subscriptionInfo;
    return ListView(
      shrinkWrap: true,
      // The scaffold already reserves the toolbar height above the body.
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20 + BottomInsetScope.of(context)),
      children: [
        _ServiceField(profile: profile, displayName: displayName),
        if (info != null && info.hasFacts) ...[
          const SizedBox(height: AppSpacing.lg),
          generateSectionV3(title: l10n.metaInfo, items: _facts(context, info)),
        ],
        const SizedBox(height: AppSpacing.lg),
        generateSectionV3(items: _actions(context, ref)),
      ],
    );
  }

  List<Widget> _facts(BuildContext context, SubscriptionInfo info) {
    final l10n = context.appLocalizations;
    final unlimited = info.unlimited;
    final free = unlimited ? 0 : (info.total - info.used).clamp(0, info.total);
    final expireDate = subscriptionExpireDate(info.expire);
    final perpetual = info.expire > 0 && expireDate == null;
    return [
      DetailRow.text(title: l10n.usedTraffic, value: info.used.traffic.show),
      if (!unlimited) ...[
        DetailRow.text(
          title: l10n.totalTraffic,
          value: info.total.traffic.show,
        ),
        DetailRow.text(title: l10n.remainingTraffic, value: free.traffic.show),
      ],
      if (info.expire > 0)
        DetailRow.text(
          title: l10n.expireTime,
          value: perpetual ? l10n.perpetualSubscription : expireDate!.show,
        ),
    ];
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final panelMeta = profile.panelMeta;
    final colorScheme = context.colorScheme;
    final buyPlanUrl = panelMeta?.buyPlanUrl;
    final buyTrafficUrl = panelMeta?.buyTrafficUrl;
    final supportUrl = panelMeta?.supportUrl;
    final reportUrl = panelMeta?.reportUrl;
    Widget link() => GlyphIcon(
      AppGlyphs.link,
      size: 18,
      color: colorScheme.onSurfaceVariant,
    );
    Widget chevron() => GlyphIcon(
      AppGlyphs.chevronForward,
      size: 18,
      color: colorScheme.onSurfaceVariant,
    );
    return [
      if (buyPlanUrl != null && buyPlanUrl.isNotEmpty)
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.sync),
          title: Text(l10n.renewSubscription),
          trailing: link(),
          onPressed: () => unawaited(dialogs.openUrl(buyPlanUrl)),
        ),
      if (buyTrafficUrl != null && buyTrafficUrl.isNotEmpty)
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.install),
          title: Text(l10n.topUpTraffic),
          trailing: link(),
          onPressed: () => unawaited(dialogs.openUrl(buyTrafficUrl)),
        ),
      if (supportUrl != null && supportUrl.isNotEmpty)
        DecorationListItem(
          leading: const GlyphIcon(AppGlyphs.support),
          title: Text(l10n.support),
          trailing: link(),
          onPressed: () => unawaited(dialogs.openUrl(supportUrl)),
        ),
      DecorationListItem(
        leading: const GlyphIcon(AppGlyphs.send),
        title: Text(l10n.subscriptionReport),
        trailing: chevron(),
        onPressed: () => unawaited(_openReport(context, reportUrl)),
      ),
    ];
  }

  // The report is a modal sheet of its own; opening it over this one would
  // stack two bottom sheets and let the report's async load resize on top of
  // a still-visible parent. Dismiss this sheet first, then raise the report
  // on the root navigator once the exit animation has cleared.
  Future<void> _openReport(BuildContext context, String? reportUrl) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final delay = context.motionDuration(Dialogs.dismissDuration);
    Navigator.of(context).pop();
    await Future<void>.delayed(delay);
    if (!rootContext.mounted) return;
    await showSubscriptionReportSheet(rootContext, reportUrl: reportUrl);
  }
}

class _ServiceField extends StatelessWidget {
  const _ServiceField({required this.profile, required this.displayName});

  final Profile profile;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final logo = profile.panelMeta?.serviceLogo;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 44,
              child: logo != null && logo.isNotEmpty
                  ? ImageCacheWidget(
                      src: logo,
                      defaultWidget: const GlyphIcon(AppGlyphs.cloud, size: 28),
                    )
                  : const GlyphIcon(AppGlyphs.cloud, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (displayName != profile.realLabel) ...[
                    const SizedBox(height: AppSpacing.xxs),
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
      ),
    );
  }
}
