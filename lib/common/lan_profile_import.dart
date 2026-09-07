import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:reclash/common/network.dart';
import 'package:reclash/common/subscription_import.dart';

const lanProfileImportBodyLimit = 8192;
const lanProfileImportMaxRequests = 4;

typedef LanProfileImportCallback =
    Future<void> Function(SubscriptionImportTarget target);
typedef LanProfileImportResolver =
    Future<SubscriptionImportTarget?> Function(String input);
typedef LanProfileImportBinder =
    Future<HttpServer> Function(InternetAddress address);

enum LanProfileImportState {
  waiting,
  importing,
  imported,
  failed,
  timedOut,
  closed,
}

class LanProfileImportServer {
  LanProfileImportServer({
    required this.onImport,
    required this.resolve,
    this.timeout = const Duration(minutes: 3),
    LanProfileImportBinder? bind,
    Random? random,
  }) : _bind = bind ?? _defaultBind,
       _random = random ?? Random.secure();

  final LanProfileImportCallback onImport;
  final LanProfileImportResolver resolve;
  final Duration timeout;
  final LanProfileImportBinder _bind;
  final Random _random;
  final state = StreamController<LanProfileImportState>.broadcast();

  HttpServer? _server;
  Timer? _timer;
  var _activeRequests = 0;
  var _consumed = false;
  var _closed = false;
  late final String token;
  late final Uri uri;

  static Future<HttpServer> _defaultBind(InternetAddress address) {
    return HttpServer.bind(address, 0, shared: false);
  }

  Future<Uri> start({InternetAddress? address}) async {
    if (_server != null) return uri;
    final selected = address ?? await _findLanAddress();
    if (selected == null) {
      throw const SocketException('No private LAN IPv4 address available');
    }
    token = _createToken();
    final server = await _bind(selected);
    if (_closed) {
      await server.close(force: true);
      throw StateError('LAN profile import server is closed');
    }
    _server = server;
    uri = Uri(
      scheme: 'http',
      host: selected.address,
      port: server.port,
      path: '/add-profile',
      queryParameters: {'token': token},
    );
    state.add(LanProfileImportState.waiting);
    _timer = Timer(timeout, _handleTimeout);
    unawaited(_serve(server));
    return uri;
  }

  Future<void> _serve(HttpServer server) async {
    try {
      await for (final request in server) {
        if (_closed || _consumed) {
          await _reject(request, HttpStatus.gone);
        } else if (_activeRequests >= lanProfileImportMaxRequests) {
          await _reject(request, HttpStatus.serviceUnavailable);
        } else {
          _activeRequests++;
          unawaited(_handle(request).whenComplete(() => _activeRequests--));
        }
      }
    } on Object {
      if (!_closed) await close();
    }
  }

  Future<void> _handle(HttpRequest request) async {
    if (request.method != 'POST') {
      await _reject(request, HttpStatus.methodNotAllowed);
      return;
    }
    if (request.uri.path != '/add-profile') {
      await _reject(request, HttpStatus.notFound);
      return;
    }
    if (request.uri.queryParameters['token'] != token) {
      await _reject(request, HttpStatus.forbidden);
      return;
    }
    if (request.headers.contentType?.mimeType != ContentType.json.mimeType) {
      await _reject(request, HttpStatus.unsupportedMediaType);
      return;
    }

    final bytes = <int>[];
    var tooLarge = false;
    await for (final chunk in request) {
      if (tooLarge || bytes.length + chunk.length > lanProfileImportBodyLimit) {
        tooLarge = true;
      } else {
        bytes.addAll(chunk);
      }
    }
    if (tooLarge) {
      await _reject(request, HttpStatus.requestEntityTooLarge, drain: false);
      return;
    }

    String? input;
    try {
      final body = jsonDecode(utf8.decode(bytes));
      if (body is Map<String, dynamic>) input = body['url'] as String?;
    } on Object {
      input = null;
    }
    if (input == null) {
      await _reject(request, HttpStatus.badRequest, drain: false);
      return;
    }

    final target = await resolve(input);
    if (target == null || target.localContent != null || target.url.isEmpty) {
      await _reject(request, HttpStatus.unprocessableEntity, drain: false);
      return;
    }
    if (_consumed || _closed) {
      await _reject(request, HttpStatus.gone, drain: false);
      return;
    }

    _consumed = true;
    _timer?.cancel();
    state.add(LanProfileImportState.importing);
    final listenerClosed = _server?.close(force: false);
    request.response.statusCode = HttpStatus.accepted;
    await request.response.close();
    await listenerClosed;
    try {
      await onImport(target);
      state.add(LanProfileImportState.imported);
    } on Object {
      state.add(LanProfileImportState.failed);
    } finally {
      await close();
    }
  }

  Future<void> _reject(
    HttpRequest request,
    int status, {
    bool drain = true,
  }) async {
    request.response.statusCode = status;
    if (drain) await request.drain<void>();
    await request.response.close();
  }

  void _handleTimeout() {
    if (_closed || _consumed) return;
    state.add(LanProfileImportState.timedOut);
    unawaited(close());
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _timer?.cancel();
    await _server?.close(force: true);
    state.add(LanProfileImportState.closed);
    await state.close();
  }

  String _createToken() {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

Future<InternetAddress?> _findLanAddress() async {
  for (final value in await getLocalIPv4s()) {
    if (isPrivateLanIPv4(value)) return InternetAddress(value);
  }
  return null;
}

bool isPrivateLanIPv4(String value) {
  final parts = value.split('.').map(int.tryParse).toList();
  if (parts.length != 4 || parts.any((part) => part == null)) return false;
  final octets = parts.cast<int>();
  if (octets.any((part) => part < 0 || part > 255)) return false;
  return octets[0] == 10 ||
      (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) ||
      (octets[0] == 192 && octets[1] == 168);
}
