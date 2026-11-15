import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

import 'brand.dart';

final _writes = <int, Future<void>>{};

Future<File> _file(int profileId) async =>
    File(await appPath.getProfileBrandPath(profileId.toString()));

/// Writes and deletes of one profile's brand run in order, because the atomic
/// write shares one temporary sibling.
Future<void> _serialized(int profileId, Future<void> Function() action) {
  final run = (_writes[profileId] ?? Future<void>.value()).then(
    (_) => action(),
  );
  final settled = run.then<void>((_) {}, onError: (Object _) {});
  _writes[profileId] = settled;
  unawaited(
    settled.then((_) {
      if (identical(_writes[profileId], settled)) _writes.remove(profileId);
    }),
  );
  return run;
}

Future<ProviderBrand?> readProfileBrand(int profileId) async {
  try {
    final file = await _file(profileId);
    if (!await file.exists()) return null;
    final source = await file.readAsString();
    // Each logo is stored as base64 of up to 512 KiB.
    return await Isolate.run(() => ProviderBrand.fromJson(jsonDecode(source)));
  } on Object catch (error) {
    commonPrint.log(
      'Could not read the profile brand: $error',
      logLevel: LogLevel.warning,
    );
    return null;
  }
}

Future<void> writeProfileBrand(int profileId, ProviderBrand brand) =>
    _serialized(profileId, () async {
      await (await _file(
        profileId,
      )).writeAsStringAtomically(jsonEncode(brand.toJson()));
    });

Future<void> deleteProfileBrand(int profileId) =>
    _serialized(profileId, () async => (await _file(profileId)).safeDelete());
