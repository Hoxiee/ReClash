import 'dart:async';
import 'dart:io';

import 'backend.dart';
import 'http_session.dart';

class CloudflareSpeedTestBackend implements SpeedTestBackend {
  CloudflareSpeedTestBackend({
    Uri? baseUri,
    this.timeout = const Duration(seconds: 5),
  }) : _baseUri = baseUri ?? Uri.https('speed.cloudflare.com');

  final Uri _baseUri;
  final Duration timeout;

  @override
  String get id => 'cloudflare';
  @override
  String get name => 'Cloudflare';
  @override
  Uri get website => Uri.https('speed.cloudflare.com');
  @override
  Uri get measurementUri => _baseUri.resolve('/__down');
  @override
  int get streams => 4;

  @override
  SpeedTestSession open(SpeedTestClientFactory createClient) =>
      _CloudflareSession(_baseUri, createClient, timeout);
}

class _CloudflareSession extends HttpSpeedTestSession {
  _CloudflareSession(this.baseUri, super.createClient, super.timeout);

  final Uri baseUri;

  Uri _downloadUrl(int bytes) => baseUri
      .resolve('/__down')
      .replace(queryParameters: {'bytes': '$bytes', 'reclash': nextToken()});

  @override
  Future<double> latency() => probe.run((client) async {
    final watch = Stopwatch()..start();
    final request = await client.getUrl(_downloadUrl(0));
    prepareMeasurement(request);
    final response = await request.close();
    final elapsed = watch.elapsedMicroseconds / 1000;
    checkMeasurement(response);
    await drainSmall(response);
    final server = _serverMillis(response.headers);
    return server != null && server < elapsed ? elapsed - server : elapsed;
  });

  /// Time the edge spent on the request itself, which is not network delay.
  static double? _serverMillis(HttpHeaders headers) {
    final timing = headers[_serverTiming]?.join(',');
    if (timing == null) return null;
    final match = _requestDuration.firstMatch(timing);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static const _serverTiming = 'server-timing';
  static final _requestDuration = RegExp(r'cfRequestDuration;dur=([\d.]+)');

  @override
  Future<void> download(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) {
    final channel = downloadLane(lane);
    return channel.run((client) async {
      final request = await client.getUrl(_downloadUrl(bytes));
      prepareMeasurement(request);
      final response = await request.close();
      checkPayload(response);
      var received = 0;
      await for (final chunk in response) {
        channel.alive();
        received += chunk.length;
        if (received > bytes) throw const HttpException('oversized payload');
        onBytes(chunk.length);
      }
      if (received != bytes) throw const HttpException('incomplete payload');
    });
  }

  @override
  Future<void> upload(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) => postPayload(baseUri.resolve('/__up'), bytes, onBytes, lane);
}
