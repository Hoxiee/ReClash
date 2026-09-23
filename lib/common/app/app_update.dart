import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

class AndroidUpdateAsset {
  const AndroidUpdateAsset({
    required this.name,
    required this.url,
    this.size,
    this.sha256,
  });

  final String name;
  final String url;
  final int? size;
  final String? sha256;
}

/// Release APKs are named `<app>-<version>-android-<abi>.apk`; the version moves
/// with every release, so only the ABI suffix can be matched.
bool matchesAndroidTarget(String assetName, String target) {
  return assetName.toLowerCase().endsWith(
    '-android-${target.toLowerCase()}.apk',
  );
}

/// [supportedAbis] is ordered best-first by Android, so the first hit wins.
AndroidUpdateAsset? selectAndroidUpdateAsset(
  Object? assets, {
  required List<String> supportedAbis,
}) {
  if (assets is! List) return null;
  final candidates = <AndroidUpdateAsset>[];
  for (final raw in assets) {
    if (raw is! Map) continue;
    final name = raw['name'];
    final url = raw['browser_download_url'];
    if (name is! String || url is! String) continue;
    if (!name.toLowerCase().endsWith('.apk')) continue;
    final size = raw['size'];
    candidates.add(
      AndroidUpdateAsset(
        name: name,
        url: url,
        size: size is int ? size : null,
        sha256: parseAssetSha256(raw['digest']),
      ),
    );
  }
  for (final abi in supportedAbis) {
    final match = candidates.firstWhereOrNull(
      (asset) => matchesAndroidTarget(asset.name, abi),
    );
    if (match != null) return match;
  }
  final universal = candidates.firstWhereOrNull(
    (asset) => matchesAndroidTarget(asset.name, 'universal'),
  );
  if (universal != null) return universal;
  // A release shipping a single APK needs no ABI token to be unambiguous.
  return candidates.length == 1 ? candidates.first : null;
}

String? parseAssetSha256(Object? digest) {
  if (digest is! String) return null;
  const prefix = 'sha256:';
  if (!digest.startsWith(prefix)) return null;
  final value = digest.substring(prefix.length).toLowerCase();
  return RegExp(r'^[0-9a-f]{64}$').hasMatch(value) ? value : null;
}

const updateApkPrefix = 'update-';

String updateApkFileName(String tag) {
  final safeTag = tag.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return '$updateApkPrefix${safeTag.isEmpty ? 'latest' : safeTag}.apk';
}

bool isStaleUpdateApk(String fileName, {required String keepFileName}) {
  if (fileName == keepFileName) return false;
  if (!fileName.startsWith(updateApkPrefix)) return false;
  return fileName.endsWith('.apk') || fileName.endsWith('.apk.tmp');
}

Future<String> fileSha256(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}

/// A digest makes the answer exact; without one a matching size is all the
/// release metadata offers.
Future<bool> matchesUpdateAsset(File file, AndroidUpdateAsset asset) async {
  if (!await file.exists()) return false;
  final expected = asset.sha256;
  if (expected != null) {
    try {
      return await fileSha256(file) == expected;
    } on FileSystemException {
      return false;
    }
  }
  final size = asset.size;
  if (size == null) return false;
  return await file.length() == size;
}

Future<void> removeStaleUpdateApks(String keepPath) async {
  try {
    final keepName = basename(keepPath);
    await for (final entry in Directory(dirname(keepPath)).list()) {
      if (entry is! File) continue;
      if (isStaleUpdateApk(basename(entry.path), keepFileName: keepName)) {
        await entry.delete();
      }
    }
  } catch (_) {
    // Best effort: a leftover APK costs disk space and nothing else.
  }
}
