import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'fade_box.dart';
import 'focus.dart';
import 'inherited.dart';
import 'list.dart';
import 'theme.dart';

class SettingInfoCard extends StatelessWidget {
  final Info info;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingInfoCard(
    this.info, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      isSelected: isSelected,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(info.iconData),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                info.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingTextCard extends StatelessWidget {
  final String text;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingTextCard(
    this.text, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onPressed: onPressed,
      isSelected: isSelected,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: context.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// One settings group: header plus card rows with grouped corner radii.
/// [SettingSection.sliver] wraps the same content for CustomScrollView bodies.
class SettingSection extends StatelessWidget {
  const SettingSection({
    super.key,
    required this.items,
    this.title,
    this.subTitle,
    this.actions,
    this.top = 0,
    this.bottom = 12,
    this.animateEnter = true,
    this.enterDelay = Duration.zero,
  }) : _isSliver = false;

  const SettingSection.sliver({
    super.key,
    required this.items,
    this.title,
    this.subTitle,
    this.actions,
    this.top = 0,
    this.bottom = 12,
    this.animateEnter = true,
    this.enterDelay = Duration.zero,
  }) : _isSliver = true;

  final List<Widget> items;
  final String? title;
  final String? subTitle;
  final List<Widget>? actions;
  final double top;
  final double bottom;
  final bool animateEnter;
  final Duration enterDelay;
  final bool _isSliver;

  @override
  Widget build(BuildContext context) {
    final header = (title != null && items.isNotEmpty)
        ? ListHeader(title: title!, subTitle: subTitle, actions: actions)
        : null;
    final body = generateSectionV3(items: items);
    final content = Column(children: [?header, body]);
    final animated = animateEnter
        ? FadeSlideEnterBox(delay: enterDelay, child: content)
        : content;
    final padded = Padding(
      padding: EdgeInsets.fromLTRB(16, top, 16, bottom),
      child: animated,
    );
    if (!_isSliver) {
      return padded;
    }
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, top, 16, bottom),
      sliver: SliverToBoxAdapter(child: animated),
    );
  }
}

class SettingBottomInset extends StatelessWidget {
  const SettingBottomInset({super.key, this.height = 16}) : _isSliver = false;

  /// [SliverToBoxAdapter] variant for CustomScrollView slivers lists.
  const SettingBottomInset.sliver({super.key, this.height = 16})
    : _isSliver = true;

  final double height;
  final bool _isSliver;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(height: height + BottomInsetScope.of(context));
    if (!_isSliver) {
      return box;
    }
    return SliverToBoxAdapter(child: box);
  }
}

/// Slider row: title above, value on the trailing edge; without a title the
/// slider spans the whole row. With [resetValue] the trailing slot keeps room
/// for a reset button, so showing it never reflows the row.
class SettingSliderItem extends StatelessWidget {
  const SettingSliderItem({
    super.key,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.title,
    this.leading,
    this.resetValue,
  });

  final String? title;
  final Widget? leading;
  final String valueLabel;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final double? resetValue;

  @override
  Widget build(BuildContext context) {
    final slider = TvFocusOutline(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          navigationMode: system.isTV
              ? NavigationMode.directional
              : MediaQuery.navigationModeOf(context),
        ),
        child: SliderTheme(
          data: SliderDefaultsM3(context),
          child: Slider(
            padding: EdgeInsets.zero,
            min: min,
            max: max,
            value: value.clamp(min, max),
            onChanged: onChanged,
          ),
        ),
      ),
    );
    final title = this.title;
    final resetValue = this.resetValue;
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: EdgeInsets.only(
        left: 16,
        right: resetValue == null ? 8 : 4,
      ),
      leading: leading,
      title: title != null ? Text(title) : slider,
      subtitle: title != null ? slider : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: Text(
              valueLabel,
              textAlign: TextAlign.end,
              style: context.textTheme.titleMedium,
            ),
          ),
          if (resetValue != null)
            SizedBox.square(
              dimension: 36,
              child: (value - resetValue).abs() < 0.001
                  ? null
                  : IconButton(
                      tooltip: context.appLocalizations.reset,
                      onPressed: () => onChanged(resetValue),
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.replay),
                    ),
            ),
        ],
      ),
    );
  }
}
