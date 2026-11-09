import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/supervisor/health.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/widgets/provider_image.dart';

import 'power_button.dart';

/// Lays [above] and [below] out at their own height; the hero gets the rest
/// of the viewport, never less than [minHero].
class FillHero extends MultiChildRenderObjectWidget {
  FillHero({
    super.key,
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
      RenderFillHero(viewport: viewport, minHero: minHero);

  @override
  void updateRenderObject(BuildContext context, RenderFillHero renderObject) {
    renderObject
      ..viewport = viewport
      ..minHero = minHero;
  }
}

const _aboveGap = 16.0;

class _FillHeroParentData extends ContainerBoxParentData<RenderBox> {}

class RenderFillHero extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FillHeroParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FillHeroParentData> {
  RenderFillHero({required double viewport, required double minHero})
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

String powerTooltip(BuildContext context, PowerLink link) {
  final appLocalizations = AppLocalizations.of(context);
  return switch (link) {
    PowerLink.paused => appLocalizations.onDemandResume,
    PowerLink.on || PowerLink.connecting => appLocalizations.stop,
    PowerLink.off => appLocalizations.start,
  };
}

/// What a tap on the button does, for its tooltip and semantics hint.
String powerTapLabel(BuildContext context, PowerFace face) {
  final appLocalizations = AppLocalizations.of(context);
  return switch (face.tap) {
    PowerAction.addProfile => appLocalizations.powerFixAddProfile,
    PowerAction.grantVpn => appLocalizations.powerFixGrantVpn,
    PowerAction.openPortal => appLocalizations.powerFixPortal,
    PowerAction.updateProfile => appLocalizations.powerFixUpdateProfile,
    PowerAction.accountSheet ||
    PowerAction.causeSheet => appLocalizations.powerTapDetails,
    _ => powerTooltip(context, face.link),
  };
}

PowerBadge? powerBadge(PowerFace face) {
  final glyph = switch (face.state) {
    PowerFaceState.accountLocked ||
    PowerFaceState.trafficLocked ||
    PowerFaceState.revoked => AppGlyphs.lock,
    PowerFaceState.noServers || PowerFaceState.broken => AppGlyphs.error,
    PowerFaceState.vpnTaken => AppGlyphs.vpn,
    PowerFaceState.vpnDenied => AppGlyphs.key,
    PowerFaceState.portal || PowerFaceState.brokenPortal => AppGlyphs.wifi,
    PowerFaceState.offline ||
    PowerFaceState.waitingNetwork => AppGlyphs.wifiOff,
    PowerFaceState.clock || PowerFaceState.brokenClock => AppGlyphs.clock,
    PowerFaceState.ending =>
      face.attention?.byTraffic ?? false
          ? AppGlyphs.dataUsage
          : AppGlyphs.clock,
    PowerFaceState.expired ||
    PowerFaceState.exhausted ||
    PowerFaceState.direct ||
    PowerFaceState.grace => AppGlyphs.warning,
    PowerFaceState.on when face.verified => AppGlyphs.check,
    _ => null,
  };
  return glyph == null ? null : PowerBadge(glyph, face.tone);
}

/// The provider label state that may replace the face's title, if any.
String? powerLabelState(PowerFace face) => switch (face.state) {
  PowerFaceState.off => 'off',
  PowerFaceState.starting || PowerFaceState.verifying => 'connecting',
  PowerFaceState.on => 'on',
  PowerFaceState.paused => 'paused',
  PowerFaceState.expired || PowerFaceState.accountLocked => 'expired',
  PowerFaceState.exhausted || PowerFaceState.trafficLocked => 'exhausted',
  PowerFaceState.ending => 'ending',
  PowerFaceState.grace => 'grace',
  _ => null,
};

String powerTitle(AppLocalizations l, PowerFace face) => switch (face.state) {
  PowerFaceState.noProfile => l.simpleStatusNoProfile,
  PowerFaceState.starting ||
  PowerFaceState.verifying => l.simpleStatusConnecting,
  PowerFaceState.accountLocked || PowerFaceState.expired => l.powerTitleExpired,
  PowerFaceState.trafficLocked ||
  PowerFaceState.exhausted => l.powerTitleExhausted,
  PowerFaceState.revoked => l.powerTitleRevoked,
  PowerFaceState.noServers => l.powerTitleNoServers,
  PowerFaceState.vpnTaken => l.powerTitleVpnTaken,
  PowerFaceState.vpnDenied => l.powerTitleVpnDenied,
  PowerFaceState.portal || PowerFaceState.brokenPortal => l.powerTitlePortal,
  PowerFaceState.offline ||
  PowerFaceState.waitingNetwork => l.powerTitleOffline,
  PowerFaceState.clock || PowerFaceState.brokenClock => l.powerTitleClock,
  PowerFaceState.recovering => l.powerTitleRecovering,
  PowerFaceState.broken => l.powerTitleBroken,
  PowerFaceState.direct => l.powerTitleDirect,
  PowerFaceState.paused => l.simpleStatusPaused,
  PowerFaceState.off => l.simpleStatusOff,
  PowerFaceState.ending when !face.running => l.simpleStatusOff,
  PowerFaceState.ending ||
  PowerFaceState.grace ||
  PowerFaceState.on => l.simpleStatusOn,
};

String? _attentionText(AppLocalizations l, PowerFace face) =>
    switch (face.attention) {
      AccountAttention(:final int daysLeft) => l.powerEndingDays(daysLeft),
      AccountAttention(:final int trafficLeft) => l.powerEndingTraffic(
        dashboardTraffic(trafficLeft),
      ),
      _ when face.state == PowerFaceState.grace =>
        face.cause == FailureCause.trafficExhausted
            ? l.powerTitleExhausted
            : l.powerTitleExpired,
      _ => null,
    };

String? _hint(AppLocalizations l, PowerFace face, String? pausedHint) =>
    switch (face.state) {
      PowerFaceState.noProfile => l.simpleStatusNoProfileHint,
      PowerFaceState.off => l.simpleStatusOffHint,
      PowerFaceState.starting => l.simpleStatusConnectingHint,
      PowerFaceState.verifying =>
        face.searching ? l.powerHintSearching : l.powerHintVerifying,
      PowerFaceState.paused => pausedHint,
      PowerFaceState.offline => l.powerHintOffline,
      PowerFaceState.waitingNetwork => l.powerHintWaitingNetwork,
      PowerFaceState.recovering => switch (face.step) {
        HealStep.bestNode when face.stepDetail != null => l.powerStepBestNode(
          face.stepDetail!,
        ),
        HealStep.updateProfile => l.powerStepUpdateProfile,
        HealStep.resetConnections => l.powerStepResetConnections,
        HealStep.restartCore || HealStep.restartTunnel => l.powerStepRestart,
        _ => l.powerHintSearching,
      },
      _ when face.checking => l.powerHintCheckingAccount,
      _ => _attentionText(l, face),
    };

String _verb(AppLocalizations l, PowerAction action) => switch (action) {
  PowerAction.renew => l.powerFixRenew,
  PowerAction.topUp => l.powerFixTopUp,
  PowerAction.support => l.powerFixSupport,
  PowerAction.updateProfile => l.powerFixUpdateProfile,
  PowerAction.grantVpn => l.powerFixGrantVpn,
  PowerAction.openVpnSettings => l.powerFixVpnSettings,
  PowerAction.openDateSettings => l.powerFixDateSettings,
  PowerAction.openPortal => l.powerFixPortal,
  PowerAction.ruleMode => l.powerFixRuleMode,
  PowerAction.repair => l.powerFixRepair,
  PowerAction.causeSheet || PowerAction.accountSheet => l.powerFixExplain,
  PowerAction.addProfile => l.powerFixAddProfile,
  PowerAction.start => l.start,
  PowerAction.stop => l.stop,
  PowerAction.resume => l.onDemandResume,
};

/// The status title and its second row, with the gap above them.
const _statusHeight = 102.0;

/// The power button over its [status], sized to its room.
class SimplePowerView extends StatelessWidget {
  const SimplePowerView({
    super.key,
    required this.minSize,
    required this.maxSize,
    required this.face,
    required this.onPressed,
    required this.logo,
    required this.images,
    required this.look,
    required this.status,
  });

  /// The button grows with its room between these, the status always under
  /// it.
  final double minSize;
  final double maxSize;
  final PowerFace face;
  final VoidCallback? onPressed;
  final String logo;
  final ProviderImages images;
  final ProviderPowerButton look;
  final Widget status;

  static double heightOf(double size) =>
      PowerButton.extentOf(size) + _statusHeight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
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
              link: face.link,
              size: size,
              logo: logo,
              images: images,
              look: look,
              tone: face.tone,
              badge: powerBadge(face),
              spin: face.state == PowerFaceState.recovering,
              tooltip: powerTapLabel(context, face),
              onPressed: face.tap == null ? null : onPressed,
            ),
            const SizedBox(height: 20),
            status,
          ],
        ),
      );
    },
  );
}

