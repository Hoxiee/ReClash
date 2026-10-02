import 'dart:math';

import 'package:emoji_regex/emoji_regex.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';

final _urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);

const _lineSpacing = 1.35;

bool _exceedsLines(
  String text,
  TextStyle? style,
  double maxWidth,
  int maxLines,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  final exceeded = painter.didExceedMaxLines;
  painter.dispose();
  return exceeded;
}

class Announce extends ConsumerStatefulWidget {
  const Announce({super.key, this.expanded = false});

  /// When set, the tile grows to show the whole announcement instead of
  /// clipping it to the deck row. The pager's dedicated page opts in; the
  /// desktop split stays collapsed beside the orb.
  final bool expanded;

  @override
  ConsumerState<Announce> createState() => _AnnounceState();
}

class _AnnounceState extends ConsumerState<Announce> {
  final _cardKey = GlobalKey();

  // The collapsed tile grows in place into a reading panel that fills the
  // column, rather than a sheet sliding in from the edge. The open-in-browser
  // action rides along in the panel header, so the tile keeps no link glyph.
  void _openMorph(BuildContext context, String? text, String? url) {
    if (text == null || text.isEmpty) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlayBox == null || cardBox == null || !cardBox.hasSize) return;
    final origin = cardBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final sourceRect = origin & cardBox.size;
    // Grow within the neighbouring card column when one marks itself, so the
    // desktop split fills its own stack instead of the whole screen.
    final boundaryBox =
        AnnounceMorphBoundary.boxOf(context)?.currentContext?.findRenderObject()
            as RenderBox?;
    final bounds = boundaryBox != null && boundaryBox.hasSize
        ? boundaryBox.localToGlobal(Offset.zero, ancestor: overlayBox) &
              boundaryBox.size
        : null;
    final radius = DashboardWidgetMetrics.radiusOf(context);
    final textScale = DashboardWidgetMetrics.textScaleOf(context);
    showGeneralDialog<void>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      barrierLabel: context.appLocalizations.announce,
      barrierColor: Colors.black54,
      transitionDuration: context.motionDuration(
        const Duration(milliseconds: 460),
      ),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, _, _) => _AnnounceMorph(
        animation: animation,
        sourceRect: sourceRect,
        sourceRadius: radius,
        overlaySize: overlayBox.size,
        bounds: bounds,
        textScale: textScale,
        text: text,
        url: url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expanded = widget.expanded;
    final panelMeta = ref.watch(
      currentProfileProvider.select((state) => state?.panelMeta),
    );
    final text = panelMeta?.announce?.trim();
    final url = panelMeta?.announceUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;
    final hasAnnouncement = text != null && text.isNotEmpty;
    final showFull = expanded && hasAnnouncement;
    return DashboardInfoCard(
      key: _cardKey,
      height: showFull ? null : DashboardWidgetMetrics.heightOf(context, 2),
      icon: AppGlyphs.announce,
      label: context.appLocalizations.announce,
      action: showFull && hasUrl
          ? const GlyphIcon(AppGlyphs.openExternal, size: 18)
          : null,
      onPressed: !hasAnnouncement
          ? null
          : showFull
          ? (hasUrl ? () => dialogs.openUrl(url) : null)
          : () => _openMorph(context, text, url),
      child: showFull
          ? _AnnounceFull(text: text)
          : _AnnounceCollapsed(text: text, hasAnnouncement: hasAnnouncement),
    );
  }
}

class _AnnounceFull extends StatelessWidget {
  const _AnnounceFull({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.colorScheme.onSurface,
      height: _lineSpacing,
    );
    return Align(
      alignment: Alignment.topLeft,
      child: AnnounceText(text: text, style: style),
    );
  }
}

class _AnnounceCollapsed extends StatelessWidget {
  const _AnnounceCollapsed({required this.text, required this.hasAnnouncement});

