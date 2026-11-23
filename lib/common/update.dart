import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/package.dart';
import 'package:reclash/enum/enum.dart';

import 'update_manifest.dart';
import 'update_summary.dart';

const _releaseConnectTimeout = Duration(seconds: 12);
const _releaseReceiveTimeout = Duration(seconds: 30);
const _releaseResponseLimit = 8 * 1024 * 1024;
const _releaseHistorySize = 30;
const _isolateDecodeThreshold = 50 * 1024;
const mirrorUpdateSourceId = 'mirror';
const officialUpdateSourceId = 'cdn';
const updateMirrorUrls = String.fromEnvironment('UPDATE_MIRROR_URLS');

abstract interface class AppUpdateSource {
  String get id;

  /// [installedVersion] lets a source stop at a cheap probe when nothing
  /// newer exists.
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
    required String installedVersion,
  });

  Uri releasePage(String tag);

  Uri assetUri(String url);
}

class AppUpdateRelease {
  const AppUpdateRelease({
    required this.data,
    required this.source,
    this.skipped = const [],
  });

  final Map<String, dynamic> data;
  final AppUpdateSource source;

  /// The releases between the installed version and this one, newest first.
  final List<AppUpdateRelease> skipped;

  String get tag => data['tag_name'] as String;
  String? get body => data['body'] is String ? data['body'] as String : null;
  ReleaseSummary? get summary => parseReleaseSummary(body, tag: tag);
  bool get prerelease => isPrereleaseRelease(
    tag: tag,
    flaggedPrerelease: data['prerelease'] == true,
  );
  List<dynamic> get assets =>
      data['assets'] is List ? data['assets'] as List<dynamic> : const [];
}

/// The last answer to each URL with its validators: a 304 costs GitHub no
/// quota and the client no decoding or signature checks.
class UpdateResponseCache {
  final _entries =
      <Uri, ({String? etag, String? lastModified, Object value})>{};

  Future<T> get<T extends Object>(
    Dio dio,
    Uri uri, {
    required FutureOr<T> Function(Uint8List bytes) parse,
    Map<String, String> headers = const {},
    int limit = _releaseResponseLimit,
  }) async {
    final cached = _entries[uri];
    final response = await dio.getUri<ResponseBody>(
      uri,
      options: Options(
        responseType: ResponseType.stream,
        connectTimeout: _releaseConnectTimeout,
        receiveTimeout: _releaseReceiveTimeout,
        validateStatus: (status) =>
            status == HttpStatus.ok || status == HttpStatus.notModified,
        headers: {
          ...headers,
          HttpHeaders.ifNoneMatchHeader: ?cached?.etag,
          HttpHeaders.ifModifiedSinceHeader: ?cached?.lastModified,
        },
      ),
    );
    final body = response.data!;
    if (response.statusCode == HttpStatus.notModified) {
      await body.stream.drain<void>();
      if (cached?.value case final T value) return value;
      throw FormatException('Not modified without a cached answer', '$uri');
    }
    final value = await parse(await _readCapped(body, limit));
    final etag = response.headers.value(HttpHeaders.etagHeader);
    final lastModified = response.headers.value(HttpHeaders.lastModifiedHeader);
    if (etag != null || lastModified != null) {
      _entries[uri] = (etag: etag, lastModified: lastModified, value: value);
    } else {
      _entries.remove(uri);
    }
    return value;
  }
}

Future<Uint8List> _readCapped(ResponseBody body, int limit) async {
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in body.stream) {
    if (bytes.length + chunk.length > limit) {
      throw const FormatException('Update response is too large');
    }
    bytes.add(chunk);
  }
  return bytes.takeBytes();
}

Future<Object?> _decodeJson(Uint8List bytes) =>
    bytes.length < _isolateDecodeThreshold
    ? Future.value(jsonDecode(utf8.decode(bytes)))
    : Isolate.run(() => jsonDecode(utf8.decode(bytes)));

Uri _gitHubReleasePage(String tag) => Uri(
  scheme: 'https',
  host: 'github.com',
  pathSegments: [...repository.split('/'), 'releases', 'tag', tag],
);

Uri _gitHubAssetUri(String tag, String name) =>
    Uri.https('github.com', '/$repository/releases/download/$tag/$name');

List<Uri> parseUpdateMirrorUrls(String value) => [
  for (final url in value.split(','))
    if (Uri.tryParse(url.trim()) case final uri?
        when uri.isScheme('https') &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty &&
            !uri.hasQuery &&
            !uri.hasFragment)
      uri.replace(path: '${uri.path.replaceFirst(RegExp(r'/+$'), '')}/'),
];

List<Uri> updateDownloadUris(Uri origin, String digest, List<Uri> mirrors) {
  final segments = origin.pathSegments;
  if (segments.length != 6 ||
      tryParseAppVersion(segments[4]) == null ||
      origin != _gitHubAssetUri(segments[4], segments[5]) ||
      !RegExp(r'^[0-9A-Za-z._+-]+$').hasMatch(segments[5])) {
    return [origin];
  }
  final tag = segments[4];
  final name = Uri.encodeComponent(segments[5]);
  return {
    origin,
    for (final mirror in mirrors) mirror.resolve('releases/$tag/$digest/$name'),
  }.toList();
}

Uri _httpsAssetUri(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    throw const FormatException(
      'Update asset URL must be an absolute HTTPS URL',
    );
  }
  return uri;
}

class GitHubUpdateSource implements AppUpdateSource {
  GitHubUpdateSource(this._dio, [UpdateResponseCache? cache])
    : _cache = cache ?? UpdateResponseCache();

  static const _api = 'https://api.github.com/repos/$repository/releases';
  static const _headers = {
    HttpHeaders.acceptHeader: 'application/vnd.github+json',
  };

