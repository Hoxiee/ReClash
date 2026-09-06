import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _dwellChoices = [30, 90, 180, 600];
const _waveChoices = [4, 8, 12, 20];

/// Everything a preset seeds is editable here, because a preset is named defaults
/// and nothing more: canaries and markers go stale, and a user on a network the
/// region table never modelled has to be able to correct them.
class SmartRoutingView extends ConsumerWidget {
  const SmartRoutingView({super.key});

  void _update(WidgetRef ref, SmartRoutingProps Function(SmartRoutingProps) f) {
    ref.read(smartRoutingSettingProvider.notifier).update(f);
  }

  void _handleEnabled(WidgetRef ref, bool value) {
    _update(ref, (state) {
      if (!value || state.preset != SmartRoutingPreset.off) {
        return state.copyWith(enabled: value);
      }
      final implied = smartRoutingPresetForLocale(Intl.defaultLocale);
      final preset = implied == SmartRoutingPreset.off ? state.preset : implied;
      return state.applyPreset(preset).copyWith(enabled: true);
    });
  }

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (confirmed != true) {
      return;
    }
    _update(ref, (state) => state.applyPreset(state.preset));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    final colorScheme = context.colorScheme;
    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        sliver: SliverToBoxAdapter(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: AppShape.xl,
              color: colorScheme.surfaceContainerHigh,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.alt_route_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appLocalizations.smartRoutingIntro,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SettingSection.sliver(
        top: 12,
        items: [
          DecorationListItem.toggle(
            title: Text(appLocalizations.smartRouting),
            subtitle: Text(appLocalizations.smartRoutingDesc),
            value: props.enabled,
            onChanged: (value) => _handleEnabled(ref, value),
          ),
        ],
      ),
    ];

    if (props.enabled) {
      slivers.addAll([
        SettingSection.sliver(
          title: appLocalizations.smartRoutingPreset,
          actions: [
            const SizedBox(width: 8),
            CommonMinFilledButtonTheme(
              child: FilledButton.tonal(
                onPressed: props.matchesPreset
                    ? null
                    : () => _handleReset(context, ref),
                child: Text(appLocalizations.reset),
              ),
            ),
          ],
          items: [
            DecorationListItem.options(
              title: Text(appLocalizations.smartRoutingRegion),
              subtitle: Text(
                props.matchesPreset
                    ? props.preset.label
                    : appLocalizations.smartRoutingPresetEdited(
                        props.preset.label,
                      ),
              ),
              dialogTitle: appLocalizations.smartRoutingRegion,
              options: SmartRoutingPreset.values,
              value: props.preset,
              textBuilder: (value) => (value as SmartRoutingPreset).label,
              onChanged: (value) => _update(
                ref,
                (state) => state.applyPreset(value as SmartRoutingPreset),
              ),
            ),
            DecorationListItem.options(
              title: Text(appLocalizations.smartRoutingStrategy),
              subtitle: Text(appLocalizations.smartRoutingStrategyDesc),
              dialogTitle: appLocalizations.smartRoutingStrategy,
              options: SmartRoutingStrategy.values,
              value: props.strategy,
              textBuilder: (value) => (value as SmartRoutingStrategy).label,
              onChanged: (value) => _update(
                ref,
                (state) =>
                    state.copyWith(strategy: value as SmartRoutingStrategy),
              ),
            ),
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.smartRoutingBehaviour,
          items: [
            DecorationListItem.toggle(
              title: Text(appLocalizations.smartRoutingDomestic),
              subtitle: Text(appLocalizations.smartRoutingDomesticDesc),
              value: props.allowDomesticLastResort,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(allowDomesticLastResort: value),
              ),
            ),
            DecorationListItem.toggle(
              title: Text(appLocalizations.smartRoutingRequireUdp),
              subtitle: Text(appLocalizations.smartRoutingRequireUdpDesc),
              value: props.requireUdp,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(requireUdp: value)),
            ),
            DecorationListItem.toggle(
              title: Text(appLocalizations.smartRoutingManualHold),
              subtitle: Text(appLocalizations.smartRoutingManualHoldDesc),
              value: props.respectPick,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(respectPick: value)),
            ),
            DecorationListItem.options(
              title: Text(appLocalizations.smartRoutingDwell),
              subtitle: Text(appLocalizations.smartRoutingDwellDesc),
              dialogTitle: appLocalizations.smartRoutingDwell,
              options: _dwellChoices,
              value: props.dwellSeconds,
              textBuilder: (value) =>
                  appLocalizations.smartRoutingSeconds(value as int),
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(dwellSeconds: value as int),
              ),
            ),
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.smartRoutingProbing,
          items: [
            DecorationListItem.options(
              title: Text(appLocalizations.smartRoutingWave),
              subtitle: Text(appLocalizations.smartRoutingWaveDesc),
              dialogTitle: appLocalizations.smartRoutingWave,
              options: _waveChoices,
              value: props.waveWidth,
              textBuilder: (value) =>
                  appLocalizations.smartRoutingWaveNodes(value as int),
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(waveWidth: value as int),
              ),
            ),
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.smartRoutingDetection,
          items: [
            _StringListItem(
              title: appLocalizations.smartRoutingCanariesForeign,
              desc: appLocalizations.smartRoutingCanariesForeignDesc,
              value: props.canaryForeign,
              write: (state, value) => state.copyWith(canaryForeign: value),
            ),
            _StringListItem(
              title: appLocalizations.smartRoutingCanariesDomestic,
              desc: appLocalizations.smartRoutingCanariesDomesticDesc,
              value: props.canaryDomestic,
              write: (state, value) => state.copyWith(canaryDomestic: value),
            ),
            _StringListItem(
              title: appLocalizations.smartRoutingCensor,
              desc: appLocalizations.smartRoutingCensorDesc,
              value: props.censorCountries,
              write: (state, value) => state.copyWith(censorCountries: value),
            ),
            _StringListItem(
              title: appLocalizations.smartRoutingBreakerPatterns,
              desc: appLocalizations.smartRoutingBreakerPatternsDesc,
              value: props.breakerPatterns,
              write: (state, value) => state.copyWith(breakerPatterns: value),
            ),
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.smartRoutingMarkers,
          items: [
            _MarkersItem(
              title: appLocalizations.smartRoutingMarkersOpen,
              desc: appLocalizations.smartRoutingMarkersOpenDesc,
              markers: props.openMarkers,
              domestic: false,
            ),
            _MarkersItem(
              title: appLocalizations.smartRoutingMarkersDomestic,
              desc: appLocalizations.smartRoutingMarkersDomesticDesc,
              markers: props.domesticMarkers,
              domestic: true,
            ),
          ],
        ),
        SettingSection.sliver(
          title: appLocalizations.smartRoutingRanking,
          bottom: 24,
          items: [
            DecorationListItem(
              minVerticalPadding: 8,
              title: Text(appLocalizations.smartRoutingRankOrder),
              subtitle: Text(
                [
                  appLocalizations.smartRoutingKeyVerdict,
                  appLocalizations.smartRoutingKeyMisfit,
                  appLocalizations.smartRoutingKeyEvidence,
                  appLocalizations.smartRoutingKeyBand,
                ].join(' → '),
              ),
            ),
            DecorationListItem(
              minVerticalPadding: 8,
              title: Text(appLocalizations.smartRoutingKeyBand),
              subtitle: Text(appLocalizations.smartRoutingRankingDesc),
            ),
          ],
        ),
      ]);
    } else {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: NullStatus(label: appLocalizations.smartRoutingOffHint),
          ),
        ),
      );
    }

    return CommonScaffold(
      title: appLocalizations.smartRouting,
      body: CustomScrollView(
        slivers: [...slivers, const SettingBottomInset.sliver()],
      ),
    );
  }
}

