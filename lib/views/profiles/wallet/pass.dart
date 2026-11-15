import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/power/attention.dart';
import 'package:reclash/features/power/face.dart' show PowerAction;
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/profiles/edit.dart' show renameProfile;
import 'package:reclash/views/profiles/extend/extend.dart';
import 'package:reclash/views/profiles/preview.dart';
import 'package:reclash/views/profiles/profiles.dart';
import 'package:reclash/widgets/widgets.dart';

import 'provider_logo.dart';
import 'status.dart';

const _padding = 18.0;
const _segments = 30;
const _notch = 22.0;

final _fileSizeProvider = FutureProvider.autoDispose.family<int?, Profile>((
  ref,
  profile,
) async {
  try {
    return await (await profile.file).length();
  } on FileSystemException {
    return null;
  }
});

/// The active profile as a ticket: what is left on top, the numbers under a
/// tear line, then what can be done with it.
class WalletPass extends ConsumerWidget {
  const WalletPass({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colorScheme;
    final brightness = scheme.brightness;
    final now = DateTime.now();
    final facts = walletFactsOf(profile, now);
    final isUrl = profile.type == ProfileType.url;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final brand = isUrl
        ? ref.watch(profileBrandProvider(profile.id)).value
        : null;
    final color = walletBrandColor(profile, brand);
    final tint = color == null ? null : BrandTint(color);
    final accent = tint?.accent(brightness) ?? scheme.onSurfaceVariant;
    final level = context.raisedSurfaceLevel;
    final pageColor = context.surfaceLevel.colorOf(scheme);
    var fill = level.colorOf(scheme);
    if (level == SurfaceLevel.card) {
      fill = PageBackgroundScope.applyCardOpacity(context, fill);
    }
    if (tint != null) {
      fill = tint.surface(fill, BrandSurface.pass, brightness);
    }
    final host = ProfileItem(
      profile: profile,
      groupValue: null,
      onChanged: (_) {},
    );
    final metadata = isUrl ? profile.subscriptionSnapshot?.metadata : null;
    final style = _PassStyle(
      scheme: scheme,
      accent: accent,
      veil: walletVeil(scheme),
      danger: scheme.error,
    );
    final groups = ref.watch(groupsProvider);
    final servers = _serverCount(groups);
    final groupNames = isUrl
        ? const <String>[]
        : [for (final group in groups) group.name];
    final groupCount = switch (profile.type) {
      ProfileType.url => null,
      ProfileType.custom =>
        ref.watch(profileGroupsCountProvider(profile.id)).value,
      _ => groupNames.isEmpty ? null : groupNames.length,
    };

    return ContextMenuRegion(
      menuItems: isUpdating ? null : host.menuItems(context, ref),
      child: Material(
        color: fill,
        shape: AppShape.all(AppCorner.xxl),
        clipBehavior: Clip.antiAlias,
        child: SurfaceScope(
          level: level,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _padding,
                  _padding,
                  _padding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      profile: profile,
                      style: style,
                      kind: metadata?.kind,
                      expired: facts.state == WalletState.expired,
                    ),
                    const SizedBox(height: 22),
                    _Usage(
                      profile: profile,
                      facts: facts,
                      style: style,
                      now: now,
                      servers: servers,
                      groupCount: groupCount,
                      unavailable:
                          facts.unlimited && !(metadata?.unlimited ?? false),
                    ),
                    if (groupNames.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _GroupChips(names: groupNames, style: style),
                    ],
                  ],
                ),
              ),
              _Tear(pageColor: pageColor, dash: scheme.onSurface),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _padding,
                  0,
                  _padding,
                  _padding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Stats(
                      profile: profile,
                      facts: facts,
                      style: style,
                      servers: servers,
                      groupCount: groupCount,
                      isUpdating: isUpdating,
                    ),
                    const SizedBox(height: 16),
                    if (facts.cta != null && facts.ctaUrl != null)
                      _CtaRow(
                        cta: facts.cta!,
                        url: facts.ctaUrl!,
                        style: style,
                        tinted: tint != null,
                        host: host,
                        isUpdating: isUpdating,
                      )
                    else
                      _Actions(
                        profile: profile,
                        host: host,
                        metadata: metadata,
                        style: style,
                        isUpdating: isUpdating,
                      ),
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

int? _serverCount(List<Group> groups) {
  final groupNames = {for (final group in groups) group.name};
  final servers = {
    for (final group in groups)
      for (final proxy in group.all)
        if (!groupNames.contains(proxy.name)) proxy.name,
  };
  return servers.isEmpty ? null : servers.length;
}

class _PassStyle {
  const _PassStyle({
    required this.scheme,
    required this.accent,
    required this.veil,
    required this.danger,
  });

  final ColorScheme scheme;
  final Color accent;
  final Color veil;
  final Color danger;

  Color get muted => scheme.onSurfaceVariant;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.profile,
    required this.style,
    required this.kind,
    required this.expired,
  });

