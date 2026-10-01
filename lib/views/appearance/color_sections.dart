import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

const _iconVariants = [
  'default',
  'velvet',
  'solar',
  'circuit',
  'echo',
  'ink',
  'blueprint',
  'strata',
  'shatter',
  'trace',
  'topo',
  'spark',
];

const _headerButtonHeight = 32.0;

class AppearanceColorSections extends ConsumerStatefulWidget {
  const AppearanceColorSections({super.key});

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
      dangerous: true,
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
      dangerous: true,
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
    final rewards = ref.watch(
      visibleMilestonesProvider.select((state) => state.unlocked),
    );
    final primaryColor = themeColors.primaryColor;
    final removable = _removablePrimaryColor;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: FadeSlideEnterBox(
            child: CommonPopScope(
              onPop: (_) {
                if (removable == null) {
                  return true;
                }
                _clearRemovable();
                return false;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoHeader(
                    info: Info(
                      search: const SettingSearch(),
                      label: appLocalizations.themeColor,
                      glyph: AppGlyphs.palette,
                    ),
                    actions: [
                      if (removable == null)
                        CommonMinFilledButtonTheme(
                          child: FilledButton.tonal(
                            onPressed: () => _handleChangeSchemeVariant(
                              themeColors.schemeVariant,
                            ),
                            child: Text(themeColors.schemeVariant.label),
                          ),
                        ),
                      if (removable != null)
                        CommonMinFilledButtonTheme(
                          child: FilledButton(
                            onPressed: _clearRemovable,
                            child: Text(appLocalizations.cancel),
                          ),
                        ),
                      if (removable == null && !themeColors.isDefault)
                        ElasticButton(
                          child: IconButton.filledTonal(
                            tooltip: appLocalizations.reset,
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: _headerButtonHeight,
                              height: _headerButtonHeight,
                            ),
                            visualDensity: VisualDensity.standard,
                            onPressed: _handleReset,
                            icon: const GlyphIcon(AppGlyphs.reset, fill: 1),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _PrimaryColorGrid(
                      colors: [null, ...themeColors.primaryColors],
                      selectedColor: primaryColor,
                      removableColor: removable,
                      onSelect: _handleSelectColor,
                      onRequestRemove: _markRemovable,
                      onDelete: _handleDel,
                      onAdd: _handleAdd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (rewards.contains('porcelain'))
          SettingSection.sliver(
            items: [
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.contrast),
                search: const SettingSearch(),
                title: Text(appLocalizations.findingPorcelain),
                subtitle: Text(appLocalizations.porcelainThemeDesc),
                trailing: const GlyphIcon(AppGlyphs.chevronForward, size: 20),
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
    'strata' => appLocalizations.appIconStrata,
    'shatter' => appLocalizations.appIconShatter,
    'trace' => appLocalizations.appIconTrace,
    'topo' => appLocalizations.appIconTopo,
    'spark' => appLocalizations.appIconSpark,
    _ => appLocalizations.defaultText,
  };
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

  static const double _size = 56;

  final List<int?> colors;
  final int? selectedColor;
  final int? removableColor;
  final void Function(int? color) onSelect;
  final void Function(int? color) onRequestRemove;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in colors)
          _PrimaryColorTile(
            color: color,
            isSelected: color == selectedColor,
            isRemovable: removableColor != null && removableColor == color,
            onSelect: () => onSelect(color),
            onRequestRemove: () => onRequestRemove(color),
            onDelete: onDelete,
          ),
        if (removableColor == null) _AddPrimaryColorTile(onPressed: onAdd),
      ],
    );
  }
}

class _PrimaryColorTile extends StatelessWidget {
  const _PrimaryColorTile({
    required this.color,
    required this.isSelected,
    required this.isRemovable,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
  });

  final int? color;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback onSelect;
  final VoidCallback onRequestRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _PrimaryColorGrid._size,
      child: Stack(
        alignment: Alignment.center,
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
            Positioned.fill(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.delete,
                onPressed: onDelete,
                iconSize: 20,
                icon: GlyphIcon(
                  color: context.colorScheme.primary,
                  AppGlyphs.delete,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPrimaryColorTile extends StatelessWidget {
  const _AddPrimaryColorTile({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _PrimaryColorGrid._size,
      child: IconButton.filledTonal(
        tooltip: context.appLocalizations.add,
        onPressed: onPressed,
        iconSize: 24,
        icon: GlyphIcon(color: context.colorScheme.primary, AppGlyphs.add),
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
          padding: AppInsets.md,
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
              padding: AppInsets.xxl,
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

class AppearanceIconSection extends ConsumerStatefulWidget {
  const AppearanceIconSection({super.key, this.isAndroid});

  final bool? isAndroid;

  @override
  ConsumerState<AppearanceIconSection> createState() =>
      _AppearanceIconSectionState();
}

class _AppearanceIconSectionState extends ConsumerState<AppearanceIconSection> {
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
    if (!(widget.isAndroid ?? system.isAndroid)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final appLocalizations = context.appLocalizations;
    final iconVariant = ref.watch(
      appSettingProvider.select((state) => state.iconVariant),
    );
    return SettingSection.sliver(
      search: const SettingSearch(gate: SettingGate.android),
      title: appLocalizations.appearanceIcon,
      glyph: AppGlyphs.iconTile,
      items: [
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columns = max((constraints.maxWidth / 112).floor(), 2);
            final tileWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final variant in _iconVariants)
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
    );
  }
}