/// A marker is a URL plus the statuses that count, so it cannot ride the plain
/// string-list editor: a bare URL would silently mean "any completed exchange".
class _MarkersItem extends StatelessWidget {
  const _MarkersItem({
    required this.title,
    required this.desc,
    required this.markers,
    required this.domestic,
  });

  final String title;
  final String desc;
  final List<RcxMarker> markers;
  final bool domestic;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(title),
      subtitle: Text(
        markers.isEmpty ? desc : markers.map((marker) => marker.url).join(', '),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onPressed: () {
        showExtend(
          context,
          props: const ExtendProps(blur: false, forceFull: true),
          builder: (_) {
            return _MarkersSheet(title: title, domestic: domestic);
          },
        );
      },
    );
  }
}

/// The sheet wrapper for a marker list: the toolbar carries the add action,
/// because the body is a bare list with no title bar of its own.
class _MarkersSheet extends ConsumerStatefulWidget {
  const _MarkersSheet({required this.title, required this.domestic});

  final String title;
  final bool domestic;

  @override
  ConsumerState<_MarkersSheet> createState() => _MarkersSheetState();
}

class _MarkersSheetState extends ConsumerState<_MarkersSheet> {
  Set<String> _selection = {};

  void _deleteSelected() {
    _writeMarkers(
      ref,
      widget.domestic,
      _markerRowsOf(
        ref.read(smartRoutingSettingProvider),
        widget.domestic,
      ).where((marker) => !_selection.contains(marker.url)).toList(),
    );
    _selection = {};
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    return AdaptiveSheetScaffold(
      title: widget.title,
      actions: [
        if (selection.isNotEmpty)
          IconButtonData(
            icon: Icons.delete,
            tooltip: context.appLocalizations.delete,
            onPressed: _deleteSelected,
          )
        else
          IconButtonData(
            icon: Icons.add,
            tooltip: context.appLocalizations.add,
            onPressed: () => showMarkerDialog(context, ref, widget.domestic),
          ),
      ],
      body: _MarkersBody(
        domestic: widget.domestic,
        selection: selection,
        onSelected: (url) => setState(() {
          _selection = {..._selection}..addOrRemove(url);
        }),
      ),
    );
  }
}

