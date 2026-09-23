import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

typedef DohQuery = Future<String?> Function(Uri url);

/// The connection factory bypasses `HttpClient.badCertificateCallback`, so the
/// caller hands its own decision down to the handshake.
typedef BadCertificateCallback = bool Function(X509Certificate certificate);

/// Addressed by IP so the query itself needs no resolver; both certificates
/// carry these as SAN entries, so the handshake still verifies.
const dohEndpoints = ['https://1.1.1.1/dns-query', 'https://8.8.8.8/resolve'];

const dohTimeout = Duration(seconds: 4);
const dohMinTtl = Duration(minutes: 1);
const dohMaxTtl = Duration(minutes: 30);
const dohFailureLimit = 2;
const dohFailureSleep = Duration(minutes: 10);
const dialTimeout = Duration(seconds: 10);
const dohCacheCapacity = 256;

Uri dohQueryUrl(String endpoint, String host) =>
    Uri.parse(endpoint).replace(queryParameters: {'name': host, 'type': 'A'});

/// Type 1 answers only: a CNAME or an AAAA record carries nothing to dial.
({InternetAddress address, Duration ttl})? parseDohAnswer(String body) {
  final Object? decoded;
  try {
    decoded = json.decode(body);
  } catch (_) {
    return null;
  }
  if (decoded is! Map) return null;
  final answers = decoded['Answer'];
  if (answers is! List) return null;
  for (final answer in answers) {
    if (answer is! Map) continue;
    if (answer['type'] != 1) continue;
    final address = InternetAddress.tryParse('${answer['data']}');
    if (address == null || !address.isIPv4) continue;
    final ttl = answer['TTL'] is int ? answer['TTL'] as int : 0;
    return (
      address: address,
      ttl: Duration(
        seconds: ttl.clamp(dohMinTtl.inSeconds, dohMaxTtl.inSeconds),
      ),
    );
  }
  return null;
}

class _DohEntry {
  final InternetAddress address;
  final DateTime expiresAt;

  const _DohEntry(this.address, this.expiresAt);
}

class DohResolver {
  final List<String> _endpoints;
  final DohQuery _query;
  final DateTime Function() _now;
  final Map<String, _DohEntry> _cache = {};

  int _failures = 0;
  DateTime? _sleepUntil;

  DohResolver({
    List<String>? endpoints,
    DohQuery? query,
    DateTime Function()? now,
  }) : _endpoints = endpoints ?? dohEndpoints,
       _query = query ?? _fetch,
       _now = now ?? DateTime.now;

  Future<InternetAddress?> lookup(String host) async {
    if (host.isEmpty || InternetAddress.tryParse(host) != null) return null;
    final now = _now();
    final cached = _cache.remove(host);
    if (cached != null && cached.expiresAt.isAfter(now)) {
      _cache[host] = cached;
      return cached.address;
    }
    final sleepUntil = _sleepUntil;
    if (sleepUntil != null && sleepUntil.isAfter(now)) return null;
    for (final endpoint in _endpoints) {
      final body = await _query(dohQueryUrl(endpoint, host));
      final answer = body == null ? null : parseDohAnswer(body);
      if (answer == null) continue;
      _failures = 0;
      _sleepUntil = null;
      _cache[host] = _DohEntry(answer.address, now.add(answer.ttl));
      if (_cache.length > dohCacheCapacity) {
        _cache.remove(_cache.keys.first);
      }
      return answer.address;
    }
    _failures++;
    if (_failures >= dohFailureLimit) {
      _sleepUntil = now.add(dohFailureSleep);
    }
    return null;
  }
}

Future<String?> _fetch(Uri url) async {
  final client = HttpClient()..connectionTimeout = dohTimeout;
  try {
    final request = await client.getUrl(url);
    request.headers.set(HttpHeaders.acceptHeader, 'application/dns-json');
    final response = await request.close().timeout(dohTimeout);
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      return null;
    }
    return await utf8.decoder.bind(response).join().timeout(dohTimeout);
  } catch (error) {
    commonPrint.log(
      'doh query failed for ${url.host}: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
    return null;
  } finally {
    client.close(force: true);
  }
}

@visibleForTesting
DohResolver dohResolver = DohResolver();

/// Dials the subscription host at the address DoH gave, so a resolver that
/// answers with the wrong one cannot keep the fetch from its panel.
Future<ConnectionTask<Socket>> dohConnect(
  Uri uri,
  String? proxyHost,
  int? proxyPort, {
  BadCertificateCallback? onBadCertificate,
}) async {
  if (proxyHost != null) {
    return Socket.startConnect(proxyHost, proxyPort ?? 80);
  }
  final secure = uri.isScheme('https');
  final port = uri.hasPort ? uri.port : (secure ? 443 : 80);
  final address = await dohResolver.lookup(uri.host);
  if (address != null) {
    try {
      return await _dial(
        address,
        port,
        sni: uri.host,
        secure: secure,
        timeout: dialTimeout,
        onBadCertificate: onBadCertificate,
      );
    } catch (error) {
      commonPrint.log(
        'doh address ${address.address} unreachable: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }
  return _dial(
    uri.host,
    port,
    sni: uri.host,
    secure: secure,
    timeout: dialTimeout,
    onBadCertificate: onBadCertificate,
  );
}

Future<ConnectionTask<Socket>> _dial(
  Object host,
  int port, {
  required String sni,
  required bool secure,
  Duration? timeout,
  BadCertificateCallback? onBadCertificate,
}) async {
  final socket = await Socket.connect(host, port, timeout: timeout);
  if (!secure) {
    return ConnectionTask.fromSocket(Future.value(socket), socket.destroy);
  }
  try {
    final secured = await SecureSocket.secure(
      socket,
      host: sni,
      onBadCertificate: onBadCertificate,
    );
    return ConnectionTask.fromSocket(Future.value(secured), secured.destroy);
  } catch (_) {
    socket.destroy();
    rethrow;
  }
}
