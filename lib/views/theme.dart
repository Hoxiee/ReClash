import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/hct/hct.dart';

class ThemeModeItem {
  final ThemeMode? themeMode;
  final IconData iconData;
  final String label;

  const ThemeModeItem({
    required this.themeMode,
    required this.iconData,
    required this.label,
  });
}

class FontFamilyItem {
  final FontFamily fontFamily;
  final String label;

  const FontFamilyItem({required this.fontFamily, required this.label});
}

class ThemeView extends StatelessWidget {
  const ThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return BaseScaffold(
      title: appLocalizations.appearance,
      body: CustomScrollView(
        slivers: [
          _SectionHeader(title: appLocalizations.appearanceTheme),
          const _ThemeModeItem(),
          const _ScheduleVisibility(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _PrueBlackItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _TextScaleFactorItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const _ContrastItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          _SectionHeader(title: appLocalizations.appearanceColor),
          const _PrimaryColorItem(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListHeader(
        title: title,
        padding: listHeaderPadding.copyWith(bottom: 8.ap),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Widget child;
  final Info info;
  final List<Widget> actions;

  const ItemCard({
    super.key,
    required this.info,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 16,
      children: [
        InfoHeader(info: info, actions: actions),
        child,
      ],
    );
  }
}

class _ThemeModeItem extends ConsumerWidget {
  const _ThemeModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (themeMode: themeMode, scheduledTheme: scheduledTheme) = ref.watch(
      themeSettingProvider.select(
        (state) => (themeMode: state.themeMode, scheduledTheme: state.scheduledTheme),
      ),
    );
    final List<ThemeModeItem> themeModeItems = [
      ThemeModeItem(
        iconData: Icons.auto_mode,
        label: appLocalizations.auto,
        themeMode: ThemeMode.system,
      ),
      ThemeModeItem(
        iconData: Icons.light_mode,
        label: appLocalizations.light,
        themeMode: ThemeMode.light,
      ),
      ThemeModeItem(
        iconData: Icons.dark_mode,
        label: appLocalizations.dark,
        themeMode: ThemeMode.dark,
      ),
      ThemeModeItem(
        iconData: Icons.schedule,
        label: appLocalizations.schedule,
        themeMode: null,
      ),
    ];
    return SliverToBoxAdapter(
      child: ItemCard(
        info: Info(
          label: appLocalizations.themeMode,
          iconData: Icons.brightness_high,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: themeModeItems.length,
            itemBuilder: (_, index) {
              final themeModeItem = themeModeItems[index];
              return CommonCard(
                isSelected: themeModeItem.themeMode == null
                    ? scheduledTheme
                    : !scheduledTheme && themeModeItem.themeMode == themeMode,
                onPressed: () {
                  ref.read(themeSettingProvider.notifier).update(
                    (state) => themeModeItem.themeMode == null
                        ? state.copyWith(
                            scheduledTheme: true,
                            darkAt: state.darkAt ?? '22:00',
                            lightAt: state.lightAt ?? '07:00',
                          )
                        : state.copyWith(
                            scheduledTheme: false,
                            themeMode: themeModeItem.themeMode!,
                          ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(child: Icon(themeModeItem.iconData)),
                      const SizedBox(width: 8),
                      Flexible(child: Text(themeModeItem.label)),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, _) {
              return const SizedBox(width: 16);
            },
          ),
        ),
      ),
    );
  }
}

class _ScheduleVisibility extends ConsumerWidget {
  const _ScheduleVisibility();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledTheme = ref.watch(
      themeSettingProvider.select((state) => state.scheduledTheme),
    );
    if (!scheduledTheme) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return const SliverToBoxAdapter(child: _ScheduleItem());
  }
}

class _ScheduleItem extends ConsumerWidget {
  const _ScheduleItem();

  Future<void> _editTime(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) async {
    final appLocalizations = context.appLocalizations;
    final current = ref.read(
      themeSettingProvider.select(
        (state) => (isDark ? state.darkAt : state.lightAt) ?? '',
      ),
    );
    final options = <String>{
      if (current.isNotEmpty) current,
      '20:00',
      '21:00',
      '22:00',
      '23:00',
      '00:00',
      '06:00',
      '07:00',
      '08:00',
      '09:00',
    }.toList();
    final value = await dialogs.showCommonDialog<String>(
      child: OptionsDialog<String>(
        title: isDark
            ? appLocalizations.darkAt
            : appLocalizations.lightAt,
        options: options,
        value: current.isEmpty ? '22:00' : current,
        textBuilder: (item) => item,
      ),
    );
    if (value == null) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update(
      (state) => isDark
          ? state.copyWith(darkAt: value)
          : state.copyWith(lightAt: value),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (darkAt: darkAt, lightAt: lightAt) = ref.watch(
      themeSettingProvider.select(
        (state) => (darkAt: state.darkAt, lightAt: state.lightAt),
      ),
    );
    return Column(
      children: [
        ListItem(
          leading: const Icon(Icons.bedtime),
          title: Text(appLocalizations.darkAt),
          subtitle: Text(darkAt ?? '22:00'),
          onTap: () => _editTime(context, ref, true),
        ),
        ListItem(
          leading: const Icon(Icons.wb_sunny),
          title: Text(appLocalizations.lightAt),
          subtitle: Text(lightAt ?? '07:00'),
          onTap: () => _editTime(context, ref, false),
        ),
      ],
    );
  }
}

class _ContrastItem extends ConsumerWidget {
  const _ContrastItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (contrastLevel: contrast, pureBlack: pureBlack) = ref.watch(
      themeSettingProvider.select(
        (state) => (
          contrastLevel: state.contrastLevel,
          pureBlack: state.pureBlack,
        ),
      ),
    );
    final process = contrast >= 0
        ? '+${(contrast * 100).round()}%'
        : '${(contrast * 100).round()}%';
    return SliverToBoxAdapter(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListItem(
          leading: Tooltip(
            message: pureBlack ? appLocalizations.contrastAmoledHint : '',
            child: const Icon(Icons.contrast),
          ),
          horizontalTitleGap: 12,
          title: Text(
            appLocalizations.contrast,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Text(process, style: context.textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: SliderDefaultsM3(context),
            child: Slider(
              padding: EdgeInsets.zero,
              min: -1,
              max: 1,
              value: contrast.clamp(-1, 1),
              onChanged: (value) {
                ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith(contrastLevel: value));
              },
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _PrimaryColorItem extends ConsumerStatefulWidget {
  const _PrimaryColorItem();

  @override
  ConsumerState<_PrimaryColorItem> createState() => _PrimaryColorItemState();
}

class _PrimaryColorItemState extends ConsumerState<_PrimaryColorItem> {
  int? _removablePrimaryColor;

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: defaultPrimaryColors,
        primaryColor: defaultPrimaryColor,
        schemeVariant: DynamicSchemeVariant.content,
      );
    });
  }

  Future<void> _handleDel() async {
    final appLocalizations = context.appLocalizations;
    if (_removablePrimaryColor == null) {
      return;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.colorSchemes),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      final newPrimaryColors = List<int>.from(state.primaryColors)
        ..remove(_removablePrimaryColor);
      int? newPrimaryColor = state.primaryColor;
      if (state.primaryColor == _removablePrimaryColor) {
        if (newPrimaryColors.contains(defaultPrimaryColor)) {
          newPrimaryColor = defaultPrimaryColor;
        } else {
          newPrimaryColor = null;
        }
      }
      return state.copyWith(
        primaryColors: newPrimaryColors,
        primaryColor: newPrimaryColor,
      );
    });
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  Future<void> _handleAdd() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showCommonDialog<int>(
      child: const _PaletteDialog(),
    );
    if (res == null) {
      return;
    }
    final isExists = ref.read(
      themeSettingProvider.select((state) => state.primaryColors.contains(res)),
    );
    if (isExists && mounted) {
      context.showNotifier(
        appLocalizations.existsTip(appLocalizations.colorSchemes),
        level: MessageLevel.warning,
      );
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: List.from(state.primaryColors)..add(res),
      );
    });
  }

  Future<void> _handleChangeSchemeVariant() async {
    final schemeVariant = ref.read(
      themeSettingProvider.select((state) => state.schemeVariant),
    );
    final value = await dialogs.showCommonDialog<DynamicSchemeVariant>(
      child: OptionsDialog<DynamicSchemeVariant>(
        title: context.appLocalizations.colorSchemes,
        options: DynamicSchemeVariant.values,
        textBuilder: (item) => item.label,
        value: schemeVariant,
      ),
    );
    if (value == null) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(schemeVariant: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final themeColors = ref.watch(
      themeSettingProvider.select(
        (state) => ThemeColorsSelectorState(
          primaryColor: state.primaryColor,
          primaryColors: state.primaryColors,
          schemeVariant: state.schemeVariant,
          isDefault:
              state.primaryColor == defaultPrimaryColor &&
              intListEquality.equals(
                state.primaryColors,
                defaultPrimaryColors,
              ) &&
              state.schemeVariant == DynamicSchemeVariant.content,
        ),
      ),
    );
    final primaryColor = themeColors.primaryColor;
    final primaryColors = [null, ...themeColors.primaryColors];
    final schemeVariant = themeColors.schemeVariant;
    final isEquals = themeColors.isDefault;

    return SliverToBoxAdapter(
      child: CommonPopScope(
        onPop: (context) {
          if (_removablePrimaryColor != null) {
            setState(() {
              _removablePrimaryColor = null;
            });
            return false;
          }
          return true;
        },
        child: ItemCard(
          info: Info(
            label: appLocalizations.themeColor,
            iconData: Icons.palette,
          ),
          actions: genActions([
            if (_removablePrimaryColor == null)
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _handleChangeSchemeVariant,
                child: Text(schemeVariant.label),
              ),
            if (_removablePrimaryColor != null)
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _clearRemovable,
                child: Text(appLocalizations.cancel),
              ),
            if (_removablePrimaryColor == null && !isEquals)
              IconButton.filledTonal(
                tooltip: context.appLocalizations.reset,
                iconSize: 20,
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                onPressed: _handleReset,
                icon: const Icon(Icons.replay),
              ),
          ], space: 8),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _PrimaryColorGrid(
              colors: primaryColors,
              selectedColor: primaryColor,
              removableColor: _removablePrimaryColor,
              onSelect: _handleSelectColor,
              onRequestRemove: _markRemovable,
              onDelete: _handleDel,
              onAdd: _handleAdd,
            ),
          ),
        ),
      ),
    );
  }

  void _clearRemovable() {
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  void _markRemovable(int? color) {
    setState(() {
      _removablePrimaryColor = color;
    });
  }

  void _handleSelectColor(int? color) {
    _clearRemovable();
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(primaryColor: color));
  }
}

class _PrimaryColorGrid extends StatelessWidget {
  const _PrimaryColorGrid({
    required this.colors,
    required this.selectedColor,
    required this.removableColor,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
    required this.onAdd,
  });

  final List<int?> colors;
  final int? selectedColor;
  final int? removableColor;
  final void Function(int? color) onSelect;
  final void Function(int? color) onRequestRemove;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = max((constraints.maxWidth / 96).ceil(), 3);
        final itemWidth = (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final color in colors)
              _PrimaryColorTile(
                color: color,
                width: itemWidth,
                isSelected: color == selectedColor,
                isRemovable: removableColor != null && removableColor == color,
                onSelect: () => onSelect(color),
                onRequestRemove: () => onRequestRemove(color),
                onDelete: onDelete,
              ),
            if (removableColor == null)
              _AddPrimaryColorTile(width: itemWidth, onPressed: onAdd),
          ],
        );
      },
    );
  }
}

