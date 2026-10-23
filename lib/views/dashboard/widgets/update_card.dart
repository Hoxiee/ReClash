import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/common/app_update_state.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'update_sheet.dart';

class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateActionProvider);
    if (!update.hasUpdate) return const SizedBox.shrink();
    final l = context.appLocalizations;
    final title = switch (update.phase) {
      UpdatePhase.downloading => l.downloadingUpdate,
      UpdatePhase.paused => l.updatePausedTitle,
      UpdatePhase.verifying => l.updateVerifyingTitle,
      UpdatePhase.ready => l.updateReadyTitle,
      UpdatePhase.vpnActive => l.updateVpnTitle,
      UpdatePhase.permission => l.updatePermissionTitle,
      UpdatePhase.confirmation => l.updateConfirmationTitle,
      UpdatePhase.installing => l.updateInstallingTitle,
      UpdatePhase.downloadFailed => l.updateDownloadFailed,
      UpdatePhase.verifyFailed => l.updateVerifyFailedTitle,
      UpdatePhase.installFailed => l.updateInstallFailed,
      _ => l.updateOfferTitle,
    };
    final transfer = const {
      UpdatePhase.downloading,
      UpdatePhase.paused,
      UpdatePhase.downloadFailed,
    }.contains(update.phase);
    return CommonCard(
      key: const ValueKey('app-update-card'),
      padding: const EdgeInsets.all(16),
      shape: AppShape.xl,
      onPressed: () => unawaited(UpdateSheet.show(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              GlyphIcon(
                update.verified ? AppGlyphs.verified : AppGlyphs.cloudDownload,
                size: 26,
                color: context.colorScheme.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(title, style: AppTextStyle.headline.of(context)),
                    Text(
                      transfer
                          ? '${update.release!.tag}  ${update.received.traffic.show}${update.total > 0 ? ' / ${update.total.traffic.show}' : ''}'
                          : update.release!.tag,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const GlyphIcon(AppGlyphs.chevronForward, size: 18),
            ],
          ),
          if (transfer)
            LinearProgressIndicator(
              value:
                  update.progress ??
                  (update.phase == UpdatePhase.downloading ? null : 0),
            ),
        ],
      ),
    );
  }
}
