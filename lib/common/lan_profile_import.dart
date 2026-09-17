import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/network.dart';
import 'package:reclash/common/shape.dart';
import 'package:reclash/common/subscription_import.dart';
import 'package:reclash/l10n/l10n.dart';

const lanProfileImportBodyLimit = 8192;
const lanProfileImportMaxRequests = 4;
const _lanProfileImportPath = '/add-profile';

String buildLanProfileImportPage({
  required AppLocalizations localizations,
  required ColorScheme colors,
}) {
  String text(String value) => const HtmlEscape().convert(value);
  String color(Color value) =>
      '#${(value.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0')}';
  final messages = base64.encode(
    utf8.encode(
      jsonEncode({
        'pending': localizations.lanProfileImportImporting,
        'success': localizations.lanProfileImportPhoneSuccess,
        'failed': localizations.lanProfileImportPhoneFailed,
        'unreachable': localizations.lanProfileImportPhoneUnreachable,
        'expired': localizations.lanProfileImportTimedOut,
      }),
    ),
  );
  return '''<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="referrer" content="no-referrer">
<title>${text(localizations.lanProfileImportTitle)}</title>
<style>
:root{color-scheme:${colors.brightness.name};--surface:${color(colors.surface)};--card:${color(colors.surfaceContainerLow)};--ink:${color(colors.onSurface)};--muted:${color(colors.onSurfaceVariant)};--primary:${color(colors.primary)};--on-primary:${color(colors.onPrimary)};--outline:${color(colors.outline)};--error:${color(colors.error)}}
*{box-sizing:border-box}body{margin:0;padding-inline:16px;padding-block:clamp(24px,8vh,80px);background:var(--surface);color:var(--ink);font:1rem/1.5 system-ui,sans-serif}
main{max-width:34rem;margin:auto;padding:clamp(20px,5vw,36px);border-radius:${AppCorner.xxl}px;background:var(--card)}
h1{font-size:1.65rem;line-height:1.2;margin:0 0 16px}p{color:var(--muted)}label{display:block;margin-block:24px 8px}
input,button{font:inherit;border-radius:${AppCorner.md}px;min-height:48px;max-width:100%}input{width:100%;padding:12px;border:1px solid var(--outline);background:var(--surface);color:var(--ink)}
button{margin-top:20px;padding:12px 24px;border:0;background:var(--primary);color:var(--on-primary);cursor:pointer}button:disabled{opacity:.6;cursor:wait}
:focus-visible{outline:3px solid var(--primary);outline-offset:3px}#status{min-height:3rem;overflow-wrap:anywhere}#status[data-error="true"]{color:var(--error)}[hidden]{display:none!important}
@supports(corner-shape:superellipse(1.5)){main,input,button{corner-shape:superellipse(1.5)}}
</style>
<main><h1>${text(localizations.lanProfileImportTitle)}</h1>
<p>${text(localizations.lanProfileImportPhoneHint)}</p>
<form id="form"><label for="url">${text(localizations.url)}</label>
<input id="url" type="text" inputmode="url" autocomplete="off" spellcheck="false" maxlength="8192" required autofocus>
<button type="submit">${text(localizations.lanProfileImportSend)}</button></form>
<p id="status" role="status" aria-live="polite"></p></main>
<script>
const messages=JSON.parse(new TextDecoder().decode(Uint8Array.from(atob('$messages'),c=>c.charCodeAt(0))));
const form=document.querySelector('#form'),status=document.querySelector('#status'),input=document.querySelector('#url'),button=form.querySelector('button');
let pending=false;
function show(message,error=false){status.textContent=message;status.dataset.error=String(error);}
async function confirmSuccess(){
  show(messages.success);form.hidden=true;
  await new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve)));
  try{await fetch(location.href,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({ack:true})});}catch(_){}
}
form.addEventListener('submit',async event=>{
  event.preventDefault();if(pending)return;pending=true;button.disabled=true;input.readOnly=true;show(messages.pending);
  try{
    const response=await fetch(location.href,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({url:input.value})});
    const result=await response.json();
    if(response.ok&&result.status==='imported'){await confirmSuccess();}
    else if(result.status==='pending'){show(messages.pending);}
    else{show(response.status===410?messages.expired:messages.failed,true);}
  }catch(_){show(messages.unreachable,true);}
  finally{pending=false;button.disabled=false;input.readOnly=false;}
});
</script>''';
}

typedef LanProfileImportCallback =
    Future<bool> Function(SubscriptionImportTarget target);
typedef LanProfileImportResolver =
    Future<SubscriptionImportTarget?> Function(String input);
typedef LanProfileImportBinder =
    Future<HttpServer> Function(InternetAddress address);

enum LanProfileImportState {
  waiting,
  importing,
  awaitingConfirmation,
  imported,
  failed,
  timedOut,
  closed,
}

class LanProfileImportServer {
  LanProfileImportServer({
    required this.onImport,
    required this.resolve,
    required this.page,
    this.timeout = const Duration(minutes: 3),
    this.confirmationTimeout = const Duration(seconds: 20),
    this.requestTimeout = const Duration(seconds: 10),
    LanProfileImportBinder? bind,
    Random? random,
  }) : _bind = bind ?? _defaultBind,
       _random = random ?? Random.secure();

  final LanProfileImportCallback onImport;
  final LanProfileImportResolver resolve;
  final String page;
  final Duration timeout;
  final Duration confirmationTimeout;
  final Duration requestTimeout;
  final LanProfileImportBinder _bind;
  final Random _random;
  final state = StreamController<LanProfileImportState>.broadcast();

