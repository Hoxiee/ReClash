import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'backend.dart';

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
  SpeedTestSession open(SpeedTestClientFactory createClient) =>
      _CloudflareSession(_baseUri, createClient, timeout);
}

class _CloudflareSession implements SpeedTestSession {
  _CloudflareSession(this.baseUri, this._factory, this._timeout)
    : _probe = _HttpChannel(_factory, _timeout);

  final Uri baseUri;
  final SpeedTestClientFactory _factory;
  final Duration _timeout;
  final _HttpChannel _probe;
  final _down = <int, _HttpChannel>{};
  final _up = <int, _HttpChannel>{};
  bool _closed = false;
  Future<Uint8List>? _uploadBuffer;
  int _sequence = 0;

  Uri _downloadUrl(int bytes) => baseUri
      .resolve('/__down')
      .replace(
        queryParameters: {
          'bytes': '$bytes',
          'reclash': '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
        },
      );

  @override
  Future<double> latency() => _probe.run((client) async {
    final watch = Stopwatch()..start();
    final request = await client.getUrl(_downloadUrl(0));
    _prepare(request);
    final response = await request.close();
    final elapsed = watch.elapsedMicroseconds / 1000;
    _check(response);
    await _drainSmall(response);
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

  _HttpChannel _lane(Map<int, _HttpChannel> lanes, int lane) {
    if (_closed) throw const HttpException('cancelled');
    return lanes[lane] ??= _HttpChannel(_factory, _timeout);
  }

  @override
  Future<void> download(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) => _lane(_down, lane).run((client) async {
    final request = await client.getUrl(_downloadUrl(bytes));
    _prepare(request);
    final response = await request.close();
    _check(response);
    if (response.headers.contentType?.mimeType.startsWith('text/') == true) {
      throw const HttpException('unexpected payload');
    }
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      if (received > bytes) throw const HttpException('oversized payload');
      onBytes(chunk.length);
    }
    if (received != bytes) throw const HttpException('incomplete payload');
  });

  @override
  Future<void> upload(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) async {
    final buffer = await (_uploadBuffer ??= Isolate.run(_makeUploadBuffer));
    await _lane(_up, lane).run((client) async {
      final request = await client.postUrl(baseUri.resolve('/__up'));
      _prepare(request);
      request.headers.contentType = ContentType.binary;
      request.contentLength = bytes;
      request.bufferOutput = false;
      var remaining = bytes;
      while (remaining > 0) {
        final count = math.min(remaining, buffer.length);
        request.add(Uint8List.sublistView(buffer, 0, count));
        onBytes(count);
        await request.flush();
        remaining -= count;
      }
      final response = await request.close();
      _check(response);
      await _drainSmall(response);
    });
  }

  static Uint8List _makeUploadBuffer() {
    final random = math.Random.secure();
    return Uint8List.fromList(
      List.generate(64 * 1024, (_) => random.nextInt(256)),
    );
  }

  static void _prepare(HttpClientRequest request) {
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    request.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
  }

  static void _check(HttpClientResponse response) {
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('status ${response.statusCode}');
    }
    final encoding = response.headers.value(HttpHeaders.contentEncodingHeader);
    if (encoding != null && encoding != 'identity') {
      throw const HttpException('encoded payload');
    }
  }

  static Future<void> _drainSmall(HttpClientResponse response) async {
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      if (received > 4096) throw const HttpException('unexpected response');
    }
  }

  @override
  void abortTransfer() {
    for (final channel in [..._down.values, ..._up.values]) {
      channel.abort();
    }
  }

  @override
  void close() {
    _closed = true;
    _probe.close();
    for (final channel in [..._down.values, ..._up.values]) {
      channel.close();
    }
  }
}

class _HttpChannel {
  _HttpChannel(this.createClient, this.timeout);

  final SpeedTestClientFactory createClient;
  final Duration timeout;
  HttpClient? _client;
  bool _closed = false;

  Future<T> run<T>(Future<T> Function(HttpClient client) operation) async {
    if (_closed) throw const HttpException('cancelled');
    final client = _client ??= createClient()..autoUncompress = false;
    var timedOut = false;
    final timer = Timer(timeout, () {
      timedOut = true;
      client.close(force: true);
      if (identical(client, _client)) _client = null;
    });
    try {
      final result = await operation(client);
      if (timedOut) throw TimeoutException('measurement timeout', timeout);
      return result;
    } on Object {
      client.close(force: true);
      if (identical(client, _client)) _client = null;
      if (timedOut) throw TimeoutException('measurement timeout', timeout);
      rethrow;
    } finally {
      timer.cancel();
    }
  }

  void abort() {
    _client?.close(force: true);
    _client = null;
  }

  void close() {
    _closed = true;
    abort();
  }
}
