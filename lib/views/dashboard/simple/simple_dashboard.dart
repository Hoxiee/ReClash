import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/dashboard.dart';
import 'package:reclash/views/dashboard/layout.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/core_status_button.dart';
import 'package:reclash/views/dashboard/widgets/update_card.dart';
import 'package:reclash/widgets/announcement_card.dart';
import 'package:reclash/widgets/update_sheet.dart';

import 'home.dart';
import 'location_card.dart';
import 'simplest.dart';
import 'widget_list.dart';

const _maxWidth = 1120.0;
const _maxHeight = 800.0;

const _columnGap = 32.0;

const _side = 24.0;

const _swipeDistance = 48.0;
const _swipeVelocity = 400.0;

/// The dashboard the appearance setting picks.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(
      appSettingProvider.select((state) => state.dashboardStyle),
    );
    return switch (style) {
      DashboardStyle.simplest => const SimplestDashboardView(),
      DashboardStyle.simple => const SimpleDashboardView(),
      DashboardStyle.detailed => const DashboardView(),
    };
  }
}

/// One big button and a few plain widgets: two pages of a pager on a phone,
/// two columns side by side on a desktop.
class SimpleDashboardView extends ConsumerStatefulWidget {
  const SimpleDashboardView({super.key});

  @override
  ConsumerState<SimpleDashboardView> createState() =>
      _SimpleDashboardViewState();
}

class _SimpleDashboardViewState extends ConsumerState<SimpleDashboardView> {
  late final PageController _pager;
  var _started = false;
  var _page = 0;

  /// Where the pager is headed, ahead of [_page] while it turns, so a swipe
  /// made during the turn steps on from there.
  var _target = 0;
  var _editing = false;
  var _swipe = 0.0;
  PageSwipeArrival? _arrival;

