import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(providerAnnouncementProvider);
    if (announcement == null) return const SizedBox.shrink();
    final l = context.appLocalizations;
    return CommonCard(
      key: const ValueKey('provider-announcement-card'),
      padding: const EdgeInsets.all(20),
      shape: AppShape.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 10,
            children: [
              GlyphIcon(
                AppGlyphs.info,
                size: 22,
                color: context.colorScheme.onSurfaceVariant,
              ),
              Expanded(
                child: Text(
                  l.providerAnnouncement,
                  style: AppTextStyle.headline.of(context),
                ),
              ),
            ],
          ),
          SelectableText(
            announcement.text,
            style: AppTextStyle.body
                .of(context)
                .copyWith(color: context.colorScheme.onSurface),
          ),
          if (announcement.link case final link?)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => unawaited(dialogs.openUrl(link.toString())),
                child: Text(l.providerAnnouncementOpen),
              ),
            ),
        ],
      ),
    );
  }
}

class NoticeCard extends ConsumerWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(providerNoticeProvider);
    if (card == null) return const SizedBox.shrink();
    final (:announcement, :id) = card;
    final l = context.appLocalizations;
    return CommonCard(
      key: const ValueKey('provider-notice-card'),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      shape: AppShape.xl,
      onPressed: () => unawaited(
        announcement.link == null
            ? dialogs.showMessage(
                title: l.providerNotice,
                message: TextSpan(text: announcement.text),
                cancelable: false,
                confirmText: l.close,
              )
            : dialogs.openUrl(announcement.link.toString()),
      ),
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
            onPressed: () =>
                ref.read(dismissedNoticesProvider.notifier).dismiss(id),
          ),
        ],
      ),
    );
  }
}
