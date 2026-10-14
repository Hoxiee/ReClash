import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/state.dart';

const subscriptionConnectTimeout = Duration(seconds: 12);
const subscriptionReceiveTimeout = Duration(seconds: 30);
const subscriptionRedirectLimit = 5;
const maxSubscriptionResponseBytes = 16 * 1024 * 1024;
const telemetrySendTimeout = Duration(seconds: 20);
const maxTelemetryReportBytes = 1024 * 1024;

class Request {
  late final Dio dio;
  late final Dio _clashDio;
  String? userAgent;

  ProviderReader? _read;

  @visibleForTesting
  ({Duration? connect, Duration? receive}) get subscriptionTimeouts => (
    connect: _clashDio.options.connectTimeout,
    receive: _clashDio.options.receiveTimeout,
  );

  @visibleForTesting
  set subscriptionAdapter(HttpClientAdapter adapter) {
    _clashDio.httpClientAdapter = adapter;
  }

  void attach(ProviderReader read) {
    _read = read;
  }

  Request() {
    dio = Dio(BaseOptions(headers: {'User-Agent': browserUa}));
    _clashDio = Dio(
      BaseOptions(
        connectTimeout: subscriptionConnectTimeout,
        receiveTimeout: subscriptionReceiveTimeout,
      ),
    );
    _clashDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        final read = _read;
        if (read != null) {
          ReClashHttpOverrides.applyProxyAuthentication(client, read);
        }
        client.findProxy = (Uri uri) {
          client.userAgent = globalState.ua;
          if (read == null) {
            return 'DIRECT';
          }
          return ReClashHttpOverrides.findProxyForReader(read, uri);
        };
        client.connectionFactory = (uri, proxyHost, proxyPort) => dohConnect(
          uri,
          proxyHost,
          proxyPort,
          onBadCertificate: (certificate) => _allowBadCertificate(
            certificate,
            uri.host,
            uri.hasPort ? uri.port : 443,
          ),
        );
        return client;
      },
    );
  }

  bool _allowBadCertificate(
    X509Certificate certificate,
    String host,
    int port,
  ) {
    final read = _read;
    if (read == null) return false;
    return ReClashHttpOverrides.allowBadCertificateForReader(
      read,
      certificate,
      host,
      port,
    );
  }

  Future<Response<Uint8List>> getFileResponseForUrl(
    String url, {
    Map<String, String>? headers,
    Dio? transport,
  }) async {
    final initialUri = Uri.parse(url);
    var currentUri = initialUri;
    var currentHeaders = Map<String, String>.from(headers ?? const {});
    final redirects = <RedirectRecord>[];
    var receivedResponse = false;
    try {
      for (var redirectCount = 0; ; redirectCount++) {
        final requestToken = CancelToken();
        final response = await (transport ?? _clashDio).get<ResponseBody>(
          currentUri.toString(),
          cancelToken: requestToken,
          options: Options(
            responseType: ResponseType.stream,
            headers: currentHeaders,
            followRedirects: false,
            validateStatus: (status) =>
                status != null &&
                ((status >= 200 && status < 300) || _isRedirectStatus(status)),
          ),
        );
        receivedResponse = true;
        final body = response.data;
        if (body == null) {
          return Response<Uint8List>(
            requestOptions: response.requestOptions,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            isRedirect: response.isRedirect,
            redirects: redirects,
            extra: response.extra,
            headers: response.headers,
          );
        }
        final location = response.headers.value(HttpHeaders.locationHeader);
        if (_isRedirectStatus(response.statusCode)) {
          requestToken.cancel();
        } else {
          final data = await _readSubscriptionBody(body, requestToken);
          return Response<Uint8List>(
            data: data,
            requestOptions: response.requestOptions,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            isRedirect: redirects.isNotEmpty,
            redirects: redirects,
            extra: response.extra,
            headers: response.headers,
          );
        }
        if (location == null) {
          throw const MessageException('subscription redirect has no location');
        }
        if (redirectCount >= subscriptionRedirectLimit) {
          throw const MessageException('too many subscription redirects');
        }
        final nextUri = currentUri.resolve(location);
        if (!isAllowedSubscriptionRedirect(currentUri, nextUri)) {
          throw const MessageException('unsafe subscription redirect');
        }
        redirects.add(RedirectRecord(response.statusCode!, 'GET', nextUri));
        currentHeaders = subscriptionRedirectHeaders(
          currentHeaders,
          from: currentUri,
          to: nextUri,
        );
        currentUri = nextUri;
      }
    } catch (error) {
      if (error is DioException && receivedResponse) {
        error.requestOptions.extra['subscriptionReceivedResponse'] = true;
      }
      commonPrint.log(
        'getFileResponseForUrl error ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  Future<Response<String>> getTextResponseForUrl(String url) async {
    try {
      return await _clashDio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
    } catch (error) {
      commonPrint.log(
        'getTextResponseForUrl error ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  /// Submits a subscription report to a provider's opt-in telemetry sink. The
  /// user confirms every call; this never runs in the background. The report
  /// goes out directly (not through a proxy) so a sick node cannot swallow its
  /// own diagnosis, and only to an absolute HTTPS URL without embedded
  /// credentials. The send is time-bounded and the payload is size-capped so a
  /// dead or hostile ingest cannot hang the UI or carry a runaway body. Throws
  /// on any failure so the caller can tell the user it did not go through.
  Future<void> submitTelemetryReport(
    String url,
    Map<String, Object?> report,
  ) async {
    final target = Uri.tryParse(url);
    if (target == null ||
        target.scheme.toLowerCase() != 'https' ||
        target.userInfo.isNotEmpty) {
      throw ArgumentError('telemetry URL must be an absolute HTTPS URL');
    }
    final payload = json.encode(report);
    if (utf8.encode(payload).length > maxTelemetryReportBytes) {
      throw ArgumentError('telemetry report exceeds the size limit');
    }
    await dio.postUri<void>(
      target,
      data: payload,
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.jsonContentType,
        sendTimeout: telemetrySendTimeout,
        receiveTimeout: telemetrySendTimeout,
        headers: const {'ReClash-Telemetry-Schema': '1'},
      ),
    );
  }


  /// prerelease and 404s on a repo that has only ever shipped them. The channel
  /// policy lives in [selectUpdateRelease]; [acceptPrereleases] lets a stable
  /// build opt into prerelease upgrades. Returns null when the build is already
  /// current, and throws on a network or API failure so a caller can tell a
  /// failed check from an up-to-date one.
  Future<Map<String, dynamic>?> checkForUpdate({
    required bool acceptPrereleases,
  }) async {
    final response = await dio.get(
      'https://api.github.com/repos/$repository/releases',
      queryParameters: const {'per_page': 50},
      options: Options(responseType: ResponseType.json),
    );
    final releases = (response.data as List)
        .whereType<Map<String, dynamic>>()
        .toList();
    final installedVersion = globalState.packageInfo.version;
    final selected = selectUpdateRelease(
      releases,
      installedVersion: installedVersion,
      acceptPrereleases: acceptPrereleases,
    );
    if (selected == null) {
      _warnOnEpochlessRelease(releases, installedVersion);
    }
    return selected;
  }

  /// A higher release that lacks the epoch marker is dropped silently by
  /// [selectUpdateRelease]; surface it so a mis-tagged release is diagnosable.
  void _warnOnEpochlessRelease(
    List<Map<String, dynamic>> releases,
    String installedVersion,
  ) {
    final installed = tryParseAppVersion(installedVersion);
    if (installed == null) return;
    for (final release in releases) {
      if (release['draft'] == true) continue;
      final tag = release['tag_name'];
      if (tag is! String) continue;
      final version = tryParseAppVersion(tag.replaceFirst(RegExp(r'^v'), ''));
      if (version == null || version.compareTo(installed) <= 0) continue;
      final body = release['body'];
      if (body is String && body.contains(releaseEpochMarker)) continue;
      commonPrint.log(
        'update $tag ignored: release body is missing $releaseEpochMarker',
        logLevel: LogLevel.warning,
      );
      return;
    }
  }

  /// Downloads to a sibling `.tmp` and renames only after the bytes are
  /// complete, so an interrupted run can never leave a half file where a
  /// cached artifact is expected. Returns an error message, or null on success.
  Future<String?> downloadFile(
    String url,
    String targetPath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final tmpPath = '$targetPath.tmp';
    await File(tmpPath).safeDelete();
    try {
      await dio.download(
        url,
        tmpPath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
      final tmpFile = File(tmpPath);
      if (!await tmpFile.exists()) {
        return 'download produced no file';
      }
      await File(targetPath).safeDelete();
      await tmpFile.rename(targetPath);
      return null;
    } catch (error) {
      await File(tmpPath).safeDelete();
      if (error is DioException && CancelToken.isCancel(error)) {
        return '';
      }
      commonPrint.log(
        'downloadFile error ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return compactError(error);
    }
  }

  final Map<String, IpInfo Function(Map<String, dynamic>)> _ipInfoSources = {
    'https://ipwho.is': IpInfo.fromIpWhoIsJson,
    'https://api.myip.com': IpInfo.fromMyIpJson,
    'https://ipapi.co/json': IpInfo.fromIpApiCoJson,
    'https://ident.me/json': IpInfo.fromIdentMeJson,
    'https://api.ip.sb/geoip': IpInfo.fromIpSbJson,
    'https://ipinfo.io/json': IpInfo.fromIpInfoIoJson,
  };

  Future<Result<IpInfo?>> checkIp({CancelToken? cancelToken}) async {
    for (final source in _ipInfoSources.entries) {
      if (cancelToken?.isCancelled == true) {
        return Result.error('cancelled');
      }
      final requestToken = CancelToken();
      if (cancelToken != null) {
        unawaited(
          cancelToken.whenCancel.then((error) {
            if (!requestToken.isCancelled) {
              requestToken.cancel(error);
            }
          }),
        );
      }
      try {
        final response = await dio
            .get<Map<String, dynamic>>(
              source.key,
              cancelToken: requestToken,
              options: Options(responseType: ResponseType.json),
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                requestToken.cancel('timeout');
                throw TimeoutException('checkIp timed out');
              },
            );
        if (response.statusCode == HttpStatus.ok && response.data != null) {
          return Result.success(source.value(response.data!));
        }
        commonPrint.log('checkIp data empty', logLevel: LogLevel.info);
      } catch (error) {
        if (cancelToken?.isCancelled == true) {
          return Result.error('cancelled');
        }
        commonPrint.log(
          'checkIp error ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
      }
    }
    return Result.success(null);
  }
}

final request = Request();

bool _isRedirectStatus(int? status) =>
    status == HttpStatus.movedPermanently ||
    status == HttpStatus.found ||
    status == HttpStatus.seeOther ||
    status == HttpStatus.temporaryRedirect ||
    status == HttpStatus.permanentRedirect;

Future<Uint8List> _readSubscriptionBody(
  ResponseBody body,
  CancelToken cancelToken,
) async {
  final declaredLength = _contentLength(body.headers);
  if (declaredLength != null && declaredLength > maxSubscriptionResponseBytes) {
    cancelToken.cancel();
    throw const MessageException('subscription response is too large');
  }
  final builder = BytesBuilder(copy: false);
  var received = 0;
  final iterator = StreamIterator(body.stream);
  try {
    while (await iterator.moveNext()) {
      final chunk = iterator.current;
      received += chunk.length;
      if (received > maxSubscriptionResponseBytes) {
        throw const MessageException('subscription response is too large');
      }
      builder.add(chunk);
    }
  } finally {
    await iterator.cancel();
  }
  return builder.takeBytes();
}

int? _contentLength(Map<String, List<String>> headers) {
  final values = headers.entries
      .where(
        (entry) => entry.key.toLowerCase() == HttpHeaders.contentLengthHeader,
      )
      .expand((entry) => entry.value);
  for (final value in values) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null && parsed >= 0) return parsed;
  }
  return null;
}

String? getFileNameForDisposition(String? disposition) {
  if (disposition == null) return null;
  final parseValue = HeaderValue.parse(disposition);
  final parameters = parseValue.parameters;
  final fileNamePointKey = parameters.keys.firstWhere(
    (key) => key == 'filename*',
    orElse: () => '',
  );
  if (fileNamePointKey.isNotEmpty) {
    final res = parameters[fileNamePointKey]?.split("''") ?? [];
    if (res.length >= 2) {
      return Uri.decodeComponent(res[1]);
    }
  }
  final fileNameKey = parameters.keys.firstWhere(
    (key) => key == 'filename',
    orElse: () => '',
  );
  if (fileNameKey.isEmpty) return null;
  return parameters[fileNameKey];
}
