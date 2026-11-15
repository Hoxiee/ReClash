import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/proxies/routing_country.dart';

String? countryOfHopName(String name) =>
    countryCodeOfName(name) ?? rcxCountryOfName(name)?.toLowerCase();

/// A chain's name on screen: an auto name is its hops, without the flags
/// the route mark already shows.
String chainTitle(ProxyChain chain) =>
    chain.nameAuto ? chainHopsTitle(chain.hops) : chain.name;

String chainHopsTitle(List<String> hops) => hops.map(serverTitle).join(' → ');

String chainLatency(AppLocalizations l, int delay) =>
    l.simpleLatency(delay).replaceAll(' ', '\u00A0');

/// The country a hop shows: its own name's, else the server its group picks.
String? hopCountry(WidgetRef ref, String name) {
  if (countryOfHopName(name) case final code?) return code;
  final leaf = ref.watch(
    realSelectedProxyStateProvider(name).select((state) => state.proxyName),
  );
  return leaf.isEmpty || leaf == name ? null : countryOfHopName(leaf);
}

/// Where sites see you, with the way in worn on its corner.
class RouteMark extends StatelessWidget {
  const RouteMark({
    super.key,
    required this.exit,
    required this.entry,
    this.size = 44,
    this.dimmed = false,
    this.broken = false,
  });

  final String? exit;
  final String? entry;
  final double size;
  final bool dimmed;
  final bool broken;

  static double extentOf(double size) => size * 1.09;

