import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/state.dart';

const _updateDownloadTimeout = Duration(minutes: 10);

class Request {
  late final Dio dio;
  late final Dio _clashDio;
  String? userAgent;
  late final List<AppUpdateSource> updateSources;

  ProviderReader? _read;

  @visibleForTesting
  set updateDownloadAdapter(HttpClientAdapter adapter) {
    _clashDio.httpClientAdapter = adapter;
  }

  void attach(ProviderReader read) {
    _read = read;
  }

  Request() {
    dio = Dio(BaseOptions(headers: {'User-Agent': browserUa}));
    _clashDio = Dio();
    _clashDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (Uri uri) {
          client.userAgent = globalState.ua;
          final read = _read;
          if (read == null) {
            return 'DIRECT';
          }
          return ReClashHttpOverrides.findProxyForReader(read, uri);
        };
        return client;
      },
    );
    updateSources = [GitHubUpdateSource(dio)];
  }

  Future<Response<T>> _download<T>(String url, ResponseType responseType) {
    final target = downloadTarget(url);
    final cancelToken = CancelToken();
    return _clashDio
        .getUri<T>(
          target.uri,
          options: Options(responseType: responseType, headers: target.headers),
          cancelToken: cancelToken,
        )
        .timeout(
          downloadTimeoutDuration,
          onTimeout: () {
            cancelToken.cancel();
            throw DioException.receiveTimeout(
              timeout: downloadTimeoutDuration,
              requestOptions: RequestOptions(path: url),
            );
          },
        );
  }

  Future<Response<Uint8List>> getFileResponseForUrl(String url) async {
    try {
      return await _download<Uint8List>(url, ResponseType.bytes);
    } catch (e) {
      commonPrint.log(
        'getFileResponseForUrl error ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  Future<Response<String>> getTextResponseForUrl(String url) async {
    try {
      return await _download<String>(url, ResponseType.plain);
    } catch (e) {
      commonPrint.log(
        'getTextResponseForUrl error ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      rethrow;
    }
  }

  /// Returns null only when a source answered and found no eligible release.
  Future<AppUpdateRelease?> checkForUpdate({
    required UpdateChannel channel,
  }) async {
    Object? lastError;
    StackTrace? lastStack;
    for (final source in updateSources) {
      try {
        final releases = await source.fetchReleases(channel: channel);
        final selected = selectUpdateRelease(
          releases,
          installedVersion: globalState.packageInfo.version,
          channel: channel,
        );
        return selected == null
            ? null
            : AppUpdateRelease(data: selected, source: source);
      } catch (error, stack) {
        lastError = error;
        lastStack = stack;
        commonPrint.log(
          'update source ${source.id} failed: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
      }
    }
    if (lastError != null) {
      Error.throwWithStackTrace(lastError, lastStack!);
    }
    throw StateError('No app update sources configured');
  }

  Future<String?> downloadUpdateFile(
    Uri uri,
    String targetPath, {
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
  }) async {
    final tempPath = '$targetPath.tmp';
    await File(tempPath).safeDelete();
    try {
      await _clashDio
          .download(
            uri.toString(),
            tempPath,
            cancelToken: cancelToken,
            onReceiveProgress: onProgress,
          )
          .timeout(
            _updateDownloadTimeout,
            onTimeout: () {
              cancelToken.cancel();
              throw DioException.receiveTimeout(
                timeout: _updateDownloadTimeout,
                requestOptions: RequestOptions(path: uri.toString()),
              );
            },
          );
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        throw FileSystemException('Update download produced no file', tempPath);
      }
      await File(targetPath).safeDelete();
      await tempFile.rename(targetPath);
      return null;
    } catch (error) {
      await File(tempPath).safeDelete();
      if (error is DioException && CancelToken.isCancel(error)) return '';
      commonPrint.log(
        'downloadUpdateFile failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return compactError(error);
    }
  }

  /// The release page redirect still answers once the hourly API quota is spent.
  @visibleForTesting
  Future<Map<String, dynamic>> latestRelease() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$repository/releases/latest',
        options: Options(responseType: ResponseType.json),
      );
      return response.data!;
    } on DioException catch (error) {
      commonPrint.log(
        'latest release API failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
    final response = await dio.get<void>(
      'https://github.com/$repository/releases/latest',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    final location = response.headers.value(HttpHeaders.locationHeader);
    final segments = Uri.tryParse(location ?? '')?.pathSegments ?? const [];
    final tagIndex = segments.indexOf('tag') + 1;
    if (tagIndex == 0 || tagIndex >= segments.length) {
      throw FormatException('No release tag in the redirect', location);
    }
    return {'tag_name': segments[tagIndex]};
  }
}

final request = Request();

/// Some subscription servers send a gzip or zlib body without saying so in
/// Content-Encoding, which is the only signal dart:io decompresses on.
Uint8List decompressUnlabeled(Uint8List bytes) {
  final codec = switch (bytes) {
    [0x1f, 0x8b, ...] => gzip,
    [0x78, final flags, ...] when (0x78 << 8 | flags) % 31 == 0 => zlib,
    _ => null,
  };
  if (codec == null) {
    return bytes;
  }
  try {
    return Uint8List.fromList(codec.decode(bytes));
  } on FormatException {
    return bytes;
  }
}

/// dart:io turns [Uri.userInfo] into Basic credentials still percent-encoded.
@visibleForTesting
({Uri uri, Map<String, Object> headers}) downloadTarget(String url) {
  final uri = url.webUri ?? Uri.parse(url);
  if (uri.userInfo.isEmpty) {
    return (uri: uri, headers: const {});
  }
  final credentials = uri.userInfo.split(':').map(_decodeUserInfo).join(':');
  return (
    uri: uri.replace(userInfo: ''),
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ${base64.encode(utf8.encode(credentials))}',
    },
  );
}

String _decodeUserInfo(String value) {
  try {
    return Uri.decodeComponent(value);
  } on ArgumentError {
    return value;
  }
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
