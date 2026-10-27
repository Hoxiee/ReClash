import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/font_family.dart';
import 'package:reclash/views/theme_preview.dart';
import 'package:reclash/views/wallpaper.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeView extends ConsumerStatefulWidget {
  const ThemeView({super.key});

  @override
  ConsumerState<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends ConsumerState<ThemeView>
    with TickerProviderStateMixin {
  late final AnimationController _transition = AnimationController(
    vsync: this,
    value: 1,
    duration: slideTabDuration,
  )..addStatusListener(_onTransitionStatus);
  late final _position = AnimationController.unbounded(vsync: this);
  late final _swipe = _AppearanceSwipeRecognizer(debugOwner: this)
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
  (String?, int)? _handledReveal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initial = !_restored;
    if (initial) {
      _restored = true;
      final saved = PageStorage.maybeOf(
        context,
      )?.readState(context, identifier: 'appearance-category');
      if (saved is int && saved >= 0 && saved < 3) _tab = saved;
      _position.value = _tab.toDouble();
      _visited.add(_tab);
    }
    final active = PageActivityScope.isActiveOf(context);
    if ((!active || context.disableAnimations) && _plan.isActive) {
      _settleTransition();
    }
    final reveal = SettingsRevealScope.maybeOf(context);
    final target = reveal?.targetId;
    if (reveal == null ||
        !reveal.active ||
        target == null ||
        !active ||
        _handledReveal == (target, reveal.nonce)) {
      return;
    }
    final index = _tabOf(target);
    if (index == null) return;
    _handledReveal = (target, reveal.nonce);
    _changeTab(index, animate: !initial);
  }

  int? _tabOf(String target) {
    if (!themeToolSettings.any((setting) => setting.id == target)) return null;
    if (target.startsWith('theme.wallpaper.')) return 1;
    return switch (target) {
      'theme.themeMode' ||
      'theme.themeColor' ||
      'theme.pureBlackMode' ||
      'theme.colorContrast' ||
      'theme.appIcon' => 0,
      _ => 2,
    };
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
      ..canGoNext = _tab < 2
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
  )?.writeState(context, _tab, identifier: 'appearance-category');

  void _changeTab(int index, {bool animate = true}) {
    if (_tab == index) return;
    final previous = _tab;
    final instant =
        !animate ||
        context.disableAnimations ||
        !PageActivityScope.isActiveOf(context);
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

  Widget _buildPages(SettingsRevealScope? reveal) {
    final active = PageActivityScope.isActiveOf(context);
    final transitioning = _plan.isActive;
    final order = [..._visited.where((index) => index != _tab), _tab];
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final index in order)
            _AppearancePage(
              key: ValueKey(index),
              animation: _transition,
              frame: () => _frameOf(index),
              visible: index == _tab || _plan.contains(index),
              active: active && index == _tab,
              child: SettingsRevealScope(
                targetId: reveal?.targetId,
                nonce: reveal?.nonce ?? 0,
                active:
                    active &&
                    index == _tab &&
                    !transitioning &&
                    (reveal?.active ?? true),
                child: PageFocusScope(child: _page(index)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swipe.dispose();
    _transition.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final reveal = SettingsRevealScope.maybeOf(context);
    final split = !ViewScope.isMobileOf(context);
    final segments = [
      GlyphSegment(value: 0, glyph: AppGlyphs.sun, label: l.appearanceTheme),
      GlyphSegment(
        value: 1,
        glyph: AppGlyphs.photos,
        label: l.appearanceBackground,
      ),
      GlyphSegment(
        value: 2,
        glyph: AppGlyphs.settings,
        label: l.appearanceInterface,
      ),
    ];
    final tabTitle = RollingTitle(
      labels: [for (final segment in segments) segment.label],
      position: _position,
    );
    return CommonScaffold(
      title: split
          ? '${l.theme} • ${segments[_tab].label}'
          : segments[_tab].label,
      titleWidget: split
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text('${l.theme} • ', maxLines: 1)),
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
        child: _buildPages(reveal),
      ),
    );
  }

  Widget _page(int index) {
    final layout = ref.watch(
      appSettingProvider.select((state) => state.navigationLayout),
    );
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    bool visible(SettingCondition condition) => isAppearanceSettingVisible(
      condition,
      layout: layout,
      themeMode: themeMode,
    );
    return switch (index) {
      0 => _ThemeSettingsPage(
        id: 'theme',
        items: [
          const _ThemeModeItem(),
          if (visible(SettingCondition.darkTheme)) ...const [
            SizedBox(height: 16),
            _PureBlackItem(),
          ],
          const SizedBox(height: 16),
          const _PrimaryColorItem(),
          const SizedBox(height: 16),
          const _ContrastItem(),
          const _AppIconItem(),
        ],
      ),
      1 => const WallpaperView(),
      _ => _ThemeSettingsPage(
        id: 'interface',
        items: [
          const _DashboardStyleItem(),
          const SizedBox(height: 16),
          const _NavigationLayoutItem(),
          if (visible(SettingCondition.navigationSidebar))
            const _SidebarWidthItem(),
          if (visible(SettingCondition.navigationBar)) ...const [
            SizedBox(height: 16),
            _NavigationBarItem(),
            SizedBox(height: 16),
            _NavigationLabelsItem(),
          ],
          const SizedBox(height: 16),
          const _TabAnimationItem(),
          const SizedBox(height: 16),
          const _LiquidGlassItem(),
          if (visible(SettingCondition.sidebarBlur) &&
              (system.isMacOS || system.isWindows)) ...const [
            SizedBox(height: 16),
            _SidebarBlurItem(),
          ],
          const _FontFamilyItem(),
          const SizedBox(height: 16),
          const _TextScaleFactorItem(),
          const _TrayIconItem(),
        ],
      ),
    };
  }
}

