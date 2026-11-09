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

class ImportHero extends StatelessWidget {
  const ImportHero({
    super.key,
    required this.monogram,
    required this.logoBytes,
    required this.logoIsSvg,
    required this.account,
    required this.kind,
    required this.glyph,
    required this.loading,
    required this.title,
    required this.caption,
    this.logoBuilder,
  });

  static const _side = 104.0;
  static const _well = 76.0;

  final String? monogram;
  final Uint8List? logoBytes;
  final bool logoIsSvg;
  final String? account;
  final SubscriptionKind? kind;
  final Glyph glyph;
  final bool loading;
  final String title;
  final String caption;

  /// Draws a logo there are no [logoBytes] for, over the monogram.
  final Widget Function(Widget fallback)? logoBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final initial = monogram?.trim().characters.firstOrNull?.toUpperCase();
    final fallback = Container(
      width: _well,
      height: _well,
      alignment: Alignment.center,
      color: initial == null
          ? context.raisedSurfaceLevel.colorOf(colorScheme)
          : colorScheme.primaryContainer,
      child: initial == null
          ? GlyphIcon(glyph, size: 34, color: colorScheme.onSurfaceVariant)
          : Text(
              initial,
              style: AppTextStyle.title1
                  .of(context, emphasized: true)
                  .copyWith(color: colorScheme.onPrimaryContainer),
            ),
    );
    final duration = context.motionDuration(commonDuration);
    final logo = logoBytes;
    final well = logo == null
        ? KeyedSubtree(
            key: ValueKey(initial ?? glyph),
            child: logoBuilder?.call(fallback) ?? fallback,
          )
        : KeyedSubtree(
            key: ObjectKey(logo),
            child: logoIsSvg
                ? SvgPicture.memory(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => fallback,
                  )
                : Image.memory(
                    logo,
                    fit: BoxFit.contain,
                    cacheWidth: (_well * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    errorBuilder: (_, _, _) => fallback,
                  ),
          );
    final muted = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        children: [
          SizedBox.square(
            dimension: _side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: duration,
                  child: loading
                      ? CommonCircleLoading(
                          size: _side,
                          color: colorScheme.primary,
                        )
                      : const SizedBox.square(dimension: _side),
                ),
                ClipPath(
                  clipper: const ShapeBorderClipper(shape: AppShape.lg),
                  child: SizedBox.square(
                    dimension: _well,
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
                      child: well,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
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
                key: ValueKey((title, account, kind, caption)),
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.title2.of(context, emphasized: true),
                  ),
                  if (kind case final kind?) ...[
                    const SizedBox(height: 6),
                    SubscriptionKindChip(kind: kind),
                  ],
                  if (account case final account?) ...[
                    const SizedBox(height: 4),
                    Text(
                      account,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.subheadline.of(context),
                    ),
                  ],
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(top: 12),
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
      padding: const EdgeInsets.only(top: 12),
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
