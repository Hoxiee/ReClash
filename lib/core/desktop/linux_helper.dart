import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:reclash/common/util/constant.dart';

import 'core_manifest.dart';

final class LinuxHelperEnvironment {
  final int uid;
  final String bundleDirectory;

  LinuxHelperEnvironment({int? uid, String? bundleDirectory})
    : uid = uid ?? _readUid(),
      bundleDirectory =
          bundleDirectory ?? p.dirname(Platform.resolvedExecutable);

  static int _readUid() {
    return DynamicLibrary.process()
        .lookupFunction<Uint32 Function(), int Function()>('getuid')();
  }

  String get socketPath => '/run/reclash-helper-$uid/helper.sock';

  String get manifestPath => p.join(bundleDirectory, coreManifestName);

  Future<String> installedHelperPath() async {
    final hash = await CoreManifest.readHelperSha256(path: manifestPath);
    if (uid <= 0 || hash == null) {
      throw const FormatException('Linux Helper manifest or owner is invalid');
    }
    return '/opt/reclash-helper/$uid/$hash/$appHelperService';
  }

  Future<Directory> stageBundle() async {
    final coreHash = await CoreManifest.readCoreSha256(path: manifestPath);
    final helperHash = await CoreManifest.readHelperSha256(path: manifestPath);
    if (uid <= 0 || coreHash == null || helperHash == null) {
      throw const FormatException('Linux Helper bundle manifest is invalid');
    }
    final stage = await Directory.systemTemp.createTemp('reclash-helper-');
    try {
      for (final entry in {
        appHelperService: helperHash,
        '${appName}Core': coreHash,
      }.entries) {
        final source = File(p.join(bundleDirectory, entry.key));
        final target = await source.copy(p.join(stage.path, entry.key));
        final digest = await sha256.bind(target.openRead()).first;
        if (digest.toString() != entry.value) {
          throw FormatException(
            'Linux Helper bundle hash mismatch: ${entry.key}',
          );
        }
      }
      return stage;
    } catch (_) {
      await stage.delete(recursive: true);
      rethrow;
    }
  }
}
