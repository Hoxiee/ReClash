import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/ui/shape.dart';
import 'package:reclash/common/ui/spacing.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';

import '../base/card.dart';
import '../layout/grid.dart';

class ColorSchemeBox extends StatelessWidget {
  final Color? primaryColor;
  final bool? isSelected;
  final void Function()? onPressed;
  final double size;

  const ColorSchemeBox({
    super.key,
    required this.primaryColor,
    this.onPressed,
    this.isSelected,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: PrimaryColorBox(
        primaryColor: primaryColor,
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Stack(
              children: [
                CommonCard(
                  isSelected: isSelected,
                  onPressed: onPressed,
                  selectWidget: Container(
                    alignment: Alignment.center,
                    child: const SelectIcon(),
                  ),
                  child: Padding(
                    padding: AppInsets.sm,
                    child: ClipRSuperellipse(
                      borderRadius: AppRadius.full,
                      child: SizedBox.expand(
                        child: Grid(
                          crossAxisCount: 2,
                          children: [
                            GridItem(
                              mainAxisCellCount: 2,
                              child: Container(color: colorScheme.primary),
                            ),
                            GridItem(
                              mainAxisCellCount: 1,
                              child: Container(color: colorScheme.secondary),
                            ),
                            GridItem(
                              mainAxisCellCount: 1,
                              child: Container(color: colorScheme.tertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (primaryColor == null)
                  const Positioned(
                    bottom: 2,
                    right: 2,
                    child: GlyphIcon(AppGlyphs.eyedropper, size: 16),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class PrimaryColorBox extends ConsumerWidget {
  final Color? primaryColor;
  final Widget child;
  final Brightness? brightness;
  final bool ignoreConfig;

  const PrimaryColorBox({
    super.key,
    required this.primaryColor,
    required this.child,
    this.brightness,
    this.ignoreConfig = true,
  });

  @override
  Widget build(BuildContext context, ref) {
    final themeData = Theme.of(context);
    final colorScheme = ref.watch(
      genColorSchemeProvider(
        brightness ?? themeData.brightness,
        color: primaryColor,
        ignoreConfig: ignoreConfig,
      ),
    );
    return Theme(
      data: themeData.copyWith(colorScheme: colorScheme),
      child: child,
    );
  }
}
