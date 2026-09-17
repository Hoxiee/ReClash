import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/hct/hct.dart';

const _iconVariants = [
  'default',
  'velvet',
  'solar',
  'circuit',
  'echo',
  'ink',
  'blueprint',
  'mesh',
  'facet',
  'strata',
  'shatter',
  'trace',
];

class AppearanceColorSections extends ConsumerStatefulWidget {
  const AppearanceColorSections({super.key, this.isAndroid});

  final bool? isAndroid;

  @override
  ConsumerState<AppearanceColorSections> createState() =>
      _AppearanceColorSectionsState();
}

class _AppearanceColorSectionsState
    extends ConsumerState<AppearanceColorSections> {
  int? _removablePrimaryColor;

  void _update(ThemeProps Function(ThemeProps) f) {
    ref.read(themeSettingProvider.notifier).update(f);
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
    _update((state) => state.copyWith(primaryColor: color));
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    _update(
      (state) => state.copyWith(
        primaryColors: defaultPrimaryColors,
        primaryColor: defaultPrimaryColor,
        schemeVariant: DynamicSchemeVariant.content,
      ),
    );
  }

  Future<void> _handleDel() async {
    final appLocalizations = context.appLocalizations;
    final removable = _removablePrimaryColor;
    if (removable == null) {
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
    _update((state) {
      final newPrimaryColors = List<int>.from(state.primaryColors)
        ..remove(removable);
      int? newPrimaryColor = state.primaryColor;
      if (state.primaryColor == removable) {
        newPrimaryColor = newPrimaryColors.contains(defaultPrimaryColor)
            ? defaultPrimaryColor
            : null;
      }
      return state.copyWith(
        primaryColors: newPrimaryColors,
        primaryColor: newPrimaryColor,
      );
    });
    _clearRemovable();
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
    _update(
      (state) => state.copyWith(
        primaryColors: List.from(state.primaryColors)..add(res),
      ),
    );
  }

  Future<void> _handleChangeSchemeVariant(DynamicSchemeVariant value) async {
    final next = await dialogs.showCommonDialog<DynamicSchemeVariant>(
      child: OptionsDialog<DynamicSchemeVariant>(
        title: context.appLocalizations.colorSchemes,
        options: DynamicSchemeVariant.values,
        textBuilder: (item) => item.label,
        value: value,
      ),
    );
    if (next == null) {
      return;
    }
    _update((state) => state.copyWith(schemeVariant: next));
  }

  Future<void> _handleSelectIcon(String variant) async {
    final asset = 'assets/images/icon_variants/$variant.png';
    final confirmed = await dialogs.showCommonDialog<bool>(
      child: _AppIconPreviewDialog(
        asset: asset,
        label: _iconVariantLabel(context, variant),
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(iconVariant: variant));
    await app?.setIconVariant(variant);
    if (mounted) {
      context.showNotifier(context.appLocalizations.appIconChangeNote);
    }
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
    final iconVariant = ref.watch(
      appSettingProvider.select((state) => state.iconVariant),
    );
    final rewards = ref.watch(
      visibleMilestonesProvider.select((state) => state.unlocked),
    );
    final iconVariants = [
      ..._iconVariants,
      if (rewards.contains('vigil')) 'vigil',
      if (rewards.contains('fullLadder')) 'topo',
      if (rewards.contains('silentAutopilot')) 'spark',
      if (rewards.contains('crown')) 'fractal',
    ];
    final primaryColor = themeColors.primaryColor;
    final isDynamic = primaryColor == null;
    final removable = _removablePrimaryColor;
    return SliverMainAxisGroup(
      slivers: [
        SettingSection.sliver(
          title: appLocalizations.themeColor,
          items: [
            DecorationListItem.toggle(
              leading: const Icon(Icons.colorize),
              title: Text(appLocalizations.systemColor),
              subtitle: Text(appLocalizations.systemColorDesc),
              value: isDynamic,
              onChanged: (value) {
                _clearRemovable();
                _update(
                  (state) => state.copyWith(
                    primaryColor: value
                        ? null
                        : (state.primaryColors.contains(defaultPrimaryColor)
                              ? defaultPrimaryColor
                              : state.primaryColors.firstOrNull),
                  ),
                );
              },
            ),
            if (isDynamic) const _SystemSeedItem(),
            DecorationListItem(
              leading: const Icon(Icons.gradient),
              title: Text(appLocalizations.colorSchemes),
              trailing: Text(
                themeColors.schemeVariant.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.opacity60,
                ),
              ),
              onPressed: () =>
                  _handleChangeSchemeVariant(themeColors.schemeVariant),
            ),
          ],
        ),
        if (rewards.contains('porcelain'))
          SettingSection.sliver(
            items: [
              DecorationListItem(
                leading: const Icon(Icons.tonality_outlined),
                title: Text(appLocalizations.findingPorcelain),
                subtitle: Text(appLocalizations.porcelainThemeDesc),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: () {
                  const color = 0xFFB8C8D4;
                  _update(
                    (state) => state.copyWith(
                      primaryColor: color,
                      primaryColors: state.primaryColors.contains(color)
                          ? state.primaryColors
                          : [...state.primaryColors, color],
                      schemeVariant: DynamicSchemeVariant.monochrome,
                    ),
                  );
                },
              ),
            ],
          ),
        SettingSection.sliver(
          title: appLocalizations.palette,
          // One always-present action: a swap of label keeps the header height
          // stable, unlike showing and hiding a button.
          actions: [
            CommonMinFilledButtonTheme(
              child: FilledButton.tonal(
                onPressed: removable != null
                    ? _clearRemovable
                    : (themeColors.isDefault ? null : _handleReset),
                child: Text(
                  removable != null
                      ? appLocalizations.cancel
                      : appLocalizations.reset,
                ),
              ),
            ),
          ],
          items: [
            CommonPopScope(
              onPop: (_) {
                if (removable == null) {
                  return true;
                }
                _clearRemovable();
                return false;
              },
              child: DisabledMask(
                status: isDynamic,
                child: ActivateBox(
                  active: !isDynamic,
                  child: _PrimaryColorGrid(
                    colors: [
                      if (!isDynamic) null,
                      ...themeColors.primaryColors,
                    ],
                    selectedColor: primaryColor,
                    removableColor: removable,
                    onSelect: _handleSelectColor,
                    onRequestRemove: _markRemovable,
                    onDelete: _handleDel,
                    onAdd: _handleAdd,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.isAndroid ?? system.isAndroid)
          SettingSection.sliver(
            title: appLocalizations.appearanceIcon,
            items: [
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final columns = max((constraints.maxWidth / 112).floor(), 2);
                  final tileWidth =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final variant in iconVariants)
                        _AppIconTile(
                          asset: 'assets/images/icon_variants/$variant.png',
                          label: _iconVariantLabel(context, variant),
                          width: tileWidth,
                          isSelected: iconVariant == variant,
                          onPressed: () => _handleSelectIcon(variant),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
      ],
    );
  }
}

String _iconVariantLabel(BuildContext context, String variant) {
  final appLocalizations = context.appLocalizations;
  return switch (variant) {
    'velvet' => appLocalizations.appIconVelvet,
    'solar' => appLocalizations.appIconSolar,
    'circuit' => appLocalizations.appIconCircuit,
    'echo' => appLocalizations.appIconEcho,
    'ink' => appLocalizations.appIconInk,
    'blueprint' => appLocalizations.appIconBlueprint,
    'mesh' => appLocalizations.appIconMesh,
    'facet' => appLocalizations.appIconFacet,
    'strata' => appLocalizations.appIconStrata,
    'shatter' => appLocalizations.appIconShatter,
    'trace' => appLocalizations.appIconTrace,
    'vigil' => appLocalizations.appIconVigil,
    'topo' => appLocalizations.appIconTopo,
    'spark' => appLocalizations.appIconSpark,
    'fractal' => appLocalizations.appIconFractal,
    _ => appLocalizations.defaultText,
  };
}

class _SystemSeedItem extends ConsumerWidget {
  const _SystemSeedItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(dynamicColorProvider).accentColor;
    final hex = (seed.toARGB32() & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: const Icon(Icons.water_drop_outlined),
      title: Text(context.appLocalizations.systemSeed),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: seed, shape: BoxShape.circle),
          ),
          Text(
            '#$hex',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.opacity60,
            ),
          ),
        ],
      ),
    );
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
            child: Focus(
              canRequestFocus: false,
              onKeyEvent: (_, event) {
                if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                  return KeyEventResult.ignored;
                }
                if (event.logicalKey == LogicalKeyboardKey.delete ||
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  onRequestRemove();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: ColorSchemeBox(
                isSelected: isSelected,
                primaryColor: color != null ? Color(color!) : null,
                onPressed: onSelect,
              ),
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

class _AppIconTile extends StatelessWidget {
  const _AppIconTile({
    required this.asset,
    required this.label,
    required this.width,
    required this.isSelected,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final double width;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 112,
      child: CommonCard(
        isSelected: isSelected,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 8,
            children: [
              ClipRSuperellipse(
                borderRadius: AppRadius.xs,
                child: Image.asset(asset, width: 56, height: 56),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppIconPreviewDialog extends StatelessWidget {
  const _AppIconPreviewDialog({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.appIconPreview,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(appLocalizations.appIconInstall),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          DecoratedBox(
            decoration: ShapeDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              shape: AppShape.xxl,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRSuperellipse(
                borderRadius: AppRadius.xxl,
                child: Image.asset(asset, width: 220, height: 220),
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
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
