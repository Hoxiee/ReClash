import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/views/dashboard/layout.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, this.expandable = false});

  final bool expandable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(providerAnnouncementProvider);
    if (announcement == null) return const SizedBox.shrink();
    final l = context.appLocalizations;
    if (expandable) {
      return _AnnouncementPreview(announcement: announcement);
    }
    return CommonCard(
      key: const ValueKey('provider-announcement-card'),
      padding: const EdgeInsets.all(20),
      shape: AppShape.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 10,
            children: [
              GlyphIcon(
                AppGlyphs.info,
                size: 22,
                color: context.colorScheme.onSurfaceVariant,
              ),
              Expanded(
                child: Text(
                  l.providerAnnouncement,
                  style: AppTextStyle.headline.of(context),
                ),
              ),
            ],
          ),
          SelectableText(
            announcement.text,
            style: AppTextStyle.body
                .of(context)
                .copyWith(color: context.colorScheme.onSurface),
          ),
          if (announcement.link case final link?)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => unawaited(dialogs.openUrl(link.toString())),
                child: Text(l.providerAnnouncementOpen),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementPreview extends StatefulWidget {
  const _AnnouncementPreview({required this.announcement});

  final ProviderAnnouncement announcement;

  @override
  State<_AnnouncementPreview> createState() => _AnnouncementPreviewState();
}

class _AnnouncementPreviewState extends State<_AnnouncementPreview> {
  final _cardKey = GlobalKey();
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    final navigator = Navigator.of(context);
    final card = _cardKey.currentContext!.findRenderObject()! as RenderBox;
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final origin =
        card.localToGlobal(Offset.zero, ancestor: overlay) & card.size;
    final route = _AnnouncementRoute(
      origin: origin,
      announcement: widget.announcement,
      color: DashboardColors.of(context).card,
      radius: dashboardCardRadius(DashboardDensityScope.of(context)),
      barrierColor: context.colorScheme.modalScrim,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      duration: context.motionDuration(const Duration(milliseconds: 550)),
      themes: InheritedTheme.capture(from: context, to: navigator.context),
    );
    setState(() => _opening = true);
    try {
      await navigator.push<void>(route);
      await route.completed;
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Visibility(
      visible: !_opening,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: DashboardCard(
        key: _cardKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            DashboardCardHeader(
              glyph: AppGlyphs.info,
              title: l.providerAnnouncement,
              trailing: [
                if (widget.announcement.link case final link?)
                  Transform.translate(
                    offset: const Offset(8, 0),
                    child: DashboardIconButton(
                      glyph: AppGlyphs.openExternal,
                      tooltip: l.providerAnnouncementOpen,
                      onPressed: () =>
                          unawaited(dialogs.openUrl(link.toString())),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final style = AppTextStyle.subheadline.of(context);
                  final lineHeight =
                      (style.fontSize ?? 15) * (style.height ?? 1);
                  final lines = math.max(
                    1,
                    (constraints.maxHeight /
                            (lineHeight *
                                MediaQuery.textScalerOf(context).scale(1)))
                        .floor(),
                  );
                  return Text(
                    widget.announcement.text,
                    maxLines: lines,
                    overflow: TextOverflow.ellipsis,
                    style: style.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: TextButton(
                onPressed: () => unawaited(_open()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Text(l.providerAnnouncementRead),
                    const GlyphIcon(AppGlyphs.chevronForward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementRoute extends PopupRoute<void> {
  _AnnouncementRoute({
    required this.origin,
    required this.announcement,
    required this.color,
    required this.radius,
    required this.barrierColor,
    required this.barrierLabel,
    required this.duration,
    required this.themes,
  });

  final Rect origin;
  final ProviderAnnouncement announcement;
  final Color color;
  final double radius;
  final Duration duration;
  final CapturedThemes themes;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => themes.wrap(
    KeyboardInsetHold(child: _AnnouncementReader(announcement: announcement)),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final insets = MediaQuery.paddingOf(context);
      final keyboard = MediaQuery.viewInsetsOf(context).bottom;
      final available = Rect.fromLTRB(
        insets.left + 24,
        insets.top + 24,
        constraints.maxWidth - insets.right - 24,
        constraints.maxHeight - math.max(insets.bottom, keyboard) - 24,
      );
      final target = Rect.fromCenter(
        center: available.center,
        width: math.min(560, available.width),
        height: math.min(600, available.height),
      );
      final t = Curves.easeInOutCubicEmphasized.transform(animation.value);
      final rect = Rect.lerp(origin, target, t)!;
      return Stack(
        children: [
          Positioned.fromRect(
            rect: rect,
            child: Material(
              color: color,
              elevation: 8 * t,
              shape: AppShape.all(lerpDouble(radius, AppCorner.xxl, t)!),
              clipBehavior: Clip.antiAlias,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: target.width,
                maxWidth: target.width,
                minHeight: target.height,
                maxHeight: target.height,
                child: Opacity(
                  opacity: const Interval(0.12, 0.75).transform(t),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _AnnouncementReader extends StatelessWidget {
  const _AnnouncementReader({required this.announcement});

  final ProviderAnnouncement announcement;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Row(
            spacing: 12,
            children: [
              const GlyphIcon(AppGlyphs.info, size: 24),
              Expanded(
                child: Text(
                  l.providerAnnouncement,
                  style: AppTextStyle.title2.of(context),
                ),
              ),
              IconButton(
                tooltip: l.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const GlyphIcon(AppGlyphs.close),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                announcement.text,
                style: AppTextStyle.body.of(context),
              ),
            ),
          ),
          if (announcement.link case final link?)
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: TextButton(
                onPressed: () => unawaited(dialogs.openUrl(link.toString())),
                child: Text(l.providerAnnouncementOpen),
              ),
            ),
        ],
      ),
    );
  }
}

class NoticeCard extends ConsumerWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(providerNoticeProvider);
    if (card == null) return const SizedBox.shrink();
    final (:announcement, :id) = card;
    final l = context.appLocalizations;
    return CommonCard(
      key: const ValueKey('provider-notice-card'),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      shape: AppShape.xl,
      onPressed: () => unawaited(
        announcement.link == null
            ? dialogs.showMessage(
                title: l.providerNotice,
                message: TextSpan(text: announcement.text),
                cancelable: false,
                confirmText: l.close,
              )
            : dialogs.openUrl(announcement.link.toString()),
      ),
      child: Row(
        spacing: 12,
        children: [
          GlyphIcon(
            AppGlyphs.info,
            size: 26,
            color: context.colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  l.providerNotice,
                  style: AppTextStyle.headline.of(context),
                ),
                Text(
                  announcement.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.close,
            icon: const GlyphIcon(AppGlyphs.close, size: 18),
            onPressed: () =>
                ref.read(dismissedNoticesProvider.notifier).dismiss(id),
          ),
        ],
      ),
    );
  }
}
