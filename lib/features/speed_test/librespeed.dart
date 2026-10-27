import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'backend.dart';
import 'http_session.dart';

class LibreSpeedBackend implements SpeedTestBackend {
  LibreSpeedBackend({
    Uri? serverList,
    this.timeout = const Duration(seconds: 5),
    this.pingTimeout = const Duration(seconds: 3),
  }) : serverList =
           serverList ??
           Uri.https('librespeed.org', '/backend-servers/servers.php');

  final Uri serverList;
  final Duration timeout;

  /// How long the nearest-server search waits for slow servers.
  final Duration pingTimeout;

  @override
  String get id => 'librespeed';
  @override
  String get name => 'LibreSpeed';
  @override
  Uri get website => Uri.https('librespeed.org');
  @override
  Uri get measurementUri => serverList;

  /// Volunteer servers often shape single connections well below their link.
  @override
  int get streams => 8;

  @override
  SpeedTestSession open(SpeedTestClientFactory createClient) =>
      _LibreSpeedSession(this, createClient);
}

class LibreSpeedServer {
  const LibreSpeedServer({
    required this.name,
    required this.download,
    required this.upload,
    required this.ping,
  });

  final String name;
  final Uri download;
  final Uri upload;
  final Uri ping;

  static LibreSpeedServer? tryParse(Object? value) {
    if (value is! Map) return null;
    final name = value['name'];
    final server = value['server'];
    if (name is! String || server is! String) return null;
    final base = Uri.tryParse(
      server.startsWith('//') ? 'https:$server' : server,
    );
    if (base == null ||
        !(base.isScheme('https') || base.isScheme('http')) ||
        base.host.isEmpty) {
      return null;
    }
    // Endpoint paths are relative to the server path, which the list often
    // writes without its trailing slash.
    final root = base.path.endsWith('/')
        ? base
        : base.replace(path: '${base.path}/');
    Uri? endpoint(Object? path, String fallback) => switch (path) {
      null => root.resolve(fallback),
      final String relative => root.resolve(relative),
      _ => null,
    };
    final download = endpoint(value['dlURL'], 'garbage.php');
    final upload = endpoint(value['ulURL'], 'empty.php');
    final ping = endpoint(value['pingURL'], 'empty.php');
    if (download == null || upload == null || ping == null) return null;
    return LibreSpeedServer(
      name: name,
      download: download,
      upload: upload,
      ping: ping,
    );
  }
}

class _LibreSpeedSession extends HttpSpeedTestSession {
  _LibreSpeedSession(this.backend, SpeedTestClientFactory createClient)
    : super(createClient, backend.timeout);

  final LibreSpeedBackend backend;
  final _search = <SpeedTestHttpChannel>{};
  Future<LibreSpeedServer>? _server;

  /// garbage.php streams whole mebibyte chunks and caps a request at 1024.
  static const _chunk = 1024 * 1024;
  static const _maxChunks = 1024;
  static const _maxListBytes = 512 * 1024;

  Future<LibreSpeedServer> _selected() => _server ??= _nearest();

  Future<LibreSpeedServer> _nearest() async {
    final servers = await _list();
    final rtts = await Future.wait([
      for (final server in servers)
        _rtt(
          server,
        ).timeout(backend.pingTimeout, onTimeout: () => double.infinity),
    ]);
    for (final channel in _search) {
      channel.close();
    }
    _search.clear();
    if (closed) throw const HttpException('cancelled');
    var best = -1;
    for (var i = 0; i < rtts.length; i++) {
      if (rtts[i].isFinite && (best < 0 || rtts[i] < rtts[best])) best = i;
    }
    if (best < 0) throw const HttpException('no reachable server');
    return servers[best];
  }

  Future<List<LibreSpeedServer>> _list() => probe.run((client) async {
    final request = await client.getUrl(backend.serverList);
    prepareMeasurement(request);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    checkMeasurement(response);
    final body = BytesBuilder(copy: false);
    await for (final chunk in response) {
      body.add(chunk);
      if (body.length > _maxListBytes) {
        throw const HttpException('oversized server list');
      }
    }
    final decoded = jsonDecode(utf8.decode(body.takeBytes()));
    final servers = [
      if (decoded is List)
        for (final value in decoded) ?LibreSpeedServer.tryParse(value),
    ];
    if (servers.isEmpty) throw const HttpException('empty server list');
    return servers;
  });

  /// Best of a few pings on one connection; the first one also pays for the
  /// connection and TLS setup, so it is left out.
  Future<double> _rtt(LibreSpeedServer server) async {
    final channel = SpeedTestHttpChannel(createClient, backend.pingTimeout);
    _search.add(channel);
    try {
      var best = double.infinity;
      for (var i = 0; i < 3; i++) {
        final value = await _ping(channel, server.ping);
        if (i > 0) best = math.min(best, value);
      }
      return best;
    } on Object {
      return double.infinity;
    } finally {
      channel.close();
    }
  }

  Future<double> _ping(SpeedTestHttpChannel channel, Uri uri) =>
      channel.run((client) async {
        final watch = Stopwatch()..start();
        final request = await client.getUrl(_unique(uri));
        prepareMeasurement(request);
        final response = await request.close();
        final elapsed = watch.elapsedMicroseconds / 1000;
        checkMeasurement(response);
        await drainSmall(response);
        return elapsed;
      });

  Uri _unique(Uri uri, [Map<String, String> parameters = const {}]) =>
      uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          ...parameters,
          'r': nextToken(),
        },
      );

  @override
  Future<double> latency() async => _ping(probe, (await _selected()).ping);

  /// Serves whole chunks, so a request may deliver less than [bytes]; only a
  /// request below one chunk is cut short.
  @override
  Future<void> download(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) async {
    final server = await _selected();
    final chunks = (bytes ~/ _chunk).clamp(1, _maxChunks);
    final full = chunks * _chunk;
    final expected = math.min(bytes, full);
    final channel = downloadLane(lane);
    await channel.run((client) async {
      final request = await client.getUrl(
        _unique(server.download, {'ckSize': '$chunks'}),
      );
      prepareMeasurement(request);
      // Volunteer servers stall or drop reused connections mid-response.
      request.persistentConnection = false;
      final response = await request.close();
      checkPayload(response);
      var received = 0;
      await for (final chunk in response) {
        channel.alive();
        final count = math.min(chunk.length, expected - received);
        received += count;
        if (count > 0) onBytes(count);
        if (received < expected) continue;
        if (expected < full) break;
        if (count < chunk.length) {
          throw const HttpException('oversized payload');
        }
      }
      if (received != expected) {
        throw const HttpException('incomplete payload');
      }
    });
  }

  @override
  Future<void> upload(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  }) async {
    final server = await _selected();
    await postPayload(_unique(server.upload), bytes, onBytes, lane);
  }

  @override
  void close() {
    super.close();
    for (final channel in _search) {
      channel.close();
    }
  }
}
