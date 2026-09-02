import 'package:freezed_annotation/freezed_annotation.dart';

import 'panel_headers.dart';

part 'generated/panel_meta.freezed.dart';
part 'generated/panel_meta.g.dart';

enum PanelWidgetsApplyMode { add, update }

@freezed
abstract class PanelMeta with _$PanelMeta {
  const factory PanelMeta({
    @Default(false) bool hwidMaxDevicesReached,
    @Default(false) bool hwidNotSupported,
    String? announce,
    String? supportUrl,
    int? updateIntervalMinutes,
    String? serviceName,
    String? serviceLogo,
    String? serverInfoGroup,
    String? buyPlanUrl,
    String? buyTrafficUrl,
    List<String>? widgets,
    @Default(PanelWidgetsApplyMode.add) PanelWidgetsApplyMode widgetsApplyMode,
    List<String>? settings,
  }) = _PanelMeta;

  factory PanelMeta.fromJson(Map<String, Object?> json) =>
      _$PanelMetaFromJson(json);

  factory PanelMeta.fromHeaders(Map<String, List<String>> headers) {
    final map = normalizePanelHeaders(headers);
    if (map.isEmpty) return const PanelMeta();
    final interval = int.tryParse(map['updateIntervalMinutes'] ?? '');
    final widgets = (map['panelWidgets'] ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final settings = (map['panelSettings'] ?? '')
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList();
    return PanelMeta(
      hwidMaxDevicesReached:
          map['hwidMaxDevicesReached']?.toLowerCase() == 'true',
      hwidNotSupported: map['hwidNotSupported']?.toLowerCase() == 'true',
      announce: map['announce'],
      supportUrl: map['supportUrl'],
      updateIntervalMinutes:
          interval != null && interval > 0 ? interval : null,
      serviceName: map['serviceName'],
      serviceLogo: map['serviceLogo'],
      serverInfoGroup: map['serverInfoGroup'],
      buyPlanUrl: map['buyPlanUrl'],
      buyTrafficUrl: map['buyTrafficUrl'],
      widgets: widgets.isNotEmpty ? widgets : null,
      widgetsApplyMode: map['widgetsApplyMode'] == 'update'
          ? PanelWidgetsApplyMode.update
          : PanelWidgetsApplyMode.add,
      settings: settings.isNotEmpty ? settings : null,
    );
  }
}

extension PanelMetaExt on PanelMeta {
  bool get hasContent =>
      hwidMaxDevicesReached ||
      hwidNotSupported ||
      announce != null ||
      supportUrl != null ||
      updateIntervalMinutes != null ||
      serviceName != null ||
      serviceLogo != null ||
      serverInfoGroup != null ||
      buyPlanUrl != null ||
      buyTrafficUrl != null ||
      widgets != null ||
      settings != null;
}
