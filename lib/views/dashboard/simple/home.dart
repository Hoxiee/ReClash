import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/update_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'location_card.dart';
import 'power_button.dart';
import 'subscription_card.dart';

/// The button, what it did and what is left to spend, under a pending app
/// update; on a phone also where traffic leaves.
class SimpleHome extends ConsumerWidget {
  const SimpleHome({super.key, required this.padding, this.wide = false});

  final EdgeInsets padding;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (minSize, maxSize) = wide ? (184.0, 256.0) : (160.0, 220.0);
    final hasUpdate = ref.watch(
      appUpdateActionProvider.select((state) => state.hasUpdate),
    );
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: _FillHero(
          viewport: constraints.maxHeight - padding.vertical,
          minHero: SimplePower.heightOf(minSize),
          above: hasUpdate ? const UpdateCard() : null,
          hero: SimplePower(minSize: minSize, maxSize: maxSize),
          below: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (!wide) const LocationCard(),
                const SubscriptionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays [above] and [below] out at their own height; the hero gets the rest
/// of the viewport, never less than [minHero].
class _FillHero extends MultiChildRenderObjectWidget {
  _FillHero({
    required this.viewport,
    required this.minHero,
    required Widget hero,
    required Widget below,
    Widget? above,
  }) : super(children: [hero, below, ?above]);

  final double viewport;
  final double minHero;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFillHero(viewport: viewport, minHero: minHero);

  @override
  void updateRenderObject(BuildContext context, _RenderFillHero renderObject) {
    renderObject
      ..viewport = viewport
      ..minHero = minHero;
  }
}

const _aboveGap = 16.0;

class _FillHeroParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderFillHero extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FillHeroParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FillHeroParentData> {
  _RenderFillHero({required double viewport, required double minHero})
    : _viewport = viewport,
      _minHero = minHero;

  double _viewport;
  set viewport(double value) {
    if (value == _viewport) return;
    _viewport = value;
    markNeedsLayout();
  }

  double _minHero;
  set minHero(double value) {
    if (value == _minHero) return;
    _minHero = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FillHeroParentData) {
      child.parentData = _FillHeroParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final hero = firstChild!;
    final below = childAfter(hero)!;
    final above = childAfter(below);
    var top = 0.0;
    if (above != null) {
      above.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);
      top = above.size.height + _aboveGap;
    }
    below.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);
    final heroHeight = math.max(_minHero, _viewport - top - below.size.height);
    hero.layout(BoxConstraints.tight(Size(width, heroHeight)));
    (hero.parentData! as BoxParentData).offset = Offset(0, top);
    (below.parentData! as BoxParentData).offset = Offset(0, top + heroHeight);
    size = constraints.constrain(
      Size(width, top + heroHeight + below.size.height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Asks for a run and shows the request: a start reads as connecting for at
/// least [_holdDuration] and until the request settles, while the run state
/// itself stays with the providers.
class SimplePower extends ConsumerStatefulWidget {
  const SimplePower({super.key, required this.minSize, required this.maxSize});

  /// The button grows with its room between these, the status always under
  /// it.
  final double minSize;
  final double maxSize;

  static double heightOf(double size) =>
      PowerButton.extentOf(size) + _statusHeight;

  @override
  ConsumerState<SimplePower> createState() => _SimplePowerState();
}

class _SimplePowerState extends ConsumerState<SimplePower> {
  static const _holdDuration = Duration(milliseconds: 600);

  var _request = 0;
  var _starting = false;
  Timer? _hold;

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    final request = ++_request;
    final starting = !ref.read(isStartProvider) && !_starting;
    _hold?.cancel();
    setState(() {
      _starting = starting;
      _hold = starting
          ? Timer(_holdDuration, () {
              if (mounted) setState(() => _hold = null);
            })
          : null;
    });
    try {
      await ref.read(commonActionProvider.notifier).toggleRunning();
    } finally {
      if (mounted && request == _request) {
        setState(() => _starting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final isStart = ref.watch(isStartProvider);
    final suspended = isStart && ref.watch(suspendProvider);
    final coreConnecting =
        isStart && ref.watch(coreStatusProvider) == CoreStatus.connecting;
    final link = !hasProfile
        ? PowerLink.off
        : _starting || _hold != null || coreConnecting
        ? PowerLink.connecting
        : suspended
        ? PowerLink.paused
        : isStart
        ? PowerLink.on
        : PowerLink.off;
    final logo = ref.watch(
      currentProfileProvider.select(
        (profile) => profile?.subscriptionSnapshot?.metadata.logo ?? '',
      ),
    );
    final look = ref.watch(providerPowerButtonProvider);
    final tooltip = switch (link) {
      PowerLink.paused => appLocalizations.onDemandResume,
      PowerLink.on || PowerLink.connecting => appLocalizations.stop,
      PowerLink.off => appLocalizations.start,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final room = math.min(
          constraints.maxHeight - _statusHeight,
          constraints.maxWidth,
        );
        final size = (room / PowerButton.extentOf(1)).clamp(
          widget.minSize,
          widget.maxSize,
        );
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PowerButton(
                link: link,
                size: size,
                logo: logo,
                look: look,
                tooltip: tooltip,
                onPressed: hasProfile ? _toggle : null,
              ),
              const SizedBox(height: 20),
              _StatusText(link: link, hasProfile: hasProfile),
            ],
          ),
        );
      },
    );
  }
}

/// The status title and hint under the button, with the gap above them.
const _statusHeight = 90.0;

class _StatusText extends ConsumerWidget {
  const _StatusText({required this.link, required this.hasProfile});

  final PowerLink link;
  final bool hasProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final secondary = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    final (title, hint) = switch (link) {
      _ when !hasProfile => (
        appLocalizations.simpleStatusNoProfile,
        appLocalizations.simpleStatusNoProfileHint,
      ),
      PowerLink.off => (
        appLocalizations.simpleStatusOff,
        appLocalizations.simpleStatusOffHint,
      ),
      PowerLink.connecting => (
        appLocalizations.simpleStatusConnecting,
        appLocalizations.simpleStatusConnectingHint,
      ),
      PowerLink.paused => (
        appLocalizations.simpleStatusPaused,
        switch (ref.watch(onDemandMatchedNetworksProvider).firstOrNull) {
          final network? => appLocalizations.simpleStatusPausedOn(network),
          null => appLocalizations.simpleStatusPausedHint,
        },
      ),
      PowerLink.on => (appLocalizations.simpleStatusOn, null),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.title1.of(context, emphasized: true),
        ),
        SizedBox(
          height: 24,
          child: Center(
            child: hint == null
                ? const FittedBox(fit: BoxFit.scaleDown, child: _LiveLine())
                : Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: secondary,
                  ),
          ),
        ),
      ],
    );
  }
}

/// The session time and the speed each way, refreshed every second.
class _LiveLine extends ConsumerWidget {
  const _LiveLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final runTime = ref.watch(runTimeProvider);
    final traffic = ref.watch(
      trafficsProvider.select((state) => state.list.safeLast(const Traffic())),
    );
    final caption = AppTextStyle.subheadline
        .of(context)
        .toTabular
        .copyWith(color: colorScheme.onSurfaceVariant);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        DecoratedBox(
          decoration: ShapeDecoration(color: colors.ok, shape: AppShape.circle),
          child: const SizedBox.square(dimension: 8),
        ),
        Text(
          getTimeText(runTime),
          style: caption.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(width: 6),
        GlyphIcon(AppGlyphs.arrowDown, size: 16, color: colorScheme.primary),
        Text('${dashboardTraffic(traffic.down)}/s', style: caption),
        const SizedBox(width: 2),
        GlyphIcon(
          AppGlyphs.arrowUp,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        Text('${dashboardTraffic(traffic.up)}/s', style: caption),
      ],
    );
  }
}