  HttpServer? _server;
  Timer? _timer;
  Future<Uri>? _starting;
  Future<void>? _closing;
  var _activeRequests = 0;
  var _importing = false;
  var _consumed = false;
  String? _importedInput;
  var _confirmed = false;
  var _closed = false;
  late final String token;
  late final Uri uri;

  static Future<HttpServer> _defaultBind(InternetAddress address) {
    return HttpServer.bind(address, 0, shared: false);
  }

  Future<Uri> start({InternetAddress? address}) {
    if (_closed) return Future.error(StateError('LAN import is closed'));
    return _starting ??= _start(address);
  }

  Future<Uri> _start(InternetAddress? address) async {
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
      path: _lanProfileImportPath,
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
        if (_closed || _activeRequests >= lanProfileImportMaxRequests) {
          await _respond(request, HttpStatus.serviceUnavailable, 'busy');
          continue;
        }
        _activeRequests++;
        unawaited(_handleSafely(request));
      }
    } on Object {
      if (!_closed) await close();
    }
  }

  Future<void> _handleSafely(HttpRequest request) async {
    try {
      await _handle(request);
    } on Object {
      await _respond(request, HttpStatus.badRequest, 'failed');
    } finally {
      _activeRequests--;
    }
  }

  Future<void> _handle(HttpRequest request) async {
    if (request.uri.path != _lanProfileImportPath) {
      await _respond(request, HttpStatus.notFound, 'failed');
      return;
    }
    if (request.uri.queryParameters['token'] != token) {
      await _respond(request, HttpStatus.forbidden, 'failed');
      return;
    }
    if (request.method == 'GET') {
      request.response
        ..statusCode = HttpStatus.ok
        ..persistentConnection = false
        ..headers.contentType = ContentType.html
        ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
        ..headers.set('X-Content-Type-Options', 'nosniff')
        ..headers.set(
          'Content-Security-Policy',
          "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; form-action 'none'; frame-ancestors 'none'; base-uri 'none'",
        )
        ..write(page);
      await request.response.close().timeout(requestTimeout);
      return;
    }
    if (request.method != 'POST') {
      await _respond(request, HttpStatus.methodNotAllowed, 'failed');
      return;
    }
    if (request.headers.contentType?.mimeType != ContentType.json.mimeType) {
      await _respond(request, HttpStatus.unsupportedMediaType, 'failed');
      return;
    }
    if (request.contentLength > lanProfileImportBodyLimit) {
      await _respond(request, HttpStatus.requestEntityTooLarge, 'failed');
      return;
    }

    final bytes = <int>[];
    await for (final chunk in request.timeout(requestTimeout)) {
      if (bytes.length + chunk.length > lanProfileImportBodyLimit) {
        await _respond(request, HttpStatus.requestEntityTooLarge, 'failed');
        return;
      }
      bytes.addAll(chunk);
    }
    final body = jsonDecode(utf8.decode(bytes));
    if (body is! Map<String, dynamic>) {
      await _respond(request, HttpStatus.badRequest, 'failed');
      return;
    }
    if (body['ack'] == true && _consumed) {
      await _respond(request, HttpStatus.ok, 'imported');
      _confirm();
      return;
    }
    final input = body['url'];
    if (input is! String || input.trim().isEmpty) {
      await _respond(request, HttpStatus.badRequest, 'failed');
      return;
    }
    if (_consumed) {
      final replay = input.trim() == _importedInput;
      await _respond(
        request,
        replay ? HttpStatus.ok : HttpStatus.gone,
        replay ? 'imported' : 'expired',
      );
      return;
    }
    if (_closed) return;
    if (_importing) {
      await _respond(request, HttpStatus.conflict, 'pending');
      return;
    }

    _importing = true;
    state.add(LanProfileImportState.importing);
    var status = HttpStatus.unprocessableEntity;
    try {
      final target = await resolve(input);
      if (_closed) return;
      if (target != null &&
          (target.localContent != null || target.url.isNotEmpty)) {
        final imported = await onImport(target);
        if (_closed) return;
        if (imported) {
          _consumed = true;
          _importedInput = input.trim();
          status = HttpStatus.ok;
          _timer?.cancel();
          _timer = Timer(confirmationTimeout, _confirm);
          state.add(LanProfileImportState.awaitingConfirmation);
        }
      }
    } on Object {
      status = HttpStatus.unprocessableEntity;
    } finally {
      _importing = false;
    }
    if (_closed) return;
    if (!_consumed) state.add(LanProfileImportState.failed);
    await _respond(request, status, _consumed ? 'imported' : 'failed');
  }

  Future<void> _respond(HttpRequest request, int status, String result) async {
    try {
      request.response
        ..statusCode = status
        ..persistentConnection = false
        ..headers.contentType = ContentType.json
        ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
        ..write(jsonEncode({'status': result}));
      await request.response.close().timeout(requestTimeout);
    } on Object {
      // A lost response must not undo a committed import or consume its retry.
    }
  }

  void _confirm() {
    if (_closed || _confirmed || !_consumed) return;
    _confirmed = true;
    _timer?.cancel();
    state.add(LanProfileImportState.imported);
    unawaited(close());
  }

  void _handleTimeout() {
    if (_closed) return;
    state.add(LanProfileImportState.timedOut);
    unawaited(close());
  }

  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
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
