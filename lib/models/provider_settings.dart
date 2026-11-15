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
      final state = ProviderSettingsState.fromJson(json);
      return state.copyWith(
        applied: _withoutBackgroundOpacity(state.applied),
        userBaseline: _withoutBackgroundOpacity(state.userBaseline),
      );
    } on Object {
      return const ProviderSettingsState();
    }
  }
}

/// The background's opacity became its own setting; a value saved together
/// with the image would otherwise read as the user's change.
Map<String, Object?> _withoutBackgroundOpacity(Map<String, Object?> values) =>
    switch (values['background']) {
      final Map<dynamic, dynamic> background
          when background.containsKey('opacity') =>
        {
          ...values,
          'background': {
            for (final MapEntry(:key, :value) in background.entries)
              if (key != 'opacity') key: value,
          },
        },
      _ => values,
    };
