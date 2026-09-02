import 'package:freezed_annotation/freezed_annotation.dart';

import 'panel_headers.dart';

part 'generated/panel_meta.freezed.dart';
part 'generated/panel_meta.g.dart';

@freezed
abstract class PanelMeta with _$PanelMeta {
  const factory PanelMeta({
    @Default(false) bool hwidMaxDevicesReached,
    @Default(false) bool hwidNotSupported,
    String? announce,
    String? supportUrl,
    int? updateIntervalMinutes,
  }) = _PanelMeta;

  factory PanelMeta.fromJson(Map<String, Object?> json) =>
      _$PanelMetaFromJson(json);

  factory PanelMeta.fromHeaders(Map<String, List<String>> headers) {
    final map = normalizePanelHeaders(headers);
    if (map.isEmpty) return const PanelMeta();
    final interval = int.tryParse(map['updateIntervalMinutes'] ?? '');
    return PanelMeta(
      hwidMaxDevicesReached:
          map['hwidMaxDevicesReached']?.toLowerCase() == 'true',
      hwidNotSupported: map['hwidNotSupported']?.toLowerCase() == 'true',
      announce: map['announce'],
      supportUrl: map['supportUrl'],
      updateIntervalMinutes:
          interval != null && interval > 0 ? interval : null,
    );
  }
}

extension PanelMetaExt on PanelMeta {
  bool get hasContent =>
      hwidMaxDevicesReached ||
      hwidNotSupported ||
      announce != null ||
      supportUrl != null ||
      updateIntervalMinutes != null;
}
