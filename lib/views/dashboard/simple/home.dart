import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/subscriptions/notification/record.dart';
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
class PowerRequest extends ConsumerStatefulWidget {
  const PowerRequest({super.key, required this.builder});

  /// A null toggle means there is no profile to run.
  final Widget Function(
    BuildContext context,
    PowerLink link,
    VoidCallback? toggle,
  )
  builder;

  @override
  ConsumerState<PowerRequest> createState() => _PowerRequestState();
}

class _PowerRequestState extends ConsumerState<PowerRequest> {
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
    return widget.builder(context, link, hasProfile ? _toggle : null);
  }
}

String powerTooltip(BuildContext context, PowerLink link) {
  final appLocalizations = context.appLocalizations;
  return switch (link) {
    PowerLink.paused => appLocalizations.onDemandResume,
    PowerLink.on || PowerLink.connecting => appLocalizations.stop,
    PowerLink.off => appLocalizations.start,
  };
}

/// The power button over its status.
class SimplePower extends ConsumerWidget {
  const SimplePower({super.key, required this.minSize, required this.maxSize});

  /// The button grows with its room between these, the status always under
  /// it.
  final double minSize;
  final double maxSize;

  static double heightOf(double size) =>
      PowerButton.extentOf(size) + _statusHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = context.colorScheme.brightness == Brightness.dark;
    final logo = ref.watch(
      currentProfileProvider.select(
        (profile) =>
            profile?.subscriptionSnapshot?.metadata.logoFor(dark: dark) ?? '',
      ),
    );
    final look = ref.watch(providerPowerButtonProvider);
    return PowerRequest(
      builder: (context, link, toggle) => LayoutBuilder(
        builder: (context, constraints) {
          final room = math.min(
            constraints.maxHeight - _statusHeight,
            constraints.maxWidth,
          );
          final size = (room / PowerButton.extentOf(1)).clamp(minSize, maxSize);
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PowerButton(
                  link: link,
                  size: size,
                  logo: logo,
                  look: look,
                  tooltip: powerTooltip(context, link),
                  onPressed: toggle,
                ),
                const SizedBox(height: 20),
                _StatusText(link: link, hasProfile: toggle != null),
              ],
            ),
          );
        },
      ),
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
        _pausedHint(context, ref),
      ),
      PowerLink.on => (appLocalizations.simpleStatusOn, null),
    };
    final custom = hasProfile ? _customLabel(ref) : null;
    final shownTitle = custom?.title ?? title;
    final shownHint = custom == null
        ? hint
        : custom.hint ??
              switch (link) {
                PowerLink.paused => _pausedHint(context, ref),
                _ => null,
              };
    final showLive = hasProfile && link == PowerLink.on;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Semantics(
          label: custom == null ? null : '$title. ${custom.title}',
          excludeSemantics: custom != null,
          child: Text(
            shownTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.title1.of(context, emphasized: true),
          ),
        ),
        SizedBox(
          height: 24,
          child: Center(
            child: showLive
                ? const FittedBox(fit: BoxFit.scaleDown, child: _LiveLine())
                : shownHint == null
                ? null
                : Text(
                    shownHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: secondary,
                  ),
          ),
        ),
      ],
    );
  }

  String _pausedHint(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return switch (ref.watch(onDemandMatchedNetworksProvider).firstOrNull) {
      final network? => appLocalizations.simpleStatusPausedOn(network),
      null => appLocalizations.simpleStatusPausedHint,
    };
  }

  /// The provider's label for the real state, null when it has none or a
  /// placeholder has no value.
  ProviderPowerLabel? _customLabel(WidgetRef ref) {
    final label = ref.watch(providerPowerLabelProvider)[link.name];
    if (label == null) return null;
    final info = ref.watch(
      currentProfileProvider.select((profile) => profile?.subscriptionInfo),
    );
    final metadata = ref.watch(
      currentProfileProvider.select(
        (profile) => profile?.subscriptionSnapshot?.metadata,
      ),
    );
    final expiry = metadata?.perpetual == true || info == null
        ? null
        : subscriptionExpireDate(info.expire);
    final left = info == null || metadata?.unlimited == true || info.total <= 0
        ? null
        : math.max(0, info.total - info.upload - info.download);
    return resolveProviderPowerLabel(label, {
      'daysLeft': expiry == null
          ? null
          : '${remainingDays(expire: info!.expire, now: DateTime.now())}',
      'trafficLeft': left == null ? null : dashboardTraffic(left),
      'server': ref.watch(providerServerNodeProvider),
    });
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
