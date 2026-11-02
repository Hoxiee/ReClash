import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/surface.dart';

import 'constant.dart';
import 'link.dart';

typedef LinkReceiverTexts = ({
  String title,
  String hint,
  String send,
  String sent,
  String invalid,
});

typedef LinkReceiverPalette = ({ColorScheme light, ColorScheme dark});

/// Serves a one-page form on the local network so a phone that scans [address]
/// can hand a link to a device that has no way to type one.
class LinkReceiver {
  static const _maxBodyBytes = 16 * 1024;

  final HttpServer _server;
  final String _token;
  final LinkReceiverTexts _texts;
  final LinkReceiverPalette _palette;
  final _link = Completer<String?>();

  final Uri address;

  LinkReceiver._(
    this._server,
    this._token,
    this._texts,
    this._palette,
    String host,
  ) : address = Uri(
        scheme: 'http',
        host: host,
        port: _server.port,
        path: '/$_token',
      );

  /// The first valid link a phone sends, or null if [close] comes first.
  Future<String?> get link => _link.future;

  static final _preferredInterface = RegExp(
    r'^(wlan|wl|eth|en|wi-?fi|ethernet)',
    caseSensitive: false,
  );

  /// The page the phone opens takes [palette], the app's own colors, so it
  /// reads as part of the app rather than a bare form.
  static Future<LinkReceiver?> start(
    LinkReceiverTexts texts, {
    LinkReceiverPalette? palette,
    @visibleForTesting String? host,
  }) async {
    host ??= await _lanHost();
    if (host == null) {
      return null;
    }
    final server = await HttpServer.bind(InternetAddress(host), 0);
    final receiver = LinkReceiver._(
      server,
      _newToken(),
      texts,
      palette ?? _defaultPalette(),
      host,
    );
    server.listen((request) => receiver._serve(request), onError: (_) {});
    return receiver;
  }

