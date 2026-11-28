import 'dart:convert';

import '../config/xray_security.dart';

({Map<String, Object?> options, bool hasLosses}) convertXhttpOptions({
  String path = '',
  String host = '',
  String mode = '',
  Object? extra,
}) {
  final conversion = _XhttpConversion();
  if (extra is String && extra.isNotEmpty) {
    try {
      extra = jsonDecode(extra);
      if (extra == null) conversion.hasLosses = true;
    } on FormatException {
      conversion.hasLosses = true;
      extra = null;
    }
  } else if (extra == '') {
    extra = null;
  }
  final fields = conversion.map(extra);
  final options = <String, Object?>{
    if (path.isNotEmpty) 'path': path,
    if (host.isNotEmpty) 'host': host,
    if (mode.isNotEmpty) 'mode': mode,
    if (fields != null) ...conversion.extra(fields),
  };
  return (options: options, hasLosses: conversion.hasLosses);
}

const _extraKeys = {
  'path': 'path',
  'host': 'host',
  'mode': 'mode',
  'scMaxEachPostBytes': 'sc-max-each-post-bytes',
  'scMinPostsIntervalMs': 'sc-min-posts-interval-ms',
  'xPaddingBytes': 'x-padding-bytes',
  'xPaddingObfsMode': 'x-padding-obfs-mode',
  'xPaddingKey': 'x-padding-key',
  'xPaddingHeader': 'x-padding-header',
  'xPaddingPlacement': 'x-padding-placement',
  'xPaddingMethod': 'x-padding-method',
  'uplinkHTTPMethod': 'uplink-http-method',
  'uplinkDataPlacement': 'uplink-data-placement',
  'uplinkDataKey': 'uplink-data-key',
  'uplinkChunkSize': 'uplink-chunk-size',
  'sessionIDPlacement': 'session-placement',
  'sessionIDKey': 'session-key',
  'sessionIDTable': 'session-table',
  'sessionIDLength': 'session-length',
  'seqPlacement': 'seq-placement',
  'seqKey': 'seq-key',
  'noGRPCHeader': 'no-grpc-header',
  'sessionPlacement': 'session-placement',
  'sessionKey': 'session-key',
};

const _reuseKeys = {
  'maxConcurrency': 'max-concurrency',
  'maxConnections': 'max-connections',
  'cMaxReuseTimes': 'c-max-reuse-times',
  'hMaxRequestTimes': 'h-max-request-times',
  'hMaxReusableSecs': 'h-max-reusable-secs',
};

class _XhttpConversion {
  bool hasLosses = false;

  Map<String, Object?>? map(Object? value) {
    if (value == null) return null;
    if (value is Map<String, Object?>) return value;
    hasLosses = true;
    return null;
  }

  void checkKeys(Map<String, Object?> source, Set<String> keys) {
    if (source.entries.any(
      (entry) => entry.value != null && !keys.contains(entry.key),
    )) {
      hasLosses = true;
    }
  }

  Map<String, Object?> scalars(
    Map<String, Object?> source,
    Map<String, String> keys,
  ) {
    final result = <String, Object?>{};
    for (final entry in keys.entries) {
      final value = source[entry.key];
      if (value == null || value == '') continue;
      if (value is bool || value is String || value is num) {
        result.putIfAbsent(
          entry.value,
          () => value is bool ? value : value.toString(),
        );
      } else {
        hasLosses = true;
      }
    }
    return result;
  }

  Map<String, Object?> headers(Object? value) {
    final source = map(value);
    if (source == null) return const {};
    final result = <String, Object?>{};
    for (final entry in source.entries) {
      if (entry.value is String) {
        result[entry.key] = entry.value;
      } else {
        hasLosses = true;
      }
    }
    return result;
  }

  Map<String, Object?> reuse(Object? value) {
    final source = map(value);
    if (source == null) return const {};
    checkKeys(source, {..._reuseKeys.keys, 'hKeepAlivePeriod'});
    final result = scalars(source, _reuseKeys);
    final period = source['hKeepAlivePeriod'];
    if (period is int) {
      result['h-keep-alive-period'] = period;
    } else if (period != null) {
      hasLosses = true;
    }
    return result;
  }

  Map<String, Object?> extra(Map<String, Object?> source) {
    checkKeys(source, {
      ..._extraKeys.keys,
      'headers',
      'xmux',
      'downloadSettings',
    });
    final result = scalars(source, _extraKeys);
    final headerValues = headers(source['headers']);
    if (headerValues.isNotEmpty) result['headers'] = headerValues;
    if (!_sessionIdsSafe(source)) {
      result.remove('session-table');
      result.remove('session-length');
      hasLosses = true;
    }
    final reuseSettings = reuse(source['xmux']);
    if (reuseSettings.isNotEmpty) result['reuse-settings'] = reuseSettings;
    final downloadSource = map(source['downloadSettings']);
    if (downloadSource != null) {
      final settings = download(downloadSource);
      if (settings.isNotEmpty) result['download-settings'] = settings;
    }
    return result;
  }