class _PrimaryColorTile extends StatelessWidget {
  const _PrimaryColorTile({
    required this.color,
    required this.width,
    required this.isSelected,
    required this.isRemovable,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
  });

  final int? color;
  final double width;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback onSelect;
  final VoidCallback onRequestRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      width: width,
      height: width,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          EffectGestureDetector(
            onLongPress: onRequestRemove,
            child: ColorSchemeBox(
              isSelected: isSelected,
              primaryColor: color != null ? Color(color!) : null,
              onPressed: onSelect,
            ),
          ),
          if (isRemovable)
            Container(
              color: Colors.white.opacity0,
              padding: const EdgeInsets.all(8),
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.delete,
                onPressed: onDelete,
                padding: const EdgeInsets.all(12),
                iconSize: 30,
                icon: Icon(color: context.colorScheme.primary, Icons.delete),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPrimaryColorTile extends StatelessWidget {
  const _AddPrimaryColorTile({required this.width, required this.onPressed});

  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      padding: const EdgeInsets.all(4),
      child: IconButton.filledTonal(
        tooltip: context.appLocalizations.add,
        onPressed: onPressed,
        iconSize: 32,
        icon: Icon(color: context.colorScheme.primary, Icons.add),
      ),
    );
  }
}

class _PrueBlackItem extends ConsumerWidget {
  const _PrueBlackItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final prueBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    return SliverToBoxAdapter(
      child: ListItem.toggle(
        leading: const Icon(Icons.contrast),
        horizontalTitleGap: 12,
        title: Text(
          appLocalizations.pureBlackMode,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        value: prueBlack,
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .update((state) => state.copyWith(pureBlack: value));
        },
      ),
    );
  }
}

