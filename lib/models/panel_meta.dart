import 'package:freezed_annotation/freezed_annotation.dart';

import 'panel_headers.dart';

part 'generated/panel_meta.freezed.dart';
part 'generated/panel_meta.g.dart';

enum PanelWidgetsApplyMode { add, update }

/// Descending, de-duplicated positive thresholds from a comma list; null when
/// the header carries nothing usable so callers fall back to their defaults.
List<int>? _parseIntList(String? raw, {required int max}) {
  if (raw == null || raw.isEmpty) return null;
  final values = <int>{};
  for (final part in raw.split(',')) {
    final value = int.tryParse(part.trim());
    if (value != null && value > 0 && value <= max) values.add(value);
  }
  if (values.isEmpty) return null;
  return values.toList()..sort((a, b) => b.compareTo(a));
}

@freezed
abstract class PanelMeta with _$PanelMeta {
  const factory PanelMeta({
    @Default(false) bool hwidMaxDevicesReached,
    @Default(false) bool hwidNotSupported,
    String? announce,
    String? announceUrl,
    String? webPageUrl,
    String? supportUrl,
    String? reportUrl,
    List<int>? expireNotifyDays,
    List<int>? trafficNotifyPercent,
    int? updateIntervalMinutes,
    String? serviceName,
    String? serviceLogo,
    String? serverInfoGroup,
    String? buyPlanUrl,
    String? buyTrafficUrl,
    List<String>? widgets,
    @Default(PanelWidgetsApplyMode.add) PanelWidgetsApplyMode widgetsApplyMode,
    List<String>? settings,
    String? newDomain,
    String? profileTitle,
    String? accountUsername,
    String? proxiesView,
    String? themeHex,
    String? background,
    String? heroRing,
    String? heroEffect,
    String? activeText,
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
    final expireNotifyDays = _parseIntList(map['expireNotifyDays'], max: 3650);
    final trafficNotifyPercent = _parseIntList(
      map['trafficNotifyPercent'],
      max: 100,
    );
    return PanelMeta(
      hwidMaxDevicesReached:
          map['hwidMaxDevicesReached']?.toLowerCase() == 'true',
      hwidNotSupported: map['hwidNotSupported']?.toLowerCase() == 'true',
      announce: map['announce'],
      announceUrl: map['announceUrl'],
      webPageUrl: map['webPageUrl'],
      supportUrl: map['supportUrl'],
      reportUrl: map['reportUrl'],
      expireNotifyDays: expireNotifyDays,
      trafficNotifyPercent: trafficNotifyPercent,
      updateIntervalMinutes: interval != null && interval > 0 ? interval : null,
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
      newDomain: map['newDomain'],
      profileTitle: map['profileTitle'],
      accountUsername: map['accountUsername'],
      proxiesView: map['proxiesView'],
      themeHex: map['themeHex'],
      background: map['background'],
      heroRing: map['heroRing'],
      heroEffect: map['heroEffect'],
      activeText: map['activeText'],
    );
  }
}

extension PanelMetaExt on PanelMeta {
  bool get explainsUndialableNodes => hwidMaxDevicesReached || hwidNotSupported;

  bool get hasContent =>
      hwidMaxDevicesReached ||
      hwidNotSupported ||
      announce != null ||
      announceUrl != null ||
      webPageUrl != null ||
      supportUrl != null ||
      reportUrl != null ||
      expireNotifyDays != null ||
      trafficNotifyPercent != null ||
      updateIntervalMinutes != null ||
      serviceName != null ||
      serviceLogo != null ||
      serverInfoGroup != null ||
      buyPlanUrl != null ||
      buyTrafficUrl != null ||
      widgets != null ||
      newDomain != null ||
      profileTitle != null ||
      accountUsername != null ||
      proxiesView != null ||
      themeHex != null ||
      background != null ||
      heroRing != null ||
      heroEffect != null ||
      activeText != null ||
      settings != null;
}
