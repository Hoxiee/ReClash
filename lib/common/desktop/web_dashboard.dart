import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

/// zashboard (MIT, (c) Zephyruso) release asset.
const zashboardUrl =
    'https://github.com/Zephyruso/zashboard/releases/download/'
    'v3.26.0/dist-no-fonts.zip';
const zashboardSha256 =
    '5b4cf64e6c9e36767d7245d2275d1f64c91d576a74ecf0d51cec53e9b13344c1';

/// metacubexd (MIT, (c) MetaCubeX) release asset.
const metacubexdUrl =
    'https://github.com/MetaCubeX/metacubexd/releases/download/'
    'v1.273.1/compressed-dist.tgz';
const metacubexdSha256 =
    'a178e00b67acabcda2dcef00afa90be6a7bb261e466a67dad58c8478d9553603';

String webDashboardUrlOf(WebDashboardFlavor flavor) => switch (flavor) {
  WebDashboardFlavor.zashboard => zashboardUrl,
  WebDashboardFlavor.metacubexd => metacubexdUrl,
};

String webDashboardSha256Of(WebDashboardFlavor flavor) => switch (flavor) {
  WebDashboardFlavor.zashboard => zashboardSha256,
  WebDashboardFlavor.metacubexd => metacubexdSha256,
};

@visibleForTesting
const webDashboardFlavorFileName = '.flavor';

/// Relative on purpose: the Core resolves `external-ui` against its home dir.
const webDashboardDirName = 'ui';

const webDashboardEntryName = 'index.html';

String webDashboardDirIn(String homeDirPath) =>
    join(homeDirPath, webDashboardDirName);

WebDashboardFlavor? installedWebDashboardFlavorIn(String homeDirPath) {
  final marker = File(
    join(webDashboardDirIn(homeDirPath), webDashboardFlavorFileName),
  );
  if (!marker.existsSync()) {
    return null;
  }
  try {
    final name = marker.readAsStringSync().trim();
    for (final flavor in WebDashboardFlavor.values) {
      if (flavor.name == name) {
        return flavor;
      }
    }
  } catch (_) {}
  return null;
}

bool isWebDashboardInstalledIn(
  String homeDirPath, [
  WebDashboardFlavor? flavor,
]) {
  final installed = File(
    join(webDashboardDirIn(homeDirPath), webDashboardEntryName),
  ).existsSync();
  if (flavor == null) {
    return installed;
  }
  if (!installed) {
    return false;
  }
  // Installs predating the flavor choice only ever shipped zashboard.
  return (installedWebDashboardFlavorIn(homeDirPath) ??
          WebDashboardFlavor.zashboard) ==
      flavor;
}

Uri _webDashboardZashboardUri(
  String authority,
  String host,
  String port,
  String secret,
) {
  final search = _encodeQuery({
    'hostname': host,
    if (port.isNotEmpty) 'port': port,
    'protocol': 'http',
    if (secret.isNotEmpty) 'secret': secret,
    'label': appName,
    // The Core binary and TUN belong to the app's lifecycle, not to a page.
    'disableUpgradeCore': '1',
    'disableTunMode': '1',
  });
  return Uri.parse('http://$authority/$webDashboardDirName/#/setup?$search');
}

/// metacubexd reads its backend from the page query, and `/ui` needs no secret.
Uri _webDashboardMetacubexdUri(
  String authority,
  String host,
  String port,
  String secret,
) {
  final search = _encodeQuery({
    'hostname': host,
    if (port.isNotEmpty) 'port': port,
    if (secret.isNotEmpty) 'secret': secret,
  });
  return Uri.parse('http://$authority/$webDashboardDirName/?$search');
}

String _encodeQuery(Map<String, String> query) => query.entries
    .map(
      (entry) =>
          '${Uri.encodeQueryComponent(entry.key)}='
          '${Uri.encodeQueryComponent(entry.value)}',
    )
    .join('&');

Uri webDashboardUri(
  String externalController, {
  String secret = '',
  WebDashboardFlavor flavor = WebDashboardFlavor.zashboard,
}) {
  final authority = externalController.isEmpty
      ? '$localhost:$defaultExternalControllerPort'
      : externalController;
  final separator = authority.lastIndexOf(':');
  final host = separator > 0 ? authority.substring(0, separator) : authority;
  final port = separator > 0 ? authority.substring(separator + 1) : '';
  return switch (flavor) {
    WebDashboardFlavor.zashboard => _webDashboardZashboardUri(
      authority,
      host,
      port,
      secret,
    ),
    WebDashboardFlavor.metacubexd => _webDashboardMetacubexdUri(
      authority,
      host,
      port,
      secret,
    ),
  };
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

  final String Function() status;

  final Future<void> Function(String status) setStatus;

  String? _borrowedFrom;

  bool get isBorrowed => _borrowedFrom != null;

  Future<void> open() async {
    final current = status();
    if (current.isNotEmpty) {
      return;
    }
    _borrowedFrom ??= current;
    await setStatus('$localhost:$defaultExternalControllerPort');
  }

  Future<void> close() async {
    final borrowedFrom = _borrowedFrom;
    _borrowedFrom = null;
    // Hand it back only while the live value is still the one we lent it: an
    // empty value or a controller the user configured meanwhile is theirs.
    if (borrowedFrom == null ||
        status() != '$localhost:$defaultExternalControllerPort') {
      return;
    }
    await setStatus(borrowedFrom);
  }
}

class WebDashboard {
  Future<bool> isInstalledFor(WebDashboardFlavor flavor) async =>
      isWebDashboardInstalledIn(await appPath.homeDirPath, flavor);

  /// Returns an error message, an empty one when the user cancelled, or null.
  Future<String?> install({
    required WebDashboardFlavor flavor,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final homeDirPath = await appPath.homeDirPath;
    final archivePath =
        '${webDashboardDirIn(homeDirPath)}${flavor == WebDashboardFlavor.metacubexd ? '.tgz' : '.zip'}';
    final error = await request.downloadFile(
      webDashboardUrlOf(flavor),
      archivePath,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    if (error != null) {
      return error;
    }
    try {
      if (!await hasWebDashboardDigest(
        File(archivePath),
        webDashboardSha256Of(flavor),
      )) {
        throw const FormatException('web dashboard checksum mismatch');
      }
      await compute(unpackWebDashboard, (
        archivePath: archivePath,
        targetPath: webDashboardDirIn(homeDirPath),
      ));
      await File(
        join(webDashboardDirIn(homeDirPath), webDashboardFlavorFileName),
      ).writeAsString(flavor.name);
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

@visibleForTesting
Future<bool> hasWebDashboardDigest(File file, String expected) async {
  final actual = await sha256.bind(file.openRead()).first;
  return '$actual' == expected;
}

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
  if (normalized.startsWith('./')) {
    normalized = normalized.substring(2);
  }
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
  final bytes = await File(args.archivePath).readAsBytes();
  final Archive archive;
  if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
    archive = TarDecoder().decodeBytes(const GZipDecoder().decodeBytes(bytes));
  } else {
    archive = ZipDecoder().decodeBytes(bytes);
  }
  final stagingPath = '${args.targetPath}.new';
  await safeDeletePath(stagingPath);
  try {
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
  }
  await safeDeletePath(args.targetPath);
  await Directory(stagingPath).rename(args.targetPath);
}