  final Profile profile;
  final _PassStyle style;
  final SubscriptionKind? kind;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final host = profile.type == ProfileType.url
        ? Uri.tryParse(profile.url)?.host ?? ''
        : switch (profile.type) {
            ProfileType.file => l.walletLocalFile,
            _ => l.walletCustomProfile,
          };
    final chipColor = expired ? style.muted : style.scheme.success;
    return Row(
      spacing: 14,
      children: [
        WalletLogo(profile: profile, size: 56),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 7,
                children: [
                  Flexible(
                    child: Text(
                      profile.realLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.title3
                          .of(context, emphasized: true)
                          .copyWith(color: style.scheme.onSurface),
                    ),
                  ),
                  if (kind != null) WalletKindChip(kind: kind!),
                ],
              ),
              Text(
                host,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: style.muted),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: ShapeDecoration(shape: AppShape.full, color: style.veil),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 11, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                GlyphIcon(AppGlyphs.check, size: 16, color: chipColor),
                Text(
                  l.walletActive,
                  style: AppTextStyle.footnote
                      .of(context, emphasized: true)
                      .copyWith(color: chipColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Usage extends StatelessWidget {
  const _Usage({
    required this.profile,
    required this.facts,
    required this.style,
    required this.now,
    required this.servers,
    required this.groupCount,
    required this.unavailable,
  });

  final Profile profile;
  final WalletFacts facts;
  final _PassStyle style;
  final DateTime now;
  final int? servers;
  final int? groupCount;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final muted = AppTextStyle.footnote
        .of(context)
        .copyWith(color: style.muted);
    final figure = AppTextStyle.display.of(context, emphasized: true).toTabular;
    final unit = AppTextStyle.title3
        .of(context, emphasized: true)
        .copyWith(color: style.muted);
    final critical = facts.state == WalletState.critical;

    Widget block({
      required String label,
      required Widget value,
      Widget? trailing,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: muted),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 8,
          children: [
            if (trailing == null) Flexible(child: value) else value,
            if (trailing != null) Expanded(child: trailing),
          ],
        ),
      ],
    );

    Widget figureWithUnit(String value, String unitText, {Color? color}) =>
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: figure.copyWith(color: color ?? style.scheme.onSurface),
              ),
              TextSpan(text: ' $unitText', style: unit),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

    if (profile.type != ProfileType.url) {
      final count = servers;
      final groups = groupCount;
      if (count == null && groups == null) {
        return const SizedBox.shrink();
      }
      return block(
        label: l.walletInProfile,
        value: count != null
            ? figureWithUnit('$count', l.walletServersLabel(count))
            : figureWithUnit('$groups', l.walletGroupsLabel(groups!)),
      );
    }

    if (facts.state == WalletState.expired) {
      final expire = facts.expire;
      final days = expire == null ? 0 : now.difference(expire).inDays;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          block(
            label: l.walletEndedAgo(days),
            value: Text(
              l.walletEnded,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: figure.copyWith(color: style.danger),
            ),
          ),
          const SizedBox(height: 14),
          _Gauge(
            lit: 0,
            color: style.danger,
            empty: style.scheme.onSurface.withValues(alpha: 0.1),
            label: l.walletEnded,
          ),
          const SizedBox(height: 9),
          Text(
            l.walletRenewToConnect,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: style.danger),
          ),
        ],
      );
    }

    if (unavailable) {
      final used = facts.used.traffic;
      return block(
        label: l.walletTrafficUnavailable,
        value: figureWithUnit(used.value, used.unit.trim()),
      );
    }

    final left = facts.left;
    final fraction = facts.leftFraction;
    final TrafficShow shown = (left ?? facts.used).traffic;
    final lit = fraction == null
        ? _segments
        : math.max(1, (fraction * _segments).round());
    final captionColor = critical ? style.danger : style.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        block(
          label: l.walletLeft,
          value: left == null
              ? Text('∞', maxLines: 1, style: figure)
              : figureWithUnit(
                  shown.value,
                  shown.unit.trim(),
                  color: critical ? style.danger : null,
                ),
          trailing: Text(
            left == null
                ? l.walletUnlimited
                : l.walletOfTotal(facts.total!.traffic.show),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyle.subheadline
                .of(context)
                .copyWith(color: style.muted),
          ),
        ),
        const SizedBox(height: 14),
        _Gauge(
          lit: lit,
          color: critical ? style.danger : style.accent,
          empty: style.scheme.onSurface.withValues(alpha: 0.1),
          label: left == null
              ? l.walletUnlimited
              : l.walletRemaining(left.traffic.show, facts.total!.traffic.show),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              critical
                  ? l.walletAlmostOut
                  : l.walletUsed(facts.used.traffic.show),
              style: AppTextStyle.footnote
                  .of(context)
                  .toTabular
                  .copyWith(color: captionColor),
            ),
            if (fraction != null)
              Text('${(fraction * 100).round()}%', style: muted.toTabular),
          ],
        ),
      ],
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({
    required this.lit,
    required this.color,
    required this.empty,
    required this.label,
  });

  final int lit;
  final Color color;
  final Color empty;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 12,
          child: Row(
            spacing: 3,
            children: [
              for (var i = 0; i < _segments; i++)
                Expanded(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: AppShape.xs,
                      color: i < lit ? color : empty,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupChips extends StatelessWidget {
  const _GroupChips({required this.names, required this.style});

  final List<String> names;
  final _PassStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: 34,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final name in names)
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: AppShape.full,
                  color: style.veil,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: Text(
                    name,
                    maxLines: 1,
                    style: AppTextStyle.footnote
                        .of(context, emphasized: true)
                        .copyWith(color: style.scheme.onSurface),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tear extends StatelessWidget {
  const _Tear({required this.pageColor, required this.dash});

  final Color pageColor;
  final Color dash;

  @override
  Widget build(BuildContext context) {
    final notch = DecoratedBox(
      decoration: ShapeDecoration(shape: AppShape.circle, color: pageColor),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: _notch,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DashPainter(dash.withValues(alpha: 0.15)),
              ),
            ),
            Positioned(
              left: -_notch / 2,
              top: 0,
              width: _notch,
              height: _notch,
              child: notch,
            ),
            Positioned(
              right: -_notch / 2,
              top: 0,
              width: _notch,
              height: _notch,
              child: notch,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (var x = _notch; x < size.width - _notch; x += 9) {
      canvas.drawLine(Offset(x, y), Offset(x + 2, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => color != oldDelegate.color;
}

class _Stats extends ConsumerWidget {
  const _Stats({
    required this.profile,
    required this.facts,
    required this.style,
    required this.servers,
    required this.groupCount,
    required this.isUpdating,
  });

  final Profile profile;
  final WalletFacts facts;
  final _PassStyle style;
  final int? servers;
  final int? groupCount;
  final bool isUpdating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final value = AppTextStyle.headline.of(context, emphasized: true).toTabular;
    final label = AppTextStyle.caption1
        .of(context)
        .copyWith(color: style.muted);
    final plain = value.copyWith(color: style.scheme.onSurface);
    final updated = isUpdating
        ? Text(l.walletUpdating, maxLines: 1, style: plain)
        : LastUpdateTimeText(
            lastUpdateDate: profile.lastUpdateDate,
            style: plain,
            compact: true,
          );

    final List<(Widget, String)> cells;
    if (profile.type == ProfileType.url) {
      final expire = facts.expire;
      final expired = facts.state == WalletState.expired;
      final days = facts.daysLeft;
      final warn =
          expired || facts.state == WalletState.critical && days != null;
      cells = [
        (
          Text(
            expired
                ? l.walletExpired
                : days == null
                ? '∞'
                : l.simpleDaysCount(days),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: value.copyWith(
              color: warn ? style.danger : style.scheme.onSurface,
            ),
          ),
          expire == null
              ? l.walletUnlimited
              : l.simpleUntilDate(
                  MaterialLocalizations.of(context).formatShortMonthDay(expire),
                ),
        ),
        (updated, l.walletUpdatedLabel),
        if (servers != null)
          (
            Text('$servers', maxLines: 1, style: plain),
            l.walletServersLabel(servers!),
          ),
      ];
    } else {
      final groups = groupCount;
      final size = ref.watch(_fileSizeProvider(profile)).value;
      cells = [
        (updated, l.walletUpdatedLabel),
        if (groups != null)
          (
            Text('$groups', maxLines: 1, style: plain),
            l.walletGroupsLabel(groups),
          ),
        if (size != null)
          (
            Text(size.traffic.show, maxLines: 1, style: plain),
            l.walletSizeLabel,
          ),
      ];
    }
    return Row(
      spacing: 12,
      children: [
        for (final (widget, caption) in cells)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget,
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: label,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.profile,
    required this.host,
    required this.metadata,
    required this.style,
    required this.isUpdating,
  });

  final Profile profile;
  final ProfileItem host;
  final SubscriptionMetadata? metadata;
  final _PassStyle style;
  final bool isUpdating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final support = metadata == null
        ? null
        : accountLinkUrl(metadata!, PowerAction.support);
    final tiles = profile.type == ProfileType.url
        ? [
            _ActionTile(
              glyph: AppGlyphs.sync,
              label: l.update,
              style: style,
              loading: isUpdating,
              onPressed: isUpdating
                  ? null
                  : () => unawaited(host.updateProfile(ref)),
            ),
            _ActionTile(
              glyph: AppGlyphs.support,
              label: l.subscriptionProviderSupport,
              style: style,
              onPressed: support == null
                  ? null
                  : () => unawaited(dialogs.openUrl('$support')),
            ),
            _ActionTile(
              glyph: AppGlyphs.qrCode,
              label: l.qrcode,
              style: style,
              onPressed: () => unawaited(
                dialogs.showQrCode(
                  title: profile.realLabel,
                  data: profile.url,
                  message: l.shareQrcodeTip,
                ),
              ),
            ),
          ]
        : profile.type == ProfileType.custom
        ? [
            _ActionTile(
              glyph: AppGlyphs.edit,
              label: l.walletEdit,
              style: style,
              onPressed: () => host.edit(context),
            ),
            _ActionTile(
              glyph: AppGlyphs.textShort,
              label: l.rename,
              style: style,
              onPressed: () => unawaited(renameProfile(context, ref, profile)),
            ),
            _ActionTile(
              glyph: AppGlyphs.eye,
              label: l.runtimeConfig,
              style: style,
              onPressed: () => unawaited(
                BaseNavigator.push<String>(
                  context,
                  PreviewProfileView(profile: profile),
                ),
              ),
            ),
          ]
        : [
            _ActionTile(
              glyph: AppGlyphs.edit,
              label: l.walletEdit,
              style: style,
              onPressed: () => host.edit(context),
            ),
            _ActionTile(
              glyph: AppGlyphs.puzzle,
              label: l.walletExtend,
              style: style,
              onPressed: () => unawaited(
                BaseNavigator.push(context, ExtendView(profileId: profile.id)),
              ),
            ),
            _ActionTile(
              glyph: AppGlyphs.export,
              label: l.walletExport,
              style: style,
              onPressed: () => unawaited(host.exportFile(context)),
            ),
          ];
    return Row(
      spacing: 8,
      children: [
        for (final tile in tiles) Expanded(child: tile),
        Expanded(
          child: _MoreMenu(
            host: host,
            enabled: !isUpdating,
            builder: (open) => _ActionTile(
              glyph: AppGlyphs.more,
              label: l.more,
              style: style,
              onPressed: open,
            ),
          ),
        ),
      ],
    );
  }
}

class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({
    required this.host,
    required this.enabled,
    required this.builder,
  });

  final ProfileItem host;
  final bool enabled;
  final Widget Function(PopupOpen open) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPopupBox(
      targetBuilder: (open) => builder(enabled ? open : () {}),
      popupBuilder: (_) => CommonPopupMenu(items: host.menuItems(context, ref)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.glyph,
    required this.label,
    required this.style,
    required this.onPressed,
    this.loading = false,
  });

  final Glyph glyph;
  final String label;
  final _PassStyle style;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final color = style.scheme.onSurface;
    return Opacity(
      opacity: onPressed == null && !loading ? 0.38 : 1,
      child: Material(
        color: style.veil,
        shape: AppShape.md,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: loading
                      ? CommonCircleLoading(size: 20, color: color)
                      : GlyphIcon(glyph, size: 20, color: color),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppTextStyle.caption2
                          .of(context, emphasized: true)
                          .copyWith(color: color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.cta,
    required this.url,
    required this.style,
    required this.tinted,
    required this.host,
    required this.isUpdating,
  });

  final WalletCta cta;
  final Uri url;
  final _PassStyle style;
  final bool tinted;
  final ProfileItem host;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final scheme = style.scheme;
    final dark = scheme.brightness == Brightness.dark;
    final fill = tinted ? style.accent : scheme.error;
    final foreground = tinted
        ? (dark ? scheme.surface : scheme.surfaceBright)
        : scheme.onError;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Material(
            color: fill,
            shape: AppShape.lg,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => unawaited(dialogs.openUrl('$url')),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        cta == WalletCta.topUp
                            ? l.topUpTraffic
                            : l.renewSubscription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.callout
                            .of(context, emphasized: true)
                            .copyWith(color: foreground),
                      ),
                    ),
                    GlyphIcon(
                      AppGlyphs.chevronForward,
                      size: 20,
                      color: foreground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: _MoreMenu(
            host: host,
            enabled: !isUpdating,
            builder: (open) => Material(
              color: style.veil,
              shape: AppShape.lg,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: open,
                child: SizedBox.square(
                  dimension: 56,
                  child: Tooltip(
                    message: l.more,
                    child: Center(
                      child: GlyphIcon(
                        AppGlyphs.more,
                        size: 20,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