  final Dio _dio;
  final UpdateResponseCache _cache;
  ({String newest, List<Map<String, dynamic>> releases})? _history;

  @override
  String get id => 'github';

  /// One small probe per check; the release history, needed only for the
  /// notes of skipped versions, is read once per newer release.
  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
    required String installedVersion,
  }) async {
    final List<Map<String, dynamic>> newest;
    try {
      newest = channel == UpdateChannel.release
          ? [await _get(Uri.parse('$_api/latest'), _release)]
          : await _get(Uri.parse('$_api?per_page=1'), _releases);
    } on DioException catch (error) {
      if (channel == UpdateChannel.pre) rethrow;
      if (error.response?.statusCode == HttpStatus.notFound) return const [];
      return [await _latestStableRelease()];
    }
    final tag = newest.firstOrNull?['tag_name'];
    if (tag is! String || !_mayBeNewer(tag, installedVersion)) return newest;
    if (_history case (newest: final seen, :final releases) when seen == tag) {
      return releases;
    }
    try {
      final releases = await _get(
        Uri.parse('$_api?per_page=$_releaseHistorySize'),
        _releases,
      );
      _history = (newest: tag, releases: releases);
      return releases;
    } on DioException {
      return newest;
    }
  }

  Future<T> _get<T extends Object>(
    Uri uri,
    FutureOr<T> Function(Object? json) parse,
  ) => _cache.get(
    _dio,
    uri,
    headers: _headers,
    parse: (bytes) async => parse(await _decodeJson(bytes)),
  );

  static bool _mayBeNewer(String tag, String installedVersion) {
    if (tryParseAppVersion(tag) == null ||
        tryParseAppVersion(installedVersion) == null) {
      return true;
    }
    return compareVersions(tag, installedVersion) > 0;
  }

  static Map<String, dynamic> _release(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid GitHub release response');
    }
    return json;
  }

  static List<Map<String, dynamic>> _releases(Object? json) {
    if (json is! List ||
        json.any((release) => release is! Map<String, dynamic>)) {
      throw const FormatException('Invalid GitHub releases response');
    }
    return json.cast<Map<String, dynamic>>();
  }

  /// The release page redirect still answers once the hourly API quota is
  /// spent.
  Future<Map<String, dynamic>> _latestStableRelease() async {
    final response = await _dio.get<void>(
      'https://github.com/$repository/releases/latest',
      options: Options(
        followRedirects: false,
        connectTimeout: _releaseConnectTimeout,
        receiveTimeout: _releaseReceiveTimeout,
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

  @override
  Uri releasePage(String tag) => _gitHubReleasePage(tag);

  @override
  Uri assetUri(String url) => _httpsAssetUri(url);
}

/// A provider's copy of the signed release manifest. Only releases signed
/// with [keys] pass, so the mirror decides where packages download from and
/// when a release is offered, never what installs.
class MirrorUpdateSource implements AppUpdateSource {
  MirrorUpdateSource(
    this._dio,
    this.manifest,
    this._cache, {
    this.keys = updateManifestKeys,
  });

  final Dio _dio;

  /// Null for the source of a restored pending update, which is not asked
  /// again.
  final Uri? manifest;
  final UpdateResponseCache _cache;
  final List<String> keys;

  @override
  String get id => mirrorUpdateSourceId;

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
    required String installedVersion,
  }) async {
    final manifest = this.manifest;
    if (manifest == null) throw StateError('No update manifest URL');
    if (!manifest.isScheme('https')) {
      throw const UpdateManifestException('not https');
    }
    final keys = this.keys;
    final official = id == officialUpdateSourceId;
    return _cache.get(
      _dio,
      manifest,
      limit: updateManifestLimit,
      parse: (bytes) => Isolate.run(() async {
        final releases = await parseUpdateManifest(bytes, keys: keys);
        return official ? _officialReleases(releases) : releases;
      }),
    );
  }

  @override
  Uri releasePage(String tag) => _gitHubReleasePage(tag);

  @override
  Uri assetUri(String url) => _httpsAssetUri(url);
}

class OfficialUpdateSource extends MirrorUpdateSource {
  OfficialUpdateSource(
    Dio dio,
    Uri base,
    UpdateResponseCache cache, {
    super.keys,
  }) : super(dio, base.resolve(updateManifestFileName), cache);

  @override
  String get id => officialUpdateSourceId;

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
    required String installedVersion,
  }) async {
    final releases = await super.fetchReleases(
      channel: channel,
      installedVersion: installedVersion,
    );
    if (channel == UpdateChannel.release &&
        releases.every(
          (release) => isPrereleaseRelease(
            tag: release['tag_name'] as String,
            flaggedPrerelease: release['prerelease'] == true,
          ),
        )) {
      throw const UpdateManifestException('no stable release in catalog');
    }
    return releases;
  }
}

List<Map<String, dynamic>> _officialReleases(
  List<Map<String, dynamic>> releases,
) {
  if (releases.isEmpty) {
    throw const UpdateManifestException('empty release catalog');
  }
  return [
    for (final release in releases)
      {
        ...release,
        'assets': [
          for (final asset
              in (release['assets'] as List).cast<Map<String, dynamic>>())
            {
              ...asset,
              'browser_download_url': _gitHubAssetUri(
                release['tag_name'] as String,
                asset['name'] as String,
              ).toString(),
            },
        ],
      },
  ];
}

UpdateChannel defaultUpdateChannel({required bool isPreBuild}) =>
    isPreBuild ? UpdateChannel.pre : UpdateChannel.release;

UpdateChannel effectiveUpdateChannel({
  required UpdateChannel? configured,
  required bool isPreBuild,
}) => configured ?? defaultUpdateChannel(isPreBuild: isPreBuild);