List<RcxMarker> _markerRowsOf(SmartRoutingProps props, bool domestic) =>
    domestic ? props.domesticMarkers : props.openMarkers;

void _writeMarkers(WidgetRef ref, bool domestic, List<RcxMarker> next) {
  ref
      .read(smartRoutingSettingProvider.notifier)
      .update(
        (state) => domestic
            ? state.copyWith(domesticMarkers: next)
            : state.copyWith(openMarkers: next),
      );
}

Future<void> showMarkerDialog(
  BuildContext context,
  WidgetRef ref,
  bool domestic, [
  int? index,
]) async {
  final rows = _markerRowsOf(ref.read(smartRoutingSettingProvider), domestic);
  final result = await dialogs.showCommonDialog<RcxMarker>(
    child: _MarkerDialog(marker: index == null ? null : rows[index]),
  );
  if (result == null) {
    return;
  }
  final next = [...rows];
  if (index == null) {
    next.add(result);
  } else {
    next[index] = result;
  }
  _writeMarkers(ref, domestic, next);
}

/// The marker list as a bare body: the opening row already named the list, and
/// the sheet's toolbar is the only title bar.
class _MarkersBody extends ConsumerWidget {
  const _MarkersBody({
    required this.domestic,
    required this.selection,
    required this.onSelected,
  });

  final bool domestic;
  final Set<String> selection;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final rows = _markerRowsOf(
      ref.watch(smartRoutingSettingProvider),
      domestic,
    );
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverToBoxAdapter(
            child: generateSectionV3(
              items: rows.isEmpty
                  ? [
                      DecorationListItem(
                        minVerticalPadding: 8,
                        title: Text(appLocalizations.smartRoutingMarkersEmpty),
                      ),
                    ]
                  : List.generate(
                      rows.length,
                      (index) => SelectedDecorationListItem(
                        title: TooltipText(
                          text: Text(
                            rows[index].url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Text(rows[index].statuses.join(', ')),
                        isSelected: selection.contains(rows[index].url),
                        isEditing: selection.isNotEmpty,
                        onSelected: () => onSelected(rows[index].url),
                        onPressed: () => selection.isEmpty
                            ? showMarkerDialog(context, ref, domestic, index)
                            : onSelected(rows[index].url),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerDialog extends StatefulWidget {
  const _MarkerDialog({this.marker});

  final RcxMarker? marker;

  @override
  State<_MarkerDialog> createState() => _MarkerDialogState();
}

class _MarkerDialogState extends State<_MarkerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url;
  late final TextEditingController _statuses;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.marker?.url ?? '');
    _statuses = TextEditingController(
      text: (widget.marker?.statuses ?? const [204]).join(', '),
    );
  }

  @override
  void dispose() {
    _url.dispose();
    _statuses.dispose();
    super.dispose();
  }

  List<int>? _parseStatuses(String? raw) {
    final parts = (raw ?? '')
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final parsed = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 100 || value > 599) {
        return null;
      }
      parsed.add(value);
    }
    return parsed.isEmpty ? null : parsed;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.of(context).pop(
      RcxMarker(
        url: _url.text.trim(),
        statuses: _parseStatuses(_statuses.text) ?? const [204],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.smartRoutingMarkers,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextFormField(
              controller: _url,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.smartRoutingMarkerUrl,
              ),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) {
                  return appLocalizations.emptyTip(
                    appLocalizations.smartRoutingMarkerUrl,
                  );
                }
                return raw.isUrl
                    ? null
                    : appLocalizations.urlTip(
                        appLocalizations.smartRoutingMarkerUrl,
                      );
              },
            ),
            TextFormField(
              controller: _statuses,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.smartRoutingMarkerStatuses,
                hintText: appLocalizations.smartRoutingMarkerStatusesHint,
              ),
              validator: (value) => _parseStatuses(value) == null
                  ? appLocalizations.smartRoutingMarkerStatusesTip
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StringListItem extends ConsumerWidget {
  const _StringListItem({
    required this.title,
    required this.desc,
    required this.value,
    required this.write,
  });

  final String title;
  final String desc;
  final List<String> value;
  final SmartRoutingProps Function(SmartRoutingProps, List<String>) write;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecorationListItem.open(
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? desc : '${value.length} · ${value.join(', ')}',
      ),
      blur: false,
      widget: ListInputPage(title: title, items: value, titleBuilder: Text.new),
      onChanged: (items) => ref
          .read(smartRoutingSettingProvider.notifier)
          .update((state) => write(state, List<String>.from(items as List))),
    );
  }
}
