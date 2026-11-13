import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'models.dart';

abstract interface class LovenseTransport {
  Future<Map<String, dynamic>> send(Map<String, Object> command);
  void close();
}

class LovenseHttpTransport implements LovenseTransport {
  LovenseHttpTransport(
    this.endpoint, {
    this.timeout = const Duration(seconds: 5),
    this.maxResponseBytes = 256 * 1024,
  }) : _http = HttpClient() {
    _http.connectionTimeout = timeout;
    _http.badCertificateCallback = null;
    _http.findProxy = (_) => 'DIRECT';
    // TLS verifies the lovense.club name while the socket goes to the LAN IP.
    _http.connectionFactory = (_, _, _) =>
        Socket.startConnect(endpoint.address, endpoint.uri.port);
  }

  final LovenseEndpoint endpoint;
  final Duration timeout;
  final int maxResponseBytes;
  final HttpClient _http;
  bool _closed = false;

  @override
  Future<Map<String, dynamic>> send(Map<String, Object> command) async {
    if (_closed) throw LovenseError(LovenseErrorKind.cancelled);
    HttpClientRequest? request;
    var expired = false;
    Future<Map<String, dynamic>> exchange() async {
      final outgoing = await _http.postUrl(endpoint.uri);
      request = outgoing;
      if (expired || _closed) {
        outgoing.abort();
        throw LovenseError(LovenseErrorKind.cancelled);
      }
      outgoing
        ..followRedirects = false
        ..headers.contentType = ContentType.json
        ..headers.set('X-platform', 'ReClash')
        ..headers.set(HttpHeaders.acceptHeader, 'application/json')
        ..write(jsonEncode(command));
      final response = await outgoing.close();
      if (response.statusCode != HttpStatus.ok) {
        outgoing.abort();
        throw LovenseError(LovenseErrorKind.remote, code: response.statusCode);
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response) {
        if (expired || _closed) {
          outgoing.abort();
          throw LovenseError(LovenseErrorKind.cancelled);
        }
        if (bytes.length + chunk.length > maxResponseBytes) {
          outgoing.abort();
          throw LovenseError(LovenseErrorKind.invalidResponse);
        }
        bytes.add(chunk);
      }
      final result = jsonDecode(utf8.decode(bytes.takeBytes()));
      if (result is! Map<String, dynamic>) {
        throw LovenseError(LovenseErrorKind.invalidResponse);
      }
      return result;
    }

    try {
      return await exchange().timeout(
        timeout,
        onTimeout: () {
          expired = true;
          request?.abort();
          throw LovenseError(LovenseErrorKind.timeout);
        },
      );
    } on LovenseError {
      rethrow;
    } on HandshakeException {
      throw LovenseError(LovenseErrorKind.tls);
    } on FormatException {
      throw LovenseError(LovenseErrorKind.invalidResponse);
    } on IOException {
      throw LovenseError(
        _closed ? LovenseErrorKind.cancelled : LovenseErrorKind.unavailable,
      );
    }
  }

  @override
  void close() {
    _closed = true;
    _http.close(force: true);
  }
}

abstract interface class LovenseApi {
  Future<List<LovenseToy>> getToys();
  Future<void> function({
    required String toyId,
    required LovenseFunction function,
    required int strength,
    required int duration,
    LovenseStroke? stroke,
  });
  Future<void> stop({String? toyId});
  void close();
}

class LovenseClient implements LovenseApi {
  LovenseClient(LovenseEndpoint endpoint, {LovenseTransport? transport})
    : _transport = transport ?? LovenseHttpTransport(endpoint);

  final LovenseTransport _transport;
  Future<void> _pending = Future.value();
  int _generation = 0;
  bool _closed = false;

  Future<Map<String, dynamic>> _send(Map<String, Object> command) async {
    if (_closed) throw LovenseError(LovenseErrorKind.cancelled);
    final response = await _transport.send(command);
    final code = int.tryParse('${response['code']}');
    if (code == null) throw LovenseError(LovenseErrorKind.invalidResponse);
    if (code != 200) throw LovenseError(LovenseErrorKind.remote, code: code);
    return response;
  }

  @override
  Future<List<LovenseToy>> getToys() async {
    final response = await _send({'command': 'GetToys'});
    final data = response['data'];
    if (data is! Map) throw LovenseError(LovenseErrorKind.invalidResponse);
    return parseLovenseToys(data['toys']);
  }

  @override
  Future<void> function({
    required String toyId,
    required LovenseFunction function,
    required int strength,
    required int duration,
    LovenseStroke? stroke,
  }) {
    _validateToyId(toyId);
    if (strength < 0 ||
        strength > function.maxStrength ||
        duration < lovenseMinDuration ||
        duration > lovenseMaxDuration ||
        (stroke != null &&
            (function != LovenseFunction.thrusting || !stroke.isValid))) {
      throw LovenseError(LovenseErrorKind.invalidCommand);
    }
    final generation = _generation;
    return _enqueue(() async {
      if (generation != _generation) {
        throw LovenseError(LovenseErrorKind.cancelled);
      }
      await _send({
        'command': 'Function',
        'action': [
          if (stroke != null) 'Stroke:${stroke.start}-${stroke.end}',
          '${function.apiName}:$strength',
        ].join(','),
        'timeSec': duration,
        'toy': toyId,
        'apiVer': 1,
        'stopPrevious': 1,
      });
    });
  }

  @override
  Future<void> stop({String? toyId}) {
    if (toyId != null) _validateToyId(toyId);
    _generation++;
    return _enqueue(() async {
      await _send({
        'command': 'Function',
        'action': 'Stop',
        'timeSec': 0,
        'toy': ?toyId,
        'apiVer': 1,
      });
    });
  }

  Future<void> _enqueue(Future<void> Function() action) {
    if (_closed) throw LovenseError(LovenseErrorKind.cancelled);
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  static void _validateToyId(String id) {
    if (!RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(id)) {
      throw LovenseError(LovenseErrorKind.invalidCommand);
    }
  }

  @override
  void close() {
    _closed = true;
    _generation++;
    _transport.close();
  }
}