  final String? text;
  final bool hasAnnouncement;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = context.textTheme.bodyMedium?.copyWith(
          color: hasAnnouncement
              ? context.colorScheme.onSurface
              : context.colorScheme.onSurfaceVariant,
          height: _lineSpacing,
        );
        final lineHeight = (style?.fontSize ?? 14) * _lineSpacing;
        final displayText = hasAnnouncement
            ? text!
            : context.appLocalizations.noAnnouncements;
        // A clipped half line reads as a rendering fault, so whole ones only.
        final maxLines = max(1, constraints.maxHeight ~/ lineHeight);
        final clipped =
            hasAnnouncement &&
            _exceedsLines(displayText, style, constraints.maxWidth, maxLines);
        final content = Align(
          alignment: Alignment.topLeft,
          child: AnnounceText(
            text: displayText,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        );
        if (!clipped) return content;
        final fade = (lineHeight / constraints.maxHeight).clamp(0.0, 0.5);
        return Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 1 - fade, 1],
                  colors: const [
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                ).createShader(rect),
                child: content,
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(child: Center(child: _MoreHint())),
            ),
          ],
        );
      },
    );
  }
}

/// A pill parked over the fade so the cut-off is unmistakable, not just a soft
/// gradient a reader might miss.
class _MoreHint extends StatelessWidget {
  const _MoreHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        shape: AppShape.full,
      ),
      child: GlyphIcon(
        AppGlyphs.chevronDown,
        size: 16,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Panel announcements mix plain text, emoji, and URLs; emoji gets the bundled
/// Twemoji face and URLs become tappable when [links] is set.
class AnnounceText extends StatefulWidget {
  const AnnounceText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.links = false,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool links;

  @override
  State<AnnounceText> createState() => _AnnounceTextState();
}

class _AnnounceTextState extends State<AnnounceText> {
  List<({String url, TapGestureRecognizer recognizer})> _links = const [];

  @override
  void initState() {
    super.initState();
    _links = _createLinks();
  }

  @override
  void didUpdateWidget(AnnounceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.links != widget.links) {
      _disposeLinks();
      _links = _createLinks();
    }
  }

  @override
  void dispose() {
    _disposeLinks();
    super.dispose();
  }

  List<({String url, TapGestureRecognizer recognizer})> _createLinks() {
    if (!widget.links) {
      return const [];
    }
    return _urlPattern
        .allMatches(widget.text)
        .map((match) => match.group(0)!)
        .map(
          (url) => (
            url: url,
            recognizer: TapGestureRecognizer()
              ..onTap = () => dialogs.openUrl(url),
          ),
        )
        .toList();
  }

  void _disposeLinks() {
    for (final link in _links) {
      link.recognizer.dispose();
    }
  }

  List<InlineSpan> _emojiSpans(String text, TextStyle? style) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in emojiRegex().allMatches(text)) {
      if (match.start > last) {
        spans.add(
          TextSpan(text: text.substring(last, match.start), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: style?.copyWith(fontFamily: FontFamily.twEmoji.value),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: style));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.textTheme.bodyMedium?.toLight;
    final linkStyle = style?.copyWith(color: context.colorScheme.primary);
    final spans = <InlineSpan>[];
    var linkIndex = 0;
    var lastIndex = 0;
    for (final match in _urlPattern.allMatches(widget.text)) {
      if (match.start > lastIndex) {
        spans.addAll(
          _emojiSpans(widget.text.substring(lastIndex, match.start), style),
        );
      }
      final url = match.group(0)!;
      if (linkIndex < _links.length) {
        spans.add(
          TextSpan(
            text: url,
            style: linkStyle,
            recognizer: _links[linkIndex].recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: url, style: style));
      }
      linkIndex++;
      lastIndex = match.end;
    }
    if (lastIndex < widget.text.length) {
      spans.addAll(_emojiSpans(widget.text.substring(lastIndex), style));
    }
    return Text.rich(
      TextSpan(children: spans),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// Grows the tapped announcement tile in place into a column-filling reading
/// panel. The surface rides a [RectTween] on the morph spring from the tile's
/// own bounds, so the eye follows it open instead of a sheet arriving from the
/// edge.
class _AnnounceMorph extends StatelessWidget {
  const _AnnounceMorph({
    required this.animation,
    required this.sourceRect,
    required this.sourceRadius,
    required this.overlaySize,
    required this.bounds,
    required this.textScale,
    required this.text,
    required this.url,
  });

  final Animation<double> animation;
  final Rect sourceRect;
  final double sourceRadius;
  final Size overlaySize;
  final Rect? bounds;
  final double textScale;
  final String text;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final limitTop = padding.top + 16;
    final limitBottom = overlaySize.height - padding.bottom - 16;
    // Fill the marked neighbour column when present, otherwise the safe area;
    // either way never outgrow the screen and always cover the source tile.
    final target = Rect.fromLTRB(
      sourceRect.left,
      bounds == null
          ? min(sourceRect.top, limitTop)
          : max(min(sourceRect.top, bounds!.top), limitTop),
      sourceRect.right,
      bounds == null
          ? max(sourceRect.bottom, limitBottom)
          : min(max(sourceRect.bottom, bounds!.bottom), limitBottom),
    );
    final morph = CurvedAnimation(
      parent: animation,
      curve: AppSpringCurves.morph,
    );
    final rectTween = RectTween(begin: sourceRect, end: target);
    final radiusTween = Tween<double>(begin: sourceRadius, end: AppCorner.xxl);
    // The morph spring overshoots past 1, so hold fades on the linear track to
    // keep opacity inside [0, 1].
    final actionsOpacity = animation.drive(
      CurveTween(curve: const Interval(0.25, 0.85, curve: Curves.easeOut)),
    );
    final color = context.colorScheme.surfaceContainerLow;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final rect = rectTween.evaluate(morph) ?? sourceRect;
        final radius = max(0.0, radiusTween.evaluate(morph));
        return Stack(
          children: [
            Positioned.fromRect(
              rect: rect,
              child: Material(
                color: color,
                clipBehavior: Clip.antiAlias,
                shape: AppShape.all(radius),
                child: _AnnouncePanel(
                  text: text,
                  url: url,
                  textScale: textScale,
                  actionsOpacity: actionsOpacity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The opened panel: a header mirroring the collapsed tile so the morph starts
/// seamless, with the full announcement revealed by the growing clip and the
/// open-in-browser and close actions fading in once the surface has room.
class _AnnouncePanel extends StatelessWidget {
  const _AnnouncePanel({
    required this.text,
    required this.url,
    required this.textScale,
    required this.actionsOpacity,
  });

  final String text;
  final String? url;
  final double textScale;
  final Animation<double> actionsOpacity;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    final theme = Theme.of(context);
    final scaledTheme = textScale == 1
        ? theme
        : theme.copyWith(
            textTheme: theme.textTheme.apply(fontSizeFactor: textScale),
          );
    final appLocalizations = context.appLocalizations;
    return Theme(
      data: scaledTheme,
      child: Builder(
        builder: (context) {
          final bodyStyle = context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
            height: _lineSpacing,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GlyphIcon(
                      AppGlyphs.announce,
                      size: 20,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        appLocalizations.announce,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FadeTransition(
                      opacity: actionsOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasUrl)
                            _PanelAction(
                              glyph: AppGlyphs.openExternal,
                              tooltip: appLocalizations.openInBrowser,
                              onPressed: () => dialogs.openUrl(url!),
                            ),
                          _PanelAction(
                            glyph: AppGlyphs.close,
                            tooltip: appLocalizations.close,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: SelectionArea(
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: AnnounceText(
                          text: text,
                          links: true,
                          style: bodyStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Marks the card column the announce morph should grow within. Without it the
/// opened panel fills the safe area; with it the panel stops at this subtree's
/// bounds, so the desktop split spans its own stack of cards, not the screen.
class AnnounceMorphBoundary extends StatefulWidget {
  const AnnounceMorphBoundary({super.key, required this.child});

  final Widget child;

  static GlobalKey? boxOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_AnnounceMorphScope>()?.boundaryKey;

  @override
  State<AnnounceMorphBoundary> createState() => _AnnounceMorphBoundaryState();
}

class _AnnounceMorphBoundaryState extends State<AnnounceMorphBoundary> {
  final _boundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _AnnounceMorphScope(
      boundaryKey: _boundaryKey,
      child: KeyedSubtree(key: _boundaryKey, child: widget.child),
    );
  }
}

class _AnnounceMorphScope extends InheritedWidget {
  const _AnnounceMorphScope({required this.boundaryKey, required super.child});

  final GlobalKey boundaryKey;

  @override
  bool updateShouldNotify(_AnnounceMorphScope oldWidget) =>
      boundaryKey != oldWidget.boundaryKey;
}

class _PanelAction extends StatelessWidget {
  const _PanelAction({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        child: Padding(
          padding: AppInsets.xs,
          child: GlyphIcon(
            glyph,
            size: 20,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