  Map<String, Object?> download(Map<String, Object?> source) {
    checkKeys(source, {
      'address',
      'port',
      'network',
      'security',
      'tlsSettings',
      'realitySettings',
      'xhttpSettings',
      'splithttpSettings',
    });
    final result = scalars(source, const {'address': 'server'});
    final port = source['port'];
    if (port is int && port > 0 && port <= 65535) {
      result['port'] = port;
    } else if (port != null) {
      hasLosses = true;
    }
    final network = source['network'];
    if (network != null && network != 'xhttp' && network != 'splithttp') {
      hasLosses = true;
    }
    final security = source['security'] ?? 'none';
    final downloadTls = map(source['tlsSettings']);
    if (security == 'reality' &&
        !xrayRealityValid(map(source['realitySettings']))) {
      hasLosses = true;
      return const {};
    }
    if (!xrayEchConfigValid(downloadTls?['echConfigList'])) {
      hasLosses = true;
      return const {};
    }
    if (security == 'tls' || security == 'reality') {
      result['tls'] = true;
      if (applyXraySecurity(result, source, type: 'vless')) hasLosses = true;
      final reality = map(source['realitySettings']);
      if (security == 'tls' && reality != null) hasLosses = true;
      if (security == 'tls') {
        result['reality-opts'] = <String, Object?>{'public-key': ''};
      }
    } else if (security == 'none') {
      result['tls'] = false;
      result['reality-opts'] = <String, Object?>{'public-key': ''};
    } else if (source['tlsSettings'] != null ||
        source['realitySettings'] != null) {
      hasLosses = true;
    }
    // Core falls back to the proxy's skip-cert-verify when the download block
    // leaves it nil. Xray's download leg is configured separately, so make
    // its verification choice explicit even when it is the safe default.
    result['skip-cert-verify'] = downloadTls?['allowInsecure'] == true;
    final xhttp = map(source['xhttpSettings'] ?? source['splithttpSettings']);
    if (xhttp != null) {
      checkKeys(xhttp, {'path', 'host', 'headers', 'extra'});
      result.addAll(scalars(xhttp, const {'path': 'path', 'host': 'host'}));
      for (final key in ['path', 'host']) {
        if (xhttp[key] == '') result[key] = '';
      }
      final headerValues = headers(xhttp['headers']);
      if (headerValues.isNotEmpty || xhttp['headers'] is Map) {
        result['headers'] = headerValues;
      }
      final extra = map(xhttp['extra']);
      if (extra != null) {
        checkKeys(extra, {'xmux'});
        final reuseSettings = reuse(extra['xmux']);
        if (reuseSettings.isNotEmpty) result['reuse-settings'] = reuseSettings;
      }
    }
    return result;
  }
}

/// Whether Core can build session IDs from [table] and [length].
///
/// Core rejects a session table that is not ASCII, a malformed range, or a
/// range too small to make enough IDs, and that rejection fails the whole
/// profile. The importer drops the fields instead and records a loss.
bool xhttpSessionIdsSafe(Object? table, Object? length) =>
    _sessionIdsSafe({'sessionIDTable': table, 'sessionIDLength': length});

bool _sessionIdsSafe(Map<String, Object?> extra) {
  final table = extra['sessionIDTable']?.toString();
  if (table == null || table.isEmpty || table == 'uuid') return true;
  if (table.length > 4096) return false;
  if (!table.codeUnits.every((unit) => unit < 0x80)) return false;
  final range = _parseSessionRange(extra['sessionIDLength']?.toString());
  if (range == null) return false;
  final (min, max) = range;
  if (min <= 0) return false;
  final base = table.length;
  if (base >= 2 && max >= 31) return true;
  if (base <= 1) return max - min + 1 >= 2147483648;
  final bigBase = BigInt.from(base);
  var room = BigInt.zero;
  for (var k = min; k <= max; k++) {
    room += bigBase.pow(k);
  }
  return room.compareTo(BigInt.from(2) << 30) >= 0;
}

(int, int)? _parseSessionRange(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return (16, 32);
  final parts = text.split('-');
  if (parts.length == 1) {
    final v = int.tryParse(parts[0]);
    if (v == null || v < 0 || v > 4096) return null;
    return (v, v);
  }
  if (parts.length != 2) return null;
  final min = int.tryParse(parts[0].trim());
  final max = int.tryParse(parts[1].trim());
  if (min == null || max == null || min < 0 || max < min) return null;
  // Core's roomSize() expands every length in the range before it gives up.
  // Keep an untrusted subscription from making config load run for minutes.
  if (max > 4096) return null;
  return (min, max);
}