  static Future<String?> _lanHost() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    final ordered = [
      ...interfaces.where((i) => _preferredInterface.hasMatch(i.name)),
      ...interfaces.where((i) => !_preferredInterface.hasMatch(i.name)),
    ];
    return lanAddress(ordered.expand((interface) => interface.addresses));
  }

  Future<void> close() {
    if (!_link.isCompleted) {
      _link.complete(null);
    }
    return _server.close(force: true);
  }

  static String _newToken() {
    final random = Random.secure();
    return base64Url
        .encode(List<int>.generate(16, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  @visibleForTesting
  static String? lanAddress(Iterable<InternetAddress> addresses) {
    for (final address in addresses) {
      final bytes = address.rawAddress;
      if (bytes.length != 4 || address.isLoopback || address.isLinkLocal) {
        continue;
      }
      final isPrivate =
          bytes[0] == 10 ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] < 32) ||
          (bytes[0] == 192 && bytes[1] == 168);
      if (isPrivate) {
        return address.address;
      }
    }
    return null;
  }

  void _serve(HttpRequest request) {
    unawaited(
      _handle(request).catchError(
        (Object _) => request.response.close().catchError((Object _) {}),
      ),
    );
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    response.headers
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..contentType = ContentType.html;
    if (request.uri.path != '/$_token' || _link.isCompleted) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    if (request.method == 'GET') {
      response.write(_page());
      await response.close();
      return;
    }
    if (request.method != 'POST') {
      response.statusCode = HttpStatus.methodNotAllowed;
      await response.close();
      return;
    }
    final text = await _readLink(request);
    final link = profileUrlFromQrCodes([text]);
    if (link == null) {
      response.statusCode = HttpStatus.badRequest;
      response.write(_page(error: _texts.invalid, value: text ?? ''));
      await response.close();
      return;
    }
    if (_link.isCompleted) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    _link.complete(link);
    response.write(_page(done: true));
    await response.close();
    unawaited(close());
  }

  Future<String?> _readLink(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
      if (bytes.length > _maxBodyBytes) {
        return null;
      }
    }
    try {
      return Uri.splitQueryString(utf8.decode(bytes))['link']?.trim();
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static LinkReceiverPalette _defaultPalette() {
    const seed = Color(defaultPrimaryColor);
    return (
      light: ColorScheme.fromSeed(seedColor: seed),
      dark: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    );
  }

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static String _rgba(Color color, double alpha) =>
      'rgba(${(color.r * 255).round()},${(color.g * 255).round()},'
      '${(color.b * 255).round()},$alpha)';

  /// The fills follow `.agents/surfaces.md`: the card on the page level and
  /// the field on the inset level, with no borders.
  static String _variables(ColorScheme colors) => [
    'color-scheme:${colors.brightness.name}',
    '--page:${_hex(SurfaceLevel.page.colorOf(colors))}',
    '--card:${_hex(SurfaceLevel.card.colorOf(colors))}',
    '--inset:${_hex(SurfaceLevel.inset.colorOf(colors))}',
    '--on:${_hex(colors.onSurface)}',
    '--muted:${_hex(colors.onSurfaceVariant)}',
    '--primary:${_hex(colors.primary)}',
    '--on-primary:${_hex(colors.onPrimary)}',
    '--glow:${_rgba(colors.primary, 0.32)}',
    '--error:${_hex(colors.errorContainer)}',
    '--on-error:${_hex(colors.onErrorContainer)}',
  ].join(';');

  String _page({bool done = false, String? error, String value = ''}) {
    const escape = HtmlEscape();
    final title = escape.convert(_texts.title);
    final light = SurfaceLevel.page.colorOf(_palette.light);
    final dark = SurfaceLevel.page.colorOf(_palette.dark);
    final body = done
        ? '''
<section class="card done">
<div class="badge"><svg viewBox="0 0 24 24" width="28" height="28" aria-hidden="true"><polyline points="5,12.5 10,17.5 19,7" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
<p class="headline">${escape.convert(_texts.sent)}</p>
</section>'''
        : '''
<form method="post">
<textarea name="link" rows="4" placeholder="${escape.convert(_texts.hint)}" aria-label="$title" autocapitalize="off" autocorrect="off" spellcheck="false" autofocus required>${escape.convert(value)}</textarea>
${error == null ? '' : '<p class="error" role="alert">${escape.convert(error)}</p>'}
<button type="submit">${escape.convert(_texts.send)}</button>
</form>''';
    return '''
<!doctype html>
<html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" media="(prefers-color-scheme: light)" content="${_hex(light)}">
<meta name="theme-color" media="(prefers-color-scheme: dark)" content="${_hex(dark)}">
<title>$title</title>
<style>
:root{${_variables(_palette.light)};--r-card:1.5rem;--r-field:1rem}
@media (prefers-color-scheme:dark){:root{${_variables(_palette.dark)}}}
@supports (corner-shape:squircle){:root{--r-card:2rem;--r-field:1.375rem}form,.card,textarea,.error{corner-shape:squircle}}
*{box-sizing:border-box}
html,body{background:var(--page)}
body{margin:0;min-height:100dvh;display:flex;justify-content:center;padding:max(2rem,env(safe-area-inset-top)) 1rem max(1.5rem,env(safe-area-inset-bottom));color:var(--on);font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;-webkit-text-size-adjust:100%;-webkit-tap-highlight-color:transparent}
main{width:100%;max-width:35rem;display:flex;flex-direction:column;gap:1.25rem}
h1{margin:0 .25rem;font-size:1.75rem;line-height:2.125rem;font-weight:700}
form,.card{margin:0;display:flex;flex-direction:column;gap:.75rem;padding:1rem;border-radius:var(--r-card);background:var(--card)}
textarea{display:block;width:100%;min-height:7.5rem;resize:none;margin:0;padding:.875rem 1rem;border:0;outline:0;border-radius:var(--r-field);background:var(--inset);color:var(--on);font:inherit;font-size:1.0625rem;line-height:1.375rem}
textarea::placeholder{color:var(--muted)}
.error{margin:0;padding:.75rem 1rem;border-radius:var(--r-field);background:var(--error);color:var(--on-error);font-size:.9375rem;line-height:1.25rem}
button{height:3.5rem;margin-top:.25rem;border:0;border-radius:62.4375rem;background:var(--primary);color:var(--on-primary);font:inherit;font-size:1.0625rem;line-height:1.375rem;font-weight:600;box-shadow:0 .375rem 1.125rem var(--glow);cursor:pointer;transition:transform .2s cubic-bezier(.2,.9,.3,1.3)}
button:active{transform:scale(.96)}
button:focus-visible{outline:.125rem solid var(--primary);outline-offset:.1875rem}
.done{align-items:center;gap:1rem;padding:2rem 1rem;text-align:center}
.badge{width:3.5rem;height:3.5rem;display:grid;place-items:center;border-radius:62.4375rem;background:var(--primary);color:var(--on-primary);box-shadow:0 .375rem 1.125rem var(--glow)}
.headline{margin:0;font-size:1.0625rem;line-height:1.375rem;font-weight:600}
@media (prefers-reduced-motion:reduce){button{transition:none}}
</style></head>
<body><main><h1>$title</h1>$body</main></body></html>''';
  }
}
