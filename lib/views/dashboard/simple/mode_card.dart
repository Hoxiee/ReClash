import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/widgets/outbound_mode.dart';

String _labelOf(BuildContext context, Mode? mode) =>
    mode?.label ?? context.appLocalizations.rcxModeAuto;

String _hintOf(BuildContext context, Mode? mode) {
  final appLocalizations = context.appLocalizations;
  return switch (mode) {
    null => appLocalizations.simpleModeAutoDesc,
    Mode.rule => appLocalizations.simpleModeRuleDesc,
    Mode.global => appLocalizations.simpleModeGlobalDesc,
    Mode.direct => appLocalizations.simpleModeDirectDesc,
  };
}

/// Outbound mode in words a person has: what goes through the tunnel.
class SimpleModeCard extends ConsumerWidget {
  const SimpleModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:items, :selected) = watchOutboundModeChoices(ref);
    final style = AppTextStyle.footnote.of(context, emphasized: true);
    return DashboardCard(
      semanticLabel: context.appLocalizations.simpleModeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.shuffle,
            title: context.appLocalizations.simpleModeTitle,
          ),
          DashboardConnectedGroup(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: DashboardConnectedButton(
                    selected: item == selected,
                    first: index == 0,
                    last: index == items.length - 1,
                    outer: 18,
                    inner: 8,
                    background: DashboardColors.of(context).tone,
                    semanticLabel: _labelOf(context, item),
                    onTap: () => changeOutboundMode(ref, item, selected),
                    builder: (foreground) => SizedBox(
                      height: 38,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6,
                            children: [
                              GlyphIcon(
                                outboundModeGlyph(item),
                                size: 16,
                                color: foreground,
                              ),
                              Flexible(
                                child: Text(
                                  _labelOf(context, item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.copyWith(color: foreground),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Text(
            _hintOf(context, selected),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DashboardText.label(context).copyWith(height: 1.3),
          ),
        ],
      ),
    );
  }
}
