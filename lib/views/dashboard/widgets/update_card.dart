import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/layout.dart';
import 'package:reclash/widgets/update_sheet.dart';

import 'card.dart';

/// The update banner above the dashboard cards: where the update stands, and
/// the one step that moves it on when that step needs no further choice.
class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key});

  static const _orbSide = 48.0;

  /// The orb's ring spans 20/24 of its side, as [CommonCircleLoading] does;
  /// the rest is clearance the card's padding gives back.
  static const _orbClearance = _orbSide / 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateActionProvider);
    final release = update.release;
    if (!update.hasUpdate || release == null) return const SizedBox.shrink();
    final action = ref.read(appUpdateActionProvider.notifier);
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final phase = update.phase;
    final direct = action.isSupported && update.asset?.sha256 != null;
    final transfer = const {
      UpdatePhase.downloading,
      UpdatePhase.paused,
      UpdatePhase.downloadFailed,
    }.contains(phase);
    final (title, glyph, color) = switch (phase) {
      UpdatePhase.downloading => (
        l.downloadingUpdate,
        AppGlyphs.cloudDownload,
        colorScheme.primary,
      ),
      UpdatePhase.paused => (
        l.updatePausedTitle,
        AppGlyphs.cloudDownload,
        colorScheme.primary,
      ),
      UpdatePhase.verifying => (
        l.updateVerifyingTitle,
        AppGlyphs.verified,
        colorScheme.primary,
      ),
      UpdatePhase.ready => (
        l.updateReadyTitle,
        AppGlyphs.check,
        colorScheme.success,
      ),
      UpdatePhase.vpnActive => (
        l.updateVpnTitle,
        AppGlyphs.vpn,
        colorScheme.warning,
      ),
      UpdatePhase.permission => (
        l.updatePermissionTitle,
        AppGlyphs.appsList,
        colorScheme.primary,
      ),
      UpdatePhase.confirmation => (
        l.updateConfirmationTitle,
        AppGlyphs.verified,
        colorScheme.primary,
      ),
      UpdatePhase.installing => (
        l.updateInstallingTitle,
        AppGlyphs.sync,
        colorScheme.primary,
      ),
      UpdatePhase.downloadFailed => (
        l.updateDownloadFailed,
        AppGlyphs.wifiOff,
        colorScheme.error,
      ),
      UpdatePhase.verifyFailed => (
        l.updateVerifyFailedTitle,
        AppGlyphs.warning,
        colorScheme.error,
      ),
      UpdatePhase.installFailed => (
        l.updateInstallFailed,
        AppGlyphs.warning,
        colorScheme.error,
      ),
      _ => (l.updateOfferTitle, AppGlyphs.cloudDownload, colorScheme.primary),
    };
    final version =
        '${globalState.packageInfo.version} › ${release.tag.replaceFirst(RegExp('^v'), '')}';
    final size = update.asset?.size;
    final progress = update.progress;
    final detail = [
      if (transfer) ...[
        if (progress != null) '${(progress * 100).floor()}%',
        update.total > 0
            ? '${update.received.traffic.show} / ${update.total.traffic.show}'
            : update.received.traffic.show,
        if (phase == UpdatePhase.downloading && update.bytesPerSecond > 0)
          l.updateTransferSpeed(update.bytesPerSecond.round().traffic.show),
      ] else ...[
        version,
        if (phase == UpdatePhase.offered && direct && size != null)
          size.traffic.show,
      ],
    ].join('  ·  ');
    final (label, onStep) = switch (phase) {
      UpdatePhase.offered when direct => (
        l.goDownload,
        () => unawaited(action.download()),
      ),
      UpdatePhase.paused || UpdatePhase.downloadFailed => (
        l.updateResumeShort,
        () => unawaited(action.download()),
      ),
      UpdatePhase.ready || UpdatePhase.installFailed => (
        l.update,
        () => unawaited(action.installNow()),
      ),
      UpdatePhase.confirmation => (
        l.confirm,
        () => unawaited(action.confirmInstall()),
      ),
      _ => (null, null),
    };
    final density = DashboardDensityScope.of(context);
    final padding = dashboardCardPadding(density);
    return DashboardCard(
      key: const ValueKey('app-update-card'),
      semanticLabel: title,
      padding: EdgeInsetsDirectional.only(
        start: padding.left - _orbClearance,
        end: padding.right - (label == null ? 4 : 8),
        top: 8,
        bottom: 8,
      ),
      onTap: () => unawaited(UpdateSheet.show(context)),
      child: Row(
        spacing: 12,
        children: [
          SurfaceScope(
            level: SurfaceLevel.card,
            child: UpdateOrb(
              update: update,
              glyph: glyph,
              color: color,
              side: _orbSide,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.callout.of(context, emphasized: true),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
          if (label != null)
            FilledButton(
              key: const ValueKey('app-update-card-step'),
              onPressed: onStep,
              child: Text(label),
            )
          else
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
