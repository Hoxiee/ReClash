import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'layout.dart';
import 'style.dart';
import 'widget_registry.dart';

const _rowHeight = 64.0;
const _rowGap = 8.0;
const _addableTop = 14.0;
const _swayLoop = Duration(milliseconds: 3600);
const _swaysPerLoop = [6, 7, 5];
const _swayPhaseStep = 1.7;
const _swayTurn = 0.7 * math.pi / 180;
const _swayBob = 1.25;
const _roomDuration = Duration(milliseconds: 260);
const _appearDuration = Duration(milliseconds: 200);
const _appearScale = 0.92;
const _liftGrowth = 0.03;

class DashboardEditor extends ConsumerWidget {
  const DashboardEditor({
    super.key,
    required this.platform,
    required this.widgets,
    required this.cardKeyOf,
    required this.padding,
    required this.gap,
    required this.onDone,
  });

  final SupportPlatform platform;
  final List<DashboardWidget> widgets;

  /// Shared with the cards outside edit mode, so each keeps its state.
  final GlobalKey Function(DashboardWidget widget) cardKeyOf;
  final EdgeInsets padding;
  final double gap;
  final VoidCallback onDone;

  /// Cards this platform cannot show stay where they were among the rest.
  List<DashboardWidget> _keepingOtherPlatforms(
    WidgetRef ref,
    List<DashboardWidget> saved,
    List<DashboardWidget> shown,
  ) {
    final result = [...shown];
    var at = 0;
    for (final card in saved) {
      if (card.platforms.contains(platform) &&
          (card != DashboardWidget.announcement ||
              ref.read(providerAnnouncementProvider) != null)) {
        final index = result.indexOf(card);
        if (index != -1) at = index + 1;
      } else {
        result.insert(at++, card);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardCardEditor<DashboardWidget>(
      cards: widgets,
      candidates: [
        for (final card in DashboardWidget.values)
          if (card != DashboardWidget.announcement &&
              card.platforms.contains(platform))
            card,
      ],
      cardOf: (card) => card.card,
      cardKeyOf: cardKeyOf,
      labelOf: (context, card) => card.label(context),
      descriptionOf: (context, card) => card.description(context),
      glyphOf: (card) => card.glyph,
      removable: (card) => card.removable,
      padding: padding,
      gap: gap,
      onDone: onDone,
      onChanged: (shown) => ref
          .read(appSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              dashboardWidgets: _keepingOtherPlatforms(
                ref,
                state.dashboardWidgets,
                shown,
              ),
            ),
          ),
    );
  }
}

class DashboardCardEditor<T extends Enum> extends StatefulWidget {
  const DashboardCardEditor({
    super.key,
    required this.cards,
    required this.candidates,
    required this.cardOf,
    required this.labelOf,
    required this.glyphOf,
    required this.padding,
    required this.gap,
    required this.onChanged,
    required this.onDone,
    this.cardKeyOf,
    this.descriptionOf,
    this.removable,
  });

  final List<T> cards;

  /// Every card that may be shown, in the order the ones to add are offered.
  final List<T> candidates;
  final Widget Function(T card) cardOf;
  final String Function(BuildContext context, T card) labelOf;
  final Glyph Function(T card) glyphOf;
  final EdgeInsets padding;
  final double gap;

  final ValueChanged<List<T>> onChanged;
  final VoidCallback onDone;

  /// Shared with the cards outside edit mode, so each keeps its state.
  final GlobalKey Function(T card)? cardKeyOf;
  final String? Function(BuildContext context, T card)? descriptionOf;
  final bool Function(T card)? removable;

  @override
  State<DashboardCardEditor<T>> createState() => _DashboardCardEditorState<T>();
}

class _DashboardCardEditorState<T extends Enum>
    extends State<DashboardCardEditor<T>>
    with SingleTickerProviderStateMixin {
  late final _sway = AnimationController(vsync: this, duration: _swayLoop);

  /// The saved cards and any removed one still on its way out.
  late var _cards = widget.cards;
  final _leaving = <T>{};
  final _entering = <T>{};

  List<T> get _shown => [
    for (final card in _cards)
      if (!_leaving.contains(card)) card,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations) {
      _sway.stop();
    } else if (!_sway.isAnimating) {
      _sway.repeat();
    }
  }

