import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/models/common.dart' show TrafficShowExt;
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/common/update_summary.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/changelog.dart';
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
  });

  final AppUpdateRelease release;
  final String currentVersion;
  final SupportPlatform platform;
  final AndroidUpdateAsset? asset;
  final bool verified;

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
    final summary = release.summary?.localized(
      Localizations.localeOf(context).toString(),
      platform: widget.platform.name.toLowerCase(),
    );
    final changelog = parseReleaseChangelog(release.body);
    final breaking = changelog?.tag == release.tag
        ? changelog!.groups
              .where((group) => group.type == ChangelogType.breaking)
              .expand((group) => group.entries)
              .toList()
        : const <ChangelogEntry>[];
    final published = DateTime.tryParse(
      release.data['published_at']?.toString() ?? '',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Semantics(
              header: true,
              child: Text(
                summary?.headline ?? l.updateOfferTitle,
                style: AppTextStyle.title1.of(context, emphasized: true),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  widget.currentVersion,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                const GlyphIcon(AppGlyphs.chevronForward, size: 16),
                Text(
                  release.tag,
                  style: AppTextStyle.subheadline.of(context, emphasized: true),
                ),
                _ChannelChip(
                  label: release.prerelease
                      ? l.updateChannelPre
                      : l.updateChannelRelease,
                ),
                if (published != null)
                  Text(
                    DateFormat.yMMMd(
                      DateFormat.localeExists(
                            Localizations.localeOf(context).toString(),
                          )
                          ? Localizations.localeOf(context).toString()
                          : 'en',
                    ).format(published.toLocal()),
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ),
        if (summary != null) ...[
          for (final warning in summary.warnings)
            _ImportantNotice(
              title: warning.title,
              description: warning.description,
            ),
          for (final entry in breaking)
            _ImportantNotice(
              title: l.changelogBreaking,
              description: entry.text,
            ),
          _Spotlight(highlight: summary.spotlight),
          for (final highlight in summary.highlights)
            _Highlight(highlight: highlight),
          if (changelog?.tag != release.tag)
            ReleaseNotes(
              body: release.body,
              tag: release.tag,
              fullReleaseUrl: release.source
                  .releasePage(release.tag)
                  .toString(),
            ),
        ] else ...[
          Text(l.updateNotesHeading, style: AppTextStyle.headline.of(context)),
          ReleaseNotes(
            body: release.body,
            tag: release.tag,
            fullReleaseUrl: release.source.releasePage(release.tag).toString(),
          ),
        ],
        Semantics(
          button: true,
          expanded: _details,
          child: TextButton(
            key: const ValueKey('update-release-details'),
            onPressed: () => setState(() => _details = !_details),
            style: TextButton.styleFrom(
              alignment: AlignmentDirectional.centerStart,
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(child: Text(l.updateReleaseDetails)),
                GlyphIcon(
                  _details ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (_details) ...[
          if (summary != null)
            ReleaseNotes(
              body: release.body,
              tag: release.tag,
              fullReleaseUrl: release.source
                  .releasePage(release.tag)
                  .toString(),
            ),
          CommonCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 12,
              children: [
                _TechnicalRow(
                  label: l.updatePackageVersion,
                  value: release.tag,
                ),
                if (widget.asset case final asset?) ...[
                  _TechnicalRow(
                    label: l.updatePackageDevice,
                    value: _abiOf(asset.name),
                  ),
                  if (asset.size case final size?)
                    _TechnicalRow(
                      label: l.updatePackageSize,
                      value: size.traffic.show,
                    ),
                ],
                _TechnicalRow(
                  label: l.updatePackageVerification,
                  value: widget.verified
                      ? l.updatePackageVerified
                      : l.updatePackageVerificationPending,
                ),
              ],
            ),
          ),
        ],
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

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: ShapeDecoration(
      color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
      shape: AppShape.full,
    ),
    child: Text(
      label,
      style: AppTextStyle.caption1.of(context, emphasized: true),
    ),
  );
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
      spacing: 12,
      children: [
        GlyphIcon(
          AppGlyphs.warning,
          color: context.colorScheme.warning,
          size: 22,
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

class _Spotlight extends StatelessWidget {
  const _Spotlight({required this.highlight});
  final ReleaseHighlight highlight;

  @override
  Widget build(BuildContext context) => CommonCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      spacing: 16,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                highlight.title,
                style: AppTextStyle.title3.of(context, emphasized: true),
              ),
              Text(
                highlight.description,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: 88,
            child: ClipRSuperellipse(
              borderRadius: AppRadius.lg,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _FeatureLandscape(context.colorScheme)),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: context.colorScheme.surfaceBright.withValues(
                          alpha: 0.88,
                        ),
                        shape: AppShape.md,
                      ),
                      child: GlyphIcon(_glyphOf(highlight.kind), size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Highlight extends StatelessWidget {
  const _Highlight({required this.highlight});
  final ReleaseHighlight highlight;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      GlyphIcon(
        _glyphOf(highlight.kind),
        size: 22,
        color: context.colorScheme.onSurfaceVariant,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              highlight.title,
              style: AppTextStyle.subheadline.of(context, emphasized: true),
            ),
            Text(
              highlight.description,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ],
  );
}

class _TechnicalRow extends StatelessWidget {
  const _TechnicalRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: [
      Expanded(
        child: Text(
          label,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyle.footnote.of(context),
        ),
      ),
    ],
  );
}

class _FeatureLandscape extends CustomPainter {
  const _FeatureLandscape(this.scheme);
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = scheme.primary.withValues(alpha: 0.24),
    );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.25),
      size.width * 0.1,
      Paint()..color = scheme.onSurface.withValues(alpha: 0.16),
    );
    final back = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.38,
        size.width * 0.4,
        size.height * 0.62,
        size.width * 0.62,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      back,
      Paint()..color = scheme.primary.withValues(alpha: 0.38),
    );
    final front = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.6,
        size.width * 0.65,
        size.height * 0.95,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      front,
      Paint()..color = scheme.primary.withValues(alpha: 0.58),
    );
  }

  @override
  bool shouldRepaint(_FeatureLandscape oldDelegate) =>
      scheme != oldDelegate.scheme;
}
