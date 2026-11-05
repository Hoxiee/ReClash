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

class UpdateAsset {
  const UpdateAsset({
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

UpdateAsset? selectAndroidUpdateAsset(
  Object? assets, {
  required List<String> supportedAbis,
}) {
  if (assets is! List) return null;
  final candidates = <UpdateAsset>[];
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
      UpdateAsset(
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

const updatePackageSuffixes = ['.apk', '-setup.exe', '.AppImage', '.dmg'];

final updatePackageNamePattern = RegExp(
  r'^update-[A-Za-z0-9._-]+(\.apk|-setup\.exe|\.AppImage|\.dmg)$',
);

String updateFileName(String tag, {String suffix = '.apk'}) {
  final safeTag = tag.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return 'update-${safeTag.isEmpty ? 'latest' : safeTag}$suffix';
}

Future<String> fileSha256(File file) {
  final path = file.path;
  return Isolate.run(() => _fileSha256AtPath(path));
}

Future<String> _fileSha256AtPath(String path) async =>
    (await sha256.bind(File(path).openRead()).first).toString();

Future<bool> matchesUpdateAsset(File file, UpdateAsset asset) async {
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

Future<void> removeStaleUpdateFiles(
  Directory directory, {
  Set<String> keep = const {},
  Set<String> keepPartial = const {},
}) async {
  try {
    final packages = <File>[];
    final temporaryFiles = <File>[];
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final name = basename(entity.path);
      if (!name.startsWith('update-')) continue;
      final partial = RegExp(
        r'^(.+?)\.tmp(\.json(\.\d+\.tmp)?)?$',
      ).firstMatch(name)?.group(1);
      if (partial != null && updatePackageSuffixes.any(partial.endsWith)) {
        if (!keepPartial.contains(partial)) temporaryFiles.add(entity);
      } else if (updatePackageSuffixes.any(name.endsWith)) {
        packages.add(entity);
      }
    }
    for (final file in temporaryFiles) {
      await file.delete();
    }
    var retained = keep;
    if (retained.isEmpty && packages.isNotEmpty) {
      packages.sort(
        (left, right) =>
            right.lastModifiedSync().compareTo(left.lastModifiedSync()),
      );
      retained = {basename(packages.first.path)};
    }
    for (final file in packages) {
      if (!retained.contains(basename(file.path))) await file.delete();
    }
  } on FileSystemException {
    return;
  }
}
