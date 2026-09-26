import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutboundModeV2 extends StatelessWidget {
  const OutboundModeV2({super.key});

  void _handleChangeMode(UiOutboundMode mode, WidgetRef ref) {
    ref.read(setupActionProvider.notifier).changeUiMode(mode);
  }

  Color _getTextColor(BuildContext context, UiOutboundMode mode) {
    return switch (mode) {
      UiOutboundMode.auto => context.colorScheme.onPrimaryContainer,
      UiOutboundMode.rule => context.colorScheme.onSecondaryContainer,
      UiOutboundMode.global => context.colorScheme.onPrimaryContainer,
      UiOutboundMode.direct => context.colorScheme.onTertiaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final height = DashboardWidgetMetrics.heightOf(context, 1);
    return SizedBox(
      height: height,
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        child: Consumer(
          builder: (_, ref, _) {
            final mode = ref.watch(uiOutboundModeProvider);
            final thumbColor = switch (mode) {
              UiOutboundMode.auto => context.colorScheme.primaryContainer,
              UiOutboundMode.rule => context.colorScheme.secondaryContainer,
              UiOutboundMode.global =>
                globalState.theme.darken3PrimaryContainer,
              UiOutboundMode.direct => context.colorScheme.tertiaryContainer,
            };
            return LayoutBuilder(
              builder: (_, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        padding: AppInsets.md,
                        constraints: const BoxConstraints.expand(),
                        child: CommonTabBar<UiOutboundMode>(
                          children: {
                            for (final item in UiOutboundMode.values)
                              item: CommonTabLabel(
                                label: item.label,
                                selected: item == mode,
                                selectedColor: _getTextColor(context, item),
                                height: height - 8.ap - 24,
                              ),
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          groupValue: mode,
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            _handleChangeMode(value, ref);
                          },
                          thumbColor: thumbColor,
                        ),
                      ),
                    ),
                    Container(
                      color: thumbColor.opacity50,
                      height: 8.ap,
                      width: constraints.maxWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
