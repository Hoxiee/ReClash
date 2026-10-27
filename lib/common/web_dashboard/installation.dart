import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/enum/enum.dart';

import 'archive.dart';
import 'dashboard.dart';
import 'hosting.dart';

typedef WebDashboardDownload =
    Future<String?> Function(
      Uri uri,
      String destination, {
      required ProgressCallback onProgress,
      required CancelToken cancelToken,
    });

typedef WebDashboardRename =
    Future<void> Function(String source, String target);

Future<void> _renameDirectory(String source, String target) async {
  await Directory(source).rename(target);
}

Future<bool> _verifyArchive((String, String, String) args) async {
  final (path, digest, cancelPath) = args;
  final actual = await sha256
      .bind(
        File(path).openRead().map((bytes) {
          if (File(cancelPath).existsSync()) {
            throw const WebDashboardException(WebDashboardFailure.cancelled);
          }
          return bytes;
        }),
      )
      .first;
  return actual.toString() == digest;
}

Future<void> _requireDirectory(String path, {bool create = false}) async {
  final type = await FileSystemEntity.type(path, followLinks: false);
  if (type == FileSystemEntityType.notFound && create) {
    await Directory(path).create();
  } else if (type != FileSystemEntityType.directory) {
    throw const WebDashboardException(WebDashboardFailure.storage);
  }
}

Future<void> _deleteManagedTree(String path) async {
  final type = await FileSystemEntity.type(path, followLinks: false);
  if (type == FileSystemEntityType.directory) {
    await Directory(path).delete(recursive: true);
  } else if (type != FileSystemEntityType.notFound) {
    throw const WebDashboardException(WebDashboardFailure.storage);
  }
}

Future<WebDashboardInstallation?> _installation(
  String directory,
  WebDashboardFlavor flavor,
) async {
  if (await FileSystemEntity.type(directory, followLinks: false) !=
      FileSystemEntityType.directory) {
    return null;
  }
  final entry = File(p.join(directory, webDashboardEntryName));
  final manifest = File(p.join(directory, webDashboardManifestName));
  if (await FileSystemEntity.type(entry.path, followLinks: false) !=
          FileSystemEntityType.file ||
      await FileSystemEntity.type(manifest.path, followLinks: false) !=
          FileSystemEntityType.file ||
      await manifest.length() > 4096 ||
      await entry.length() == 0) {
    return null;
  }
  try {
    final metadata = jsonDecode(await manifest.readAsString());
    if (metadata
        case {
          'panel': final String panel,
          'version': final String version,
          'sha256': final String digest,
        }
        when panel == flavor.name &&
            version.isNotEmpty &&
            version.length <= 64 &&
            RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      return WebDashboardInstallation(version: version);
    }
  } on FormatException catch (_) {}
  return null;
}

class WebDashboardStore {
  WebDashboardStore({
    required this.homeDirectory,
    required this.download,
    this.rename = _renameDirectory,
    this.downloadTimeout = const Duration(minutes: 5),
  });

  final Future<String> Function() homeDirectory;
  final WebDashboardDownload download;
  final WebDashboardRename rename;
  final Duration downloadTimeout;
  bool _busy = false;

  Future<String> _root() async {
    final home = await homeDirectory();
    await _requireDirectory(home);
    return p.join(home, webDashboardDirectoryName);
  }

  Future<Map<WebDashboardFlavor, WebDashboardInstallation>>
  installations() async {
    final root = await _root();
    final type = await FileSystemEntity.type(root, followLinks: false);
    if (type == FileSystemEntityType.notFound) return {};
    await _requireDirectory(root);
    final result = <WebDashboardFlavor, WebDashboardInstallation>{};
    for (final flavor in WebDashboardFlavor.values) {
      final path = p.join(root, flavor.name);
      final directoryType = await FileSystemEntity.type(
        path,
        followLinks: false,
      );
      if (directoryType == FileSystemEntityType.notFound) continue;
      await _requireDirectory(path);
      final installed = await _installation(path, flavor);
      if (installed != null) {
        result[flavor] = installed;
      }
    }
    return result;
  }

  Future<void> prepareForOpen(WebDashboardFlavor flavor) async {
    if (_busy) throw const WebDashboardException(WebDashboardFailure.busy);
    _busy = true;
    Directory? work;
    try {
      final root = await _root();
      await _requireDirectory(root);
      if (await _installation(p.join(root, flavor.name), flavor) == null) {
        throw const WebDashboardException(WebDashboardFailure.storage);
      }
      final target = File(p.join(root, webDashboardRecoveryFileName));
      final type = await FileSystemEntity.type(target.path, followLinks: false);
      if (type != FileSystemEntityType.notFound &&
          type != FileSystemEntityType.file) {
        throw const WebDashboardException(WebDashboardFailure.storage);
      }
      final contents = utf8.encode(webDashboardRecoveryWorker);
      if (type == FileSystemEntityType.file &&
          await target.length() == contents.length &&
          listEquals(await target.readAsBytes(), contents)) {
        return;
      }
      final workRoot = p.join(p.dirname(root), webDashboardWorkDirectoryName);
      await _requireDirectory(workRoot, create: true);
      work = await Directory(workRoot).createTemp('recovery-');
      final next = File(p.join(work.path, webDashboardRecoveryFileName));
      await next.writeAsBytes(contents, flush: true);
      await next.rename(target.path);
    } on WebDashboardException {
      rethrow;
    } catch (_) {
      throw const WebDashboardException(WebDashboardFailure.storage);
    } finally {
      try {
        if (work != null) await _deleteManagedTree(work.path);
      } finally {
        _busy = false;
      }
    }
  }

