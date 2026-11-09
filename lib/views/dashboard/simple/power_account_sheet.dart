import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/power/attention.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/features/power/providers.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/notification/record.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';

Future<void> showPowerAccountSheet(BuildContext context) => showSheet<void>(
  context: context,
  builder: (_) => const PowerAccountSheet(),
);

/// Why the plan keeps the button shut, and the ways out of it.
class PowerAccountSheet extends ConsumerWidget {
  const PowerAccountSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final face = ref.watch(powerFaceProvider);
    final stoppedByUs = ref.watch(
      accountStandingProvider.select((standing) => standing.stoppedByUs),
    );
    final profile = ref.watch(currentProfileProvider);
    final metadata =
        profile?.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
    final other = ref
        .watch(profilesProvider)
        .where((candidate) => candidate.id != profile?.id)
        .firstOrNull;
    final byTraffic = switch (face.state) {
      PowerFaceState.trafficLocked || PowerFaceState.exhausted => true,
      _ => false,
    };
    final revoked = face.state == PowerFaceState.revoked;
    final locked = switch (face.state) {
      PowerFaceState.accountLocked || PowerFaceState.trafficLocked => true,
      _ => false,
    };
    final buy = accountLinkUrl(
      metadata,
      byTraffic ? PowerAction.topUp : PowerAction.renew,
    );
    final support = accountLinkUrl(metadata, PowerAction.support);
    final close = Navigator.of(context).pop;

    void openUrl(Uri url) {
      close();
      unawaited(dialogs.openUrl(url.toString()));
    }

    Future<void> recheck() async {
      close();
      final renewed = await ref.read(accountGuardProvider).recheck();
      if (!renewed) {
        dialogs.showNotifier(
          appLocalizations.powerAccountStillEnded,
          level: MessageLevel.warning,
        );
      }
    }

    final title = revoked
        ? appLocalizations.powerTitleRevoked
        : byTraffic
        ? appLocalizations.powerTitleExhausted
        : appLocalizations.powerTitleExpired;
    final detail = [
      metadata.name ?? profile?.realLabel,
      ?_reading(context, revoked: revoked, byTraffic: byTraffic, profile),
    ].nonNulls.join(' · ');
    final sentence = [
      if (detail.isNotEmpty) '$detail.',
      if (stoppedByUs) appLocalizations.powerAccountStopped,
    ].join(' ');
    final rows = [
      if (!revoked)
        _Row(
          glyph: AppGlyphs.sync,
          title: appLocalizations.powerAccountPaid,
          subtitle: appLocalizations.powerAccountPaidHint,
          onTap: () => unawaited(recheck()),
        ),
      if (other != null)
        _Row(
          glyph: AppGlyphs.swap,
          title: appLocalizations.powerAccountSwitch(other.realLabel),
          onTap: () {
            close();
            ref.read(currentProfileIdProvider.notifier).value = other.id;
          },
        ),
      if (support != null)
        _Row(
          glyph: AppGlyphs.support,
          title: appLocalizations.powerFixSupport,
          onTap: () => openUrl(support),
        ),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + context.bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: colorScheme.errorContainer,
                shape: AppShape.circle,
              ),
              child: SizedBox.square(
                dimension: 64,
                child: Center(
                  child: GlyphIcon(
                    AppGlyphs.lock,
                    size: 30,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.title2.of(context, emphasized: true),
          ),
          if (sentence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sentence,
              textAlign: TextAlign.center,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
          if (buy != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => openUrl(buy),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              iconAlignment: IconAlignment.end,
              icon: const GlyphIcon(AppGlyphs.openExternal, size: 18, fill: 1),
              label: Text(
                byTraffic
                    ? appLocalizations.topUpTraffic
                    : appLocalizations.renewSubscription,
              ),
            ),
          ],
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 16),
            Material(
              color: colors.card,
              shape: AppShape.xl,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (index, row) in rows.indexed) ...[
                    if (index > 0)
                      Divider(
                        height: 1,
                        indent: 52,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    row,
                  ],
                ],
              ),
            ),
          ],
          if (locked) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                close();
                unawaited(ref.read(accountGuardProvider).connectAnyway());
              },
              child: Text(
                appLocalizations.powerAccountConnectAnyway,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: true)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _reading(
    BuildContext context,
    Profile? profile, {
    required bool revoked,
    required bool byTraffic,
  }) {
    final appLocalizations = context.appLocalizations;
    if (revoked) return null;
    final info = profile?.subscriptionInfo;
    if (info == null) return null;
    if (byTraffic) {
      return info.total <= 0
          ? null
          : appLocalizations.powerAccountExhaustedUsed(
              dashboardTraffic(info.upload + info.download),
              dashboardTraffic(info.total),
            );
    }
    return switch (subscriptionExpireDate(info.expire)) {
      final date? => appLocalizations.powerAccountExpiredOn(
        MaterialLocalizations.of(context).formatMediumDate(date),
      ),
      null => null,
    };
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.glyph,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final Glyph glyph;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final subtitle = this.subtitle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          spacing: 14,
          children: [
            GlyphIcon(glyph, size: 22, color: colorScheme.primary),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(title, style: AppTextStyle.body.of(context)),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
