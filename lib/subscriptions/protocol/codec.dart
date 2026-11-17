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
  final aliases = _aliasesEnabled(
    headers,
    warnings,
    manifest: secure && headers.containsKey('reclash-config'),
  );
  for (final field in subscriptionFields) {
    final sources = [
      if (field.header case final header?)
        (header, SubscriptionAliasFormat.plain),
      if (aliases)
        for (final alias in field.aliases) (alias.name, alias.format),
    ];
    for (final (name, format) in sources) {
      final values = headers[name];
      if (values == null) continue;
      if ((field.secure || field.type == SubscriptionFieldType.hosts) &&
          !secure) {
        _warning(warnings, 'Provider field needs an HTTPS response: $name');
        continue;
      }
      if (values.length != 1) {
        _warning(warnings, 'Duplicate singleton: $name');
        continue;
      }
      final decoded = _decodeHeader(field, format, values.single.trim());
      if (decoded == null) {
        _warning(warnings, 'Invalid provider field: $name');
        continue;
      }
      fields[field.path] = decoded.value;
      if (field.suffix case final suffix?) {
        if (decoded.count case final count?) {
          fields[suffix.path] = count;
        } else if (decoded.countInvalid) {
          _warning(warnings, 'Invalid provider field: $name');
        }
      }
      break;
    }
  }
  for (final key in headers.keys) {
    if (key.startsWith('reclash-') &&
        key != 'reclash-config' &&
        key != subscriptionAliasSwitchHeader) {
      _warning(warnings, 'Unsupported provider field: $key');
    }
  }
  return SubscriptionMetadata(Map.unmodifiable(fields));
}

/// Aliases apply by default only without a manifest pointer; a present switch
/// that is not explicitly true turns them off.
bool _aliasesEnabled(
  Map<String, List<String>> headers,
  List<String> warnings, {
  required bool manifest,
}) {
  final values = headers[subscriptionAliasSwitchHeader];
  if (values == null) return !manifest;
  final value = values.length == 1 ? values.single.trim().toLowerCase() : '';
  if (const {'1', 'true', 'yes'}.contains(value)) return true;
  if (!const {'0', 'false', 'no'}.contains(value)) {
    _warning(
      warnings,
      'Invalid provider field: $subscriptionAliasSwitchHeader',
    );
  }
  return false;
}

typedef _Decoded = ({Object value, int? count, bool countInvalid});

/// The valid value [raw] holds for [field] in [format], or null.
_Decoded? _decodeHeader(
  SubscriptionField field,
  SubscriptionAliasFormat format,
  String raw,
) {
  Object? value;
  int? count;
  var countInvalid = false;
  try {
    switch (format) {
      case SubscriptionAliasFormat.plain:
        value = _decodeStandard(field, raw);
      case SubscriptionAliasFormat.percentEncoded:
        value = _decodeText(Uri.decodeComponent(raw));
      case SubscriptionAliasFormat.urlWithNumber:
        final comma = raw.lastIndexOf(',');
        value = comma == -1 ? raw : raw.substring(0, comma).trim();
        if (comma != -1) {
          final number = int.tryParse(raw.substring(comma + 1).trim());
          final suffix = field.suffix;
          if (number != null &&
              suffix != null &&
              number >= suffix.minimum &&
              number <= suffix.maximum) {
            count = number;
          } else {
            countInvalid = true;
          }
        }
      case SubscriptionAliasFormat.hostList:
        final hosts = _decodeHosts(raw).take(field.limit).toList();
        value = hosts.isEmpty ? null : hosts;
    }
  } on FormatException {
    return null;
  } on ArgumentError {
    return null;
  }
  if (value == null || !validSubscriptionField(field, value)) return null;
  return (value: value, count: count, countInvalid: countInvalid);
}

Object? _decodeStandard(SubscriptionField field, String raw) =>
    switch (field.type) {
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

/// Each entry of a comma-separated list reduced to `host[:port]`; invalid
/// entries and repeats are dropped.
Iterable<String> _decodeHosts(String raw) {
  final seen = <String>{};
  for (final entry in raw.split(',')) {
    var item = entry.trim();
    if (item.contains('://')) {
      final uri = Uri.tryParse(item);
      if (uri == null || uri.host.isEmpty) continue;
      item = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
    } else {
      final slash = item.indexOf('/');
      if (slash != -1) item = item.substring(0, slash);
    }
    if (subscriptionAuthority(item) case final authority?) seen.add(authority);
  }
  return seen;
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
