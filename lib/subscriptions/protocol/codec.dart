import 'dart:convert';

import '../metadata/metadata.dart';
import '../metadata/provider_config.dart';
import 'registry.dart';

class SubscriptionMetadataResult {
  const SubscriptionMetadataResult({
    required this.metadata,
    required this.source,
    this.deviceStatus,
    this.warnings = const [],
  });
  final SubscriptionMetadata metadata;
  final SubscriptionDataSource source;
  final SubscriptionDeviceStatus? deviceStatus;
  final List<String> warnings;
}

/// Lays the manifest's fields over the standard headers' fallbacks, then adds
/// the config's own package lists. A missing manifest leaves only the headers.
SubscriptionMetadataResult withManifest(
  SubscriptionMetadataResult headers,
  ProviderConfig? manifest, {
  required List<String> excluded,
  required List<String> included,
}) => withConfigPackages(
  SubscriptionMetadataResult(
    metadata: headers.metadata.merge(
      SubscriptionMetadata(manifest?.fields ?? const {}),
    ),
    source: headers.source,
    deviceStatus: headers.deviceStatus,
    warnings: headers.warnings,
  ),
  excluded: excluded,
  included: included,
);

/// Adds a Clash config's own `tun` package lists to what the headers sent.
SubscriptionMetadataResult withConfigPackages(
  SubscriptionMetadataResult result, {
  required List<String> excluded,
  required List<String> included,
}) {
  if (excluded.isEmpty && included.isEmpty) return result;
  final metadata = result.metadata;
  List<String> union(String path, List<String> extra) {
    final limit = subscriptionFields.firstWhere((f) => f.path == path).limit;
    return {...metadata.strings(path), ...extra}.take(limit).toList();
  }

  return SubscriptionMetadataResult(
    metadata: SubscriptionMetadata(
      Map.unmodifiable({
        ...metadata.fields,
        if (excluded.isNotEmpty)
          'apps.exclude': union('apps.exclude', excluded),
        if (included.isNotEmpty)
          'apps.include': union('apps.include', included),
      }),
    ),
    source: result.source,
    deviceStatus: result.deviceStatus,
    warnings: result.warnings,
  );
}

SubscriptionMetadataResult readSubscriptionMetadata(
  Map<String, List<String>> headers, {
  bool secure = false,
}) {
  final warnings = <String>[];
  final lowered = _normalizeHeaders(headers);
  return SubscriptionMetadataResult(
    metadata: _decodeFields(
      lowered,
      warnings,
      secure: secure,
    ).merge(_commonUsage(lowered, warnings)),
    source: SubscriptionDataSource.http,
    deviceStatus: _deviceStatus(lowered),
    warnings: List.unmodifiable(warnings),
  );
}

Map<String, List<String>> _normalizeHeaders(Map<String, List<String>> headers) {
  final lowered = <String, List<String>>{};
  var total = 0;
  for (final MapEntry(:key, :value) in headers.entries) {
    total += utf8.encode(key).length;
    for (final item in value) {
      final length = utf8.encode(item).length;
      total += length + 4;
      if (length > subscriptionHeaderLimit ||
          total > subscriptionHeadersLimit) {
        throw const FormatException('Response headers exceed limit');
      }
    }
    lowered.putIfAbsent(key.toLowerCase(), () => []).addAll(value);
  }
  return lowered;
}

SubscriptionMetadata _decodeFields(
  Map<String, List<String>> headers,
  List<String> warnings, {
  required bool secure,
}) {
  final fields = <String, Object?>{};
  for (final field in subscriptionFields) {
    final name = field.header;
    if (name == null) continue;
    final values = headers[name];
    if (values == null) continue;
    if (field.secure && !secure) {
      _warning(warnings, 'Provider field needs an HTTPS response: $name');
      continue;
    }
    if (values.length != 1) {
      _warning(warnings, 'Duplicate singleton: $name');
      continue;
    }
    final raw = values.single.trim();
    Object? value;
    try {
      value = switch (field.type) {
        SubscriptionFieldType.text => _decodeText(raw),
        SubscriptionFieldType.url => raw,
        SubscriptionFieldType.integer => switch (int.tryParse(raw)) {
          final count? => count * field.headerScale,
          null => null,
        },
        SubscriptionFieldType.boolean => switch (raw.toLowerCase()) {
          '1' || 'true' || 'yes' => true,
          '0' || 'false' || 'no' => false,
          _ => null,
        },
        _ => null,
      };
    } on FormatException {
      value = null;
    }
    if (value == null || !validSubscriptionField(field, value)) {
      _warning(warnings, 'Invalid provider field: $name');
      continue;
    }
    fields[field.path] = value;
  }
  for (final key in headers.keys) {
    if (key.startsWith('reclash-') && key != 'reclash-config') {
      _warning(warnings, 'Unsupported provider field: $key');
    }
  }
  return SubscriptionMetadata(Map.unmodifiable(fields));
}

String _decodeText(String value) {
  if (!value.startsWith('base64:') && !value.startsWith('base64,')) {
    return value;
  }
  return utf8.decode(base64.decode(base64.normalize(value.substring(7))));
}

SubscriptionDeviceStatus? _deviceStatus(Map<String, List<String>> headers) {
  bool flag(String key) {
    final values = headers[key];
    return values != null &&
        values.length == 1 &&
        const {'1', 'true', 'yes'}.contains(values.single.trim().toLowerCase());
  }

  if (flag('x-hwid-max-devices-reached')) {
    return SubscriptionDeviceStatus.limitReached;
  }
  if (flag('x-hwid-not-supported')) return SubscriptionDeviceStatus.unsupported;
  return null;
}

SubscriptionMetadata _commonUsage(
  Map<String, List<String>> headers,
  List<String> warnings,
) {
  final values = headers['subscription-userinfo'];
  if (values == null) return const SubscriptionMetadata();
  if (values.length != 1) {
    _warning(warnings, 'Duplicate usage singleton');
    return const SubscriptionMetadata();
  }
  final fields = <String, Object?>{};
  final repeated = <String>{};
  for (final part in values.single.split(';')) {
    final pair = part.trim().split('=');
    if (pair.length != 2 ||
        !const {
          'upload',
          'download',
          'total',
          'expire',
        }.contains(pair.first.toLowerCase())) {
      continue;
    }
    final key = 'subscription.${pair.first.toLowerCase()}';
    if (fields.containsKey(key)) {
      repeated.add(key);
      continue;
    }
    final count = num.tryParse(pair.last.trim());
    final maximum = key == 'subscription.expire'
        ? 8640000000000
        : 9007199254740991;
    if (count == null || !count.isFinite || count < 0 || count > maximum) {
      continue;
    }
    fields[key] = count.toInt();
  }
  for (final key in repeated) {
    fields.remove(key);
  }
  if (fields.containsKey('subscription.total')) {
    fields['subscription.unlimited'] = fields['subscription.total'] == 0;
  }
  if (fields.containsKey('subscription.expire')) {
    fields['subscription.perpetual'] = fields['subscription.expire'] == 0;
  }
  return SubscriptionMetadata(Map.unmodifiable(fields));
}

void _warning(List<String> warnings, String message) {
  if (warnings.length < 32 && !warnings.contains(message)) {
    warnings.add(message);
  }
}