  @override
  Widget build(BuildContext context) {
    final ring = context.raisedSurfaceLevel.colorOf(context.colorScheme);
    final small = size * 0.5;
    return SizedBox.square(
      dimension: extentOf(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: 0,
            end: 0,
            child: ShapeFlag(code: exit, size: size, dimmed: dimmed || broken),
          ),
          PositionedDirectional(
            start: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: ShapeDecoration(color: ring, shape: AppShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: broken
                    ? ShapeBadge(
                        shape: MaterialShapes.softBurst,
                        color: context.colorScheme.error,
                        size: small,
                        child: GlyphIcon(
                          AppGlyphs.close,
                          size: small * 0.5,
                          color: context.colorScheme.onError,
                        ),
                      )
                    : ShapeFlag(code: entry, size: small, dimmed: dimmed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hops' flags joined by chevrons, for a line of text.
class RouteFlags extends StatelessWidget {
  const RouteFlags({
    super.key,
    required this.codes,
    this.color,
    this.flag = 16,
  });

  final List<String?> codes;
  final Color? color;
  final double flag;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? DashboardText.label(context).color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        for (final (index, code) in codes.indexed) ...[
          if (index > 0)
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: flag * 0.8,
              color: color?.withValues(alpha: 0.7),
            ),
          ShapeFlag(code: code, size: flag),
        ],
      ],
    );
  }
}

/// A segment's health: what the test said about the way to the next node.
enum ChainSeg { idle, ok, slow, fail }

enum ChainSlot { filled, active, empty, failed }

ChainSeg chainSegOf(int? delay) => switch (delay) {
  null => ChainSeg.idle,
  <= 0 => ChainSeg.fail,
  < 600 => ChainSeg.ok,
  _ => ChainSeg.slow,
};

class StripNode {
  const StripNode({
    this.code,
    this.group = false,
    required this.label,
    required this.caption,
    this.slot = ChainSlot.filled,
    this.glyph,
    this.captionTone,
    this.onTap,
  });

  /// The flag of a filled hop; a filled node without a hop draws [glyph].
  final String? code;
  final bool group;
  final String label;
  final String caption;
  final ChainSlot slot;
  final Glyph? glyph;
  final Color? captionTone;
  final VoidCallback? onTap;
}

StripNode youNode(BuildContext context) {
  final l = context.appLocalizations;
  return StripNode(
    label: l.chainsYou,
    caption: system.isDesktop ? l.chainsYouComputer : l.chainsYouPhone,
    glyph: AppGlyphs.devices,
  );
}

/// The chain drawn as the way traffic goes, health on its segments, so a
/// break shows where it is without a word.
class RouteStrip extends StatelessWidget {
  const RouteStrip({
    super.key,
    required this.nodes,
    required this.segments,
    this.flag = 44,
  });

  final List<StripNode> nodes;

  /// One per gap between [nodes].
  final List<ChainSeg> segments;
  final double flag;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = constraints.maxWidth / nodes.length;
        const gap = 6.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final node in nodes)
                  Expanded(
                    child: _Node(node: node, size: flag),
                  ),
              ],
            ),
            for (final (index, seg) in segments.indexed)
              Positioned(
                left: cell * (index + 0.5) + flag / 2 + gap,
                width: math.max(cell - flag - gap * 2, 0),
                top: 0,
                height: flag,
                child: _Segment(seg: seg),
              ),
          ],
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.seg});

  final ChainSeg seg;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final color = switch (seg) {
      ChainSeg.idle => colors.track,
      ChainSeg.ok => colors.ok,
      ChainSeg.slow => colors.warn,
      ChainSeg.fail => colorScheme.error,
    };
    final line = DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: AppShape.full),
      child: const SizedBox(height: 3),
    );
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: seg == ChainSeg.fail
              ? Row(
                  spacing: 16,
                  children: [
                    Expanded(child: line),
                    Expanded(child: line),
                  ],
                )
              : line,
        ),
        if (seg == ChainSeg.fail)
          ShapeBadge(
            shape: MaterialShapes.softBurst,
            color: colorScheme.error,
            size: 18,
            child: GlyphIcon(
              AppGlyphs.close,
              size: 10,
              color: colorScheme.onError,
            ),
          ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.node, required this.size});

  final StripNode node;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final active = node.slot == ChainSlot.active;
    final Widget mark = switch (node.slot) {
      ChainSlot.empty || ChainSlot.active => ShapeBadge(
        shape: MaterialShapes.circle,
        color: colors.tone2,
        size: size,
        ring: active
            ? BorderSide(
                color: colorScheme.primary,
                width: 2.5,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
        child: GlyphIcon(
          AppGlyphs.add,
          size: size * 0.42,
          color: active ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      ChainSlot.failed => ShapeBadge(
        shape: MaterialShapes.softBurst,
        color: colorScheme.error,
        size: size,
        child: GlyphIcon(
          AppGlyphs.warning,
          size: size * 0.44,
          color: colorScheme.onError,
        ),
      ),
      ChainSlot.filled when node.glyph != null => ShapeBadge(
        shape: MaterialShapes.circle,
        color: colors.tone2,
        size: size,
        child: GlyphIcon(
          node.glyph!,
          size: size * 0.46,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      ChainSlot.filled when node.group => Stack(
        clipBehavior: Clip.none,
        children: [
          ShapeFlag(code: node.code, size: size),
          PositionedDirectional(
            end: -4,
            bottom: -2,
            child: ShapeBadge(
              shape: MaterialShapes.circle,
              color: colorScheme.inverseSurface,
              size: size * 0.42,
              child: GlyphIcon(
                AppGlyphs.swap,
                size: size * 0.26,
                color: colorScheme.onInverseSurface,
              ),
            ),
          ),
        ],
      ),
      ChainSlot.filled => ShapeFlag(code: node.code, size: size),
    };
    final column = Column(
      children: [
        mark,
        const SizedBox(height: 8),
        Text(
          node.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.footnote
              .of(context, emphasized: true)
              .copyWith(color: active ? colorScheme.primary : null),
        ),
        Text(
          node.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: DashboardText.label(
            context,
            color: node.captionTone,
          ).toTabular,
        ),
      ],
    );
    final onTap = node.onTap;
    if (onTap == null) return column;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: column,
      ),
    );
  }
}

/// The delay as text in the delay colors, or a failure in the error color.
class ChainDelayText extends StatelessWidget {
  const ChainDelayText({super.key, required this.delay, this.failure});

  final int? delay;
  final String? failure;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final failure = this.failure;
    final delay = this.delay;
    return Text(
      failure ??
          switch (delay) {
            null => '—',
            > 0 => chainLatency(context.appLocalizations, delay),
            _ => context.appLocalizations.chainsNoResponse,
          },
      maxLines: 1,
      style: AppTextStyle.caption2
          .of(context, emphasized: true)
          .toTabular
          .copyWith(
            color: failure != null
                ? colorScheme.error
                : colorScheme.delayColor(delay),
          ),
    );
  }
}