  @override
  void didUpdateWidget(DashboardCardEditor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.cards, _shown)) {
      _cards = widget.cards;
      _leaving.clear();
      _entering.clear();
    }
  }

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  void _save() => widget.onChanged(_shown);

  void _remove(T card) {
    setState(() => _leaving.add(card));
    _save();
  }

  void _add(T card) {
    setState(() {
      if (!_leaving.remove(card)) {
        _entering.add(card);
        _cards = [..._cards, card];
      }
    });
    _save();
  }

  void _reorder(int from, int to) {
    setState(() => _cards = _cards.copyAndReorder(from, to));
    _save();
  }

  void _settle(T card) {
    _entering.remove(card);
    if (mounted && _leaving.remove(card)) {
      setState(() => _cards = [..._cards]..remove(card));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards;
    final shown = _shown;
    final addable = [
      for (final card in widget.candidates)
        if (!shown.contains(card)) card,
    ];
    final density = DashboardDensityScope.of(context);
    final scale = DashboardDensityScope.scaleOf(context);
    final sway = context.disableAnimations ? null : _sway;
    final appLocalizations = context.appLocalizations;
    final removable = widget.removable;

    final revealPadding = EdgeInsets.only(
      top: widget.padding.top,
      bottom: widget.padding.bottom,
    );

    Widget spaced(Widget child) => Padding(
      padding: EdgeInsets.only(bottom: widget.gap),
      child: child,
    );

    return BackLayerScope(
      onBack: widget.onDone,
      child: SliverPadding(
        padding: widget.padding,
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverReorderableList(
              itemCount: cards.length,
              itemBuilder: (_, index) {
                final card = cards[index];
                return _Presence(
                  key: ValueKey(card),
                  entering: _entering.contains(card),
                  leaving: _leaving.contains(card),
                  revealPadding: revealPadding,
                  onSettled: () => _settle(card),
                  child: spaced(
                    _EditableCard(
                      card: widget.cardOf(card),
                      label: widget.labelOf(context, card),
                      cardKey: widget.cardKeyOf?.call(card),
                      index: index,
                      seed: card.index,
                      sway: sway,
                      onRemove: removable == null || removable(card)
                          ? () => _remove(card)
                          : null,
                    ),
                  ),
                );
              },
              // The held card rides in the overlay, outside the density scope,
              // and takes its key along while the list leaves its place empty.
              proxyDecorator: (_, index, animation) => DashboardDensityScope(
                density: density,
                scale: scale,
                child: spaced(
                  _LiftedCard(
                    animation: animation,
                    child: AbsorbPointer(
                      child: RepaintBoundary(
                        key: widget.cardKeyOf?.call(cards[index]),
                        child: widget.cardOf(cards[index]),
                      ),
                    ),
                  ),
                ),
              ),
              onReorderItem: _reorder,
            ),
            if (addable.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(top: _addableTop),
                sliver: SliverList.list(
                  children: [
                    _SectionLabel(appLocalizations.dashboardAddableSection),
                    for (final card in addable)
                      Padding(
                        padding: const EdgeInsets.only(bottom: _rowGap),
                        child: _AddRow(
                          label: widget.labelOf(context, card),
                          description: widget.descriptionOf?.call(
                            context,
                            card,
                          ),
                          glyph: widget.glyphOf(card),
                          onAdd: () => _add(card),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Brings an added card in once its room has opened and scrolled into view,
/// and takes a removed one out before closing its room, so the cards around
/// it slide instead of jumping.
class _Presence extends StatefulWidget {
  const _Presence({
    super.key,
    required this.entering,
    required this.leaving,
    required this.revealPadding,
    required this.onSettled,
    required this.child,
  });

  final bool entering;
  final bool leaving;

  /// What floats over the viewport's edges, kept clear of an opening room.
  final EdgeInsets revealPadding;
  final VoidCallback onSettled;
  final Widget child;

  @override
  State<_Presence> createState() => _PresenceState();
}

class _PresenceState extends State<_Presence>
    with SingleTickerProviderStateMixin {
  final _content = GlobalKey();
  late final _controller = AnimationController(
    vsync: this,
    value: widget.entering ? 0 : 1,
  );
  late final _roomShare =
      _roomDuration.inMicroseconds /
      (_roomDuration + _appearDuration).inMicroseconds;
  late final _room = CurvedAnimation(
    parent: _controller,
    curve: Interval(0, _roomShare, curve: Curves.easeOutCubic),
    reverseCurve: Interval(0, _roomShare, curve: Curves.easeInCubic),
  );
  late final _appear = CurvedAnimation(
    parent: _controller,
    curve: Interval(_roomShare, 1, curve: Curves.easeOutCubic),
  );
  VoidCallback? _follow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motionDuration(
      _roomDuration + _appearDuration,
    );
    if (widget.entering && _controller.isDismissed) {
      _run();
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void didUpdateWidget(_Presence oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.leaving != oldWidget.leaving) {
      _run();
    }
  }

  @override
  void dispose() {
    _stopFollowing();
    _room.dispose();
    _appear.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _run() {
    final run = widget.leaving ? _controller.reverse() : _controller.forward();
    run.then((_) {
      if (mounted) {
        widget.onSettled();
      }
    });
  }

  void _reveal() {
    final box = _content.currentContext?.findRenderObject();
    final position = Scrollable.maybeOf(context)?.position;
    if (!mounted || box is! RenderBox || !box.hasSize || position == null) {
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) {
      return;
    }
    final rect = widget.revealPadding.inflateRect(Offset.zero & box.size);
    final leading = viewport.getOffsetToReveal(box, 0, rect: rect).offset;
    final trailing = viewport.getOffsetToReveal(box, 1, rect: rect).offset;
    final from = position.pixels;
    final to = clampDouble(
      trailing > leading ? leading : clampDouble(from, trailing, leading),
      position.minScrollExtent,
      position.maxScrollExtent + box.size.height * (1 - _room.value),
    );
    if ((to - from).abs() < precisionErrorTolerance) {
      return;
    }
    // Moved once each frame has laid the grown room out: a jump past the old
    // scroll end would send the position bouncing back to it.
    void follow() {
      final room = _room.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && position.hasPixels) {
          position.jumpTo(lerpDouble(from, to, room)!);
        }
      });
      if (room == 1) {
        _stopFollowing();
      }
    }

    _follow = follow;
    _room.addListener(follow);
  }

  void _stopFollowing() {
    final follow = _follow;
    if (follow != null) {
      _room.removeListener(follow);
      _follow = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.leaving,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Align(
          alignment: AlignmentDirectional.topStart,
          heightFactor: _room.value,
          child: KeyedSubtree(
            key: _content,
            child: Opacity(
              opacity: _appear.value,
              child: Transform.scale(
                scale: lerpDouble(_appearScale, 1, _appear.value)!,
                child: child,
              ),
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class _EditableCard extends StatelessWidget {
  const _EditableCard({
    required this.card,
    required this.label,
    required this.cardKey,
    required this.index,
    required this.seed,
    required this.sway,
    required this.onRemove,
  });

  final Widget card;
  final String label;
  final GlobalKey? cardKey;
  final int index;

  /// Sets the card's own rhythm, so neighbours do not sway in step.
  final int seed;
  final Animation<double>? sway;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final card = AbsorbPointer(
      child: RepaintBoundary(key: cardKey, child: this.card),
    );
    final onRemove = this.onRemove;
    final content = Stack(
      fit: StackFit.passthrough,
      children: [
        ReorderableDelayedDragStartListener(index: index, child: card),
        if (onRemove != null)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: _RoundButton(
              glyph: AppGlyphs.remove,
              tooltip: '${context.appLocalizations.remove} $label',
              background: colorScheme.errorContainer,
              foreground: colorScheme.onErrorContainer,
              onPressed: onRemove,
            ),
          ),
      ],
    );
    final sway = this.sway;
    // The sway repaints every frame; the boundary keeps that to this card.
    return RepaintBoundary(
      child: sway == null
          ? content
          : _Sway(sway: sway, seed: seed, child: content),
    );
  }
}

class _Sway extends AnimatedWidget {
  const _Sway({
    required Animation<double> sway,
    required this.seed,
    required this.child,
  }) : super(listenable: sway);

  final int seed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final swings = _swaysPerLoop[seed % _swaysPerLoop.length];
    final turn =
        (listenable as Animation<double>).value * 2 * math.pi * swings +
        seed * _swayPhaseStep;
    return Transform.translate(
      offset: Offset(0, math.cos(turn) * _swayBob),
      child: Transform.rotate(angle: math.sin(turn) * _swayTurn, child: child),
    );
  }
}

class _LiftedCard extends StatelessWidget {
  const _LiftedCard({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shadows = DashboardShadows.e2(context);
    final shape = AppShape.all(DashboardCorner.mobileCard);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOut.transform(animation.value);
        return Transform.scale(
          scale: 1 + _liftGrowth * t,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: shape,
              shadows: [
                for (final shadow in shadows)
                  shadow.copyWith(
                    color: shadow.color.withValues(alpha: shadow.color.a * t),
                  ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
      child: Text(
        text,
        style: AppTextStyle.footnote
            .of(context, emphasized: true)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({
    required this.label,
    required this.description,
    required this.glyph,
    required this.onAdd,
  });

  final String label;
  final String? description;
  final Glyph glyph;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final description = this.description;
    return Container(
      height: _rowHeight,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
      decoration: ShapeDecoration(
        color: colors.card.withValues(alpha: 0.55),
        shape: AppShape.all(DashboardCorner.mobileBlock),
      ),
      child: Row(
        spacing: 12,
        children: [
          _RoundButton(
            glyph: AppGlyphs.add,
            tooltip: '${context.appLocalizations.add} $label',
            background: colorScheme.primary,
            foreground: colorScheme.onPrimary,
            onPressed: onAdd,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: colors.card,
              shape: AppShape.all(DashboardCorner.badge),
            ),
            child: Center(
              child: GlyphIcon(
                glyph,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subheadline.of(context, emphasized: true),
                ),
                if (description != null)
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DashboardText.label(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.glyph,
    required this.tooltip,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final Glyph glyph;
  final String tooltip;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 28,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size.square(28),
          fixedSize: const Size.square(28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        icon: GlyphIcon(glyph, size: 16, color: foreground),
      ),
    );
  }
}