/// The face's title and its second row: the [live] line, the fix pill or a
/// hint. A provider's [custom] label replaces the title.
class PowerStatusView extends StatelessWidget {
  const PowerStatusView({
    super.key,
    required this.face,
    required this.custom,
    required this.pausedHint,
    required this.live,
    this.onFix,
  });

  final PowerFace face;
  final ProviderPowerLabel? custom;

  /// Read only while the face is paused.
  final String? pausedHint;

  /// The second row while the connection is plainly on.
  final Widget live;

  final ValueChanged<PowerAction>? onFix;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final title = powerTitle(appLocalizations, face);
    final custom = this.custom;
    final shownTitle = custom?.title ?? title;
    final fix = face.checking ? null : face.fix;
    final hint = custom?.hint ?? _hint(appLocalizations, face, pausedHint);
    final Widget? second = switch (fix) {
      final fix? => PowerPillView(
        prefix: _pillPrefix(appLocalizations, fix),
        label: _pillLabel(appLocalizations, fix),
        tone: face.tone,
        glyph: switch (fix) {
          PowerAction.addProfile => AppGlyphs.add,
          PowerAction.ruleMode => AppGlyphs.vpn,
          PowerAction.repair => AppGlyphs.wrench,
          PowerAction.causeSheet => AppGlyphs.info,
          _ => null,
        },
        external: switch (fix) {
          PowerAction.renew || PowerAction.topUp || PowerAction.support => true,
          _ => false,
        },
        filled: fix == PowerAction.addProfile,
        onPressed: onFix == null ? null : () => onFix!(fix),
      ),
      _ when face.state == PowerFaceState.on => FittedBox(
        fit: BoxFit.scaleDown,
        child: live,
      ),
      _ when hint != null => Text(
        hint,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.subheadline
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
      _ => null,
    };
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
        SizedBox(height: 36, child: Center(child: second)),
      ],
    );
  }

  String? _attentionFor(AppLocalizations l) => switch (face.state) {
    PowerFaceState.ending || PowerFaceState.grace => _attentionText(l, face),
    _ => null,
  };

  String? _pillPrefix(AppLocalizations l, PowerAction fix) => switch (fix) {
    PowerAction.renew || PowerAction.topUp => _attentionFor(l),
    _ => null,
  };

  String _pillLabel(AppLocalizations l, PowerAction fix) => switch (fix) {
    PowerAction.renew || PowerAction.topUp => _verb(l, fix),
    _ => _attentionFor(l) ?? _verb(l, fix),
  };
}

