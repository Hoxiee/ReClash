import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';
import 'package:reclash/widgets/widgets.dart';

const _recurrenceFloorChoices = [1, 2, 3, 4, 5, 8];
const _latencyToleranceChoices = [0, 10, 20, 30, 50, 80];

/// The comparison ladder the engine reads, laid out inline as it ranks: top rung
/// first, each step a toggle plus, where the rung is tunable, a tappable
/// threshold. The direction of every step is intrinsic to the engine and never
/// editable here. An empty [SmartRoutingProps.ladder] is the wire signal for
/// "use the engine default", so the specs materialize only once the user touches
/// the ladder, keeping an untouched config on the engine's own order.
///
/// Returns a [SliverMainAxisGroup] so the ladder drops straight into the studio's
/// inline decision core, in rank order, beside strategy and admission.
class RoutingLadderEditorSliver extends ConsumerWidget {
  const RoutingLadderEditorSliver({super.key});

  List<RcxRungSpec> _effective(SmartRoutingProps props) =>
      props.ladder.isEmpty ? routingDefaultLadderSpecs() : props.ladder;

  void _write(WidgetRef ref, List<RcxRungSpec> specs) {
    ref
        .read(smartRoutingSettingProvider.notifier)
        .update((state) => state.copyWith(ladder: specs));
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l10n = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      dangerous: true,
      title: l10n.reset,
      message: TextSpan(text: l10n.resetTip),
    );
    if (confirmed != true) {
      return;
    }
    ref
        .read(smartRoutingSettingProvider.notifier)
        .update((state) => state.resetSeedGroup(RoutingFacetGroup.ladder));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    final specs = _effective(props);
    final touched = props.ladder.isNotEmpty;

    Widget rowAt(int index) => _LadderRow(
      key: ValueKey(specs[index].id),
      spec: specs[index],
      position: ItemPosition.get(index, specs.length),
      onEnabled: (value) => _write(ref, [
        for (var at = 0; at < specs.length; at++)
          at == index ? specs[at].copyWith(enabled: value) : specs[at],
      ]),
      onRecurrenceFloor: (value) => _write(ref, [
        for (var at = 0; at < specs.length; at++)
          at == index ? specs[at].copyWith(recurrenceFloor: value) : specs[at],
      ]),
      onLatencyTolerance: (value) => _write(ref, [
        for (var at = 0; at < specs.length; at++)
          at == index
              ? specs[at].copyWith(latencyToleranceMs: value)
              : specs[at],
      ]),
    );

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: ListHeader(
            title: appLocalizations.smartRoutingLadderEditor,
            subTitle: appLocalizations.smartRoutingLadderReorderHint,
            actions: touched
                ? [
                    CommonMinFilledButtonTheme(
                      child: FilledButton.tonal(
                        onPressed: () => _reset(context, ref),
                        child: Text(appLocalizations.reset),
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        if (touched)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                appLocalizations.smartRoutingLadderChangedDefault(
                  routingStrategyLabel(appLocalizations, props.strategy.wire),
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverReorderableList(
            itemCount: specs.length,
            itemBuilder: (_, index) => rowAt(index),
            proxyDecorator: (child, index, animation) =>
                commonProxyDecorator(rowAt(index), index, animation),
            onReorderItem: (oldIndex, newIndex) =>
                _write(ref, specs.copyAndReorder(oldIndex, newIndex)),
          ),
        ),
      ],
    );
  }
}

class _LadderRow extends StatelessWidget {
  const _LadderRow({
    super.key,
    required this.spec,
    required this.position,
    required this.onEnabled,
    required this.onRecurrenceFloor,
    required this.onLatencyTolerance,
  });

  final RcxRungSpec spec;
  final ItemPosition position;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<int> onRecurrenceFloor;
  final ValueChanged<int> onLatencyTolerance;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final rung = RoutingRung.values.asNameMap()[spec.id];
    final label = rung == null
        ? spec.id
        : routingRungLabel(appLocalizations, rung);
    final tunable =
        rung == RoutingRung.recurrence || rung == RoutingRung.latency;
    final showThreshold = spec.enabled && tunable;
    return ReorderableDelayedDragStartListener(
      key: ValueKey(spec.id),
      index: position.index,
      child: ItemPositionProvider(
        position: position,
        child: DecorationListItem(
          leading: GlyphIcon(
            AppGlyphs.dragHandle,
            color: colorScheme.onSurfaceVariant,
          ),
          title: Row(
            spacing: AppSpacing.sm,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: spec.enabled
                      ? null
                      : context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
              if (!spec.enabled)
                AppTag(
                  appLocalizations.smartRoutingRungOff,
                  foreground: colorScheme.onSurfaceVariant,
                  background: colorScheme.surfaceContainerHighest,
                ),
            ],
          ),
          subtitle: !showThreshold
              ? null
              : Text(
                  rung == RoutingRung.recurrence
                      ? appLocalizations.smartRoutingRecurrenceFloor
                      : appLocalizations.smartRoutingLatencyTolerance,
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.sm,
            children: [
              if (showThreshold)
                GestureDetector(
                  onTap: () => _editThreshold(context, rung!),
                  child: AppTag(
                    rung == RoutingRung.recurrence
                        ? appLocalizations.smartRoutingEpisodes(
                            spec.recurrenceFloor,
                          )
                        : appLocalizations.smartRoutingMillis(
                            spec.latencyToleranceMs,
                          ),
                    foreground: colorScheme.onPrimaryContainer,
                    background: colorScheme.primaryContainer,
                  ),
                ),
              _tappableSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tappableSwitch() => Builder(
    builder: (context) => GestureDetector(
      onTap: () => onEnabled(!spec.enabled),
      child: Switch(value: spec.enabled, onChanged: onEnabled),
    ),
  );

  Future<void> _editThreshold(BuildContext context, RoutingRung rung) async {
    final appLocalizations = context.appLocalizations;
    if (rung == RoutingRung.recurrence) {
      final picked = await dialogs.showCommonDialog<int>(
        child: OptionsDialog<int>(
          title: appLocalizations.smartRoutingRecurrenceFloor,
          options: _recurrenceFloorChoices,
          value: _nearest(spec.recurrenceFloor, _recurrenceFloorChoices),
          textBuilder: appLocalizations.smartRoutingEpisodes,
        ),
      );
      if (picked != null) {
        onRecurrenceFloor(picked);
      }
      return;
    }
    final picked = await dialogs.showCommonDialog<int>(
      child: OptionsDialog<int>(
        title: appLocalizations.smartRoutingLatencyTolerance,
        options: _latencyToleranceChoices,
        value: _nearest(spec.latencyToleranceMs, _latencyToleranceChoices),
        textBuilder: appLocalizations.smartRoutingMillis,
      ),
    );
    if (picked != null) {
      onLatencyTolerance(picked);
    }
  }

  int _nearest(int value, List<int> options) =>
      options.contains(value) ? value : options.first;
}