class _AppearanceSwipeRecognizer extends HorizontalDragGestureRecognizer {
  _AppearanceSwipeRecognizer({super.debugOwner});

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

class _AppearancePage extends StatelessWidget {
  const _AppearancePage({
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

class _ThemeSettingsPage extends StatefulWidget {
  const _ThemeSettingsPage({required this.id, required this.items});

  final String id;
  final List<Widget> items;

  @override
  State<_ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<_ThemeSettingsPage> {
  late final ScrollController _controller = sheetScrollController(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: PageStorageKey('theme-tab-${widget.id}'),
    controller: _controller,
    padding: context.bodyInsets,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.appBarInset),
        if (showThemeLivePreview &&
            ViewScope.sizeOf(context).width <= maxMobileWidth) ...const [
          ThemeLivePreview(),
          SizedBox(height: 16),
        ],
        ...widget.items,
        SizedBox(height: context.bottomInset + 32),
      ],
    ),
  );
}

class _ThemeModeItem extends ConsumerWidget {
  const _ThemeModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    final light = MiniScreen(
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.light)),
      floatingBar: floatingBar,
      liquidGlass: liquidGlass,
      simpleDashboard: simpleDashboard,
    );
    final dark = MiniScreen(
      colorScheme: ref.watch(genColorSchemeProvider(Brightness.dark)),
      floatingBar: floatingBar,
      liquidGlass: liquidGlass,
      simpleDashboard: simpleDashboard,
    );
    return SettingTarget(
      spec: themeToolSettings[0],
      child: PreviewChoiceGroup<ThemeMode>(
        info: Info(
          label: themeToolSettings[0].title(appLocalizations),
          glyph: AppGlyphs.sun,
        ),
        value: themeMode,
        choices: [
          PreviewChoice(
            value: ThemeMode.system,
            label: appLocalizations.auto,
            pictogram: MiniScreenThumb(
              screen: MiniSplitScreen(light: light, dark: dark),
            ),
          ),
          PreviewChoice(
            value: ThemeMode.light,
            label: appLocalizations.light,
            pictogram: MiniScreenThumb(screen: light),
          ),
          PreviewChoice(
            value: ThemeMode.dark,
            label: appLocalizations.dark,
            pictogram: MiniScreenThumb(screen: dark),
          ),
        ],
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(themeMode: value));
        },
      ),
    );
  }
}

