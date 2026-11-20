import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/datetime.dart';
import 'package:reclash/common/number_text.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/subscription_kind_chip.dart';

/// The provider's logo, its initial, or [glyph] in a stage badge whose ring
/// spins while [loading] and otherwise shows [value].
class ImportBadge extends StatelessWidget {
  const ImportBadge({
    super.key,
    required this.monogram,
    required this.glyph,
    this.logoBytes,
    this.logoIsSvg = false,
    this.logoBuilder,
    this.loading = false,
    this.value = 0,
    this.color,
  });

  static const _logo = 64.0;

  final String? monogram;
  final Glyph glyph;
  final Uint8List? logoBytes;
  final bool logoIsSvg;

  /// Draws a logo there are no [logoBytes] for, over the monogram.
  final Widget Function(Widget fallback)? logoBuilder;
  final bool loading;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colorScheme.primary;
    final initial = monogram?.trim().characters.firstOrNull?.toUpperCase();
    final Widget fallback = initial == null
        ? GlyphIcon(glyph)
        : Text(
            initial,
            style: AppTextStyle.title1
                .of(context, emphasized: true)
                .copyWith(color: tint),
          );
    final logo = logoBytes;
    final Widget content = switch (logo) {
      null => KeyedSubtree(
        key: ValueKey(initial ?? glyph),
        child: switch (logoBuilder) {
          null => fallback,
          final builder => ClipOval(
            child: SizedBox.square(
              dimension: _logo,
              child: builder(Center(child: fallback)),
            ),
          ),
        },
      ),
      final logo => KeyedSubtree(
        key: ObjectKey(logo),
        child: ClipOval(
          child: SizedBox.square(
            dimension: _logo,
            child: logoIsSvg
                ? SvgPicture.memory(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(child: fallback),
                  )
                : Image.memory(
                    logo,
                    fit: BoxFit.contain,
                    cacheWidth: (_logo * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    errorBuilder: (_, _, _) => Center(child: fallback),
                  ),
          ),
        ),
      ),
    };
    final duration = context.motionDuration(commonDuration);
    return StageSheetBadge(
      color: tint,
      value: loading ? null : value,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: content,
      ),
    );
  }
}

/// What sits under the hero title: the plan kind, the account, where the
/// profile comes from and what the sheet is doing.
class ImportHeroDetails extends StatelessWidget {
  const ImportHeroDetails({
    super.key,
    this.kind,
    this.account,
    this.caption = '',
    this.status,
  });

  final SubscriptionKind? kind;
  final String? account;
  final String caption;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(commonDuration);
    final account = this.account;
    final status = this.status;
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: Column(
          key: ValueKey((kind, account, caption, status)),
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (kind case final kind?)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: SubscriptionKindChip(kind: kind),
              ),
            if (account != null)
              Text(
                account,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.colorScheme.onSurface),
              ),
            if (caption.isNotEmpty)
              Text(caption, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (status != null)
              Text(
                status,
                style: TextStyle(color: context.colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

class ImportAnnounce extends StatelessWidget {
  const ImportAnnounce({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(colorScheme),
          shape: AppShape.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              GlyphIcon(
                AppGlyphs.sparkle,
                size: 20,
                color: colorScheme.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      AppLocalizations.of(context).profileImportFromProvider,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    Text(text, style: AppTextStyle.subheadline.of(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The server count the import found and the plan's usage.
class ImportStats extends StatelessWidget {
  const ImportStats({super.key, required this.nodes, required this.usage});

  final int? nodes;
  final ({int used, int total, int expire})? usage;

  static String _traffic(num bytes) {
    final (:value, :unit) = bytes.trafficParts;
    return '$value$unit';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = usage;
    final used = info == null ? 0 : info.used;
    final expire = info == null || info.expire == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(info.expire * 1000);
    final expired = expire?.isBeforeNow ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            if (nodes case final nodes?)
              _StatTile(
                flex: 2,
                label: l10n.profileImportServers,
                value: '$nodes',
              ),
            if (info != null) ...[
              _StatTile(
                flex: 3,
                label: l10n.traffic,
                value: info.total == 0
                    ? l10n.profileImportUnlimited
                    : '${_traffic(used)} / ${_traffic(info.total)}',
                progress: info.total == 0
                    ? null
                    : (used / info.total).clamp(0.0, 1.0).toDouble(),
              ),
              _StatTile(
                flex: 3,
                label: l10n.profileImportValidUntil,
                value: expire == null
                    ? l10n.infiniteTime
                    : expired
                    ? l10n.profileImportExpired
                    : expire.show,
                warning: expired,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.flex,
    this.progress,
    this.warning = false,
  });

  final String label;
  final String value;
  final int flex;
  final double? progress;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final progress = this.progress;
    return Expanded(
      flex: flex,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(colorScheme),
          shape: AppShape.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: AppTextStyle.headline
                      .of(context, emphasized: true)
                      .copyWith(
                        color: warning ? colorScheme.error : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  minHeight: 4,
                  value: progress,
                  color: progress >= 0.9 ? colorScheme.error : null,
                  backgroundColor: colorScheme.primary.opacity15,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
