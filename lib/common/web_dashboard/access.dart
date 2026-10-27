import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';

import 'dashboard.dart';

PatchClashConfig webDashboardEffectiveConfig(
  PatchClashConfig config, {
  required String temporarySecret,
  required bool safeMode,
}) {
  if (safeMode) {
    return config.copyWith(externalController: ExternalControllerStatus.close);
  }
  if (config.externalController == ExternalControllerStatus.open &&
      config.secret.isNotEmpty) {
    return config;
  }
  if (config.externalController == ExternalControllerStatus.close &&
      temporarySecret.isNotEmpty) {
    return config.copyWith(
      externalController: ExternalControllerStatus.open,
      secret: temporarySecret,
    );
  }
  return config.copyWith(externalController: ExternalControllerStatus.close);
}

const _javascriptMimeTypes = {
  'application/javascript',
  'text/javascript',
  'application/ecmascript',
  'text/ecmascript',
  'application/x-javascript',
};

Map<Uri, bool> _dashboardResources(Uri document, String html) {
  final parsed = html_parser.parse(html);
  final base = document.resolve(
    parsed.querySelector('base[href]')?.attributes['href'] ?? '',
  );
  if (!isWebDashboardNavigation(document, base)) {
    throw const WebDashboardException(WebDashboardFailure.unreachable);
  }
  final resources = <Uri, bool>{};
  void add(String reference, {required bool script}) {
    final uri = base.resolve(reference).removeFragment();
    if (reference.isEmpty ||
        !isWebDashboardNavigation(document, uri) ||
        resources.length >= 64) {
      throw const WebDashboardException(WebDashboardFailure.unreachable);
    }
    resources[uri] = script;
  }

  for (final script in parsed.querySelectorAll('script[src]')) {
    final type = (script.attributes['type'] ?? '').trim().toLowerCase();
    if (type != 'module' &&
        (script.attributes.containsKey('onerror') ||
            (type.isNotEmpty && !_javascriptMimeTypes.contains(type)))) {
      continue;
    }
    add(script.attributes['src']!, script: true);
  }
  if (resources.isEmpty) {
    throw const WebDashboardException(WebDashboardFailure.unreachable);
  }
  for (final link in parsed.querySelectorAll('link[href]')) {
    final relations = (link.attributes['rel'] ?? '').toLowerCase().split(
      RegExp(r'\s+'),
    );
    if (relations.contains('stylesheet')) {
      add(link.attributes['href']!, script: false);
    } else if (relations.contains('modulepreload')) {
      add(link.attributes['href']!, script: true);
    }
  }
  return resources;
}

Future<void> probeWebDashboard(
  WebDashboardEndpoint endpoint,
  WebDashboardFlavor flavor, {
  CancelToken? cancelToken,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = HttpClient()
    ..findProxy = ((_) => 'DIRECT')
    ..connectionTimeout = const Duration(seconds: 1)
    ..userAgent = null;
  if (cancelToken?.isCancelled == true) {
    client.close(force: true);
    throw const WebDashboardException(WebDashboardFailure.cancelled);
  }
  var active = true;
  var failure = WebDashboardFailure.unreachable;
  final deadline = DateTime.now().add(timeout);
  if (cancelToken != null) {
    unawaited(
      cancelToken.whenCancel.then((_) {
        if (active) {
          client.close(force: true);
        }
      }),
    );
  }
  var received = 0;
  Future<({int status, String body, String? mimeType, int length})> get(
    Uri uri, {
    bool authenticated = false,
    bool readBody = true,
  }) async {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    if (authenticated) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${endpoint.secret}',
      );
    }
    final response = await request.close();
    var length = 0;
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      length += chunk.length;
      received += chunk.length;
      if (length > (readBody ? 1024 * 1024 : webDashboardMaxFileBytes) ||
          received > webDashboardMaxDownloadBytes) {
        throw const WebDashboardException(WebDashboardFailure.unreachable);
      }
      if (readBody) bytes.add(chunk);
    }
    return (
      status: response.statusCode,
      body: readBody ? utf8.decode(bytes.takeBytes()) : '',
      mimeType: response.headers.contentType?.mimeType.toLowerCase(),
      length: length,
    );
  }

  Future<bool> ready() async {
    final document = endpoint
        .uriFor(flavor)
        .replace(query: '')
        .removeFragment();
    final response = await get(document);
    if (response.status != HttpStatus.ok ||
        response.mimeType != 'text/html' ||
        !response.body.toLowerCase().contains('<html')) {
      return false;
    }
    for (final resource in _dashboardResources(
      document,
      response.body,
    ).entries) {
      final asset = await get(resource.key, readBody: false);
      if (asset.status != HttpStatus.ok ||
          asset.length == 0 ||
          !(resource.value
              ? _javascriptMimeTypes.contains(asset.mimeType)
              : asset.mimeType == 'text/css')) {
        return false;
      }
    }
    return true;
  }

  Future<void> probe() async {
    while (active && DateTime.now().isBefore(deadline)) {
      if (cancelToken?.isCancelled == true) {
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      }
      try {
        final response = await get(
          endpoint.controller.replace(path: '/version'),
          authenticated: true,
        );
        if (response.status == HttpStatus.unauthorized ||
            response.status == HttpStatus.forbidden) {
          failure = WebDashboardFailure.authentication;
        } else if (response.status == HttpStatus.ok) {
          final metadata = jsonDecode(response.body);
          if (metadata case {
            'version': final String version,
          } when version.isNotEmpty) {
            if (await ready()) return;
          }
        }
      } on WebDashboardException {
        rethrow;
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw WebDashboardException(failure);
  }

  try {
    await probe().timeout(
      timeout,
      onTimeout: () => throw WebDashboardException(failure),
    );
    if (cancelToken?.isCancelled == true) {
      throw const WebDashboardException(WebDashboardFailure.cancelled);
    }
  } catch (_) {
    if (cancelToken?.isCancelled == true) {
      throw const WebDashboardException(WebDashboardFailure.cancelled);
    }
    rethrow;
  } finally {
    active = false;
    client.close(force: true);
  }
}

bool isWebDashboardNavigation(Uri dashboard, Uri target) {
  if (!['http', 'https'].contains(target.scheme) ||
      target.scheme != dashboard.scheme ||
      target.host != dashboard.host ||
      target.port != dashboard.port ||
      target.userInfo.isNotEmpty) {
    return false;
  }
  try {
    final path = p.posix.normalize(
      Uri.decodeComponent(target.path).replaceAll('\\', '/'),
    );
    return p.posix.isWithin(dashboard.path, path) ||
        path == p.posix.normalize(dashboard.path);
  } on FormatException {
    return false;
  }
}
