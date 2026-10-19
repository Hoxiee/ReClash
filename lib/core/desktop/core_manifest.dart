import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:reclash/common/constant.dart';

abstract final class CoreManifest {
  static Future<String?> readCoreSha256({String? path}) =>
      _readHash('coreSha256', path);

  static Future<String?> readHelperSha256({String? path}) =>
      _readHash('helperSha256', path);

  static Future<String?> _readHash(String field, String? path) async {
    try {
      final file = File(
        path ??
            p.join(p.dirname(Platform.resolvedExecutable), coreManifestName),
      );
      final value = jsonDecode(await file.readAsString());
      if (value is! Map<String, dynamic>) return null;
      final hash = value[field];
      return hash is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)
          ? hash
          : null;
    } on Object {
      return null;
    }
  }
}
