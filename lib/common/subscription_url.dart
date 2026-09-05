import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

const _githubHosts = {'github.com', 'www.github.com'};
const _githubRawHost = 'raw.githubusercontent.com';
const _githubFileMarkers = {'blob', 'raw'};

const maxFallbackHosts = 4;

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
