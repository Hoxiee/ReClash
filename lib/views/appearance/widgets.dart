import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

Widget appearanceSection({
  required List<Widget> items,
  String? title,
  List<Widget>? actions,
  double top = 0,
  double bottom = 12,
}) {
  return SliverPadding(
    padding: EdgeInsets.fromLTRB(16, top, 16, bottom),
    sliver: SliverToBoxAdapter(
      child: generateSectionV3(title: title, actions: actions, items: items),
    ),
  );
}

Widget appearanceBottomInset(BuildContext context) {
  return SliverToBoxAdapter(
    child: SizedBox(height: 16 + BottomInsetScope.of(context)),
  );
}

class AppearanceSwitchItem extends StatelessWidget {
  const AppearanceSwitchItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.desc,
    this.leading,
  });

  final String title;
  final String? desc;
  final Widget? leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final desc = this.desc;
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: leading,
      title: Text(title),
      subtitle: desc != null ? Text(desc) : null,
      onPressed: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class AppearanceValueItem extends StatelessWidget {
  const AppearanceValueItem({
    super.key,
    required this.title,
    required this.value,
    this.desc,
    this.leading,
    this.onPressed,
  });

  final String title;
  final String? desc;
  final Widget? leading;
  final String value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final desc = this.desc;
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: leading,
      title: Text(title),
      subtitle: desc != null ? Text(desc) : null,
      onPressed: onPressed,
      trailing: Text(
        value,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface.opacity60,
        ),
      ),
    );
  }
}

/// Слайдер живёт в строке секции: заголовок сверху, значение справа. Без
/// заголовка слайдер занимает всю строку — так подписан переключатель выше.
class AppearanceSliderItem extends StatelessWidget {
  const AppearanceSliderItem({
    super.key,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.title,
    this.leading,
    this.enabled = true,
  });

  final String? title;
  final Widget? leading;
  final String valueLabel;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final slider = DisabledMask(
      status: !enabled,
      child: ActivateBox(
        active: enabled,
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
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: leading,
      title: title != null ? Text(title) : slider,
      subtitle: title != null ? slider : null,
      trailing: Text(valueLabel, style: context.textTheme.titleMedium),
    );
  }
}
