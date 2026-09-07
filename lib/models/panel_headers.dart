import 'dart:convert';

class _PanelHeaderConverter {
  const _PanelHeaderConverter({
    required this.sourceKeys,
    required this.canonicalKey,
    this.convertValue,
  });

  /// Wire keys in priority order, lower case: the first one present in a
  /// response wins, so the reclash-* namespace outranks compatibility keys.
  final List<String> sourceKeys;

  final String canonicalKey;
  final String Function(String value)? convertValue;
}

String _hoursToMinutes(String value) {
  final hours = int.tryParse(value.trim());
  if (hours == null || hours <= 0) return '';
  return '${hours * 60}';
}

final _base64Payload = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');

/// Panels may base64 their strings because HTTP headers cannot carry Cyrillic
/// or emoji. Unprefixed values decode only when long enough and yielding
/// printable text, so plain names like `Kiwi` are not mistaken for payloads.
String _decodeBase64Header(String value) {
  final prefixed = value.startsWith('base64,') || value.startsWith('base64:');
  final payload = prefixed ? value.substring(7).trim() : value;
  if (payload.isEmpty) return value;
  if (!prefixed &&
      (payload.length < _minUnprefixedBase64 ||
          payload.length % 4 != 0 ||
          !_base64Payload.hasMatch(payload))) {
    return value;
  }
  try {
    final decoded = utf8.decode(base64.decode(base64.normalize(payload)));
    if (!prefixed && _hasControlChars(decoded)) return value;
    return decoded;
  } catch (_) {
    return value;
  }
}

const _minUnprefixedBase64 = 8;

bool _hasControlChars(String value) => value.runes.any(
  (rune) => rune < 0x20 && rune != 0x09 && rune != 0x0a && rune != 0x0d,
);

const _panelHeaderConverters = <_PanelHeaderConverter>[
  _PanelHeaderConverter(
    sourceKeys: ['x-hwid-max-devices-reached'],
    canonicalKey: 'hwidMaxDevicesReached',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['x-hwid-not-supported'],
    canonicalKey: 'hwidNotSupported',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-announce', 'announce'],
    canonicalKey: 'announce',
    convertValue: _decodeBase64Header,
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-supporturl', 'support-url', 'flclashx-supporturl'],
    canonicalKey: 'supportUrl',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-autoupdateinterval'],
    canonicalKey: 'updateIntervalMinutes',
  ),
  // The compatibility header counts hours, ours counts minutes.
  _PanelHeaderConverter(
    sourceKeys: ['profile-update-interval', 'flclashx-autoupdateinterval'],
    canonicalKey: 'updateIntervalMinutes',
    convertValue: _hoursToMinutes,
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-servicename', 'flclashx-servicename'],
    canonicalKey: 'serviceName',
    convertValue: _decodeBase64Header,
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-servicelogo', 'flclashx-servicelogo'],
    canonicalKey: 'serviceLogo',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-serverinfo', 'flclashx-serverinfo'],
    canonicalKey: 'serverInfoGroup',
    convertValue: _decodeBase64Header,
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-buyplan', 'flclashx-buyplan'],
    canonicalKey: 'buyPlanUrl',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-buytraffic', 'flclashx-buytraffic'],
    canonicalKey: 'buyTrafficUrl',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-view', 'flclashx-view'],
    canonicalKey: 'proxiesView',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-hex', 'flclashx-hex'],
    canonicalKey: 'themeHex',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-background', 'flclashx-background'],
    canonicalKey: 'background',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-heroring'],
    canonicalKey: 'heroRing',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-widgets'],
    canonicalKey: 'panelWidgets',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-custom'],
    canonicalKey: 'widgetsApplyMode',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-settings'],
    canonicalKey: 'panelSettings',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-newdomain', 'flclashx-newdomain'],
    canonicalKey: 'newDomain',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-fallbackhosts'],
    canonicalKey: 'fallbackHosts',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['profile-title'],
    canonicalKey: 'profileTitle',
  ),
];

Map<String, String> normalizePanelHeaders(Map<String, List<String>> headers) {
  final raw = <String, String>{
    for (final entry in headers.entries)
      entry.key.toLowerCase(): entry.value.join(',').trim(),
  };
  if (raw.isEmpty) return const {};
  final result = <String, String>{};
  for (final converter in _panelHeaderConverters) {
    if (result.containsKey(converter.canonicalKey)) continue;
    for (final key in converter.sourceKeys) {
      final value = raw[key];
      if (value == null || value.isEmpty) continue;
      final converted = converter.convertValue?.call(value) ?? value;
      if (converted.isEmpty) continue;
      result[converter.canonicalKey] = converted;
      break;
    }
  }
  return result;
}
