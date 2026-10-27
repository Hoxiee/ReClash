import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'backend.dart';

/// Lanes, uploads and cancellation shared by the HTTP backends.
abstract class HttpSpeedTestSession implements SpeedTestSession {
  HttpSpeedTestSession(this.createClient, this.timeout)
    : probe = SpeedTestHttpChannel(createClient, timeout);

  final SpeedTestClientFactory createClient;
  final Duration timeout;
  final SpeedTestHttpChannel probe;
  final _down = <int, SpeedTestHttpChannel>{};
  final _up = <int, SpeedTestHttpChannel>{};
  bool _closed = false;
  Future<Uint8List>? _uploadBuffer;
  int _sequence = 0;

  bool get closed => _closed;

  /// A per-request value that keeps caches out of the measurement.
  String nextToken() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  SpeedTestHttpChannel downloadLane(int lane) => _lane(_down, lane);

  SpeedTestHttpChannel _lane(Map<int, SpeedTestHttpChannel> lanes, int lane) {
    if (_closed) throw const HttpException('cancelled');
    return lanes[lane] ??= SpeedTestHttpChannel(createClient, timeout);
  }

  Future<void> postPayload(
    Uri uri,
    int bytes,
    SpeedTestByteCallback onBytes,
    int lane,
  ) async {
    final buffer = await (_uploadBuffer ??= Isolate.run(_makeUploadBuffer));
    final channel = _lane(_up, lane);
    await channel.run((client) async {
      final request = await client.postUrl(uri);
      prepareMeasurement(request);
      request.headers.contentType = ContentType.binary;
      request.contentLength = bytes;
      request.bufferOutput = false;
      var remaining = bytes;
      while (remaining > 0) {
        final count = math.min(remaining, buffer.length);
        request.add(Uint8List.sublistView(buffer, 0, count));
        onBytes(count);
        await request.flush();
        channel.alive();
        remaining -= count;
      }
      final response = await request.close();
      checkMeasurement(response);
      await drainSmall(response);
    });
  }

  static Uint8List _makeUploadBuffer() {
    final random = math.Random.secure();
    return Uint8List.fromList(
      List.generate(64 * 1024, (_) => random.nextInt(256)),
    );
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
    probe.close();
    for (final channel in [..._down.values, ..._up.values]) {
      channel.close();
    }
  }
}

void prepareMeasurement(HttpClientRequest request) {
  request.followRedirects = false;
  request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
  request.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
}

void checkMeasurement(HttpClientResponse response) {
  if (response.statusCode != HttpStatus.ok) {
    throw HttpException('status ${response.statusCode}');
  }
  final encoding = response.headers.value(HttpHeaders.contentEncodingHeader);
  if (encoding != null && encoding != 'identity') {
    throw const HttpException('encoded payload');
  }
}

/// Rejects error pages served with a success status in place of the payload.
void checkPayload(HttpClientResponse response) {
  checkMeasurement(response);
  if (response.headers.contentType?.mimeType.startsWith('text/') == true) {
    throw const HttpException('unexpected payload');
  }
}

Future<void> drainSmall(HttpClientResponse response) async {
  var received = 0;
  await for (final chunk in response) {
    received += chunk.length;
    if (received > 4096) throw const HttpException('unexpected response');
  }
}

class SpeedTestHttpChannel {
  SpeedTestHttpChannel(this.createClient, this.timeout);

  final SpeedTestClientFactory createClient;
  final Duration timeout;
  HttpClient? _client;
  bool _closed = false;
  Timer? _watchdog;
  void Function()? _onStall;

  /// Pushes the stall deadline back: [timeout] bounds the wait for the next
  /// response or chunk, not a whole transfer.
  void alive() {
    final onStall = _onStall;
    if (onStall == null) return;
    _watchdog?.cancel();
    _watchdog = Timer(timeout, onStall);
  }

  Future<T> run<T>(Future<T> Function(HttpClient client) operation) async {
    if (_closed) throw const HttpException('cancelled');
    final client = _client ??= createClient()..autoUncompress = false;
    var timedOut = false;
    _onStall = () {
      timedOut = true;
      client.close(force: true);
      if (identical(client, _client)) _client = null;
    };
    alive();
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
      _watchdog?.cancel();
      _watchdog = null;
      _onStall = null;
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
