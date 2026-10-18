import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/release_notes.dart';

class UpdateOfferDialog extends StatelessWidget {
  const UpdateOfferDialog({
    super.key,
    required this.release,
    required this.primaryLabel,
    this.skipLabel,
    this.currentVersion,
  });

  final AppUpdateRelease release;
  final String primaryLabel;
  final String? skipLabel;
  final String? currentVersion;

  static Future<bool?> show(
    BuildContext context, {
    required AppUpdateRelease release,
    required String primaryLabel,
    String? skipLabel,
    String? currentVersion,
  }) => dialogs.showCommonDialog<bool>(
    context: context,
    child: UpdateOfferDialog(
      release: release,
      primaryLabel: primaryLabel,
      skipLabel: skipLabel,
      currentVersion: currentVersion,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final prerelease = isPrereleaseRelease(
      tag: release.tag,
      flaggedPrerelease: release.data['prerelease'] == true,
    );
    final published = DateTime.tryParse(
      release.data['published_at']?.toString() ?? '',
    );
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                key: const ValueKey('update-offer-scroll'),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ReleaseHero(
                      tag: release.tag,
                      channel: prerelease
                          ? l10n.updateChannelPre
                          : l10n.updateChannelRelease,
                      currentVersion: currentVersion,
                      published: published,
                    ),
                    const SizedBox(height: 28),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.updateNotesHeading,
                        style: AppTextStyle.headline.of(
                          context,
                          emphasized: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReleaseNotes(
                      body: release.body,
                      fullReleaseUrl: release.source
                          .releasePage(release.tag)
                          .toString(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dismiss = TextButton(
                    key: const ValueKey('update-offer-dismiss'),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      skipLabel ?? l10n.cancel,
                      textAlign: TextAlign.center,
                    ),
                  );
                  final accept = FilledButton(
                    key: const ValueKey('update-offer-accept'),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(primaryLabel, textAlign: TextAlign.center),
                  );
                  if (constraints.maxWidth < 400 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [accept, dismiss],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 12,
                    children: [
                      Flexible(child: dismiss),
                      Flexible(child: accept),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseHero extends StatelessWidget {
  const _ReleaseHero({
    required this.tag,
    required this.channel,
    this.currentVersion,
    this.published,
  });

  final String tag;
  final String channel;
  final String? currentVersion;
  final DateTime? published;

  @override
  Widget build(BuildContext context) {
    final secondary = context.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
                shape: AppShape.md,
              ),
              child: GlyphIcon(
                AppGlyphs.cloudDownload,
                size: 28,
                color: context.colorScheme.primary,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    context.appLocalizations.discoverNewVersion,
                    style: AppTextStyle.subheadline
                        .of(context)
                        .copyWith(color: secondary),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      tag,
                      style: AppTextStyle.title1.of(context, emphasized: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: ShapeDecoration(
                color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
                shape: AppShape.full,
              ),
              child: Text(
                channel,
                style: AppTextStyle.caption1
                    .of(context, emphasized: true)
                    .copyWith(color: secondary),
              ),
            ),
            if (published case final published?)
              Text(
                DateFormat.yMMMd(
                  DateFormat.localeExists(
                        Localizations.localeOf(context).toString(),
                      )
                      ? Localizations.localeOf(context).toString()
                      : 'en',
                ).format(published.toLocal()),
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: secondary),
              ),
          ],
        ),
        if (currentVersion case final version?)
          Text(
            context.appLocalizations.updateInstalledVersion(version),
            style: AppTextStyle.footnote.of(context).copyWith(color: secondary),
          ),
      ],
    );
  }
}
