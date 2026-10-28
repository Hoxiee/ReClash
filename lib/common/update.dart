import 'dart:io';

import 'package:dio/dio.dart';

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/package.dart';
import 'package:reclash/enum/enum.dart';
import 'update_summary.dart';

const _releaseConnectTimeout = Duration(seconds: 12);
const _releaseReceiveTimeout = Duration(seconds: 30);

abstract interface class AppUpdateSource {
  String get id;

  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
  });

  Uri releasePage(String tag);

  Uri assetUri(String url);
}

class AppUpdateRelease {
  const AppUpdateRelease({required this.data, required this.source});

  final Map<String, dynamic> data;
  final AppUpdateSource source;

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

class GitHubUpdateSource implements AppUpdateSource {
  const GitHubUpdateSource(this._dio);

  final Dio _dio;

  @override
  String get id => 'github';

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://api.github.com/repos/$repository/releases',
        queryParameters: const {'per_page': 100},
        options: Options(
          responseType: ResponseType.json,
          connectTimeout: _releaseConnectTimeout,
          receiveTimeout: _releaseReceiveTimeout,
        ),
      );
      final data = response.data;
      if (data == null ||
          data.any((release) => release is! Map<String, dynamic>)) {
        throw const FormatException('Invalid GitHub releases response');
      }
      return data.cast<Map<String, dynamic>>();
    } on DioException {
      if (channel == UpdateChannel.pre) rethrow;
      return [await _latestStableRelease()];
    }
  }

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
  Uri releasePage(String tag) => Uri(
    scheme: 'https',
    host: 'github.com',
    pathSegments: [...repository.split('/'), 'releases', 'tag', tag],
  );

  @override
  Uri assetUri(String url) {
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
}

UpdateChannel defaultUpdateChannel({required bool isPreBuild}) =>
    isPreBuild ? UpdateChannel.pre : UpdateChannel.release;

UpdateChannel effectiveUpdateChannel({
  required UpdateChannel? configured,
  required bool isPreBuild,
}) => configured ?? defaultUpdateChannel(isPreBuild: isPreBuild);
