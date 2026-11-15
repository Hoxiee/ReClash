import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/profiles/profiles.dart';
import 'package:reclash/widgets/widgets.dart';

import 'provider_logo.dart';
import 'status.dart';

const walletStackCardHeight = 72.0;

List<BoxShadow> walletLiftShadows(Brightness brightness) =>
    brightness == Brightness.dark
    ? const [
        BoxShadow(
          color: Color(0x73000000),
          blurRadius: 22,
          offset: Offset(0, -8),
        ),
      ]
    : const [
        BoxShadow(
          color: Color(0x0D14141E),
          blurRadius: 12,
          offset: Offset(0, -4),
        ),
      ];

const _ringSize = 30.0;
const _ringStroke = 4.0;

/// An inactive profile as a card in the wallet's stack: tap makes it active.
class WalletStackCard extends ConsumerWidget {
  const WalletStackCard({
    super.key,
    required this.profile,
    required this.onPressed,
    this.lifted = false,
  });

  final Profile profile;
  final VoidCallback onPressed;

  /// Casts a shadow upward, for a card that overlaps the one above it.
  final bool lifted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colorScheme;
    final brightness = scheme.brightness;
    final facts = walletFactsOf(profile, DateTime.now());
    final isUrl = profile.type == ProfileType.url;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final brand = isUrl
        ? ref.watch(profileBrandProvider(profile.id)).value
        : null;
    final color = walletBrandColor(profile, brand);
    final tint = color == null ? null : BrandTint(color);
    final level = context.raisedSurfaceLevel;
    var fill = level.colorOf(scheme);
    if (level == SurfaceLevel.card) {
      fill = PageBackgroundScope.applyCardOpacity(context, fill);
    }
    if (tint != null) {
      fill = tint.surface(fill, BrandSurface.card, brightness);
    }
    final host = ProfileItem(
      profile: profile,
      groupValue: null,
      onChanged: (_) {},
    );
    final kind = isUrl ? profile.subscriptionSnapshot?.metadata.kind : null;
    final expired = facts.state == WalletState.expired;
    const shape = AppShape.xl;

    return ContextMenuRegion(
      menuItems: isUpdating ? null : host.menuItems(context, ref),
      child: SizedBox(
        height: walletStackCardHeight,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape,
            shadows: lifted ? walletLiftShadows(brightness) : null,
          ),
          child: Material(
            color: fill,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: SurfaceScope(
              level: level,
              child: InkWell(
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 14, end: 16),
                  child: Row(
                    spacing: 12,
                    children: [
                      WalletLogo(profile: profile, size: 40),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Flexible(
                                  child: Text(
                                    profile.realLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.subheadline
                                        .of(context, emphasized: true)
                                        .copyWith(
                                          color: expired
                                              ? scheme.onSurfaceVariant
                                              : scheme.onSurface,
                                        ),
                                  ),
                                ),
                                if (kind != null) WalletKindChip(kind: kind),
                              ],
                            ),
                            _Meta(
                              profile: profile,
                              facts: facts,
                              isUpdating: isUpdating,
                            ),
                          ],
                        ),
                      ),
                      _Trailing(
                        profile: profile,
                        facts: facts,
                        accent: tint?.accent(brightness) ?? scheme.primary,
                        unavailable:
                            facts.unlimited &&
                            !(profile
                                    .subscriptionSnapshot
                                    ?.metadata
                                    .unlimited ??
                                false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.profile,
    required this.facts,
    required this.isUpdating,
  });

  final Profile profile;
  final WalletFacts facts;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final style = AppTextStyle.caption1
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant);
    Widget text(String value) =>
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);

    if (isUpdating) {
      return text(l.walletUpdating);
    }
    if (profile.type != ProfileType.url) {
      return Row(
        children: [
          Flexible(
            child: text(
              '${profile.type == ProfileType.file ? l.walletLocalFile : l.walletCustomProfile} · ',
            ),
          ),
          LastUpdateTimeText(
            lastUpdateDate: profile.lastUpdateDate,
            style: style,
            compact: true,
          ),
        ],
      );
    }
    final days = facts.daysLeft;
    if (facts.state == WalletState.expired) {
      final expire = facts.expire;
      return text(
        l.walletEndedAgo(
          expire == null ? 0 : DateTime.now().difference(expire).inDays,
        ),
      );
    }
    return text(
      days == null
          ? (Uri.tryParse(profile.url)?.host ?? '')
          : l.walletDaysLeft(days),
    );
  }
}

class _Trailing extends ConsumerWidget {
  const _Trailing({
    required this.profile,
    required this.facts,
    required this.accent,
    required this.unavailable,
  });

  final Profile profile;
  final WalletFacts facts;
  final Color accent;
  final bool unavailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final scheme = context.colorScheme;
    final critical = facts.state == WalletState.critical;

    Widget figure(String value, String caption, {Color? color}) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          maxLines: 1,
          style: AppTextStyle.subheadline
              .of(context, emphasized: true)
              .toTabular
              .copyWith(color: color ?? scheme.onSurface),
        ),
        Text(
          caption,
          maxLines: 1,
          style: AppTextStyle.caption2
              .of(context)
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );

    if (profile.type == ProfileType.custom) {
      final count = ref.watch(profileGroupsCountProvider(profile.id)).value;
      return count == null
          ? const SizedBox.shrink()
          : figure('$count', l.walletGroupsLabel(count));
    }
    if (profile.type == ProfileType.file) {
      return const SizedBox.shrink();
    }
    if (facts.state == WalletState.expired) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          shape: AppShape.full,
          color: scheme.errorContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          child: Text(
            l.walletExpired,
            maxLines: 1,
            style: AppTextStyle.caption1
                .of(context, emphasized: true)
                .copyWith(color: scheme.onErrorContainer),
          ),
        ),
      );
    }
    if (unavailable) {
      return figure('—', l.walletLeftLabel);
    }
    final left = facts.left;
    final fraction = facts.leftFraction;
    if (left == null || fraction == null) {
      return figure('∞', l.walletUnlimited);
    }
    final ringColor = critical ? scheme.error : accent;
    return Row(
      spacing: 9,
      children: [
        figure(
          left.traffic.show,
          l.walletLeftLabel,
          color: critical ? scheme.error : null,
        ),
        CustomPaint(
          size: const Size.square(_ringSize),
          painter: _RingPainter(
            fraction: fraction,
            color: ringColor,
            track: scheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
  });

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_ringStroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      color != oldDelegate.color ||
      track != oldDelegate.track;
}
