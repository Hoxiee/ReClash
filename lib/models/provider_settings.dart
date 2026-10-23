import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/provider_settings.freezed.dart';
part 'generated/provider_settings.g.dart';

/// Values are kept in their JSON form, so a setting the user changed is one
/// whose value no longer equals what the provider last wrote.
@freezed
abstract class ProviderSettingsState with _$ProviderSettingsState {
  const factory ProviderSettingsState({
    @Default({}) Map<String, Object?> applied,
    @Default({}) Map<String, Object?> userBaseline,
    @Default({}) Set<String> userOwned,
  }) = _ProviderSettingsState;

  factory ProviderSettingsState.fromJson(Map<String, Object?> json) =>
      _$ProviderSettingsStateFromJson(json);

  static ProviderSettingsState safeFromJson(Map<String, Object?>? json) {
    if (json == null) return const ProviderSettingsState();
    try {
      return ProviderSettingsState.fromJson(json);
    } on Object {
      return const ProviderSettingsState();
    }
  }
}
