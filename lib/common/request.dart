import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path/path.dart' show normalize;
import 'package:reclash/common/common.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/state.dart';

const _updateDownloadTimeout = Duration(minutes: 10);

class Request {
  static final _updateDownloads = <String>{};

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
    bool resume = false,
    String? expectedSha256,
    int? expectedSize,
  }) async {
    final path = normalize(File(targetPath).absolute.path);
    if (!_updateDownloads.add(path)) {
      return 'Update download is already in progress';
    }
    final transfer = _UpdateFileTransfer(
      dio: _clashDio,
      uri: uri,
      target: File(path),
      onProgress: onProgress,
      cancelToken: cancelToken,
      resume: resume,
      expectedSha256: expectedSha256,
      expectedSize: expectedSize,
    );
    try {
      await transfer.run();
      return null;
    } catch (error) {
      if (error is DioException && CancelToken.isCancel(error)) return '';
      commonPrint.log(
        'downloadUpdateFile failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      if (error is UpdateDownloadVerificationException) rethrow;
      return compactError(error);
    } finally {
      _updateDownloads.remove(path);
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

class _UpdateFileTransfer {
  _UpdateFileTransfer({
    required this.dio,
    required this.uri,
    required this.target,
    required this.onProgress,
    required this.cancelToken,
    required this.resume,
    required this.expectedSha256,
    required this.expectedSize,
  });

  final Dio dio;
  final Uri uri;
  final File target;
  final ProgressCallback onProgress;
  final CancelToken cancelToken;
  final bool resume;
  final String? expectedSha256;
  final int? expectedSize;
  late final File _partial = File('${target.path}.tmp');
  late final File _metadataFile = File('${target.path}.tmp.json');
  late _UpdateResumeMetadata _metadata;
  CancelToken? _networkToken;
  bool _timedOut = false;
  bool _rangeRestarted = false;
  int _received = 0;

  Future<void> run() async {
    final digest = expectedSha256 == null
        ? null
        : parseAssetSha256('sha256:$expectedSha256');
    final timer = Timer(_updateDownloadTimeout, () {
      _timedOut = true;
      _networkToken?.cancel('Update download timed out');
    });
    unawaited(
      cancelToken.whenCancel.then((error) => _networkToken?.cancel(error)),
    );
    try {
      if ((expectedSha256 != null && digest == null) ||
          (resume && digest == null) ||
          (expectedSize != null && expectedSize! <= 0)) {
        throw const UpdateDownloadVerificationException(
          'Invalid pinned update asset',
        );
      }
      _metadata = _UpdateResumeMetadata(
        url: uri.toString(),
        sha256: digest,
        size: expectedSize,
      );
      await _restorePartial();
      _ensureActive();
      while (!await _receiveResponse()) {
        _ensureActive();
      }
      _ensureActive();
      await _publish();
    } catch (error) {
      if (!resume || error is UpdateDownloadVerificationException) {
        await _discardPartial();
      }
      _ensureActive();
      rethrow;
    } finally {
      timer.cancel();
      _networkToken?.cancel();
      _networkToken = null;
    }
  }

  Future<void> _restorePartial() async {
    if (resume && await _partial.exists() && await _metadataFile.exists()) {
      try {
        if (await _metadataFile.length() > 16384) {
          throw const FormatException('Update metadata is too large');
        }
        final saved = _UpdateResumeMetadata.fromJson(
          jsonDecode(await _metadataFile.readAsString()),
        );
        final length = await _partial.length();
        final total = saved.size ?? saved.total;
        if (saved.matches(_metadata) && (total == null || length <= total)) {
          _metadata = saved;
          _received = length;
          return;
        }
      } on Object {
        // A partial without its exact asset identity is never resumed.
      }
    }
    await _discardPartial();
  }

  Future<bool> _receiveResponse() async {
    _ensureActive();
    final networkToken = CancelToken();
    _networkToken = networkToken;
    final offset = _received;
    final validator = _metadata.validator;
    ResponseBody? body;
    var bodyConsumed = false;
    try {
      final response = await dio.getUri<ResponseBody>(
        uri,
        cancelToken: networkToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            HttpHeaders.acceptEncodingHeader: 'identity',
            if (offset > 0) HttpHeaders.rangeHeader: 'bytes=$offset-',
            if (offset > 0 && validator != null)
              HttpHeaders.ifRangeHeader: validator,
          },
          validateStatus: (_) => true,
        ),
      );
      body = response.data;
      final status = response.statusCode;
      if (status == HttpStatus.requestedRangeNotSatisfiable) {
        final total = _unsatisfiedRangeTotal(
          response.headers.value(HttpHeaders.contentRangeHeader),
        );
        if (expectedSize != null &&
            offset == expectedSize &&
            total == expectedSize) {
          _metadata = _metadata.withResponse(total: total);
          return true;
        }
        if (_rangeRestarted) {
          throw const UpdateDownloadVerificationException(
            'The server rejected the update range',
          );
        }
        _rangeRestarted = true;
        await _discardPartial();
        _metadata = _metadata.withoutResponse();
        return false;
      }
      if (status != HttpStatus.ok && status != HttpStatus.partialContent) {
        throw DioException.badResponse(
          statusCode: status ?? 0,
          requestOptions: response.requestOptions,
          response: response,
        );
      }
      final encoding = response.headers.value(
        HttpHeaders.contentEncodingHeader,
      );
      if (encoding != null && encoding.toLowerCase() != 'identity') {
        throw const UpdateDownloadVerificationException(
          'Encoded update ranges are not supported',
        );
      }
      final rawLength = response.headers.value(HttpHeaders.contentLengthHeader);
      final length = rawLength == null ? null : int.tryParse(rawLength);
      if (rawLength != null && (length == null || length < 0)) {
        throw const UpdateDownloadVerificationException(
          'Invalid update Content-Length',
        );
      }
      final range = status == HttpStatus.partialContent
          ? _UpdateContentRange.parse(
              response.headers.value(HttpHeaders.contentRangeHeader),
            )
          : null;
      if (status == HttpStatus.partialContent &&
          (range == null ||
              range.start != offset ||
              (length != null && length != range.length))) {
        throw const UpdateDownloadVerificationException(
          'Invalid update Content-Range',
        );
      }
      final total = range?.total ?? length ?? expectedSize;
      if (expectedSize != null && total != null && total != expectedSize) {
        throw const UpdateDownloadVerificationException(
          'Update length does not match the release',
        );
      }
      final etag = _strongUpdateEtag(
        response.headers.value(HttpHeaders.etagHeader),
      );
      final modified = _updateLastModified(
        response.headers.value(HttpHeaders.lastModifiedHeader),
      );
      if (range != null &&
          offset > 0 &&
          ((_metadata.total != null && _metadata.total != total) ||
              (_metadata.etag != null &&
                  etag != null &&
                  _metadata.etag != etag) ||
              (_metadata.etag == null &&
                  _metadata.lastModified != null &&
                  modified != null &&
                  _metadata.lastModified != modified))) {
        throw const UpdateDownloadVerificationException(
          'The resumed update resource changed',
        );
      }
      if (status == HttpStatus.ok) {
        await _partial.safeDelete();
        _received = 0;
        _metadata = _metadata.withoutResponse();
      }
      _metadata = _metadata.withResponse(
        total: total,
        etag: etag,
        lastModified: modified,
      );
      if (resume) {
        await _metadataFile.writeAsStringAtomically(
          jsonEncode(_metadata.toJson()),
        );
      }
      _ensureActive();
      if (body == null) {
        throw const UpdateDownloadVerificationException(
          'The update response has no body',
        );
      }
      final segmentLength = range?.length ?? length;
      final startedAt = _received;
      await _partial.parent.create(recursive: true);
      final file = await _partial.open(
        mode: _received > 0 ? FileMode.append : FileMode.write,
      );
      try {
        onProgress(_received, total ?? -1);
        bodyConsumed = true;
        await for (final chunk in body.stream) {
          _ensureActive();
          final next = _received + chunk.length;
          if ((total != null && next > total) ||
              (segmentLength != null && next - startedAt > segmentLength)) {
            throw const UpdateDownloadVerificationException(
              'The update body exceeds its declared length',
            );
          }
          await file.writeFrom(chunk);
          _received = next;
          onProgress(_received, total ?? -1);
        }
      } finally {
        try {
          await file.flush();
        } finally {
          await file.close();
        }
      }
      _ensureActive();
      if (segmentLength != null && _received - startedAt != segmentLength) {
        throw const HttpException(
          'The update download ended before its declared length',
        );
      }
      if (total != null && _received < total) {
        if (range != null && _received > startedAt) return false;
        throw const HttpException('The update download is incomplete');
      }
      return true;
    } finally {
      if (body != null && !bodyConsumed) {
        await body.stream.listen(null, onError: (Object error) {}).cancel();
      }
      networkToken.cancel();
      if (identical(_networkToken, networkToken)) _networkToken = null;
    }
  }

  Future<void> _publish() async {
    if (!await _partial.exists() ||
        await _partial.length() != _received ||
        _received == 0) {
      throw const UpdateDownloadVerificationException(
        'The update download produced an invalid file',
      );
    }
    final size = expectedSize ?? _metadata.total;
    if (size != null && _received != size) {
      throw const UpdateDownloadVerificationException(
        'The update file length is invalid',
      );
    }
    final digest = _metadata.sha256;
    if (digest != null && await fileSha256(_partial) != digest) {
      throw const UpdateDownloadVerificationException(
        'The update SHA-256 does not match the release',
      );
    }
    _ensureActive();
    await target.safeDelete();
    await _partial.rename(target.path);
    await _metadataFile.safeDelete();
    onProgress(_received, _received);
  }

  Future<void> _discardPartial() async {
    await _partial.safeDelete();
    await _metadataFile.safeDelete();
    _received = 0;
  }

  void _ensureActive() {
    if (_timedOut) {
      throw TimeoutException(
        'Update download timed out',
        _updateDownloadTimeout,
      );
    }
    if (cancelToken.cancelError case final error?) throw error;
  }
}

class _UpdateContentRange {
  const _UpdateContentRange(this.start, this.end, this.total);

  final int start;
  final int end;
  final int total;

  int get length => end - start + 1;

  static _UpdateContentRange? parse(String? header) {
    final match = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(header ?? '');
    if (match == null) return null;
    final start = int.tryParse(match.group(1)!);
    final end = int.tryParse(match.group(2)!);
    final total = int.tryParse(match.group(3)!);
    if (start == null ||
        end == null ||
        total == null ||
        start > end ||
        end >= total) {
      return null;
    }
    return _UpdateContentRange(start, end, total);
  }
}

class _UpdateResumeMetadata {
  const _UpdateResumeMetadata({
    required this.url,
    required this.sha256,
    required this.size,
    this.total,
    this.etag,
    this.lastModified,
  });

  final String url;
  final String? sha256;
  final int? size;
  final int? total;
  final String? etag;
  final String? lastModified;

  String? get validator => etag ?? lastModified;

  bool matches(_UpdateResumeMetadata other) =>
      url == other.url && sha256 == other.sha256 && size == other.size;

  _UpdateResumeMetadata withoutResponse() =>
      _UpdateResumeMetadata(url: url, sha256: sha256, size: size);

  _UpdateResumeMetadata withResponse({
    int? total,
    String? etag,
    String? lastModified,
  }) => _UpdateResumeMetadata(
    url: url,
    sha256: sha256,
    size: size,
    total: total ?? this.total,
    etag: etag ?? this.etag,
    lastModified: lastModified ?? this.lastModified,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'url': url,
    'sha256': sha256,
    'size': size,
    'total': total,
    'etag': etag,
    'lastModified': lastModified,
  };

  factory _UpdateResumeMetadata.fromJson(Object? value) {
    if (value is! Map<String, dynamic> || value['schemaVersion'] != 1) {
      throw const FormatException('Invalid update resume metadata');
    }
    final url = value['url'];
    final sha256 = value['sha256'];
    final size = value['size'];
    final total = value['total'];
    final etag = value['etag'];
    final modified = value['lastModified'];
    if (url is! String ||
        sha256 is! String ||
        parseAssetSha256('sha256:$sha256') == null ||
        (size != null && (size is! int || size <= 0)) ||
        (total != null && (total is! int || total <= 0)) ||
        (etag != null &&
            (etag is! String || _strongUpdateEtag(etag) == null)) ||
        (modified != null &&
            (modified is! String || _updateLastModified(modified) == null))) {
      throw const FormatException('Invalid update resume metadata identity');
    }
    return _UpdateResumeMetadata(
      url: url,
      sha256: sha256,
      size: size as int?,
      total: total as int?,
      etag: etag as String?,
      lastModified: modified as String?,
    );
  }
}

int? _unsatisfiedRangeTotal(String? header) {
  final match = RegExp(r'^bytes \*/(\d+)$').firstMatch(header ?? '');
  return match == null ? null : int.tryParse(match.group(1)!);
}

String? _strongUpdateEtag(String? header) =>
    header != null && RegExp(r'^"[^"\r\n]*"$').hasMatch(header) ? header : null;

String? _updateLastModified(String? header) {
  if (header == null) return null;
  try {
    HttpDate.parse(header);
    return header;
  } on FormatException {
    return null;
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
  final parts = uri.userInfo.split(':');
  if (parts.length == 1) parts.add('');
  final credentials = parts.map(_decodeUserInfo).join(':');
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
  try {
    final parameters = HeaderValue.parse(disposition).parameters;
    return _decodeDispositionFileName(parameters['filename*']) ??
        parameters['filename'];
  } on HttpException {
    return null;
  }
}

String? _decodeDispositionFileName(String? value) {
  if (value == null) return null;
  final parts = value.split("'");
  if (parts.length != 3 || parts.last.isEmpty) return null;
  final encoding = switch (parts.first.toLowerCase()) {
    'utf-8' => utf8,
    'iso-8859-1' => latin1,
    _ => null,
  };
  if (encoding == null) return null;
  try {
    return Uri.decodeQueryComponent(
      parts.last.replaceAll('+', '%2B'),
      encoding: encoding,
    );
  } on FormatException {
    return null;
  } on ArgumentError {
    return null;
  }
}
