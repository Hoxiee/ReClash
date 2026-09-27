import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';

import 'background_tab.dart';
import 'motion_tab.dart';
import 'theme_tab.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.appearance,
      floatBody: true,
      body: AppBarClearance(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              SettingsTabs(
                labels: [
                  appLocalizations.appearanceTheme,
                  appLocalizations.appearanceBackground,
                  appLocalizations.other,
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    AppearanceThemeTab(),
                    AppearanceBackgroundTab(),
                    AppearanceMotionTab(),
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

/// Segmented selector driving the ambient [TabController].
class SettingsTabs extends StatefulWidget {
  const SettingsTabs({super.key, required this.labels});

  final List<String> labels;

  @override
  State<SettingsTabs> createState() => _SettingsTabsState();
}

class _SettingsTabsState extends State<SettingsTabs> {
  TabController? _controller;
  int _index = 0;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: SizedBox(
        width: double.infinity,
        child: CommonTabBar<int>(
          groupValue: _index,
          backgroundColor: colorScheme.surfaceContainerHigh,
          thumbColor: colorScheme.secondaryContainer,
          onValueChanged: _handleSelect,
          children: {
            for (final (index, label) in widget.labels.indexed)
              index: CommonTabLabel(label: label, selected: index == _index),
          },
        ),
      ),
    );
  }
}
