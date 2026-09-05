import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

/// zashboard (MIT, (c) Zephyruso) is fetched from its own release, not bundled.
const webDashboardUrl =
    'https://github.com/Zephyruso/zashboard/releases/latest/download/dist-no-fonts.zip';

/// Relative on purpose: the Core resolves `external-ui` against its home dir.
const webDashboardDirName = 'ui';

const webDashboardEntryName = 'index.html';

String webDashboardDirIn(String homeDirPath) =>
    join(homeDirPath, webDashboardDirName);

bool isWebDashboardInstalledIn(String homeDirPath) {
  return File(
    join(webDashboardDirIn(homeDirPath), webDashboardEntryName),
  ).existsSync();
}

/// zashboard reads its backend from the hash query, and `/ui` needs no secret.
Uri webDashboardUri(String externalController) {
  final authority = externalController.isEmpty
      ? ExternalControllerStatus.open.value
      : externalController;
  final separator = authority.lastIndexOf(':');
  final host = separator > 0 ? authority.substring(0, separator) : authority;
  final port = separator > 0 ? authority.substring(separator + 1) : '';
  final query = {
    'hostname': host,
    if (port.isNotEmpty) 'port': port,
    'protocol': 'http',
    'label': appName,
    // The Core binary and TUN belong to the app's lifecycle, not to a page.
    'disableUpgradeCore': '1',
    'disableTunMode': '1',
  };
  final search = query.entries
      .map(
        (entry) =>
            '${Uri.encodeQueryComponent(entry.key)}='
            '${Uri.encodeQueryComponent(entry.value)}',
      )
      .join('&');
  return Uri.parse('http://$authority/$webDashboardDirName/#/setup?$search');
}

/// The Core mounts `/ui` only while a config carrying `external-ui` is loaded,
/// and it serves it only while the external controller listens.
enum WebDashboardReadiness { serving, unmounted, unreachable }

Future<WebDashboardReadiness> probeWebDashboard(
  Uri uri, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final probe = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: '/$webDashboardDirName/',
  );
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 1)
    ..userAgent = null;
  var readiness = WebDashboardReadiness.unreachable;
  final deadline = DateTime.now().add(timeout);
  try {
    while (true) {
      try {
        final response = await (await client.getUrl(probe)).close();
        await response.drain<void>();
        if (response.statusCode == HttpStatus.ok) {
          return WebDashboardReadiness.serving;
        }
        readiness = WebDashboardReadiness.unmounted;
      } catch (_) {
        readiness = WebDashboardReadiness.unreachable;
      }
      if (!DateTime.now().isBefore(deadline)) {
        return readiness;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  } finally {
    client.close(force: true);
  }
}

/// Borrows the external controller for as long as the dashboard is open: leaving
/// it on afterwards would keep the Core's API reachable for the whole session.
class WebDashboardSession {
  WebDashboardSession({required this.status, required this.setStatus});

  final ExternalControllerStatus Function() status;

  final Future<void> Function(ExternalControllerStatus status) setStatus;

  ExternalControllerStatus? _borrowedFrom;

  bool get isBorrowed => _borrowedFrom != null;

  Future<void> open() async {
    final current = status();
    if (current == ExternalControllerStatus.open) {
      return;
    }
    _borrowedFrom ??= current;
    await setStatus(ExternalControllerStatus.open);
  }

  Future<void> close() async {
    final borrowedFrom = _borrowedFrom;
    _borrowedFrom = null;
    if (borrowedFrom == null || status() != ExternalControllerStatus.open) {
      return;
    }
    await setStatus(borrowedFrom);
  }
}

class WebDashboard {
  Future<bool> get isInstalled async =>
      isWebDashboardInstalledIn(await appPath.homeDirPath);

  /// Returns an error message, an empty one when the user cancelled, or null.
  Future<String?> install({
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final homeDirPath = await appPath.homeDirPath;
    final archivePath = '${webDashboardDirIn(homeDirPath)}.zip';
    final error = await request.downloadFile(
      webDashboardUrl,
      archivePath,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    if (error != null) {
      return error;
    }
    try {
      await compute(unpackWebDashboard, (
        archivePath: archivePath,
        targetPath: webDashboardDirIn(homeDirPath),
      ));
      return null;
    } catch (error) {
      commonPrint.log(
        'web dashboard unpack failed ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return compactError(error);
    } finally {
      await File(archivePath).safeDelete();
    }
  }

  Future<void> remove() async {
    await safeDeletePath(webDashboardDirIn(await appPath.homeDirPath));
  }
}

final webDashboard = WebDashboard();

/// A release wraps everything in `dist/`, which the Core would serve below `/ui`.
@visibleForTesting
String? webDashboardArchiveRoot(Iterable<String> names) {
  String? root;
  var rootDepth = -1;
  for (final name in names) {
    final normalized = posix.normalize(name.replaceAll('\\', '/'));
    if (posix.basename(normalized) != webDashboardEntryName) {
      continue;
    }
    final dir = posix.dirname(normalized);
    final depth = dir == '.' ? 0 : posix.split(dir).length;
    if (rootDepth < 0 || depth < rootDepth) {
      rootDepth = depth;
      root = depth == 0 ? null : dir;
    }
  }
  return root;
}

/// A release archive comes off the network: an entry must not escape the target.
@visibleForTesting
String? webDashboardEntryPath(String targetPath, String name, String? root) {
  var normalized = posix.normalize(name.replaceAll('\\', '/'));
  if (root != null) {
    if (!posix.isWithin(root, normalized)) {
      return null;
    }
    normalized = posix.relative(normalized, from: root);
  }
  if (normalized.isEmpty ||
      normalized == '.' ||
      posix.isAbsolute(normalized) ||
      normalized == '..' ||
      normalized.startsWith('../')) {
    return null;
  }
  final outPath = normalize(join(targetPath, normalized));
  if (!isWithin(targetPath, outPath)) {
    return null;
  }
  return outPath;
}

Future<void> unpackWebDashboard(
  ({String archivePath, String targetPath}) args,
) async {
  final stagingPath = '${args.targetPath}.new';
  await safeDeletePath(stagingPath);
  final input = InputFileStream(args.archivePath);
  try {
    final archive = ZipDecoder().decodeStream(input);
    final files = archive.files.where((file) => file.isFile).toList();
    final root = webDashboardArchiveRoot(files.map((file) => file.name));
    var written = 0;
    for (final file in files) {
      final outPath = webDashboardEntryPath(stagingPath, file.name, root);
      if (outPath == null) {
        continue;
      }
      final outputStream = OutputFileStream(outPath);
      file.writeContent(outputStream);
      await outputStream.close();
      written++;
    }
    if (written == 0 ||
        !File(join(stagingPath, webDashboardEntryName)).existsSync()) {
      throw const FormatException('web dashboard archive has no entry point');
    }
  } catch (_) {
    await safeDeletePath(stagingPath);
    rethrow;
  } finally {
    await input.close();
  }
  await safeDeletePath(args.targetPath);
  await Directory(stagingPath).rename(args.targetPath);
}
