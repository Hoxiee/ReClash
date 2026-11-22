import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

/// Explains once per installed build that a pre-release runs ahead of stable.
class PreReleaseNoticeDialog extends StatelessWidget {
  const PreReleaseNoticeDialog({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonDialog(
      title: l10n.preReleaseNoticeTitle,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.updateGotIt),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          _BuildPlate(version: version),
          const SizedBox(height: 12),
          Text(l10n.preReleaseNoticeBody),
          const SizedBox(height: 4),
          Wrap(
            spacing: 20,
            children: [
              _SupportLink(
                glyph: AppGlyphs.send,
                label: l10n.preReleaseNoticeTelegramChat,
                url: telegramChatUrl,
              ),
              _SupportLink(
                glyph: AppGlyphs.code,
                label: l10n.preReleaseNoticeGithubIssues,
                url: repositoryIssuesUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The channel and the build it labels, as one object rather than prose.
class _BuildPlate extends StatelessWidget {
  const _BuildPlate({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TonalChip(
              label: l10n.updateChannelPre,
              color: colorScheme.primary.withValues(alpha: 0.14),
              foregroundColor: colorScheme.primary,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  version,
                  maxLines: 1,
                  style: AppTextStyle.headline
                      .of(context, emphasized: true)
                      .copyWith(color: colorScheme.onSurface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportLink extends StatelessWidget {
  const _SupportLink({
    required this.glyph,
    required this.label,
    required this.url,
  });

  final Glyph glyph;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      ),
      onPressed: () => unawaited(dialogs.openUrl(url)),
      icon: GlyphIcon(glyph, size: 18),
      label: Text(label),
    );
  }
}
