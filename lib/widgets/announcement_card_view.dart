import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

/// The announcement laid open on top of the simple dashboard's widgets, in
/// full: it never folds into a preview.
class OpenAnnouncementCardView extends StatelessWidget {
  const OpenAnnouncementCardView({
    super.key,
    required this.announcement,
    required this.onOpenLink,
  });

  final ProviderAnnouncement announcement;
  final void Function(Uri link) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DashboardCard(
      semanticLabel: l.providerAnnouncement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.megaphone,
            title: l.providerAnnouncement,
            trailing: [
              if (announcement.link case final link?)
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: DashboardIconButton(
                    glyph: AppGlyphs.openExternal,
                    tooltip: l.providerAnnouncementOpen,
                    onPressed: () => onOpenLink(link),
                  ),
                ),
            ],
          ),
          Text(announcement.text, style: AppTextStyle.subheadline.of(context)),
        ],
      ),
    );
  }
}

class NoticeCardView extends StatelessWidget {
  const NoticeCardView({
    super.key,
    required this.announcement,
    required this.onPressed,
    required this.onDismiss,
  });

  final ProviderAnnouncement announcement;
  final VoidCallback onPressed;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CommonCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      shape: AppShape.xl,
      onPressed: onPressed,
      child: Row(
        spacing: 12,
        children: [
          GlyphIcon(
            AppGlyphs.info,
            size: 26,
            color: context.colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  l.providerNotice,
                  style: AppTextStyle.headline.of(context),
                ),
                Text(
                  announcement.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.close,
            icon: const GlyphIcon(AppGlyphs.close, size: 18),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
