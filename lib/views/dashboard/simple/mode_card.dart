import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/widgets/outbound_mode.dart';

String _hintOf(BuildContext context, Mode mode) {
  final appLocalizations = context.appLocalizations;
  return switch (mode) {
    Mode.rule => appLocalizations.simpleModeRuleDesc,
    Mode.global => appLocalizations.simpleModeGlobalDesc,
    Mode.direct => appLocalizations.simpleModeDirectDesc,
  };
}

class SimpleModeCard extends ConsumerWidget {
  const SimpleModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:items, :selected) = watchOutboundModeChoices(ref);
    final modes = items.whereType<Mode>().toList();
    final automatic = selected == null;
    final effective = ref.watch(effectiveModeProvider);
    final appLocalizations = context.appLocalizations;
    final style = AppTextStyle.footnote.of(context, emphasized: true);
    return DashboardCard(
      semanticLabel: appLocalizations.simpleModeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.shuffle,
            title: appLocalizations.simpleModeTitle,
          ),
          DashboardConnectedGroup(
            children: [
              for (final (index, mode) in modes.indexed)
                Expanded(
                  child: DashboardConnectedButton(
                    selected: mode == effective,
                    first: index == 0,
                    last: index == modes.length - 1,
                    outer: 18,
                    inner: 8,
                    background: DashboardColors.of(context).tone,
                    semanticLabel: mode.label,
                    onTap: automatic
                        ? null
                        : () => changeOutboundMode(ref, mode, selected),
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
                                outboundModeGlyph(mode),
                                size: 16,
                                color: foreground,
                              ),
                              Flexible(
                                child: Text(
                                  mode.label,
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
            _hintOf(context, effective),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DashboardText.label(context).copyWith(height: 1.3),
          ),
          if (items.contains(null))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                spacing: 12,
                children: [
                  GlyphIcon(
                    AppGlyphs.sparkle,
                    size: 18,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(appLocalizations.rcxModeAuto, style: style),
                        Text(
                          appLocalizations.simpleModeAutoDesc,
                          style: DashboardText.label(
                            context,
                          ).copyWith(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  DashboardSwitch(
                    value: automatic,
                    semanticLabel: appLocalizations.rcxModeAuto,
                    onChanged: (value) => unawaited(
                      globalState.safeRun(
                        () => ref
                            .read(rcxRoutingActionProvider.notifier)
                            .setManualMode(!value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
