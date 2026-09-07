import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('profile_save_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  setUp(() async {
    await preferences.clearPreferences();
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Profile.saveFile', () {
    // EditProfileView relies on this throwing rather than silently
    // succeeding, so a caller-level try/catch can surface the failure.
    test('rejects an invalid config without touching the saved file', () async {
      final profile = Profile.normal(label: 'p');
      final bytes = Uint8List.fromList(utf8.encode('bad: ['));

      await expectLater(
        profile.saveFile(bytes, validate: (_) async => 'invalid config'),
        throwsA(
          isA<MessageException>().having(
            (e) => e.message,
            'message',
            'invalid config',
          ),
        ),
      );

      final savedFile = await profile.file;
      expect(await savedFile.length(), 0);
    });

    test('copies validated bytes and stamps the update time', () async {
      final profile = Profile.normal(label: 'p');
      final bytes = Uint8List.fromList(utf8.encode('proxies: []'));

      final saved = await profile.saveFile(bytes, validate: (_) async => '');

      expect(saved.lastUpdateDate, isNotNull);
      final savedFile = await profile.file;
      expect(await savedFile.readAsString(), 'proxies: []');
    });
  });

  group('Profile.update domain migration', () {
    test('commits the separately validated candidate response', () async {
      final profile = Profile.normal(
        label: 'old',
        url: 'https://old.test:8443/sub?token=abc',
        clientEmulation: SubscriptionClient.clash,
      );
      final requests = <String>[];
      final sentHeaders = <Map<String, String>?>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (path) async =>
            const ConfigInspection(servers: ['node.example.org']),
        fetch: (url, {headers}) async {
          requests.add(url);
          sentHeaders.add(headers);
          return _response(
            url,
            url.contains('new.test') ? 'candidate payload' : 'old payload',
            headers: {
              'flclashx-newdomain': [
                url.contains('new.test') ? 'ignored.test' : 'new.test:9443',
              ],
            },
          );
        },
      );

      expect(requests, [
        'https://old.test:8443/sub?token=abc',
        'https://new.test:9443/sub?token=abc',
      ]);
      expect(sentHeaders[1], sentHeaders[0]);
      expect(updated.url, 'https://new.test:9443/sub?token=abc');
      expect(await (await updated.file).readAsString(), 'candidate payload');
    });

    test('keeps the old response when the candidate fetch fails', () async {
      await _expectOldHostFallback((url, {headers}) async {
        if (url.contains('new.test')) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.connectionError,
          );
        }
        return _response(
          url,
          'old payload',
          headers: const {
            'flclashx-newdomain': ['new.test'],
          },
        );
      });
    });

    test(
      'keeps the old response when the candidate config is invalid',
      () async {
        await _expectOldHostFallback(
          (url, {headers}) async => _response(
            url,
            url.contains('new.test') ? 'invalid candidate' : 'old payload',
            headers: url.contains('new.test')
                ? null
                : const {
                    'flclashx-newdomain': ['new.test'],
                  },
          ),
          validate: (path) async =>
              (await File(path).readAsString()).contains('invalid')
              ? 'invalid config'
              : '',
        );
      },
    );

    test('keeps the old response when the candidate is undialable', () async {
      await _expectOldHostFallback(
        (url, {headers}) async => _response(
          url,
          url.contains('new.test') ? 'stub candidate' : 'old payload',
          headers: url.contains('new.test')
              ? null
              : const {
                  'flclashx-newdomain': ['new.test'],
                },
        ),
        inspect: (path) async => ConfigInspection(
          servers: (await File(path).readAsString()).contains('old')
              ? const ['node.example.org']
              : const [],
        ),
      );
    });
  });
}

Response<Uint8List> _response(
  String url,
  String content, {
  Map<String, List<String>>? headers,
}) {
  return Response<Uint8List>(
    requestOptions: RequestOptions(path: url),
    data: Uint8List.fromList(utf8.encode(content)),
    headers: Headers.fromMap(headers ?? const {}),
  );
}

Future<void> _expectOldHostFallback(
  FetchProfileResponse fetch, {
  ValidateConfig? validate,
  InspectConfig? inspect,
}) async {
  final profile = Profile.normal(
    label: 'old',
    url: 'https://old.test/sub?token=abc',
    clientEmulation: SubscriptionClient.clash,
  );
  final updated = await profile.update(
    validate: validate ?? (_) async => '',
    inspect:
        inspect ??
        (_) async => const ConfigInspection(servers: ['node.example']),
    fetch: fetch,
  );

  expect(updated.url, 'https://old.test/sub?token=abc');
  expect(await (await updated.file).readAsString(), 'old payload');
}
