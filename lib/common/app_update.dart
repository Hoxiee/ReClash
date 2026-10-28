import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

class UpdateDownloadVerificationException implements Exception {
  const UpdateDownloadVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

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

bool matchesAndroidTarget(String assetName, String target) =>
    assetName.toLowerCase().endsWith('-android-${target.toLowerCase()}.apk');

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
    if (name is! String ||
        url is! String ||
        !name.toLowerCase().endsWith('.apk')) {
      continue;
    }
    candidates.add(
      AndroidUpdateAsset(
        name: name,
        url: url,
        size: raw['size'] is int ? raw['size'] as int : null,
        sha256: parseAssetSha256(raw['digest']),
      ),
    );
  }
  for (final abi in supportedAbis) {
    for (final asset in candidates) {
      if (matchesAndroidTarget(asset.name, abi)) return asset;
    }
  }
  for (final asset in candidates) {
    if (matchesAndroidTarget(asset.name, 'universal')) return asset;
  }
  return candidates.length == 1 &&
          !candidates.single.name.toLowerCase().contains('-android-')
      ? candidates.single
      : null;
}

String? parseAssetSha256(Object? digest) {
  if (digest is! String || !digest.startsWith('sha256:')) return null;
  final value = digest.substring('sha256:'.length).toLowerCase();
  return RegExp(r'^[0-9a-f]{64}$').hasMatch(value) ? value : null;
}

String updateApkFileName(String tag) {
  final safeTag = tag.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return 'update-${safeTag.isEmpty ? 'latest' : safeTag}.apk';
}

Future<String> fileSha256(File file) {
  final path = file.path;
  return Isolate.run(() => _fileSha256AtPath(path));
}

Future<String> _fileSha256AtPath(String path) async =>
    (await sha256.bind(File(path).openRead()).first).toString();

Future<bool> matchesUpdateAsset(File file, AndroidUpdateAsset asset) async {
  final expected = asset.sha256;
  if (expected == null || !await file.exists()) return false;
  try {
    final size = asset.size;
    if (size != null && await file.length() != size) return false;
    return await fileSha256(file) == expected;
  } on FileSystemException {
    return false;
  }
}

Future<void> removeStaleUpdateApks(
  Directory directory, {
  Set<String> keep = const {},
  Set<String> keepPartial = const {},
}) async {
  try {
    final apkFiles = <File>[];
    final temporaryFiles = <File>[];
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final name = basename(entity.path);
      if (!name.startsWith('update-')) continue;
      final partialAt = name.lastIndexOf('.apk.tmp');
      if (partialAt >= 0 &&
          (name.endsWith('.apk.tmp') ||
              name.endsWith('.apk.tmp.json') ||
              RegExp(r'\.apk\.tmp\.json\.\d+\.tmp$').hasMatch(name))) {
        final apkName = name.substring(0, partialAt + '.apk'.length);
        if (!keepPartial.contains(apkName)) temporaryFiles.add(entity);
      } else if (name.endsWith('.apk')) {
        apkFiles.add(entity);
      }
    }
    for (final file in temporaryFiles) {
      await file.delete();
    }
    var retained = keep;
    if (retained.isEmpty && apkFiles.isNotEmpty) {
      apkFiles.sort(
        (left, right) =>
            right.lastModifiedSync().compareTo(left.lastModifiedSync()),
      );
      retained = {basename(apkFiles.first.path)};
    }
    for (final file in apkFiles) {
      if (!retained.contains(basename(file.path))) await file.delete();
    }
  } on FileSystemException {
    return;
  }
}
