import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:reclash/common/app_update.dart';
import 'package:reclash/common/app_update_runtime.dart';
import 'package:reclash/common/update.dart';
import 'package:reclash/common/update_summary.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';

class TestUpdateSource implements AppUpdateSource {
  const TestUpdateSource();

  @override
  String get id => 'test';

  @override
  Uri assetUri(String url) => Uri.parse(url);

  @override
  Uri releasePage(String tag) => Uri.https('updates.example', '/$tag');

  @override
  Future<List<Map<String, dynamic>>> fetchReleases({
    required UpdateChannel channel,
  }) async => [];
}

final updateTestBytes = utf8.encode('a verified package for the update tests');

AppUpdateRelease testUpdateRelease({
  String tag = 'v0.8.96',
  bool authored = true,
  bool automatic = true,
  bool breaking = false,
  bool warning = false,
  bool prerelease = false,
  bool digest = true,
}) {
  final summary = ReleaseSummary(
    tag: tag,
    automaticInstall: automatic,
    locales: {
      'en': ReleaseSummaryLocale(
        headline: 'Updates without interruption',
        spotlight: const ReleaseHighlight(
          title: 'Your background',
          description: 'Choose a wallpaper.',
          kind: 'wallpaper',
        ),
        warnings: warning
            ? const [
                ReleaseHighlight(
                  title: 'Read first',
                  description: 'Make an explicit choice.',
                ),
              ]
            : const [],
      ),
    },
  );
  final changelog = jsonEncode({
    'schemaVersion': 2,
    'versions': [
      {
        'version': tag.substring(1),
        'tag': tag,
        'prerelease': prerelease,
        'groups': [
          {
            'type': breaking ? 'breaking' : 'feat',
            'entries': [
              {
                'id': 'example',
                'text': breaking ? 'Review this change.' : 'Improved updates.',
              },
            ],
          },
        ],
      },
    ],
  });
  return AppUpdateRelease(
    source: const TestUpdateSource(),
    data: {
      'tag_name': tag,
      'prerelease': prerelease,
      'published_at': '2026-10-18T10:00:00Z',
      'body':
          '${authored ? renderReleaseSummary(summary) : ''}<!-- reclash:changelog:json\n$changelog\n-->\n',
      'assets': [
        {
          'name': 'ReClash-android-arm64-v8a.apk',
          'browser_download_url': 'https://updates.example/update.apk',
          'size': updateTestBytes.length,
          if (digest) 'digest': 'sha256:${sha256.convert(updateTestBytes)}',
        },
      ],
    },
  );
}

class TestUpdateRuntime extends AppUpdateRuntime {
  TestUpdateRuntime(this.root);

  final Directory root;
  bool enabled = true;
  bool wifi = false;
  bool vpn = false;
  bool permission = true;
  bool validPackage = true;
  bool saved = true;
  String version = '0.8.95';
  String actualVersion = '0.8.95';
  int downloads = 0;
  int verifies = 0;
  int installations = 0;
  int permissionRequests = 0;
  int confirmations = 0;
  bool? lastAutomatic;
  Config? savedConfig;
  AppUpdateRelease? available;
  Object? checkFailure;
  ApkInstallStatus nativeStatus = ApkInstallStatus.installing;
  Future<String?> Function(String, CancelToken, ProgressCallback)?
  downloadOperation;
  Future<bool> Function()? verifyOperation;
  Future<bool> Function()? confirmOperation;
  Future<bool> Function()? saveOperation;
  final wifiEvents = StreamController<bool>.broadcast(sync: true);
  final installEvents = StreamController<ApkInstallStatus>.broadcast(
    sync: true,
  );

  @override
  bool get supported => enabled;

  @override
  String get installedVersion => version;

  @override
  Future<AppUpdateRelease?> check(UpdateChannel channel) async {
    if (checkFailure case final error?) throw error;
    return available;
  }

  @override
  Future<Directory> directory() async {
    await root.create(recursive: true);
    return root;
  }

  @override
  Future<List<String>> supportedAbis() async => ['arm64-v8a'];

  @override
  Future<bool> onWifi() async => wifi;

  @override
  Stream<bool> get wifiChanges => wifiEvents.stream;

  @override
  Stream<ApkInstallStatus> get installChanges => installEvents.stream;

  void setWifi(bool value) {
    wifi = value;
    wifiEvents.add(value);
  }

  @override
  Future<String?> download(
    Uri uri,
    String path, {
    required CancelToken cancelToken,
    required ProgressCallback onProgress,
    required String sha256,
    int? size,
  }) async {
    downloads++;
    if (downloadOperation case final operation?) {
      return operation(path, cancelToken, onProgress);
    }
    await File(path).writeAsBytes(updateTestBytes);
    onProgress(updateTestBytes.length, updateTestBytes.length);
    return null;
  }

  @override
  Future<bool> verify(
    File file,
    AndroidUpdateAsset asset,
    String version,
  ) async {
    verifies++;
    return (verifyOperation != null
            ? await verifyOperation!()
            : validPackage) &&
        await matchesUpdateAsset(file, asset);
  }

  @override
  Future<bool> vpnActive() async => vpn;

  @override
  Future<bool> installPermission() async => permission;

  @override
  Future<bool> openPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<ApkInstallResult> install(
    String path, {
    required String version,
    required String sha256,
    required bool automatic,
  }) async {
    if (vpn) return ApkInstallResult.vpnActive;
    if (!permission) return ApkInstallResult.permissionRequired;
    installations++;
    lastAutomatic = automatic;
    return ApkInstallResult.started;
  }

  @override
  Future<ApkInstallStatus> installStatus() async => nativeStatus;

  @override
  Future<bool> confirmInstall() async {
    confirmations++;
    return confirmOperation != null ? confirmOperation!() : true;
  }

  @override
  Future<bool> saveConfig(Config config) async {
    savedConfig = config;
    return saveOperation != null ? saveOperation!() : saved;
  }

  @override
  Future<String> actualInstalledVersion() async => actualVersion;

  @override
  AppUpdateSource? source(String id) =>
      id == 'test' ? const TestUpdateSource() : null;

  Future<void> dispose() async {
    await wifiEvents.close();
    await installEvents.close();
  }
}
