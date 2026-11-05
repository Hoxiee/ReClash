import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form_row.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'release_notes.dart';

class UpdateReleaseContent extends StatefulWidget {
  const UpdateReleaseContent({
    super.key,
    required this.release,
    required this.currentVersion,
    required this.platform,
    this.asset,
    this.verified = false,
    this.note,
  });

  final AppUpdateRelease release;
  final String currentVersion;
  final SupportPlatform platform;
  final AndroidUpdateAsset? asset;
  final bool verified;
  final String? note;

  @override
  State<UpdateReleaseContent> createState() => _UpdateReleaseContentState();
}

class _UpdateReleaseContentState extends State<UpdateReleaseContent> {
  bool _details = false;

  @override
  void didUpdateWidget(UpdateReleaseContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.release.tag != widget.release.tag) _details = false;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final release = widget.release;
    final locale = Localizations.localeOf(context).toString();
    final summary = release.summary?.localized(
      locale,
      platform: widget.platform.name.toLowerCase(),
    );
    final breaking = summary == null || summary.warnings.isNotEmpty
        ? const <String>[]
        : (parseReleaseNotes(release.body)?.breaking ?? const <String>[]);
    final muted = context.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (widget.note case final note?)
          Text(
            note,
            style: AppTextStyle.footnote.of(context).copyWith(color: muted),
          ),
        if (summary != null) ...[
          for (final warning in summary.warnings)
            _ImportantNotice(
              title: warning.title,
              description: warning.description,
            ),
          for (final entry in breaking)
            _ImportantNotice(title: l.changelogBreaking, description: entry),
          generateGroup([
            DecorationListItem(
              leading: GlyphIcon(
                _glyphOf(summary.spotlight.kind),
                color: context.colorScheme.primary,
              ),
              title: Text(
                summary.spotlight.title,
                style: AppTextStyle.headline.of(context),
              ),
              subtitle: Text(summary.spotlight.description),
            ),
            for (final highlight in summary.highlights)
              DecorationListItem(
                leading: GlyphIcon(_glyphOf(highlight.kind)),
                title: Text(highlight.title),
                subtitle: Text(highlight.description),
              ),
          ]),
        ] else
          ReleaseNotes(
            body: release.body,
            fullReleaseUrl: release.source.releasePage(release.tag).toString(),
          ),
        if (summary != null || widget.asset != null)
          generateGroup([
            Semantics(
              button: true,
              expanded: _details,
              child: ListItem(
                key: const ValueKey('update-release-details'),
                title: Text(l.updateReleaseDetails),
                trailing: GlyphIcon(
                  _details ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
                  size: 18,
                ),
                onTap: () => setState(() => _details = !_details),
              ),
            ),
          ]),
        if (_details) ...[
          if (summary != null)
            ReleaseNotes(
              body: release.body,
              fullReleaseUrl: release.source
                  .releasePage(release.tag)
                  .toString(),
            ),
          if (widget.asset case final asset?)
            generateGroup([
              FormRow(
                title: l.updatePackageDevice,
                trailing: Text(_abiOf(asset.name)),
              ),
              if (asset.size case final size?)
                FormRow(
                  title: l.updatePackageSize,
                  trailing: Text(size.traffic.show),
                ),
              FormRow(
                title: l.updatePackageVerification,
                trailing: Text(
                  widget.verified
                      ? l.updatePackageVerified
                      : l.updatePackageVerificationPending,
                ),
              ),
            ]),
        ],
      ],
    );
  }
}

/// The offer's title and a line under it: the version step, the channel and
/// the publication date.
String updateOfferHeadline(
  BuildContext context,
  AppUpdateRelease release,
  SupportPlatform platform,
) {
  final summary = release.summary?.localized(
    Localizations.localeOf(context).toString(),
    platform: platform.name.toLowerCase(),
  );
  return summary?.headline ?? context.appLocalizations.updateOfferTitle;
}

/// The version step, the channel and the publication date of an offer.
class UpdateOfferMeta extends StatelessWidget {
  const UpdateOfferMeta({
    super.key,
    required this.release,
    required this.currentVersion,
  });

  final AppUpdateRelease release;
  final String currentVersion;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final published = DateTime.tryParse(
      release.data['published_at']?.toString() ?? '',
    );
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _VersionStep(
          from: currentVersion,
          to: release.tag.replaceFirst(RegExp('^v'), ''),
        ),
        if (release.prerelease)
          CommonChip(label: context.appLocalizations.updateChannelPre),
        if (published != null)
          Text(
            DateFormat.yMMMd(
              DateFormat.localeExists(locale) ? locale : 'en',
            ).format(published.toLocal()),
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }
}

String _abiOf(String name) {
  for (final abi in [
    'arm64-v8a',
    'armeabi-v7a',
    'x86_64',
    'x86',
    'universal',
  ]) {
    if (matchesAndroidTarget(name, abi)) return abi;
  }
  return name;
}

class _VersionStep extends StatelessWidget {
  const _VersionStep({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final muted = context.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Flexible(
              child: Text(
                from,
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(color: muted),
              ),
            ),
            GlyphIcon(AppGlyphs.chevronForward, size: 14, color: muted),
            Flexible(
              child: Text(
                to,
                style: AppTextStyle.subheadline.of(context, emphasized: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportantNotice extends StatelessWidget {
  const _ImportantNotice({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => CommonCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        GlyphIcon(
          AppGlyphs.warning,
          color: context.colorScheme.warning,
          size: 24,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                title,
                style: AppTextStyle.subheadline.of(context, emphasized: true),
              ),
              Text(description, style: AppTextStyle.footnote.of(context)),
            ],
          ),
        ),
      ],
    ),
  );
}

Glyph _glyphOf(String kind) => switch (kind) {
  'wallpaper' => AppGlyphs.photos,
  'link' => AppGlyphs.link,
  'dashboard' => AppGlyphs.dashboard,
  'shield' => AppGlyphs.verified,
  'speed' => AppGlyphs.speed,
  _ => AppGlyphs.cloudDownload,
};