class _TextScaleFactorItem extends ConsumerWidget {
  const _TextScaleFactorItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final String process = '${(textScale.scale * 100).round()}%';
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListItem.toggle(
              leading: const Icon(Icons.text_fields),
              horizontalTitleGap: 12,
              title: Text(
                appLocalizations.textScale,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              value: textScale.enable,
              onChanged: (value) {
                ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith.textScale(enable: value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              spacing: 32,
              children: [
                Expanded(
                  child: DisabledMask(
                    status: !textScale.enable,
                    child: ActivateBox(
                      active: textScale.enable,
                      child: SliderTheme(
                        data: SliderDefaultsM3(context),
                        child: Slider(
                          padding: EdgeInsets.zero,
                          min: minTextScale,
                          max: maxTextScale,
                          value: textScale.scale,
                          onChanged: (value) {
                            ref
                                .read(themeSettingProvider.notifier)
                                .update(
                                  (state) =>
                                      state.copyWith.textScale(scale: value),
                                );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(process, style: context.textTheme.titleMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteDialog extends StatefulWidget {
  const _PaletteDialog();

  @override
  State<_PaletteDialog> createState() => _PaletteDialogState();
}

class _PaletteDialogState extends State<_PaletteDialog> {
  final _controller = ValueNotifier<Color>(Color(Hct.from(0, 0, 60).toInt()));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.palette,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.value.toARGB32());
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 300, child: Palette(controller: _controller)),
        ],
      ),
    );
  }
}
