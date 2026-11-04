import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:reclash/features/doctor/fixlink/link.dart';
import 'package:reclash/features/doctor/fixlink/nonces.dart';
import 'package:reclash/features/doctor/fixlink/verifier.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/report/sources.dart';

/// The link `core/cmd/reclash-fix` signs with a seed of 32 zero bytes.
const vectorHeader = 'ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik';
const vectorKeyId = 'E545QOZLVJE';
const vectorLink =
    'reclash://fix?p=eyJ2IjoxLCJraWQiOiJFNTQ1UU9aTFZKRSIsInJpZCI6IlJDLTdLM0YtOTJRRCIsImV4cCI6MTc2NzIyNTYwMCwibm9uY2UiOiJBQUVDQXdRRkJnY0lDUW9MIiwiZml4IjpbeyJpZCI6InByb2ZpbGUudXBkYXRlIn0seyJpZCI6InByb3h5LnNlbGVjdCIsImdyb3VwIjoiQXV0byIsIm5vZGUiOiJOTC0xIn1dfQ&s=XEdYg90ecSzT7cV1dRxH9cCVLpw01KXGiWC1Lz4iUD0kYga2zSoZwr1VQnkXVkVlyx5D3L3fGx_ursuvQvmBDQ';
const vectorReport = 'RC-7K3F-92QD';

/// Two days before the vector expires.
final fixtureNow = DateTime.utc(2025, 12, 30);

Future<SimpleKeyPair> seededKeys([int fill = 0]) =>
    Ed25519().newKeyPairFromSeed(List.filled(32, fill));

Future<List<int>> publicKey(SimpleKeyPair pair) async =>
    (await pair.extractPublicKey()).bytes;

Map<String, Object?> fixturePayload({
  String? kid,
  String rid = vectorReport,
  DateTime? expires,
  String nonce = 'AAECAwQFBgcICQoL',
  List<Map<String, Object?>> fix = const [
    {'id': 'profile.update'},
    {'id': 'proxy.select', 'group': 'Auto', 'node': 'NL-1'},
  ],
}) => {
  'v': 1,
  'kid': kid ?? vectorKeyId,
  'rid': rid,
  'exp':
      (expires ?? fixtureNow.add(const Duration(days: 2)))
          .millisecondsSinceEpoch ~/
      1000,
  'nonce': nonce,
  'fix': fix,
};

Future<String> signLink(
  Map<String, Object?> payload, {
  SimpleKeyPair? keys,
}) async {
  final bytes = utf8.encode(jsonEncode(payload));
  final signature = await Ed25519().sign(
    bytes,
    keyPair: keys ?? await seededKeys(),
  );
  return 'reclash://fix?p=${encodeBase64Url(bytes)}'
      '&s=${encodeBase64Url(signature.bytes)}';
}

class MemoryNonces implements NonceStore {
  final used = <String>{};

  @override
  Future<bool> isUsed(String nonce) async => used.contains(nonce);

  @override
  Future<bool> consume(String nonce, DateTime expires) async => used.add(nonce);
}

class FixtureReports implements ReportRegistry {
  FixtureReports(this.records);

  final List<ReportRecord> records;

  @override
  Future<ReportRecord?> find(String id) async =>
      records.where((record) => record.id == id).firstOrNull;

  @override
  Future<List<ReportRecord>> list() async => records;
}

ReportRecord fixtureReport({
  String id = vectorReport,
  int? profileId = 1,
  Duration age = const Duration(days: 1),
}) => ReportRecord(
  id: id,
  profileId: profileId,
  createdAt: fixtureNow.subtract(age),
  redaction: 'standard',
);

const fixtureReach = {
  'config.ruleMode': RemedyReach.app,
  'proxy.clearOwn': RemedyReach.own,
  'proxy.clear': RemedyReach.foreign,
  'overrides.reset': RemedyReach.app,
};

Future<FixLinkVerifier> fixtureVerifier({
  List<TrustedKey>? keys,
  NonceStore? nonces,
  List<ReportRecord>? reports,
  Set<String> groups = const {'Auto'},
}) async {
  final trusted =
      keys ??
      [TrustedKey(profileId: 1, key: await publicKey(await seededKeys()))];
  final registry = FixtureReports(reports ?? [fixtureReport()]);
  return FixLinkVerifier(
    keys: () => trusted,
    nonces: nonces ?? MemoryNonces(),
    findReport: registry.find,
    remedyReach: (id) => fixtureReach[id],
    hasGroup: (_, group) => groups.contains(group),
    clock: () => fixtureNow,
  );
}
