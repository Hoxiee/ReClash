import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

const _githubHosts = {'github.com', 'www.github.com'};
const _githubRawHost = 'raw.githubusercontent.com';
const _githubFileMarkers = {'blob', 'raw'};

const maxFallbackHosts = 4;

const _sensitiveSubscriptionHeaders = {
  'authorization',
  'cookie',
  'proxy-authorization',
  'user-agent',
  'x-api-key',
  'x-app-version',
  'x-client',
  'x-device-locale',
  'x-device-model',
  'x-device-os',
  'x-hwid',
  'x-ver-os',
};

final _hostname = RegExp(
  r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$',
);

/// A blob link serves GitHub's HTML viewer, which no parser accepts.
String normalizeSubscriptionUrl(String url) {
  final trimmed = url.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !_githubHosts.contains(uri.host.toLowerCase())) {
    return trimmed;
  }
  final segments = uri.pathSegments;
  if (segments.length < 5 || !_githubFileMarkers.contains(segments[2])) {
    return trimmed;
  }
  return uri
      .replace(
        scheme: 'https',
        host: _githubRawHost,
        pathSegments: [segments[0], segments[1], ...segments.skip(3)],
      )
      .toString();
}

String? subscriptionDomainCandidate(String url, String? newDomain) {
  final source = Uri.tryParse(url);
  final authority = newDomain?.trim();
  if (source == null ||
      authority == null ||
      authority.isEmpty ||
      (source.scheme != 'http' && source.scheme != 'https') ||
      source.host.isEmpty ||
      source.userInfo.isNotEmpty ||
      authority.contains(RegExp(r'[\s/@?#]')) ||
      authority.contains('://')) {
    return null;
  }

  final parsed = Uri.tryParse('${source.scheme}://$authority');
  if (parsed == null ||
      parsed.host.isEmpty ||
      parsed.userInfo.isNotEmpty ||
      parsed.path.isNotEmpty ||
      parsed.hasQuery ||
      parsed.hasFragment) {
    return null;
  }
  final host = parsed.host.toLowerCase();
  if (!_hostname.hasMatch(host)) {
    return null;
  }

  int? port;
  try {
    if (parsed.hasPort) {
      port = parsed.port;
      if (port < 1 || port > 65535) return null;
    }
  } on FormatException {
    return null;
  }

  final candidate = port == null
      ? source.replace(host: host)
      : source.replace(host: host, port: port);
  if (candidate.host.toLowerCase() == source.host.toLowerCase() &&
      candidate.port == source.port) {
    return null;
  }
  return candidate.toString();
}

List<String> parseFallbackHosts(String? value) {
  if (value == null || value.isEmpty) return const [];
  return value
      .split(',')
      .map((host) => host.trim().toLowerCase())
      .where(_hostname.hasMatch)
      .toSet()
      .take(maxFallbackHosts)
      .toList();
}

/// The primary host stays first: a panel that moved for good says so through
/// its `newDomain` header instead of leaving clients on a spare.
List<String> subscriptionUrlCandidates(String url, List<String> hosts) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return [url];
  final seen = {uri.host.toLowerCase()};
  return [
    url,
    for (final host in hosts)
      if (seen.add(host)) uri.replace(host: host).toString(),
  ];
}

String? subscriptionDisplaySource(String source, {int maxLength = 120}) {
  final trimmed = source.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return null;
  final value = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  ).toString();
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength - 1)}…';
}

Map<String, String> subscriptionRedirectHeaders(
  Map<String, String> headers, {
  required Uri from,
  required Uri to,
}) {
  if (_sameSubscriptionOrigin(from, to)) return headers;
  return Map<String, String>.from(headers)..removeWhere(
    (name, _) => _sensitiveSubscriptionHeaders.contains(name.toLowerCase()),
  );
}

bool isAllowedSubscriptionRedirect(Uri from, Uri to) {
  if (to.scheme != 'http' && to.scheme != 'https') return false;
  return from.scheme != 'https' || to.scheme == 'https';
}

bool _sameSubscriptionOrigin(Uri left, Uri right) =>
    left.scheme.toLowerCase() == right.scheme.toLowerCase() &&
    left.host.toLowerCase() == right.host.toLowerCase() &&
    left.port == right.port;

bool shouldTryNextSubscriptionClient(Object error) {
  if (error is! DioException) return false;
  return switch (error.type) {
    DioExceptionType.badResponse => switch (error.response?.statusCode ?? 0) {
      HttpStatus.badRequest ||
      HttpStatus.unauthorized ||
      HttpStatus.forbidden ||
      HttpStatus.notAcceptable ||
      HttpStatus.unsupportedMediaType => true,
      _ => false,
    },
    // Panels that cannot render a format tear the body down mid-stream
    // instead of answering with a status the next client could read.
    DioExceptionType.unknown => error.error is HttpException,
    _ => false,
  };
}

/// Whether the host itself is what failed, rather than the subscription being
/// gone or the client being turned away.
bool shouldTryFallbackHost(Object error) {
  if (error is SocketException ||
      error is HandshakeException ||
      error is TimeoutException) {
    return true;
  }
  if (error is! DioException) return false;
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode ?? 0;
      return status == HttpStatus.requestTimeout ||
          status == HttpStatus.tooManyRequests ||
          status >= HttpStatus.internalServerError;
    case DioExceptionType.unknown:
      final inner = error.error;
      return inner != null && inner is! FormatException
          ? shouldTryFallbackHost(inner)
          : false;
    case DioExceptionType.badCertificate:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.cancel:
      return false;
  }
}

/// Spare hosts a panel handed out, kept per profile so a dead primary domain
/// still has somewhere to fetch from.
class SubscriptionHostRecord {
  final Map<String, List<String>> hosts;

  const SubscriptionHostRecord({this.hosts = const {}});

  static SubscriptionHostRecord fromJson(Object? json) {
    if (json is! Map) return const SubscriptionHostRecord();
    final hosts = <String, List<String>>{};
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! List) continue;
      final parsed = parseFallbackHosts(value.join(','));
      if (parsed.isNotEmpty) hosts[key] = parsed;
    }
    return SubscriptionHostRecord(hosts: hosts);
  }

  Map<String, Object?> toJson() => hosts;

  List<String> hostsFor(int profileId) => hosts['$profileId'] ?? const [];

  SubscriptionHostRecord remember({
    required int profileId,
    required List<String> hosts,
  }) {
    final merged = [
      ...hosts,
      ...hostsFor(profileId),
    ].where(_hostname.hasMatch).toSet().take(maxFallbackHosts).toList();
    if (merged.isEmpty) return this;
    return SubscriptionHostRecord(hosts: {...this.hosts, '$profileId': merged});
  }

  SubscriptionHostRecord forget(int profileId) {
    if (!hosts.containsKey('$profileId')) return this;
    return SubscriptionHostRecord(
      hosts: {
        for (final entry in hosts.entries)
          if (entry.key != '$profileId') entry.key: entry.value,
      },
    );
  }

  @override
  String toString() => 'SubscriptionHostRecord($hosts)';
}
