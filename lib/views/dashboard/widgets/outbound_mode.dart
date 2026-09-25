import 'dart:math';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutboundMode extends ConsumerWidget {
  const OutboundMode({super.key});

  void _handleChangeMode(UiOutboundMode mode, WidgetRef ref) {
    ref.read(setupActionProvider.notifier).changeUiMode(mode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final height = DashboardWidgetMetrics.heightOf(context, 2);
    return SizedBox(
      height: height,
      child: Consumer(
        builder: (_, ref, _) {
          final mode = ref.watch(uiOutboundModeProvider);
          return Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: CommonCard(
              radius: DashboardWidgetMetrics.radiusOf(context),
              infoPadding: DashboardWidgetMetrics.paddingOf(
                context,
              ).copyWith(bottom: 0),
              onPressed: () {},
              skipTraversal: true,
              info: Info(
                label: appLocalizations.outboundMode,
                iconData: AppGlyphs.split,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: RadioGroup<UiOutboundMode>(
                  groupValue: mode,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _handleChangeMode(value, ref);
                  },
                  child: _ModeRadioList(
                    onSelect: (item) {
                      _handleChangeMode(item, ref);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeRadioList extends StatelessWidget {
  const _ModeRadioList({required this.onSelect});

  final void Function(UiOutboundMode mode) onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final minTileHeight = min(
          constraints.maxHeight / UiOutboundMode.values.length,
          globalState.measure.bodyMediumHeight + 16,
        );
        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (final item in UiOutboundMode.values)
              ListItem.radio(
                horizontalTitleGap: 8,
                tileTitleAlignment: ListTileTitleAlignment.center,
                minTileHeight: minTileHeight,
                minVerticalPadding: 0,
                padding: EdgeInsets.only(left: 12.ap, right: 16.ap),
                onTap: () {
                  onSelect(item);
                },
                value: item,
                title: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.toSoftBold,
                ),
              ),
          ],
        );
      },
    );
  }
}

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
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints.expand(),
                        child: CommonTabBar<UiOutboundMode>(
                          children: {
                            for (final item in UiOutboundMode.values)
                              item: _ModeTab(
                                label: item.label,
                                height: height - 8.ap - 24,
                                color: item == mode
                                    ? _getTextColor(context, item)
                                    : null,
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

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.height,
    required this.color,
  });

  final String label;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: const BoxDecoration(),
      height: height,
      padding: const EdgeInsets.all(4),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.adjustSize(1).copyWith(color: color),
      ),
    );
  }
}