  /// A swipe that brings the dashboard in from the next app page goes on
  /// with its last page, and one from the page before with its first.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arrival = PageSwipeEntry.of(context);
    final entered = arrival != null && !identical(arrival, _arrival);
    _arrival = arrival;
    final page = entered ? (arrival.forward ? 0 : 1) : _target;
    if (!_started) {
      _started = true;
      _page = _target = page;
      _pager = PageController(initialPage: page);
    } else if (page != _target) {
      _target = page;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _target == page && _pager.hasClients) {
          _pager.jumpToPage(page);
        }
      });
    }
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _setEditing(bool editing) => setState(() => _editing = editing);

  void _showPage(int page) {
    if (!_pager.hasClients) return;
    _target = page;
    _pager.animateToPage(
      page,
      duration: context.motionDuration(const Duration(milliseconds: 360)),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  /// A swipe turns the page once and never holds it between two: the pager
  /// ignores the finger and flips on the gesture's distance or fling. Past
  /// either end it goes on to the app's next page.
  void _endSwipe(DragEndDetails details) {
    final sign = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final distance = _swipe * sign;
    final velocity = details.primaryVelocity ?? 0;
    _swipe = 0;
    final forward =
        velocity * sign < -_swipeVelocity || distance <= -_swipeDistance;
    final back = velocity * sign > _swipeVelocity || distance >= _swipeDistance;
    if (forward == back) return;
    final page = _target + (forward ? 1 : -1);
    if (page >= 0 && page <= 1) {
      _showPage(page);
    } else if (!_editing) {
      PageSwipeNotification(forward: forward).dispatch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final viewSize = ref.watch(viewSizeProvider);
    final sideWidth = ref.watch(sideWidthProvider);
    final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
    final desktop = DashboardDensity.of(
      Size(viewSize.width - sideWidth, viewSize.height) / scale,
    ).isDesktop;
    final editable = !ref.watch(
      providerRestrictionsProvider.select(
        (restrictions) =>
            restrictions.contains(ProviderRestriction.denyWidgets),
      ),
    );
    if (!editable || (!desktop && _page != 1)) _editing = false;
    final editing = _editing;
    final hasUpdate = ref.watch(
      appUpdateActionProvider.select((state) => state.hasUpdate),
    );
    final announcement = ref.watch(
      providerAnnouncementProvider.select((card) => card != null),
    );
    final edit = IconButtonData(
      glyph: AppGlyphs.edit,
      tooltip: appLocalizations.simpleDashboardEditWidgets,
      onPressed: () => _setEditing(true),
    );
    return CommonScaffold(
      backgroundColor: DashboardColors.of(context).page,
      title: desktop ? appLocalizations.dashboard : null,
      titleWidget: desktop
          ? null
          : _PagerTitle(
              controller: _pager,
              labels: [
                appLocalizations.simpleDashboardHome,
                appLocalizations.simpleDashboardWidgets,
              ],
              onSelect: _showPage,
            ),
      actions: [
        if (!desktop && _page == 0 && hasUpdate) const _UpdateButton(),
        if (!editing && coreLib == null) const CoreStatusButton(),
      ],
      confirmationAction: editing
          ? IconButtonData(
              glyph: AppGlyphs.check,
              tooltip: appLocalizations.done,
              onPressed: () => _setEditing(false),
            )
          : null,
      iconActions: [if (!editing && editable && (desktop || _page == 1)) edit],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final room = constraints.biggest / scale;
          final density = DashboardDensity.of(room);
          return DashboardDensityScope(
            density: density,
            scale: scale,
            child: density.isDesktop
                ? _desktop(context, editing, announcement, hasUpdate, scale)
                : _mobile(
                    context,
                    constraints.maxWidth,
                    editing,
                    announcement,
                    hasUpdate,
                  ),
          );
        },
      ),
    );
  }

  Widget _mobile(
    BuildContext context,
    double width,
    bool editing,
    bool announcement,
    bool hasUpdate,
  ) {
    final side = dashboardMobileSideOf(width);
    final top = context.contentTopPadding;
    final bottom = 12 + context.bottomInset;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _swipe = 0,
      onHorizontalDragUpdate: (details) => _swipe += details.primaryDelta ?? 0,
      onHorizontalDragCancel: () => _swipe = 0,
      onHorizontalDragEnd: _endSwipe,
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pager,
        onPageChanged: (page) => setState(() => _page = page),
        children: [
          _Page(
            active: _page == 0,
            child: SimpleHome(
              padding: EdgeInsets.fromLTRB(side, top, side, bottom),
            ),
          ),
          _Page(
            active: _page == 1,
            child: SimpleWidgetList(
              editing: editing,
              onDone: () => _setEditing(false),
              padding: EdgeInsets.fromLTRB(side, top, side, bottom),
              leading: [
                if (hasUpdate) const UpdateCard(),
                if (announcement) const OpenAnnouncementCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktop(
    BuildContext context,
    bool editing,
    bool announcement,
    bool hasUpdate,
    double scale,
  ) {
    final top = context.contentTopPadding;
    final bottom = 24 + context.bottomInset;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxWidth + 2 * _side,
          maxHeight: _maxHeight * scale,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SimpleHome(
                padding: EdgeInsets.fromLTRB(
                  _side,
                  top,
                  _columnGap / 2,
                  bottom,
                ),
                wide: true,
              ),
            ),
            Expanded(
              child: SimpleWidgetList(
                editing: editing,
                onDone: () => _setEditing(false),
                padding: EdgeInsets.fromLTRB(
                  _columnGap / 2,
                  top,
                  _side,
                  bottom,
                ),
                leading: [
                  if (hasUpdate) const UpdateCard(),
                  const LocationCard(),
                  if (announcement) const OpenAnnouncementCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pending app update, opening the update sheet from the header's end.
class _UpdateButton extends StatelessWidget {
  const _UpdateButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const ValueKey('simple-dashboard-update'),
      onPressed: () => unawaited(UpdateSheet.show(context)),
      icon: const GlyphIcon(AppGlyphs.cloudDownload, size: 18, fill: 1),
      label: Text(context.appLocalizations.update),
    );
  }
}

/// The pager named as a title: the page in view at full ink, the other one
/// dimmed, following the swipe.
class _PagerTitle extends StatelessWidget {
  const _PagerTitle({
    required this.controller,
    required this.labels,
    required this.onSelect,
  });

  final PageController controller;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  double _position() {
    if (!controller.hasClients) return controller.initialPage.toDouble();
    final position = controller.position;
    return position.hasContentDimensions && position.viewportDimension > 0
        ? controller.page ?? 0
        : controller.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = AppTextStyle.title2.of(context, emphasized: true);
    final dim = colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final at = _position();
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              for (final (index, label) in labels.indexed)
                Semantics(
                  button: true,
                  selected: at.round() == index,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(index),
                    child: Text(
                      label,
                      style: style.copyWith(
                        color: Color.lerp(
                          colorScheme.onSurface,
                          dim,
                          (at - index).abs().clamp(0, 1).toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Keeps a page and its probes alive off screen, with its tickers paused.
class _Page extends StatefulWidget {
  const _Page({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TickerMode(enabled: widget.active, child: widget.child);
  }
}
