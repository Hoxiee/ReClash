import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

import 'app_version.dart';

/// Ed25519 public keys, base64, whose signature makes a mirrored release
/// installable. A list, so a successor ships in the app before the old key
/// retires; empty, mirrors are refused and GitHub answers instead.
const updateManifestKeys = ['13jh6ngw81CHozTu2OASUVQvv538qIH4XDjo2zaD0Z8='];

const updateManifestFileName = 'update-manifest.json';
const updateManifestLimit = 1024 * 1024;

const _domain = 'reclash-update-v1';
final _token = RegExp(r'^[0-9A-Za-z._+-]+$');
final _sha256 = RegExp(r'^[0-9a-f]{64}$');

typedef UpdateManifestAsset = ({String name, int size, String sha256});

class UpdateManifestException implements Exception {
  const UpdateManifestException(this.message);

  final String message;

  @override
  String toString() => 'update manifest rejected: $message';
}

/// The bytes a release's signature covers. Asset URLs stay out so a mirror
/// can point them at itself: the signed size and hash vouch for each file.
/// The notes are in because they decide whether an update may install
/// unattended.
List<int> updateManifestMessage({
  required String tag,
  required bool prerelease,
  required String notes,
  required Iterable<UpdateManifestAsset> assets,
}) {
  if (!_token.hasMatch(tag) || tryParseAppVersion(tag) == null) {
    throw UpdateManifestException('malformed tag $tag');
  }
  final entries = <String, UpdateManifestAsset>{};
  for (final asset in assets) {
    if (!_token.hasMatch(asset.name) ||
        !_sha256.hasMatch(asset.sha256) ||
        asset.size <= 0) {
      throw UpdateManifestException('malformed asset ${asset.name}');
    }
    if (entries.containsKey(asset.name)) {
      throw UpdateManifestException('duplicate asset ${asset.name}');
    }
    entries[asset.name] = asset;
  }
  final names = entries.keys.toList()..sort();
  return utf8.encode(
    [
      '$_domain\n$tag\n${prerelease ? 'pre' : 'stable'}\n',
      '${crypto.sha256.convert(utf8.encode(notes))}\n',
      for (final name in names)
        '$name ${entries[name]!.size} ${entries[name]!.sha256}\n',
    ].join(),
  );
}

Future<String> signUpdateManifestMessage(
  List<int> message,
  List<int> seed,
) async {
  final keyPair = await DartEd25519().newKeyPairFromSeed(seed);
  final signature = await DartEd25519().sign(message, keyPair: keyPair);
  return base64.encode(signature.bytes);
}

Future<String> updateManifestPublicKey(List<int> seed) async {
  final keyPair = await DartEd25519().newKeyPairFromSeed(seed);
  return base64.encode((await keyPair.extractPublicKey()).bytes);
}

/// Decodes and verifies a manifest into the shape of GitHub's release list.
/// A release that fails is dropped; a manifest whose every release fails is
/// refused, so a broken mirror falls back instead of reporting no update.
Future<List<Map<String, dynamic>>> parseUpdateManifest(
  List<int> bytes, {
  List<String> keys = updateManifestKeys,
}) async {
  if (keys.isEmpty) throw const UpdateManifestException('no trusted key');
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const UpdateManifestException('not JSON');
  }
  if (json case {'releases': final List<Object?> entries}) {
    final releases = <Map<String, dynamic>>[];
    for (final entry in entries) {
      final release = await _verifiedRelease(entry, keys);
      if (release != null) releases.add(release);
    }
    if (entries.isNotEmpty && releases.isEmpty) {
      throw const UpdateManifestException('no release verifies');
    }
    return releases;
  }
  throw const UpdateManifestException('no release list');
}

Future<Map<String, dynamic>?> _verifiedRelease(
  Object? entry,
  List<String> keys,
) async {
  if (entry case {
    'tag': final String tag,
    'prerelease': final bool prerelease,
    'notes': final String notes,
    'assets': final List<Object?> rawAssets,
    'signature': final String signature,
  }) {
    final assets = <({UpdateManifestAsset asset, Uri url})>[];
    for (final raw in rawAssets) {
      if (raw case {
        'name': final String name,
        'size': final int size,
        'sha256': final String sha256,
        'url': final String url,
      }) {
        final uri = Uri.tryParse(url);
        if (uri == null ||
            !uri.isScheme('https') ||
            uri.host.isEmpty ||
            uri.userInfo.isNotEmpty) {
          return null;
        }
        assets.add((
          asset: (name: name, size: size, sha256: sha256.toLowerCase()),
          url: uri,
        ));
      } else {
        return null;
      }
    }
    try {
      final message = updateManifestMessage(
        tag: tag,
        prerelease: prerelease,
        notes: notes,
        assets: assets.map((item) => item.asset),
      );
      if (!await _verify(message, signature, keys)) return null;
    } on UpdateManifestException {
      return null;
    }
    return {
      'tag_name': tag,
      'prerelease': prerelease,
      'body': notes,
      if (entry case {'published_at': final String date}) 'published_at': date,
      'assets': [
        for (final (:asset, :url) in assets)
          {
            'name': asset.name,
            'size': asset.size,
            'digest': 'sha256:${asset.sha256}',
            'browser_download_url': url.toString(),
          },
      ],
    };
  }
  return null;
}

Future<bool> _verify(
  List<int> message,
  String signature,
  List<String> keys,
) async {
  final signatureBytes = _decode(signature, 64);
  if (signatureBytes == null) return false;
  for (final key in keys) {
    final keyBytes = _decode(key, 32);
    if (keyBytes == null) continue;
    if (await DartEd25519().verify(
      message,
      signature: Signature(
        signatureBytes,
        publicKey: SimplePublicKey(keyBytes, type: KeyPairType.ed25519),
      ),
    )) {
      return true;
    }
  }
  return false;
}

List<int>? _decode(String value, int length) {
  try {
    final bytes = base64.decode(value);
    return bytes.length == length ? bytes : null;
  } on FormatException {
    return null;
  }
}
