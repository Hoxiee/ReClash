import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/proxies/routing.dart';
import 'package:reclash/views/proxies/routing_import.dart';
import 'package:reclash/views/proxies/routing_scenario.dart';
import 'package:reclash/views/proxies/routing_studio.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _tabCount = 3;

/// Auto routing as a whole: what it does now, the routes of the running
/// scenario, and the library of scenarios and group profiles.
class RoutingSettingsView extends ConsumerStatefulWidget {
  const RoutingSettingsView({super.key, this.route});

  /// A route of the running scenario to open on the Routes tab.
  final String? route;

  /// Opens [route] in the hub [context] is in, else in a new one.
  static void showRoute(BuildContext context, String route) {
    final hub = context.findAncestorStateOfType<_RoutingSettingsViewState>();
    if (hub != null) {
      hub._showRoute(route);
    } else {
      unawaited(
        BaseNavigator.push<void>(context, RoutingSettingsView(route: route)),
      );
    }
  }

  @override
  ConsumerState<RoutingSettingsView> createState() =>
      _RoutingSettingsViewState();
}

class _RoutingSettingsViewState extends ConsumerState<RoutingSettingsView>
    with TickerProviderStateMixin {
  late final AnimationController _transition = AnimationController(
    vsync: this,
    value: 1,
    duration: slideTabDuration,
  )..addStatusListener(_onTransitionStatus);
  late final _position = AnimationController.unbounded(vsync: this);
  late final _swipe = _TabSwipeRecognizer(debugOwner: this)
    ..onlyAcceptDragOnThreshold = true
    ..onStart = _startSwipe
    ..onUpdate = _updateSwipe
    ..onEnd = _endSwipe
    ..onCancel = () => _finishSwipe(0, cancelled: true);

  int _tab = 0;
  int? _swipeTarget;
  double _swipeDistance = 0;
  final _visited = <int>{};
  final _plan = TabMotionPlan<int>();
  bool _restored = false;
  late String? _route = widget.route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restored) {
      _restored = true;
      final saved = PageStorage.maybeOf(
        context,
      )?.readState(context, identifier: 'routing-tab');
      if (saved is int && saved >= 0 && saved < _tabCount) _tab = saved;
      if (_route != null) _tab = 1;
      _position.value = _tab.toDouble();
      _visited.add(_tab);
    }
    final active = PageActivityScope.isActiveOf(context);
    if ((!active || context.disableAnimations) && _plan.isActive) {
      _settleTransition();
    }
  }

  void _showRoute(String route) {
    setState(() {
      _route = route;
      _changeTab(1);
    });
  }

  void _select(int index) {
    if (_tab == index) return;
    setState(() => _changeTab(index));
  }

  TabFrame _frameOf(int index) =>
      _plan.frameOf(index, current: _tab, value: _transition.value);

  double _logical(double value) =>
      Directionality.of(context) == TextDirection.rtl ? -value : value;

  void _addSwipe(PointerDownEvent event) {
    if (!PageActivityScope.isActiveOf(context) || _swipeTarget != null) return;
    _swipe
      ..canGoPrevious = _tab > 0
      ..canGoNext = _tab < _tabCount - 1
      ..direction = Directionality.of(context)
      ..gestureSettings = MediaQuery.gestureSettingsOf(context)
      ..addPointer(event);
  }

  void _startSwipe(DragStartDetails details) {
    final target = _tab + (_logical(_swipe.globalDistanceMoved) < 0 ? 1 : -1);
    setState(() {
      _settleTransition();
      _swipeTarget = target;
      _swipeDistance = 0;
      _visited.add(target);
      _plan.beginDrag(target, current: _tab, forward: target > _tab);
      _transition.value = 0;
    });
  }

  void _updateSwipe(DragUpdateDetails details) {
    final target = _swipeTarget;
    if (target == null) return;
    final direction = target > _tab ? -1.0 : 1.0;
    _swipeDistance += _logical(details.primaryDelta!);
    final progress = (_swipeDistance * direction / context.size!.width).clamp(
      0.0,
      1.0,
    );
    _transition.value = progress;
    _position.value = _tab + (target - _tab) * progress;
  }

  void _endSwipe(DragEndDetails details) =>
      _finishSwipe(_logical(details.velocity.pixelsPerSecond.dx));

  void _finishSwipe(double velocity, {bool cancelled = false}) {
    final target = _swipeTarget;
    if (target == null) return;
    final forwardVelocity = velocity * (target > _tab ? -1 : 1);
    final commit =
        !cancelled &&
        (forwardVelocity.abs() >= context.size!.width
            ? forwardVelocity > 0
            : _transition.value > 0.5);
    setState(() {
      _swipeTarget = null;
      if (commit) {
        _tab = target;
        _saveTab();
      }
      springToSegment(_position, _tab, instant: context.disableAnimations);
      if (context.disableAnimations || _transition.value == (commit ? 1 : 0)) {
        _settleTransition();
      } else {
        _transition.animateTo(
          commit ? 1 : 0,
          duration: slideTabDuration,
          curve: slideTabCurve,
        );
      }
    });
  }

  void _saveTab() => PageStorage.maybeOf(
    context,
  )?.writeState(context, _tab, identifier: 'routing-tab');

  void _changeTab(int index) {
    if (_tab == index) return;
    final previous = _tab;
    final instant =
        context.disableAnimations || !PageActivityScope.isActiveOf(context);
    if (!instant) {
      _plan.retarget(
        index,
        current: previous,
        value: _transition.value,
        forward: index > previous,
        fade: ref.read(appSettingProvider).tabAnimation == TabAnimation.fade,
      );
    }
    _swipeTarget = null;
    _transition.stop();
    springToSegment(_position, index, instant: instant);
    _tab = index;
    _visited.add(index);
    _saveTab();
    if (instant) {
      _settleTransition();
      return;
    }
    _transition.duration = _plan.duration;
    _transition.forward(from: 0);
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _swipeTarget == null &&
        _plan.isActive) {
      setState(_plan.clear);
    }
  }

  void _settleTransition() {
    _swipeTarget = null;
    springToSegment(_position, _tab, instant: true);
    _transition.stop();
    _plan.clear();
    _transition.value = 1;
  }

  @override
  void dispose() {
    _swipe.dispose();
    _transition.dispose();
    _position.dispose();
    super.dispose();
  }

  Widget _page(int index) => switch (index) {
    0 => const _OverviewTab(),
    1 => RoutingRoutesTab(
      route: _route,
      onRouteShown: () => setState(() => _route = null),
    ),
    _ => const _LibraryTab(),
  };

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final split = !ViewScope.isMobileOf(context);
    final active = PageActivityScope.isActiveOf(context);
    final segments = [
      GlyphSegment(value: 0, glyph: AppGlyphs.status, label: l.rcxHubOverview),
      GlyphSegment(value: 1, glyph: AppGlyphs.split, label: l.rcxHubRoutes),
      GlyphSegment(value: 2, glyph: AppGlyphs.layers, label: l.rcxHubLibrary),
    ];
    final tabTitle = RollingTitle(
      labels: [for (final segment in segments) segment.label],
      position: _position,
    );
    final order = [..._visited.where((index) => index != _tab), _tab];
    return CommonScaffold(
      title: split
          ? '${l.rcxTitle} • ${segments[_tab].label}'
          : segments[_tab].label,
      titleWidget: split
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text('${l.rcxTitle} • ', maxLines: 1)),
                Flexible(child: tabTitle),
              ],
            )
          : tabTitle,
      animateTrailingPress: false,
      trailing: GlyphSegmentedControl<int>(
        segments: segments,
        value: _tab,
        position: _position,
        onChanged: _select,
      ),
      body: Listener(
        onPointerDown: _addSwipe,
        behavior: HitTestBehavior.translucent,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (final index in order)
                _TabPage(
                  key: ValueKey(index),
                  animation: _transition,
                  frame: () => _frameOf(index),
                  visible: index == _tab || _plan.contains(index),
                  active: active && index == _tab,
                  child: PageFocusScope(child: _page(index)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabSwipeRecognizer extends HorizontalDragGestureRecognizer {
  _TabSwipeRecognizer({super.debugOwner});

  bool canGoPrevious = false;
  bool canGoNext = false;
  TextDirection direction = TextDirection.ltr;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    final sufficient = switch (defaultTargetPlatform) {
      TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows =>
        globalDistanceMoved.abs() >
            computePanSlop(pointerDeviceKind, gestureSettings),
      _ => super.hasSufficientGlobalDistanceToAccept(
        pointerDeviceKind,
        deviceTouchSlop,
      ),
    };
    if (!sufficient) return false;
    final delta = direction == TextDirection.rtl
        ? -globalDistanceMoved
        : globalDistanceMoved;
    if (delta < 0 ? canGoNext : canGoPrevious) return true;
    resolve(GestureDisposition.rejected);
    return false;
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({
    super.key,
    required this.animation,
    required this.frame,
    required this.visible,
    required this.active,
    required this.child,
  });

  final Animation<double> animation;
  final TabFrame Function() frame;
  final bool visible;
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => Offstage(
    offstage: !visible,
    child: TickerMode(
      enabled: active,
      child: PageActivityScope(
        isActive: active,
        child: ExcludeFocus(
          excluding: !active,
          child: ExcludeSemantics(
            excluding: !active,
            child: IgnorePointer(
              ignoring: !active,
              child: TabMotionTransition(
                animation: animation,
                frame: frame,
                axis: Axis.horizontal,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A tab's scroll view, under the app bar and above the floating bar.
class _TabList extends StatefulWidget {
  const _TabList({required this.id, required this.children});

  final String id;
  final List<Widget> children;

  @override
  State<_TabList> createState() => _TabListState();
}

class _TabListState extends State<_TabList> {
  late final ScrollController _controller = sheetScrollController(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    key: PageStorageKey('routing-${widget.id}'),
    controller: _controller,
    padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.appBarInset, bottom: context.bottomInset + 32) +
        context.bodyInsets,
    children: widget.children,
  );
}

String _profileTitle(List<RcxProfileInfo> library, String id, String locale) =>
    library.where((p) => p.id == id).firstOrNull?.displayTitle(locale) ?? id;

String _description(RcxProfileInfo? info, String locale) =>
    info == null ? '' : info.localize(info.description, locale);

/// A waiting consent is a question for the user, not a fault to flag red.
bool _isFault(RcxReason? problem) =>
    problem != null && problem.code != 'profile.consent';

/// What auto routing does right now: the scenario, the network and mode it
/// holds, and where each route and smart group sends traffic.
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    List<RcxProfileInfo> library,
    String current,
  ) async {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final byId = {
      for (final p in library)
        if (p.isScenario) p.id: p,
    };
    final picked = await showInSheet<String>(
      context,
      builder: (sheetContext) => SelectionSheet<String>(
        title: l.rcxHubChange,
        sections: [
          for (final source in const ['user', 'provider', 'builtin'])
            if (byId.values.where((p) => p.source == source).toList()
                case final profiles when profiles.isNotEmpty)
              SelectionSection(
                label: rcxSourceLabel(l, source),
                items: [for (final p in profiles) p.id],
                subtitleBuilder: (_, id) {
                  final text = _description(byId[id], locale);
                  return text.isEmpty ? null : text;
                },
              ),
        ],
        labelBuilder: (id) => _profileTitle(library, id, locale),
        selectedOf: (_) => current,
        onSelected: (id) => Navigator.of(sheetContext).pop(id),
      ),
    );
    if (picked == null || picked == current) return;
    await ref.read(rcxRoutingActionProvider.notifier).setScenario(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final hasProfile = ref.watch(
      currentProfileProvider.select((profile) => profile != null),
    );
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final status = ref.watch(rcxStatusStateProvider);
    final layer = ref.watch(currentRoutingLayerProvider);
    final action = ref.read(rcxRoutingActionProvider.notifier);
    if (!hasProfile) {
      return NullStatus(
        label: l.rcxHubNoProfile,
        description: l.rcxHubNoProfileHint,
        illustration: NullStatusIllustration.profile,
      );
    }
    if (status == null) {
      return NullStatus(
        label: l.rcxHubNeedsCore,
        illustration: NullStatusIllustration.proxies,
      );
    }
    final scenario = status.scenario;
    final current = scenario?.id ?? '';
    final info = library
        .where((p) => p.isScenario && p.id == current)
        .firstOrNull;
    String own(String text) => info?.localize(text, locale) ?? text;
    final kind = scenario?.network?.kind;
    final description = _description(info, locale);
    final routeNames = {
      for (final route in scenario?.routes ?? const <RcxRouteStatus>[])
        route.name,
    };
    final groupsByName = {for (final group in status.groups) group.name: group};
    final groups = [
      for (final group in status.groups)
        if (!group.route && !routeNames.contains(group.name)) group,
    ];
    return _TabList(
      id: 'overview',
      children: [
        if (scenario?.problem case RcxReason(
          code: 'profile.consent',
          :final args,
        ))
          RoutingConsentSection(
            hosts: [
              for (final host in args['hosts'] as List? ?? const []) '$host',
            ],
            title: info?.displayTitle(locale) ?? current,
          ),
        generateAnimatedSection(
          footer: switch (scenario?.problem) {
            final problem? when problem.code != 'profile.consent' =>
              rcxReasonText(l, problem),
            _ => scenario == null ? l.rcxHubOffHint : null,
          },
          items: [
            ListItem.toggle(
              key: const ValueKey('master'),
              title: Text(l.rcxHubAuto),
              value: scenario != null,
              onChanged: (on) => unawaited(
                action.setScenario(on ? rcxScenarioToTurnOn(ref) : null),
              ),
            ),
            if (scenario != null)
              DecorationListItem(
                key: const ValueKey('scenario'),
                title: EmojiText(
                  info?.displayTitle(locale) ??
                      (scenario.title.isEmpty ? current : scenario.title),
                ),
                subtitle: description.isEmpty ? null : EmojiText(description),
                onPressed: () =>
                    unawaited(_choose(context, ref, library, current)),
                trailing: Text(
                  l.rcxHubChange,
                  style: AppTextStyle.body
                      .of(context)
                      .copyWith(color: context.colorScheme.primary),
                ),
              ),
            if (scenario != null && scenario.problem == null)
              DecorationListItem(
                key: const ValueKey('live'),
                title: Text(l.rcxModeIs(rcxModeLabel(status.tunnelMode))),
                subtitle: Text(
                  [
                    if (kind != null)
                      l.rcxNetwork(rcxKindLabel(l, kind, own: own)),
                    scenario.manual
                        ? l.rcxModeManualNow
                        : scenario.mode.isEmpty
                        ? l.rcxModeYours
                        : l.rcxModeByScenario,
                  ].join('\n'),
                ),
              ),
            if (scenario != null && scenario.manual && scenario.holdsMode)
              FormRow(
                key: const ValueKey('back-to-auto'),
                title: l.rcxModeBackToAuto,
                onPressed: () => unawaited(action.setManualMode(false)),
                trailing: const GlyphIcon(AppGlyphs.sparkle),
              ),
          ],
        ),
        if (scenario != null && scenario.routes.isNotEmpty)
          generateSection(
            title: l.rcxHubRoutes,
            items: [
              for (final route in scenario.routes)
                _routeRow(context, l, route, groupsByName[route.name]),
            ],
          ),
        if (groups.isNotEmpty || !layer.scenarioOff)
          generateSection(
            title: l.rcxSmartGroups,
            footer: status.energy.requests > 0
                ? l.rcxEnergyToday(
                    status.energy.requests,
                    status.energy.bytes.traffic.show,
                    status.energy.capBytes.traffic.show,
                  )
                : groups.isEmpty
                ? l.rcxHubGroupsEmpty
                : null,
            items: [
              for (final group in groups)
                DecorationListItem(
                  invalid: _isFault(group.problem),
                  title: EmojiText(group.name),
                  subtitle: EmojiText(
                    _groupLine(l, group, status.tunnelMode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () =>
                      unawaited(showRoutingSheet(context, group.name)),
                  trailing: const DisclosureIndicator(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _routeRow(
    BuildContext context,
    AppLocalizations l,
    RcxRouteStatus route,
    RcxGroupStatus? group,
  ) {
    final fixed = route.to.isNotEmpty;
    final open = fixed || group == null
        ? () => RoutingSettingsView.showRoute(context, route.name)
        : () => unawaited(showRoutingSheet(context, route.name));
    return DecorationListItem(
      invalid: _isFault(route.problem),
      title: EmojiText(route.name),
      subtitle: EmojiText(
        switch ((route.problem, group)) {
          (final problem?, _) => rcxReasonText(l, problem),
          _ when fixed => route.to == 'DIRECT' ? l.direct : route.to,
          (_, final group?) => _groupLine(l, group, ''),
          _ => l.rcxModeAuto,
        },
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: open,
      trailing: const DisclosureIndicator(),
    );
  }

  String _groupLine(AppLocalizations l, RcxGroupStatus group, String mode) {
    if (group.problem case final problem?) return rcxReasonText(l, problem);
    if (group.idle) return l.rcxReasonIdle(rcxModeLabel(mode));
    if (group.fixed.isNotEmpty) return l.rcxFixedOn(group.fixed);
    final current = group.current;
    return [
      if (current != null) ...[
        current.name,
        if (current.exit.isNotEmpty)
          if (rcxCountryLabel(current.exit) case final country
              when !current.name.contains(country.split(' ').first))
            country,
        if (current.latencyMs > 0) '${current.latencyMs} ms',
      ],
      if (group.decision.tier.isNotEmpty) group.decision.tier,
    ].join(' · ');
  }
}

/// Scenarios and group profiles from every source; the user's own entries
/// edit in place, the others open as a copy to edit.
class _LibraryTab extends ConsumerStatefulWidget {
  const _LibraryTab();

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> {
  bool _scenarios = true;

  RcxRoutingAction get _action => ref.read(rcxRoutingActionProvider.notifier);

  Future<String?> _sourceOf(RcxProfileInfo info) async {
    final result = await _action.studio({
      'op': 'source',
      'id': info.id,
      if (info.isScenario) 'kind': 'scenario',
    });
    return result?.text;
  }

  Future<void> _open(RcxProfileInfo info, {required bool copy}) async {
    final name = info.id.split('/').last;
    final mine = info.source == 'user';
    if (mine && !copy) {
      return info.isScenario
          ? openScenarioEditor(context, name: name)
          : openRoutingStudio(context, name: name);
    }
    final text = await _sourceOf(info);
    if (text == null || !mounted) return;
    final from = mine ? '' : info.id;
    return info.isScenario
        ? openScenarioEditor(context, text: text, from: from)
        : openRoutingStudio(context, text: text, from: from);
  }

  Future<void> _run(RcxProfileInfo info) async {
    final running = ref.read(rcxStatusStateProvider)?.scenario?.id;
    if (info.id == running) return;
    await _action.setScenario(info.id);
  }

  Future<void> _export(RcxProfileInfo info) async {
    final text = await _sourceOf(info) ?? '';
    if (!mounted) return;
    await exportRoutingDocument(
      context,
      ref,
      id: info.id,
      kind: info.isScenario ? 'scenario' : '',
      text: text,
      title: info.displayTitle(Localizations.localeOf(context).toString()),
    );
  }

  Future<void> _delete(RcxProfileInfo info) async {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final confirmed = await dialogs.showMessage(
      title: l.delete,
      destructive: true,
      message: TextSpan(text: l.rcxDeleteProfile(info.displayTitle(locale))),
    );
    if (confirmed != true) return;
    await _action.saveProfile(info.id.split('/').last, null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final locale = Localizations.localeOf(context).toString();
    final library = ref.watch(rcxLibraryProvider).value ?? const [];
    final active = ref.watch(
      rcxStatusStateProvider.select((status) => status?.scenario?.id),
    );
    final profiles = [
      for (final p in library)
        if (p.isScenario == _scenarios) p,
    ];
    return _TabList(
      id: 'library',
      children: [
        generateSection(
          items: [
            ListItem(
              leading: const GlyphIcon(AppGlyphs.add),
              title: Text(l.rcxNewScenario),
              trailing: const GlyphIcon(AppGlyphs.chevronForward),
              onTap: () => unawaited(openScenarioEditor(context)),
            ),
            ListItem(
              leading: const GlyphIcon(AppGlyphs.add),
              title: Text(l.rcxNewProfile),
              trailing: const GlyphIcon(AppGlyphs.chevronForward),
              onTap: () => unawaited(openRoutingStudio(context)),
            ),
            ListItem(
              leading: const GlyphIcon(AppGlyphs.importFile),
              title: Text(l.import),
              onTap: () => unawaited(pickRoutingImport(context)),
            ),
          ],
        ),
        const ListSectionGap(),
        SegmentedControl<bool>(
          segments: [(true, l.rcxScenarios), (false, l.rcxGroupProfiles)],
          value: _scenarios,
          onChanged: (value) => setState(() => _scenarios = value),
        ),
        const SizedBox(height: 8),
        generateAnimatedSection(
          footer: _scenarios ? l.rcxScenariosHint : l.rcxGroupProfilesHint,
          items: [
            for (final info in profiles)
              ContextMenuRegion(
                key: ValueKey(info.id),
                menuItems: [
                  if (info.source == 'user')
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.edit,
                      label: l.edit,
                      onPressed: () => unawaited(_open(info, copy: false)),
                    ),
                  CommonPopupMenuItem(
                    glyph: AppGlyphs.copy,
                    label: l.rcxDuplicate,
                    onPressed: () => unawaited(_open(info, copy: true)),
                  ),
                  CommonPopupMenuItem(
                    glyph: AppGlyphs.export,
                    label: l.rcxExport,
                    onPressed: () => unawaited(_export(info)),
                  ),
                  if (info.source == 'user')
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.delete,
                      label: l.delete,
                      danger: true,
                      onPressed: () => unawaited(_delete(info)),
                    ),
                ],
                child: _LibraryCard(
                  info: info,
                  locale: locale,
                  active: info.isScenario && info.id == active,
                  onPressed: info.isScenario && info.error.isEmpty
                      ? () => unawaited(_run(info))
                      : () => unawaited(_open(info, copy: false)),
                  onEdit: info.isScenario
                      ? () => unawaited(_open(info, copy: false))
                      : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.info,
    required this.locale,
    required this.active,
    required this.onPressed,
    this.onEdit,
  });

  final RcxProfileInfo info;
  final String locale;
  final bool active;
  final VoidCallback onPressed;

  /// Opens the entry to edit when a tap does something else, as running a
  /// scenario does.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final description = _description(info, locale);
    return DecorationListItem(
      invalid: info.error.isNotEmpty,
      isSelected: active,
      title: EmojiText(info.displayTitle(locale)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.error.isNotEmpty)
            Text(info.error, maxLines: 3, overflow: TextOverflow.ellipsis)
          else if (description.isNotEmpty)
            EmojiText(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              MetaChip(label: rcxSourceLabel(l, info.source)),
              if (!info.isScenario)
                MetaChip(label: rcxLevelLabel(l, info.level)),
              if (info.consent.isNotEmpty) MetaChip(label: l.rcxNeedsConsent),
            ],
          ),
        ],
      ),
      onPressed: onPressed,
      trailing: switch (onEdit) {
        final onEdit? => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (active) const SelectionCheck(),
            IconButton(
              tooltip: info.source == 'user' ? l.edit : l.rcxDuplicate,
              onPressed: onEdit,
              icon: const GlyphIcon(AppGlyphs.edit),
            ).withAppTooltip(),
          ],
        ),
        null => active ? const SelectionCheck() : null,
      },
    );
  }
}

/// The auto-routing entry of the advanced settings.
Widget routingSettingsItem(AppLocalizations l) => ListItem.open(
  title: Text(l.rcxTitle),
  leading: const GlyphIcon(AppGlyphs.shuffle),
  widget: const RoutingSettingsView(),
);