class _PrimaryColorItem extends ConsumerWidget {
  const _PrimaryColorItem();

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
      destructive: true,
      confirmText: context.appLocalizations.reset,
    );
    if (res != true || !context.mounted) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: defaultPrimaryColors,
        primaryColor: defaultPrimaryColor,
        colorStyle: ColorStyle.vivid,
      );
    });
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    int color,
  ) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.color),
      ),
      destructive: true,
      confirmText: appLocalizations.delete,
    );
    if (res != true || !context.mounted) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      final primaryColors = List<int>.from(state.primaryColors)..remove(color);
      var primaryColor = state.primaryColor;
      if (primaryColor == color) {
        primaryColor = primaryColors.contains(defaultPrimaryColor)
            ? defaultPrimaryColor
            : null;
      }
      return state.copyWith(
        primaryColors: primaryColors,
        primaryColor: primaryColor,
      );
    });
  }

  void _showColorSheet(
    BuildContext context,
    Color initialColor,
    ValueChanged<int> onConfirmed,
  ) {
    showSheet<void>(
      context: context,
      props: const SheetProps(detents: [0.9]),
      builder: (_) => _CustomColorSheet(
        initialColor: initialColor,
        onConfirmed: (color) {
          if (context.mounted) {
            onConfirmed(color);
          }
        },
      ),
    );
  }

  void _handleAdd(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.read(themeSettingProvider).primaryColor;
    _showColorSheet(
      context,
      primaryColor != null
          ? Color(primaryColor)
          : ref.read(dynamicColorProvider).accentColor,
      (color) => _update(
        ref,
        (state) => state.copyWith(
          primaryColors: state.primaryColors.contains(color)
              ? state.primaryColors
              : [...state.primaryColors, color],
          primaryColor: color,
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context, WidgetRef ref, int color) {
    _showColorSheet(
      context,
      Color(color),
      (edited) => _update(ref, (state) {
        final index = state.primaryColors.indexOf(color);
        if (edited == color || index == -1) {
          return state;
        }
        final primaryColors = List<int>.from(state.primaryColors);
        if (primaryColors.contains(edited)) {
          primaryColors.removeAt(index);
        } else {
          primaryColors[index] = edited;
        }
        return state.copyWith(
          primaryColors: primaryColors,
          primaryColor: state.primaryColor == color
              ? edited
              : state.primaryColor,
        );
      }),
    );
  }

  void _update(WidgetRef ref, ThemeProps Function(ThemeProps state) update) {
    ref.read(themeSettingProvider.notifier).update(update);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final themeColors = ref.watch(
      themeSettingProvider.select(
        (state) => ThemeColorsSelectorState(
          primaryColor: state.primaryColor,
          primaryColors: state.primaryColors,
          colorStyle: state.colorStyle,
          isDefault:
              state.primaryColor == defaultPrimaryColor &&
              intListEquality.equals(
                state.primaryColors,
                defaultPrimaryColors,
              ) &&
              state.colorStyle == ColorStyle.vivid,
        ),
      ),
    );
    return SettingTarget(
      spec: themeToolSettings[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(
            info: Info(
              label: appLocalizations.themeColor,
              glyph: AppGlyphs.palette,
            ),
            actions: [
              ?providerSpecTag(ref, themeToolSettings[1]),
              if (!themeColors.isDefault)
                _ResetButton(onPressed: () => _handleReset(context, ref)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                _ColorSwatches(
                  colors: [null, ...themeColors.primaryColors],
                  selected: themeColors.primaryColor,
                  onSelect: (color) => _update(
                    ref,
                    (state) => state.copyWith(primaryColor: color),
                  ),
                  onEdit: (color) => _handleEdit(context, ref, color),
                  onDelete: (color) => _handleDelete(context, ref, color),
                  onAdd: () => _handleAdd(context, ref),
                ),
                generateGroup([
                  ListItem<ColorStyle>.options(
                    title: Text(appLocalizations.colorStyle),
                    options: ColorStyle.values,
                    value: themeColors.colorStyle,
                    textBuilder: (style) => style.label,
                    onChanged: (style) => _update(
                      ref,
                      (state) => state.copyWith(colorStyle: style),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatches extends ConsumerWidget {
  const _ColorSwatches({
    required this.colors,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  static const double _minGap = 6;

  // Lines the dots, not their selection rings, up with the rows' text.
  static const double _inset = 16 - (_ColorSwatch.size - _ColorSwatch.dot) / 2;

  final List<int?> colors;
  final int? selected;
  final ValueChanged<int?> onSelect;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final level = context.raisedSurfaceLevel;
    final systemColor = ref
        .watch(dynamicColorProvider)
        .seedOf(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.all(_inset),
      decoration: ShapeDecoration(
        color: level.colorOf(colorScheme),
        shape: AppShape.xl,
      ),
      child: SurfaceScope(
        level: level,
        child: LayoutBuilder(
          builder: (_, constraints) {
            const cell = _ColorSwatch.size;
            final width = constraints.maxWidth;
            final columns = max(
              1,
              ((width + _minGap) / (cell + _minGap)).floor(),
            );
            final gap = columns > 1
                ? ((width - columns * cell) / (columns - 1)).floorToDouble()
                : 0.0;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final color in colors)
                  _ColorSwatch(
                    color: color == null ? null : Color(color),
                    systemColor: systemColor,
                    isSelected: color == selected,
                    label: color == null
                        ? appLocalizations.followSystem
                        : Color(color).hex,
                    onPressed: () => onSelect(color),
                    menuItems: color == null
                        ? null
                        : [
                            CommonPopupMenuItem(
                              glyph: AppGlyphs.edit,
                              label: appLocalizations.edit,
                              onPressed: () => onEdit(color),
                            ),
                            CommonPopupMenuItem(
                              danger: true,
                              glyph: AppGlyphs.delete,
                              label: appLocalizations.delete,
                              onPressed: () => onDelete(color),
                            ),
                          ],
                  ),
                _AddColorButton(onPressed: onAdd),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatefulWidget {
  const _ColorSwatch({
    required this.color,
    required this.systemColor,
    required this.isSelected,
    required this.label,
    required this.onPressed,
    this.menuItems,
  });

  static const double size = 44;
  static const double dot = 32;
  static const double _ring = 2.5;
  static const _duration = Duration(milliseconds: 200);

  static const double _badge = 20;

  /// Null follows the system's accent color, [systemColor].
  final Color? color;
  final Color systemColor;
  final bool isSelected;
  final String label;
  final VoidCallback onPressed;
  final List<CommonPopupMenuItem>? menuItems;

  @override
  State<_ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<_ColorSwatch> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final fill = color ?? widget.systemColor;
    final selected = widget.isSelected;
    final check = ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final swatch = Semantics(
      button: true,
      selected: selected,
      label: widget.label,
      child: SizedBox.square(
        dimension: _ColorSwatch.size,
        child: Material(
          type: MaterialType.transparency,
          shape: AppShape.circle,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: AppShape.circle,
            onTap: widget.onPressed,
            onFocusChange: (value) => setState(() => _focused = value),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: selected || _focused ? 1 : 0,
                  duration: _ColorSwatch._duration,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: AppShape.circle.copyWith(
                        side: BorderSide(
                          color: selected ? fill : context.colorScheme.primary,
                          width: _ColorSwatch._ring,
                        ),
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                SizedBox.square(
                  dimension: _ColorSwatch.dot,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: fill,
                      shape: AppShape.circle,
                    ),
                  ),
                ),
                if (color == null)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: _EyedropperBadge(size: _ColorSwatch._badge),
                  ),
                AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: _ColorSwatch._duration,
                  curve: Curves.easeOutBack,
                  child: GlyphIcon(
                    AppGlyphs.check,
                    size: 18,
                    fill: 1,
                    color: check,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final menuItems = widget.menuItems;
    if (menuItems == null) {
      return swatch;
    }
    return ContextMenuRegion(menuItems: menuItems, child: swatch);
  }
}

class _EyedropperBadge extends StatelessWidget {
  const _EyedropperBadge({required this.size});

  static const double _gap = 2;

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(_gap),
      decoration: ShapeDecoration(
        color: context.surfaceLevel.colorOf(colorScheme),
        shape: AppShape.circle,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.raisedSurfaceLevel.colorOf(colorScheme),
          shape: AppShape.circle,
        ),
        child: Center(
          child: GlyphIcon(
            AppGlyphs.eyedropper,
            size: size - _gap * 2 - 4,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _AddColorButton extends StatelessWidget {
  const _AddColorButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Tooltip(
      message: context.appLocalizations.add,
      child: Semantics(
        button: true,
        child: SizedBox.square(
          dimension: _ColorSwatch.size,
          child: Material(
            type: MaterialType.transparency,
            shape: AppShape.circle,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: AppShape.circle,
              onTap: onPressed,
              child: Center(
                child: Container(
                  width: _ColorSwatch.dot,
                  height: _ColorSwatch.dot,
                  decoration: ShapeDecoration(
                    color: context.raisedSurfaceLevel.colorOf(colorScheme),
                    shape: AppShape.circle,
                  ),
                  child: GlyphIcon(
                    AppGlyphs.add,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
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

final _floatingBarProvider = appSettingProvider.select(
  (state) => state.floatingNavigationBar,
);

final _liquidGlassProvider = themeSettingProvider.select(
  (state) => state.liquidGlass != LiquidGlassMode.none,
);

final _simpleDashboardProvider = appSettingProvider.select(
  (state) => state.dashboardStyle == DashboardStyle.simple,
);

class _PureBlackItem extends ConsumerWidget {
  const _PureBlackItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final pureBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    Widget preview(bool pureBlack) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: ref.watch(
          genColorSchemeProvider(Brightness.dark, pureBlack: pureBlack),
        ),
        floatingBar: floatingBar,
        liquidGlass: liquidGlass,
        simpleDashboard: simpleDashboard,
      ),
    );
    return SettingTarget(
      spec: themeToolSettings[2],
      child: PreviewChoiceGroup<bool>(
        info: Info(
          label: themeToolSettings[2].title(appLocalizations),
          glyph: AppGlyphs.pureBlack,
        ),
        actions: [?providerSpecTag(ref, themeToolSettings[2])],
        value: pureBlack,
        choices: [
          PreviewChoice(
            value: false,
            label: appLocalizations.standard,
            pictogram: preview(false),
          ),
          PreviewChoice(
            value: true,
            label: appLocalizations.pureBlack,
            pictogram: preview(true),
          ),
        ],
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(pureBlack: value));
        },
      ),
    );
  }
}

class _ContrastItem extends ConsumerWidget {
  const _ContrastItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final contrast = ref.watch(
      themeSettingProvider.select((state) => state.contrast),
    );
    final brightness = Theme.of(context).brightness;
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    Widget preview(ColorContrast contrast) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: ref.watch(
          genColorSchemeProvider(brightness, contrast: contrast),
        ),
        floatingBar: floatingBar,
        liquidGlass: liquidGlass,
        simpleDashboard: simpleDashboard,
      ),
    );
    return SettingTarget(
      spec: themeToolSettings[10],
      child: PreviewChoiceGroup<ColorContrast>(
        info: Info(
          label: themeToolSettings[10].title(appLocalizations),
          glyph: AppGlyphs.eye,
        ),
        value: contrast,
        choices: [
          for (final (value, label) in [
            (ColorContrast.standard, appLocalizations.standard),
            (ColorContrast.medium, appLocalizations.contrastMedium),
            (ColorContrast.high, appLocalizations.contrastHigh),
          ])
            PreviewChoice(
              value: value,
              label: label,
              pictogram: preview(value),
            ),
        ],
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(contrast: value));
        },
      ),
    );
  }
}

extension on AppIcon {
  String get asset => 'assets/images/icon_variants/$name.webp';

  String label(AppLocalizations l) => switch (this) {
    AppIcon.standard => l.appIconStandard,
    AppIcon.velvet => l.appIconVelvet,
    AppIcon.solar => l.appIconSolar,
    AppIcon.circuit => l.appIconCircuit,
    AppIcon.echo => l.appIconEcho,
    AppIcon.ink => l.appIconInk,
    AppIcon.blueprint => l.appIconBlueprint,
    AppIcon.strata => l.appIconStrata,
    AppIcon.shatter => l.appIconShatter,
    AppIcon.trace => l.appIconTrace,
    AppIcon.topo => l.appIconTopo,
    AppIcon.spark => l.appIconSpark,
  };
}

class _AppIconItem extends ConsumerWidget {
  const _AppIconItem();

  static const double _minTileWidth = 84;
  static const double _icon = 56;

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    AppIcon icon,
  ) async {
    final confirmed = await dialogs.showCommonDialog<bool>(
      context: context,
      child: _AppIconPreviewDialog(icon: icon),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(appIcon: icon));
    context.showNotifier(context.appLocalizations.appIconChangeNote);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!system.isAndroid) {
      return const SizedBox.shrink();
    }
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final level = context.raisedSurfaceLevel;
    final selected = ref.watch(
      appSettingProvider.select((state) => state.appIcon),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SettingTarget(
        spec: themeToolSettings[11],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InfoHeader(
              info: Info(
                label: themeToolSettings[11].title(appLocalizations),
                glyph: AppGlyphs.iconTile,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  color: level.colorOf(colorScheme),
                  shape: AppShape.xl,
                ),
                child: SurfaceScope(
                  level: level,
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final columns = max(
                        3,
                        (constraints.maxWidth / _minTileWidth).floor(),
                      );
                      final width = constraints.maxWidth / columns;
                      return Wrap(
                        runSpacing: 4,
                        children: [
                          for (final icon in AppIcon.values)
                            SizedBox(
                              width: width,
                              child: _ChoiceTile(
                                size: const Size.square(_icon),
                                corner: AppCorner.fit(_icon),
                                label: icon.label(appLocalizations),
                                isSelected: icon == selected,
                                onPressed: icon == selected
                                    ? null
                                    : () => _select(context, ref, icon),
                                child: Image.asset(
                                  icon.asset,
                                  cacheWidth:
                                      (_icon *
                                              MediaQuery.devicePixelRatioOf(
                                                context,
                                              ))
                                          .round(),
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A picture to pick, ringed and checked while it is the choice.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.size,
    required this.corner,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.child,
  });

  static const double _ring = 2.5;
  static const double _ringGap = 3;
  static const double _badge = 22;
  static const _duration = Duration(milliseconds: 220);

  final Size size;
  final double corner;
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const inset = (_ring + _ringGap) * 2;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        shape: AppShape.md,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: AppShape.md,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              spacing: 6,
              children: [
                SizedBox(
                  width: size.width + inset,
                  height: size.height + inset,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: isSelected ? 1 : 0,
                        duration: _duration,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: AppShape.all(corner + _ring + _ringGap)
                                .copyWith(
                                  side: BorderSide(
                                    color: colorScheme.primary,
                                    width: _ring,
                                  ),
                                ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      AnimatedScale(
                        scale: isSelected ? 1 : 0.94,
                        duration: _duration,
                        curve: Curves.easeOutCubic,
                        child: ClipRSuperellipse(
                          borderRadius: AppRadius.all(corner),
                          child: SizedBox.fromSize(size: size, child: child),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: AnimatedScale(
                          scale: isSelected ? 1 : 0,
                          duration: _duration,
                          curve: Curves.easeOutBack,
                          child: Container(
                            width: _badge,
                            height: _badge,
                            decoration: ShapeDecoration(
                              color: colorScheme.primary,
                              shape: AppShape.circle.copyWith(
                                side: BorderSide(
                                  color: context.surfaceLevel.colorOf(
                                    colorScheme,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: GlyphIcon(
                              AppGlyphs.check,
                              size: 14,
                              fill: 1,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: _duration,
                  style: AppTextStyle.caption1
                      .of(context, emphasized: isSelected)
                      .copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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

class _AppIconPreviewDialog extends StatelessWidget {
  const _AppIconPreviewDialog({required this.icon});

  static const double _image = 112;

  final AppIcon icon;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final label = icon.label(appLocalizations);
    return CommonDialog(
      title: appLocalizations.appIcon,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(appLocalizations.appIconApply),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: ShapeDecoration(
              shape: AppShape.all(AppCorner.fit(_image)),
              shadows: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRSuperellipse(
              borderRadius: AppRadius.all(AppCorner.fit(_image)),
              child: Image.asset(
                icon.asset,
                width: _image,
                height: _image,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyle.title3.of(context, emphasized: true),
          ),
        ],
      ),
    );
  }
}

class _NavigationLabelsItem extends ConsumerWidget {
  const _NavigationLabelsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final labels = ref.watch(
      appSettingProvider.select((state) => state.navigationLabels),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    final colorScheme = context.colorScheme;
    return SettingTarget(
      spec: themeToolSettings[12],
      child: PreviewChoiceGroup<NavigationLabels>(
        info: Info(
          label: themeToolSettings[12].title(appLocalizations),
          glyph: AppGlyphs.textShort,
        ),
        value: labels,
        choices: [
          for (final (value, label) in [
            (NavigationLabels.always, appLocalizations.navigationLabelsAlways),
            (
              NavigationLabels.selected,
              appLocalizations.navigationLabelsSelected,
            ),
            (NavigationLabels.never, appLocalizations.navigationLabelsNever),
          ])
            PreviewChoice(
              value: value,
              label: label,
              pictogram: MiniScreenThumb(
                screen: MiniScreen(
                  colorScheme: colorScheme,
                  floatingBar: floatingBar,
                  liquidGlass: liquidGlass,
                  simpleDashboard: simpleDashboard,
                  labels: value,
                ),
              ),
            ),
        ],
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(navigationLabels: value));
        },
      ),
    );
  }
}

class _TrayIconItem extends ConsumerWidget {
  const _TrayIconItem();

  static const _panels = {
    TrayIconStyle.color: null,
    TrayIconStyle.light: Color(0xFF26272B),
    TrayIconStyle.dark: Color(0xFFE9E9EC),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!system.isLinux && !system.isWindows) {
      return const SizedBox.shrink();
    }
    final appLocalizations = context.appLocalizations;
    final style = ref.watch(
      appSettingProvider.select((state) => state.trayIconStyle),
    );
    final colorScheme = context.colorScheme;
    Widget preview(TrayIconStyle style) => SizedBox.fromSize(
      size: MiniScreenThumb.size,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: _panels[style] ?? colorScheme.surfaceContainerHighest,
          shape: AppShape.sm,
        ),
        child: Center(
          child: Image.asset(
            switch (style) {
              TrayIconStyle.color => 'assets/images/tray/unix/status_2.png',
              _ => 'assets/images/tray/unix/${style.name}/status_2.png',
            },
            width: 18,
            height: 18,
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SettingTarget(
        spec: themeToolSettings[13],
        child: PreviewChoiceGroup<TrayIconStyle>(
          info: Info(
            label: themeToolSettings[13].title(appLocalizations),
            glyph: AppGlyphs.status,
          ),
          value: style,
          choices: [
            for (final (value, label) in [
              (TrayIconStyle.color, appLocalizations.trayIconColor),
              (TrayIconStyle.light, appLocalizations.trayIconLight),
              (TrayIconStyle.dark, appLocalizations.trayIconDark),
            ])
              PreviewChoice(
                value: value,
                label: label,
                pictogram: preview(value),
              ),
          ],
          onChanged: (value) {
            ref
                .read(appSettingProvider.notifier)
                .update((state) => state.copyWith(trayIconStyle: value));
          },
        ),
      ),
    );
  }
}

class _DashboardStyleItem extends ConsumerWidget {
  const _DashboardStyleItem();

  static const Size _screen = Size(96, 128);
  static const double _scale = 0.875;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final level = context.raisedSurfaceLevel;
    final style = ref.watch(
      appSettingProvider.select((state) => state.dashboardStyle),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final labels = ref.watch(
      appSettingProvider.select((state) => state.navigationLabels),
    );
    Widget tile(DashboardStyle value, String label) => _ChoiceTile(
      size: _screen * _scale,
      corner: AppCorner.md * _scale,
      label: label,
      isSelected: value == style,
      onPressed: value == style
          ? null
          : () => ref
                .read(appSettingProvider.notifier)
                .update((state) => state.copyWith(dashboardStyle: value)),
      child: FittedBox(
        child: SizedBox.fromSize(
          size: _screen,
          child: MiniScreen(
            colorScheme: colorScheme,
            floatingBar: floatingBar,
            liquidGlass: liquidGlass,
            labels: labels,
            simpleDashboard: value == DashboardStyle.simple,
          ),
        ),
      ),
    );
    return SettingTarget(
      spec: themeToolSettings[14],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoHeader(
            info: Info(
              label: themeToolSettings[14].title(appLocalizations),
              glyph: AppGlyphs.dashboard,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: ShapeDecoration(
                color: level.colorOf(colorScheme),
                shape: AppShape.xl,
              ),
              child: SurfaceScope(
                level: level,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 40,
                  children: [
                    for (final (value, label) in [
                      (
                        DashboardStyle.simple,
                        appLocalizations.dashboardStyleSimple,
                      ),
                      (
                        DashboardStyle.detailed,
                        appLocalizations.dashboardStyleDetailed,
                      ),
                    ])
                      tile(value, label),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarWidthItem extends ConsumerWidget {
  const _SidebarWidthItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final narrow = ref.watch(
      appSettingProvider.select(
        (state) => resolveSidebarNarrow(state.sidebarNarrow, isTV: system.isTV),
      ),
    );
    return SettingTarget(
      spec: themeToolSettings.firstWhere(
        (spec) => spec.id == 'theme.sidebarWidth',
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: generateGroup([
          ListItem<bool>.options(
            title: Text(l.sidebarWidth),
            options: const [false, true],
            value: narrow,
            textBuilder: (value) =>
                value ? l.sidebarWidthNarrow : l.sidebarWidthWide,
            onChanged: (value) => ref
                .read(appSettingProvider.notifier)
                .update((state) => state.copyWith(sidebarNarrow: value)),
          ),
        ]),
      ),
    );
  }
}

class _NavigationLayoutItem extends ConsumerWidget {
  const _NavigationLayoutItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final layout = ref.watch(
      appSettingProvider.select((state) => state.navigationLayout),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    final labels = ref.watch(
      appSettingProvider.select((state) => state.navigationLabels),
    );
    final expanded = ref.watch(
      appSettingProvider.select((state) => state.sidebarExpanded),
    );
    final colorScheme = context.colorScheme;
    final bar = MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: colorScheme,
        floatingBar: floatingBar,
        liquidGlass: liquidGlass,
        labels: labels,
        simpleDashboard: simpleDashboard,
      ),
    );
    final sidebar = MiniSidebarThumb(
      colorScheme: colorScheme,
      expanded: expanded,
      simpleDashboard: simpleDashboard,
    );
    return SettingTarget(
      spec: themeToolSettings[9],
      child: PreviewChoiceGroup<NavigationLayout>(
        info: Info(
          label: themeToolSettings[9].title(appLocalizations),
          glyph: AppGlyphs.layers,
        ),
        value: layout,
        choices: [
          PreviewChoice(
            value: NavigationLayout.auto,
            label: appLocalizations.auto,
            pictogram: SizedBox.fromSize(
              size: MiniScreenThumb.size,
              // The split would cut the power button in half.
              child: MiniSplitScreen(
                light: MiniSidebarThumb(
                  colorScheme: colorScheme,
                  expanded: expanded,
                ),
                dark: bar,
              ),
            ),
          ),
          PreviewChoice(
            value: NavigationLayout.bar,
            label: appLocalizations.navigationLayoutBar,
            pictogram: bar,
          ),
          PreviewChoice(
            value: NavigationLayout.sidebar,
            label: appLocalizations.navigationLayoutSidebar,
            pictogram: sidebar,
          ),
        ],
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(navigationLayout: value));
        },
      ),
    );
  }
}

class _NavigationBarItem extends ConsumerWidget {
  const _NavigationBarItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    final colorScheme = context.colorScheme;
    return SettingTarget(
      spec: themeToolSettings[3],
      child: PreviewChoiceGroup<bool>(
        info: Info(
          label: themeToolSettings[3].title(appLocalizations),
          glyph: AppGlyphs.layers,
        ),
        actions: [?providerSpecTag(ref, themeToolSettings[3])],
        value: floatingBar,
        choices: [
          PreviewChoice(
            value: true,
            label: appLocalizations.floating,
            pictogram: MiniScreenThumb(
              screen: MiniScreen(
                colorScheme: colorScheme,
                floatingBar: true,
                liquidGlass: liquidGlass,
                simpleDashboard: simpleDashboard,
              ),
            ),
          ),
          PreviewChoice(
            value: false,
            label: appLocalizations.docked,
            pictogram: MiniScreenThumb(
              screen: MiniScreen(
                colorScheme: colorScheme,
                floatingBar: false,
                simpleDashboard: simpleDashboard,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(floatingNavigationBar: value));
        },
      ),
    );
  }
}

class _TabAnimationItem extends ConsumerWidget {
  const _TabAnimationItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final tabAnimation = ref.watch(
      appSettingProvider.select((state) => state.tabAnimation),
    );
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    final colorScheme = context.colorScheme;
    Widget switching(TabAnimation tabAnimation) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: colorScheme,
        floatingBar: floatingBar,
        liquidGlass: liquidGlass,
        simpleDashboard: simpleDashboard,
        selected: 1,
        previous: 0,
        progress: 0.55,
        tabAnimation: tabAnimation,
      ),
    );
    return SettingTarget(
      spec: themeToolSettings[4],
      child: PreviewChoiceGroup<TabAnimation>(
        info: Info(
          label: themeToolSettings[4].title(appLocalizations),
          glyph: AppGlyphs.motion,
        ),
        actions: [?providerSpecTag(ref, themeToolSettings[4])],
        value: tabAnimation,
        choices: [
          PreviewChoice(
            value: TabAnimation.slide,
            label: appLocalizations.slide,
            pictogram: switching(TabAnimation.slide),
          ),
          PreviewChoice(
            value: TabAnimation.fade,
            label: appLocalizations.fade,
            pictogram: switching(TabAnimation.fade),
          ),
        ],
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(tabAnimation: value));
        },
      ),
    );
  }
}

class _LiquidGlassItem extends ConsumerWidget {
  const _LiquidGlassItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final mode = ref.watch(
      themeSettingProvider.select((state) => state.liquidGlass),
    );
    final colorScheme = context.colorScheme;
    // Floating either way, as a docked bar stays a fill, over the list page,
    // whose rows run on under the bar where glass shows them.
    Widget preview(bool liquidGlass) => MiniScreenThumb(
      screen: MiniScreen(
        colorScheme: colorScheme,
        floatingBar: true,
        liquidGlass: liquidGlass,
        selected: 1,
      ),
    );
    return SettingTarget(
      spec: themeToolSettings[5],
      child: PreviewChoiceGroup<LiquidGlassMode>(
        info: Info(
          label: appLocalizations.liquidGlass,
          glyph: AppGlyphs.liquidGlass,
        ),
        actions: [?providerSpecTag(ref, themeToolSettings[5])],
        value: mode,
        choices: [
          PreviewChoice(
            value: LiquidGlassMode.none,
            label: appLocalizations.none,
            pictogram: preview(false),
          ),
          PreviewChoice(
            value: LiquidGlassMode.standard,
            label: appLocalizations.standard,
            pictogram: preview(true),
          ),
          PreviewChoice(
            value: LiquidGlassMode.ultra,
            label: appLocalizations.ultra,
            pictogram: preview(true),
          ),
        ],
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(liquidGlass: value));
        },
      ),
    );
  }
}

class _SidebarBlurItem extends ConsumerWidget {
  const _SidebarBlurItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!system.isMacOS && !system.isWindows) {
      return const SizedBox.shrink();
    }
    final appLocalizations = context.appLocalizations;
    final sidebarBlur = ref.watch(
      themeSettingProvider.select((state) => state.sidebarBlur),
    );
    return SettingTarget(
      spec: themeToolSettings[6],
      child: ListItem.toggle(
        leading: const GlyphIcon(AppGlyphs.blur),
        horizontalTitleGap: 12,
        title: Text(
          themeToolSettings[6].title(appLocalizations),
          style: AppTextStyle.subheadline
              .of(context, emphasized: true)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        subtitle: Text(appLocalizations.sidebarBlurDesc),
        value: sidebarBlur,
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(sidebarBlur: value));
        },
      ),
    );
  }
}

class _FontFamilyItem extends ConsumerWidget {
  const _FontFamilyItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final fontFamily = ref.watch(
      themeSettingProvider.select((state) => state.fontFamily),
    );
    final preview = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        spacing: 12,
        children: [
          Text(
            'Aa',
            style: AppTextStyle.headline
                .of(context)
                .copyWith(fontFamily: fontFamily),
          ),
          Expanded(
            child: Text(
              fontFamily ?? appLocalizations.defaultText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(
                    fontFamily: fontFamily,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          GlyphIcon(
            AppGlyphs.chevronForward,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
    final cardColor = context.raisedSurfaceLevel.colorOf(colorScheme);
    Widget card(VoidCallback onTap) => Material(
      color: cardColor,
      shape: AppShape.lg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(customBorder: AppShape.lg, onTap: onTap, child: preview),
    );
    return SettingTarget(
      spec: themeToolSettings[7],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(
            info: Info(
              label: themeToolSettings[7].title(appLocalizations),
              glyph: AppGlyphs.font,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: context.isMobileView
                ? OpenContainer<void>(
                    closedShape: AppShape.lg,
                    closedColor: cardColor,
                    closedBuilder: (_, open) => card(open),
                    openBuilder: (_, _) => const FontFamilyView(),
                  )
                : card(
                    () => showSheet<void>(
                      context: context,
                      builder: (_) => const FontFamilyView(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TextScaleFactorItem extends ConsumerStatefulWidget {
  const _TextScaleFactorItem();

  static const _step = 0.05;

  @override
  ConsumerState<_TextScaleFactorItem> createState() =>
      _TextScaleFactorItemState();
}

class _TextScaleFactorItemState extends ConsumerState<_TextScaleFactorItem> {
  double? _draft;

  void _update(TextScale Function(TextScale textScale) update) {
    setState(() => _draft = null);
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(textScale: update(state.textScale)));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final systemScale = systemTextScaleOf(
      context,
    ).clamp(minTextScale, maxTextScale).toDouble();
    final scale = _draft ?? (textScale.enable ? textScale.scale : systemScale);
    final percent = '${(scale * 100).round()}%';
    final level = context.raisedSurfaceLevel;
    final divisions =
        ((maxTextScale - minTextScale) / _TextScaleFactorItem._step).round();
    return SettingTarget(
      spec: themeToolSettings[8],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(
            info: Info(
              label: appLocalizations.textScale,
              glyph: AppGlyphs.textSize,
            ),
            actions: [
              if (textScale.enable && textScale.scale != 1)
                _ResetButton(
                  onPressed: () => _update((state) => state.copyWith(scale: 1)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              spacing: 8,
              children: [
                SegmentedControl<bool>(
                  segments: [
                    (false, appLocalizations.followSystem),
                    (true, appLocalizations.custom),
                  ],
                  value: textScale.enable,
                  onChanged: (value) =>
                      _update((state) => state.copyWith(enable: value)),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: ShapeDecoration(
                    color: level.colorOf(colorScheme),
                    shape: AppShape.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Expanded(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topLeft,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaler: TextScaler.linear(scale),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      'Aa',
                                      style: AppTextStyle.title3.of(context),
                                    ),
                                    Text(
                                      appLocalizations.textScalePreview,
                                      style: AppTextStyle.subheadline
                                          .of(context)
                                          .copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: ShapeDecoration(
                              color: level.next.colorOf(colorScheme),
                              shape: AppShape.full,
                            ),
                            child: Text(
                              percent,
                              style: AppTextStyle.subheadline
                                  .of(context, emphasized: true)
                                  .copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MediaQuery.withNoTextScaling(
                        child: Row(
                          spacing: 12,
                          children: [
                            ExcludeSemantics(
                              child: Text(
                                'A',
                                style: AppTextStyle.footnote
                                    .of(context)
                                    .copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderDefaultsM3(context),
                                child: Slider(
                                  padding: EdgeInsets.zero,
                                  min: minTextScale,
                                  max: maxTextScale,
                                  divisions: divisions,
                                  value: scale,
                                  label: percent,
                                  onChanged: textScale.enable
                                      ? (value) =>
                                            setState(() => _draft = value)
                                      : null,
                                  onChangeEnd: (value) => _update(
                                    (state) => state.copyWith(scale: value),
                                  ),
                                ),
                              ),
                            ),
                            ExcludeSemantics(
                              child: Text(
                                'A',
                                style: AppTextStyle.title2
                                    .of(context)
                                    .copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TonalButtonTheme(
      size: TonalButtonSize.section,
      child: ElasticPress(
        child: IconButton(
          tooltip: context.appLocalizations.reset,
          onPressed: onPressed,
          icon: const GlyphIcon(AppGlyphs.reset),
        ),
      ),
    );
  }
}

class _CustomColorSheet extends StatefulWidget {
  const _CustomColorSheet({
    required this.initialColor,
    required this.onConfirmed,
  });

  final Color initialColor;

  /// Runs once the sheet has closed, so retheming every page cannot stall it.
  final ValueChanged<int> onConfirmed;

  @override
  State<_CustomColorSheet> createState() => _CustomColorSheetState();
}

class _CustomColorSheetState extends State<_CustomColorSheet> {
  late final _controller = ValueNotifier<Color>(widget.initialColor);

  void _confirm() {
    final color = _controller.value.toARGB32();
    final onConfirmed = widget.onConfirmed;
    unawaited(
      ModalRoute.of(context)!.completed.whenComplete(() => onConfirmed(color)),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    // Clears Android's edge back-swipe zone; exclusion rects stop at 200 dp.
    final gestureInsets = MediaQuery.systemGestureInsetsOf(context);
    return CommonScaffold(
      title: appLocalizations.customColor,
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: appLocalizations.confirm,
        onPressed: _confirm,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          max(16, gestureInsets.left),
          context.contentTopPadding,
          max(16, gestureInsets.right),
          20 + context.bottomInset,
        ),
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, color, _) => _CustomColorPreview(
              color: color,
              onChanged: (color) => _controller.value = color,
            ),
          ),
          const SizedBox(height: 16),
          Palette(controller: _controller),
        ],
      ),
    );
  }
}

class _CustomColorPreview extends ConsumerWidget {
  const _CustomColorPreview({required this.color, required this.onChanged});

  static const Size _screenSize = Size(96, 128);
  static const double _scale = 0.75;

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floatingBar = ref.watch(_floatingBarProvider);
    final liquidGlass = ref.watch(_liquidGlassProvider);
    final simpleDashboard = ref.watch(_simpleDashboardProvider);
    final level = context.raisedSurfaceLevel;
    Widget screen(Brightness brightness) => ExcludeSemantics(
      child: SizedBox.fromSize(
        size: _screenSize * _scale,
        child: ClipRSuperellipse(
          borderRadius: AppRadius.md,
          child: FittedBox(
            child: SizedBox.fromSize(
              size: _screenSize,
              child: MiniScreen(
                colorScheme: ref.watch(
                  genColorSchemeProvider(brightness, color: color),
                ),
                floatingBar: floatingBar,
                liquidGlass: liquidGlass,
                simpleDashboard: simpleDashboard,
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: level.colorOf(context.colorScheme),
        shape: AppShape.xl,
      ),
      child: SurfaceScope(
        level: level,
        child: Row(
          spacing: 12,
          children: [
            screen(Brightness.light),
            screen(Brightness.dark),
            Expanded(
              child: HexColorField(color: color, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }
}

final themeToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'theme.themeMode',
    page: ToolPage.theme,
    title: (l) => l.themeMode,
    keywords: ['themeMode'],
  ),
  SettingSpec(
    id: 'theme.themeColor',
    page: ToolPage.theme,
    title: (l) => l.themeColor,
    keywords: ['themeColor'],
  ),
  SettingSpec(
    id: 'theme.pureBlackMode',
    page: ToolPage.theme,
    title: (l) => l.pureBlackMode,
    keywords: ['pureBlackMode'],
    condition: SettingCondition.darkTheme,
  ),
  SettingSpec(
    id: 'theme.navigationBarStyle',
    page: ToolPage.theme,
    title: (l) => l.navigationBarStyle,
    keywords: ['navigationBarStyle'],
    condition: SettingCondition.navigationBar,
  ),
  SettingSpec(
    id: 'theme.tabAnimation',
    page: ToolPage.theme,
    title: (l) => l.tabAnimation,
    keywords: ['tabAnimation'],
  ),
  SettingSpec(
    id: 'theme.liquidGlass',
    page: ToolPage.theme,
    title: (l) => l.liquidGlass,
    keywords: ['liquidGlass'],
  ),
  SettingSpec(
    id: 'theme.sidebarBlur',
    page: ToolPage.theme,
    title: (l) => l.sidebarBlur,
    keywords: ['sidebarBlur'],
    condition: SettingCondition.sidebarBlur,
  ),
  SettingSpec(
    id: 'theme.fontFamily',
    page: ToolPage.theme,
    title: (l) => l.fontFamily,
    keywords: ['fontFamily'],
  ),
  SettingSpec(
    id: 'theme.textScale',
    page: ToolPage.theme,
    title: (l) => l.textScale,
    keywords: ['textScale'],
  ),
  SettingSpec(
    id: 'theme.navigationLayout',
    page: ToolPage.theme,
    title: (l) => l.navigationLayout,
    keywords: ['navigationLayout'],
  ),
  SettingSpec(
    id: 'theme.colorContrast',
    page: ToolPage.theme,
    title: (l) => l.colorContrast,
    keywords: ['colorContrast'],
  ),
  SettingSpec(
    id: 'theme.appIcon',
    page: ToolPage.theme,
    title: (l) => l.appIcon,
    keywords: ['appIcon'],
    condition: SettingCondition.android,
  ),
  SettingSpec(
    id: 'theme.navigationLabels',
    page: ToolPage.theme,
    title: (l) => l.navigationLabels,
    keywords: ['navigationLabels'],
    condition: SettingCondition.navigationBar,
  ),
  SettingSpec(
    id: 'theme.trayIcon',
    page: ToolPage.theme,
    title: (l) => l.trayIcon,
    keywords: ['trayIcon'],
    condition: SettingCondition.linuxOrWindows,
  ),
  SettingSpec(
    id: 'theme.dashboardStyle',
    page: ToolPage.theme,
    title: (l) => l.dashboardStyle,
    keywords: ['dashboardStyle', 'dashboardStyleSimple'],
  ),
  SettingSpec(
    id: 'theme.sidebarWidth',
    page: ToolPage.theme,
    title: (l) => l.sidebarWidth,
    keywords: ['sidebarWidth', 'sidebarWidthNarrow', 'sidebarWidthWide'],
    condition: SettingCondition.navigationSidebar,
  ),
  ...wallpaperToolSettings,
];
