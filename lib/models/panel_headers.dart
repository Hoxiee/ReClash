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
  ),
  _PanelHeaderConverter(
    sourceKeys: [
      'reclash-supporturl',
      'support-url',
      'flclashx-supporturl',
    ],
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
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-servicelogo', 'flclashx-servicelogo'],
    canonicalKey: 'serviceLogo',
  ),
  _PanelHeaderConverter(
    sourceKeys: ['reclash-serverinfo', 'flclashx-serverinfo'],
    canonicalKey: 'serverInfoGroup',
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
