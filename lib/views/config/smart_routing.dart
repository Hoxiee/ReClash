import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _manualHoldChoices = [0, 15, 30, 60, 240];
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

  Widget _switchItem({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(title),
      subtitle: Text(desc),
      onPressed: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _optionsItem<T>(
    BuildContext context, {
    required String title,
    required String desc,
    required List<T> options,
    required T value,
    required String Function(T value) labelOf,
    required ValueChanged<T> onChanged,
  }) {
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(title),
      subtitle: Text(desc),
      trailing: Text(
        labelOf(value),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface.opacity60,
        ),
      ),
      onPressed: () async {
        final next = await dialogs.showCommonDialog<T>(
          child: OptionsDialog<T>(
            title: title,
            options: options,
            value: value,
            textBuilder: labelOf,
          ),
        );
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }

  Widget _listItem({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String desc,
    required List<String> value,
    required SmartRoutingProps Function(SmartRoutingProps, List<String>) write,
  }) {
    return DecorationListItem(
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? desc : '${value.length} · ${value.join(', ')}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onPressed: () {
        final controller = ListEditingController(
          items: value,
          onChanged: (items) => _update(
            ref,
            (state) => write(state, List<String>.from(items)),
          ),
        );
        showExtend(
          context,
          props: const ExtendProps(blur: false),
          builder: (_) {
            return AdaptiveSheetScaffold(
              title: title,
              actions: controller.iconActions(context),
              body: ListInputBody(
                controller: controller,
                titleBuilder: Text.new,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final props = ref.watch(smartRoutingSettingProvider);
    final slivers = <Widget>[
      _section(
        items: [
          _switchItem(
            title: appLocalizations.smartRouting,
            desc: appLocalizations.smartRoutingDesc,
            value: props.enabled,
            onChanged: (value) => _handleEnabled(ref, value),
          ),
        ],
      ),
    ];

    if (props.enabled) {
      slivers.addAll([
        _section(
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
            _optionsItem<SmartRoutingPreset>(
              context,
              title: appLocalizations.smartRoutingRegion,
              desc:
                  props.matchesPreset
                      ? props.preset.label
                      : appLocalizations.smartRoutingPresetEdited(
                        props.preset.label,
                      ),
              options: SmartRoutingPreset.values,
              value: props.preset,
              labelOf: (value) => value.label,
              onChanged: (value) =>
                  _update(ref, (state) => state.applyPreset(value)),
            ),
          ],
        ),
        _section(
          title: appLocalizations.smartRoutingBehaviour,
          items: [
            _switchItem(
              title: appLocalizations.smartRoutingDomestic,
              desc: appLocalizations.smartRoutingDomesticDesc,
              value: props.allowDomesticLastResort,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(allowDomesticLastResort: value),
              ),
            ),
            _switchItem(
              title: appLocalizations.smartRoutingRequireUdp,
              desc: appLocalizations.smartRoutingRequireUdpDesc,
              value: props.requireUdp,
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(requireUdp: value)),
            ),
            _optionsItem<int>(
              context,
              title: appLocalizations.smartRoutingManualHold,
              desc: appLocalizations.smartRoutingManualHoldDesc,
              options: _manualHoldChoices,
              value: props.manualHoldMinutes,
              labelOf: (value) => _minutesLabel(context, value),
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(manualHoldMinutes: value)),
            ),
            _optionsItem<int>(
              context,
              title: appLocalizations.smartRoutingDwell,
              desc: appLocalizations.smartRoutingDwellDesc,
              options: _dwellChoices,
              value: props.dwellSeconds,
              labelOf: (value) => appLocalizations.smartRoutingSeconds(value),
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(dwellSeconds: value)),
            ),
          ],
        ),
        _section(
          title: appLocalizations.smartRoutingProbing,
          items: [
            _switchItem(
              title: appLocalizations.smartRoutingSaveData,
              desc: appLocalizations.smartRoutingSaveDataDesc,
              value: props.saveMobileData,
              onChanged: (value) => _update(
                ref,
                (state) => state.copyWith(saveMobileData: value),
              ),
            ),
            _optionsItem<int>(
              context,
              title: appLocalizations.smartRoutingWave,
              desc: appLocalizations.smartRoutingWaveDesc,
              options: _waveChoices,
              value: props.waveWidth,
              labelOf: (value) =>
                  appLocalizations.smartRoutingWaveNodes(value),
              onChanged: (value) =>
                  _update(ref, (state) => state.copyWith(waveWidth: value)),
            ),
          ],
        ),
        _section(
          title: appLocalizations.smartRoutingDetection,
          items: [
            _listItem(
              context: context,
              ref: ref,
              title: appLocalizations.smartRoutingCanariesForeign,
              desc: appLocalizations.smartRoutingCanariesForeignDesc,
              value: props.canaryForeign,
              write: (state, value) => state.copyWith(canaryForeign: value),
            ),
            _listItem(
              context: context,
              ref: ref,
              title: appLocalizations.smartRoutingCanariesDomestic,
              desc: appLocalizations.smartRoutingCanariesDomesticDesc,
              value: props.canaryDomestic,
              write: (state, value) => state.copyWith(canaryDomestic: value),
            ),
            _listItem(
              context: context,
              ref: ref,
              title: appLocalizations.smartRoutingCensor,
              desc: appLocalizations.smartRoutingCensorDesc,
              value: props.censorCountries,
              write: (state, value) => state.copyWith(censorCountries: value),
            ),
            _listItem(
              context: context,
              ref: ref,
              title: appLocalizations.smartRoutingBreakerPatterns,
              desc: appLocalizations.smartRoutingBreakerPatternsDesc,
              value: props.breakerPatterns,
              write: (state, value) => state.copyWith(breakerPatterns: value),
            ),
          ],
        ),
        _section(
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
        _section(
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
    }

    return CommonScaffold(
      title: appLocalizations.smartRouting,
      body: CustomScrollView(slivers: slivers),
    );
  }
}

Widget _section({
  required List<Widget> items,
  String? title,
  List<Widget>? actions,
  double bottom = 12,
}) {
  return SliverPadding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
    sliver: SliverToBoxAdapter(
      child: generateSectionV3(title: title, actions: actions, items: items),
    ),
  );
}

String _minutesLabel(BuildContext context, int minutes) {
  final appLocalizations = context.appLocalizations;
  return minutes == 0
      ? appLocalizations.smartRoutingManualHoldOff
      : appLocalizations.smartRoutingManualHoldMinutes(minutes);
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
        markers.isEmpty
            ? desc
            : markers.map((marker) => marker.url).join(', '),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onPressed: () {
        showExtend(
          context,
          props: const ExtendProps(blur: false),
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
class _MarkersSheet extends ConsumerWidget {
  const _MarkersSheet({required this.title, required this.domestic});

  final String title;
  final bool domestic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveSheetScaffold(
      title: title,
      actions: [
        IconButtonData(
          icon: Icons.add,
          tooltip: context.appLocalizations.add,
          onPressed: () => showMarkerDialog(context, ref, domestic),
        ),
      ],
      body: _MarkersBody(domestic: domestic),
    );
  }
}

List<RcxMarker> _markerRowsOf(SmartRoutingProps props, bool domestic) =>
    domestic ? props.domesticMarkers : props.openMarkers;

void _writeMarkers(WidgetRef ref, bool domestic, List<RcxMarker> next) {
  ref.read(smartRoutingSettingProvider.notifier).update(
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
  const _MarkersBody({required this.domestic});

  final bool domestic;

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
                        title: Text(
                          appLocalizations.smartRoutingMarkersEmpty,
                        ),
                      ),
                    ]
                  : List.generate(
                      rows.length,
                      (index) => DecorationListItem(
                        minVerticalPadding: 8,
                        title: TooltipText(
                          text: Text(
                            rows[index].url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Text(rows[index].statuses.join(', ')),
                        onPressed: () => showMarkerDialog(context, ref, domestic, index),
                        trailing: IconButton(
                          tooltip: appLocalizations.delete,
                          onPressed: () {
                            _writeMarkers(
                              ref,
                              domestic,
                              [...rows]..removeAt(index),
                            );
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
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
