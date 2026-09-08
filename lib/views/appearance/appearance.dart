import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'layout_tab.dart';
import 'motion_tab.dart';
import 'theme_tab.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.appearance,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _AppearanceTabs(
              labels: [
                appLocalizations.appearanceTheme,
                appLocalizations.appearanceLayout,
                appLocalizations.appearanceMotion,
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AppearanceThemeTab(),
                  AppearanceLayoutTab(),
                  AppearanceMotionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveTabIntent extends Intent {
  const _MoveTabIntent(this.delta);

  final int delta;
}

/// Segmented selector driving the ambient [TabController]. [CommonTabBar] has
/// no focus handling of its own, so arrow keys and the focus ring live here.
const _focusDuration = Duration(milliseconds: 150);

class _AppearanceTabs extends StatefulWidget {
  const _AppearanceTabs({required this.labels});

  final List<String> labels;

  @override
  State<_AppearanceTabs> createState() => _AppearanceTabsState();
}

class _AppearanceTabsState extends State<_AppearanceTabs> {
  TabController? _controller;
  int _index = 0;
  bool _focused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (controller == _controller) {
      return;
    }
    _controller?.animation?.removeListener(_handleOffsetChange);
    _controller = controller;
    _index = controller.index;
    controller.animation?.addListener(_handleOffsetChange);
  }

  @override
  void dispose() {
    _controller?.animation?.removeListener(_handleOffsetChange);
    super.dispose();
  }

  void _handleOffsetChange() {
    final animation = _controller?.animation;
    if (animation == null) {
      return;
    }
    final index = animation.value.round();
    if (index == _index || !mounted) {
      return;
    }
    setState(() {
      _index = index;
    });
  }

  void _handleSelect(int? index) {
    final controller = _controller;
    if (controller == null || index == null || index == controller.index) {
      return;
    }
    controller.animateTo(
      index,
      duration: context.motionDuration(kThemeAnimationDuration),
    );
  }

  void _handleMove(int delta) {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _handleSelect((controller.index + delta).clamp(0, controller.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      // The always-present ring border adds the missing 2px of the 16 inset.
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: FocusableActionDetector(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowLeft): _MoveTabIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowRight): _MoveTabIntent(1),
        },
        actions: {
          _MoveTabIntent: CallbackAction<_MoveTabIntent>(
            onInvoke: (intent) {
              _handleMove(intent.delta);
              return null;
            },
          ),
        },
        onShowFocusHighlight: (value) {
          if (!mounted || value == _focused) {
            return;
          }
          setState(() {
            _focused = value;
          });
        },
        child: AnimatedContainer(
          duration: context.motionDuration(_focusDuration),
          curve: Easing.standard,
          decoration: BoxDecoration(
            borderRadius: AppRadius.all(AppCorner.sm + 5),
            border: Border.all(
              color: _focused ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: CommonTabBar<int>(
              groupValue: _index,
              backgroundColor: colorScheme.surfaceContainerHigh,
              thumbColor: colorScheme.secondaryContainer,
              onValueChanged: _handleSelect,
              children: {
                for (final (index, label) in widget.labels.indexed)
                  index: _TabLabel(label: label, isSelected: index == _index),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      alignment: Alignment.center,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleSmall?.copyWith(
          color: isSelected
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