  Future<void> install(
    WebDashboardFlavor flavor, {
    required CancelToken cancelToken,
    required ValueChanged<WebDashboardProgress> onProgress,
    WebDashboardRelease? release,
  }) async {
    if (_busy) throw const WebDashboardException(WebDashboardFailure.busy);
    _busy = true;
    Directory? work;
    var retainRecovery = false;
    var active = true;
    try {
      _checkCancelled(cancelToken);
      final root = await _root();
      await _requireDirectory(root, create: true);
      final workRoot = p.join(p.dirname(root), webDashboardWorkDirectoryName);
      await _requireDirectory(workRoot, create: true);
      work = await Directory(workRoot).createTemp('${flavor.name}-');
      final cancelPath = p.join(work.path, 'cancelled');
      unawaited(
        cancelToken.whenCancel.then((_) {
          if (active) {
            try {
              File(cancelPath).writeAsStringSync('');
            } on FileSystemException catch (_) {}
          }
        }),
      );
      final archivePath = p.join(work.path, 'download');
      final package = release ?? flavor.release;
      var oversized = false;
      var timedOut = false;
      onProgress(const WebDashboardProgress(WebDashboardPhase.downloading));
      String? message;
      try {
        message =
            await download(
              Uri.parse(package.url),
              archivePath,
              cancelToken: cancelToken,
              onProgress: (received, total) {
                if (received > webDashboardMaxDownloadBytes ||
                    total > webDashboardMaxDownloadBytes) {
                  oversized = true;
                  cancelToken.cancel();
                  return;
                }
                onProgress(
                  WebDashboardProgress(
                    WebDashboardPhase.downloading,
                    received: received,
                    total: total,
                  ),
                );
              },
            ).timeout(
              downloadTimeout,
              onTimeout: () {
                timedOut = true;
                cancelToken.cancel();
                throw const WebDashboardException(WebDashboardFailure.download);
              },
            );
      } catch (_) {
        if (oversized) {
          throw const WebDashboardException(WebDashboardFailure.tooLarge);
        }
        if (!timedOut) {
          _checkCancelled(cancelToken);
        }
        throw const WebDashboardException(WebDashboardFailure.download);
      }
      if (oversized) {
        throw const WebDashboardException(WebDashboardFailure.tooLarge);
      }
      _checkCancelled(cancelToken);
      if (message != null) {
        throw const WebDashboardException(WebDashboardFailure.download);
      }
      if (await File(archivePath).length() > webDashboardMaxDownloadBytes) {
        throw const WebDashboardException(WebDashboardFailure.tooLarge);
      }
      onProgress(const WebDashboardProgress(WebDashboardPhase.verifying));
      if (!await compute(_verifyArchive, (
        archivePath,
        package.sha256,
        cancelPath,
      ))) {
        throw const WebDashboardException(WebDashboardFailure.checksum);
      }
      _checkCancelled(cancelToken);
      onProgress(const WebDashboardProgress(WebDashboardPhase.extracting));
      final stagingPath = p.join(work.path, 'next');
      await Directory(stagingPath).create();
      await compute(extractWebDashboard, (
        archivePath: archivePath,
        stagingPath: stagingPath,
        cancelPath: cancelPath,
      ));
      await File(p.join(stagingPath, webDashboardManifestName)).writeAsString(
        jsonEncode({
          'panel': flavor.name,
          'version': package.version,
          'sha256': package.sha256,
        }),
        flush: true,
      );
      _checkCancelled(cancelToken);
      final target = p.join(root, flavor.name);
      final previous = p.join(work.path, 'previous');
      final exists =
          await FileSystemEntity.type(target, followLinks: false) !=
          FileSystemEntityType.notFound;
      if (exists) {
        await _requireDirectory(target);
        await rename(target, previous);
      }
      try {
        _checkCancelled(cancelToken);
        await rename(stagingPath, target);
      } catch (_) {
        if (exists) {
          try {
            await rename(previous, target);
          } catch (_) {
            retainRecovery = true;
          }
        }
        rethrow;
      }
    } on WebDashboardException {
      rethrow;
    } catch (_) {
      throw const WebDashboardException(WebDashboardFailure.storage);
    } finally {
      active = false;
      try {
        if (work != null && !retainRecovery) {
          await _deleteManagedTree(work.path);
        }
      } finally {
        _busy = false;
      }
    }
  }

  Future<void> remove(WebDashboardFlavor flavor) async {
    if (_busy) throw const WebDashboardException(WebDashboardFailure.busy);
    _busy = true;
    try {
      final root = await _root();
      if (await FileSystemEntity.type(root, followLinks: false) ==
          FileSystemEntityType.notFound) {
        return;
      }
      await _requireDirectory(root);
      await _deleteManagedTree(p.join(root, flavor.name));
    } on WebDashboardException {
      rethrow;
    } catch (_) {
      throw const WebDashboardException(WebDashboardFailure.storage);
    } finally {
      _busy = false;
    }
  }

  void _checkCancelled(CancelToken token) {
    if (token.isCancelled) {
      throw const WebDashboardException(WebDashboardFailure.cancelled);
    }
  }
}

Future<String> webDashboardServedDirectory(String home) async {
  final root = p.join(home, webDashboardDirectoryName);
  if (await FileSystemEntity.type(root, followLinks: false) !=
      FileSystemEntityType.directory) {
    return '';
  }
  for (final flavor in WebDashboardFlavor.values) {
    final panel = p.join(root, flavor.name);
    if (await _installation(panel, flavor) != null) {
      return webDashboardDirectoryName;
    }
  }
  return '';
}

Future<void> clearWebDashboardFiles(String home) async {
  await _requireDirectory(home);
  for (final name in [
    webDashboardDirectoryName,
    webDashboardWorkDirectoryName,
  ]) {
    await _deleteManagedTree(p.join(home, name));
  }
}