/// A fix under the title, tinted by the face's [tone]; [external] marks a
/// link that leaves the app.
class PowerPillView extends StatelessWidget {
  const PowerPillView({
    super.key,
    required this.label,
    required this.tone,
    required this.onPressed,
    this.prefix,
    this.glyph,
    this.external = false,
    this.filled = false,
  });

  /// Read before [label] and shortened first, so the action stays whole.
  final String? prefix;
  final String label;
  final PowerTone tone;
  final Glyph? glyph;
  final bool external;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final (fill, ink) = filled
        ? (colorScheme.primary, colorScheme.onPrimary)
        : switch (tone) {
            PowerTone.attention ||
            PowerTone.problem => (colors.warnContainer, colors.onWarnContainer),
            PowerTone.failure => (
              colorScheme.errorContainer,
              colorScheme.onErrorContainer,
            ),
            PowerTone.normal => (
              colorScheme.primaryContainer,
              colorScheme.onPrimaryContainer,
            ),
            PowerTone.quiet => (colors.tone, colorScheme.onSurface),
          };
    final glyph = this.glyph;
    final prefix = this.prefix;
    final style = AppTextStyle.subheadline
        .of(context, emphasized: true)
        .copyWith(color: ink);
    return Semantics(
      button: true,
      label: prefix == null ? label : '$prefix, $label',
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: AppShape.full,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 36,
            child: Padding(
              padding: EdgeInsets.only(
                left: glyph == null ? 16 : 12,
                right: external ? 12 : 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  if (glyph != null) GlyphIcon(glyph, size: 18, color: ink),
                  if (prefix != null) ...[
                    Flexible(
                      child: Text(
                        prefix,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                    ),
                    Text('·', style: style),
                    Text(label, maxLines: 1, style: style),
                  ] else
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                    ),
                  if (external)
                    GlyphIcon(AppGlyphs.openExternal, size: 16, color: ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The session [time] and the speed each way.
class PowerLiveLineView extends StatelessWidget {
  const PowerLiveLineView({
    super.key,
    required this.time,
    required this.down,
    required this.up,
  });

  final String time;
  final num down;
  final num up;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
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
        Text(time, style: caption.copyWith(color: colorScheme.onSurface)),
        const SizedBox(width: 6),
        GlyphIcon(AppGlyphs.arrowDown, size: 16, color: colorScheme.primary),
        Text('${dashboardTraffic(down)}/s', style: caption),
        const SizedBox(width: 2),
        GlyphIcon(
          AppGlyphs.arrowUp,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        Text('${dashboardTraffic(up)}/s', style: caption),
      ],
    );
  }
}
