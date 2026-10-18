import 'dart:convert';

import '../compatibility/clients.dart';
import '../compatibility/metadata_adapter.dart';
import '../metadata/metadata.dart';
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

Map<String, String> encodeSubscriptionMetadata(SubscriptionMetadata metadata) =>
    {
      for (final field in subscriptionFields)
        if (metadata.fields[field.path] case final value?)
          field.header: switch (field.type) {
            SubscriptionFieldType.hosts => (value as List).join(','),
            SubscriptionFieldType.text => _encodeText(value as String),
            _ => value.toString(),
          },
    };

String _encodeText(String value) =>
    value.runes.every((r) => r >= 32 && r < 127) &&
        !value.startsWith('base64:') &&
        !value.startsWith('base64,')
    ? value
    : 'base64:${base64.encode(utf8.encode(value))}';

SubscriptionMetadataResult readSubscriptionMetadata(
  Map<String, List<String>> headers, {
  String body = '',
  SubscriptionClientPreset? clientPreset,
}) {
  final warnings = <String>[];
  final adapter = clientPreset == null
      ? null
      : subscriptionCompatibilityAdapterFor(clientPreset);
  final normalizedHeaders = _normalizeHeaders(headers);
  final lowered =
      adapter?.normalizeResponseHeaders(normalizedHeaders) ?? normalizedHeaders;
  final bodyHeaders = subscriptionBodyHeaders(
    body,
    additionalHeaders: adapter?.responseHeaderAliases.keys ?? const [],
  );
  final bodyValues =
      adapter?.normalizeResponseHeaders(bodyHeaders) ?? bodyHeaders;
  final bodyMetadata = _decodeFields(bodyValues, warnings);
  final httpMetadata = _decodeFields(
    lowered,
    warnings,
  ).merge(_commonUsage(lowered, warnings));
  return SubscriptionMetadataResult(
    metadata: bodyMetadata.merge(httpMetadata),
    source: httpMetadata.fields.isNotEmpty
        ? SubscriptionDataSource.http
        : SubscriptionDataSource.body,
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
  List<String> warnings,
) {
  final fields = <String, Object?>{};
  for (final field in subscriptionFields) {
    final values = headers[field.header.toLowerCase()];
    if (values == null) continue;
    if (values.length != 1) {
      _warning(warnings, 'Duplicate singleton: ${field.header}');
      continue;
    }
    final raw = values.single.trim();
    Object? value;
    try {
      value = switch (field.type) {
        SubscriptionFieldType.text => _decodeText(raw),
        SubscriptionFieldType.url => raw,
        SubscriptionFieldType.integer => int.tryParse(raw),
        SubscriptionFieldType.boolean => switch (raw.toLowerCase()) {
          '1' || 'true' || 'yes' => true,
          '0' || 'false' || 'no' => false,
          _ => null,
        },
        SubscriptionFieldType.hosts =>
          raw
              .split(',')
              .map((v) => v.trim())
              .where((v) => v.isNotEmpty)
              .toList(),
      };
    } on FormatException {
      value = null;
    }
    if (value == null || !validSubscriptionField(field, value)) {
      _warning(warnings, 'Invalid provider field: ${field.header}');
      continue;
    }
    fields[field.path] = value;
  }
  final supported = {for (final field in subscriptionFields) field.header};
  for (final key in headers.keys) {
    if ((key.startsWith('reclash-') || key.startsWith('flclashx-')) &&
        !supported.contains(key)) {
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

Map<String, List<String>> subscriptionBodyHeaders(
  String body, {
  Iterable<String> additionalHeaders = const [],
}) {
  final result = <String, List<String>>{};
  final names = {
    for (final field in subscriptionFields) field.header,
    ...additionalHeaders,
  };
  var used = 0;
  for (final line in const LineSplitter().convert(
    body.length > subscriptionHeadersLimit
        ? body.substring(0, subscriptionHeadersLimit)
        : body,
  )) {
    used += line.length;
    if (used > subscriptionHeadersLimit) break;
    final text = line.trim();
    if (text.isEmpty) continue;
    if (!text.startsWith('#')) break;
    final value = text.substring(1).trimLeft();
    final separator = value.indexOf(':');
    if (separator <= 0) continue;
    final name = value.substring(0, separator).trim().toLowerCase();
    if (names.contains(name)) {
      result
          .putIfAbsent(name, () => [])
          .add(value.substring(separator + 1).trim());
    }
  }
  return result;
}

void _warning(List<String> warnings, String message) {
  if (warnings.length < 32 && !warnings.contains(message)) {
    warnings.add(message);
  }
}
