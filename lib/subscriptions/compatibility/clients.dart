import 'import_policy.dart';

enum SubscriptionClientPreset {
  auto,
  reclash,
  flClashX,
  clashMeta,
  clash,
  happ,
  incy,
  singbox,
  v2rayng,
  custom,
}

const subscriptionClientPresetOrder = [
  SubscriptionClientPreset.reclash,
  SubscriptionClientPreset.flClashX,
  SubscriptionClientPreset.clashMeta,
  SubscriptionClientPreset.clash,
  SubscriptionClientPreset.happ,
  SubscriptionClientPreset.incy,
  SubscriptionClientPreset.singbox,
  SubscriptionClientPreset.v2rayng,
];

Map<String, String> subscriptionClientRequestHeaders(
  SubscriptionClientPreset preset, {
  required String defaultUserAgent,
  String customUserAgent = '',
  String? locale,
}) {
  final headers = <String, String>{
    'User-Agent': switch (preset) {
      SubscriptionClientPreset.auto => defaultUserAgent,
      SubscriptionClientPreset.reclash => defaultUserAgent,
      SubscriptionClientPreset.flClashX => 'FlClashX/0.4.2',
      SubscriptionClientPreset.clashMeta => 'ClashMetaForAndroid/2.11.7.Meta',
      SubscriptionClientPreset.clash => 'ClashForAndroid/2.5.12',
      SubscriptionClientPreset.happ => 'Happ/4.6.0',
      SubscriptionClientPreset.incy => 'INCY/3.3.1',
      SubscriptionClientPreset.singbox => 'Karing/1.0.0',
      SubscriptionClientPreset.v2rayng => 'v2rayNG/1.9.24',
      SubscriptionClientPreset.custom => _validatedCustomSubscriptionUserAgent(
        customUserAgent,
      ),
    },
    if (preset == SubscriptionClientPreset.incy) ...{
      'x-client': 'INCY',
      'x-app-version': '3.3.1',
      if (locale != null && locale.isNotEmpty) ...{
        'x-device-locale': locale,
        'Accept-Language': locale,
      },
    },
  };
  return Map.unmodifiable(headers);
}

String? validateCustomSubscriptionUserAgent(String value) {
  final userAgent = value.trim();
  if (userAgent.isEmpty) return 'empty';
  if (value.length > 512) return 'tooLong';
  if (value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
    return 'controlCharacter';
  }
  return null;
}

String _validatedCustomSubscriptionUserAgent(String value) {
  final reason = validateCustomSubscriptionUserAgent(value);
  if (reason != null) {
    throw const FormatException('Invalid subscription User-Agent');
  }
  return value.trim();
}

class SubscriptionClientSettings {
  const SubscriptionClientSettings({
    this.preset = SubscriptionClientPreset.reclash,
    this.customUserAgent = '',
    this.importPolicy = const SubscriptionImportPolicy(),
  });

  const SubscriptionClientSettings.forNewProfile()
    : preset = SubscriptionClientPreset.auto,
      customUserAgent = '',
      importPolicy = const SubscriptionImportPolicy();

  final SubscriptionClientPreset preset;
  final String customUserAgent;
  final SubscriptionImportPolicy importPolicy;

  SubscriptionClientSettings copyWith({
    SubscriptionClientPreset? preset,
    String? customUserAgent,
    SubscriptionImportPolicy? importPolicy,
  }) => SubscriptionClientSettings(
    preset: preset ?? this.preset,
    customUserAgent: customUserAgent ?? this.customUserAgent,
    importPolicy: importPolicy ?? this.importPolicy,
  );

  bool get isValid =>
      preset != SubscriptionClientPreset.custom ||
      validateCustomSubscriptionUserAgent(customUserAgent) == null;

  Map<String, Object?> toJson() => {
    'preset': preset.name,
    'customUserAgent': customUserAgent,
    'importPolicy': importPolicy.toJson(),
  };

  static SubscriptionClientSettings safeFromJson(Object? value) {
    if (value is! Map) return const SubscriptionClientSettings();
    final presetName = value['preset'];
    final customUserAgent = value['customUserAgent'];
    if (presetName is! String ||
        customUserAgent != null && customUserAgent is! String) {
      return const SubscriptionClientSettings();
    }
    final preset = SubscriptionClientPreset.values
        .cast<SubscriptionClientPreset?>()
        .firstWhere((item) => item?.name == presetName, orElse: () => null);
    if (preset == null ||
        customUserAgent is String && customUserAgent.length > 512) {
      return const SubscriptionClientSettings();
    }
    return SubscriptionClientSettings(
      preset: preset,
      customUserAgent: customUserAgent as String? ?? '',
      importPolicy: SubscriptionImportPolicy.safeFromJson(
        value['importPolicy'],
      ),
    );
  }
}
