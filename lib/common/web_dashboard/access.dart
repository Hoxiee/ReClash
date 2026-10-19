import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
  Future<(int, String)> get(String path, {bool authenticated = false}) async {
    final request = await client.getUrl(
      endpoint.controller.replace(path: path),
    );
    request.followRedirects = false;
    if (authenticated) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${endpoint.secret}',
      );
    }
    final response = await request.close();
    var length = 0;
    final body = await utf8.decoder
        .bind(
          response.map((bytes) {
            length += bytes.length;
            if (length > 1024 * 1024) {
              throw const WebDashboardException(
                WebDashboardFailure.unreachable,
              );
            }
            return bytes;
          }),
        )
        .join();
    return (response.statusCode, body);
  }

  Future<void> probe() async {
    while (active && DateTime.now().isBefore(deadline)) {
      if (cancelToken?.isCancelled == true) {
        throw const WebDashboardException(WebDashboardFailure.cancelled);
      }
      try {
        final (status, body) = await get('/version', authenticated: true);
        if (status == HttpStatus.unauthorized ||
            status == HttpStatus.forbidden) {
          failure = WebDashboardFailure.authentication;
        } else if (status == HttpStatus.ok) {
          final metadata = jsonDecode(body);
          if (metadata case {
            'version': final String version,
          } when version.isNotEmpty) {
            final (uiStatus, html) = await get('/ui/${flavor.name}/');
            if (uiStatus == HttpStatus.ok &&
                html.toLowerCase().contains('<html')) {
              return;
            }
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
