import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/fixlink/apply.dart';
import 'package:reclash/features/doctor/fixlink/link.dart';
import 'package:reclash/features/doctor/fixlink/nonces.dart';
import 'package:reclash/features/doctor/fixlink/overrides.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/remedies/environment.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/models/models.dart';

import '../../../views/doctor/doctor_fakes.dart';
import 'fixture.dart';

class _Kernel extends FakeDoctorKernel {
  final recorded = <DiagnosticEvent>[];
  final undone = <String>[];
  RemedyStatus undoStatus = RemedyStatus.undone;

  @override
  Future<RemedyOutcome> apply(String remedyId, {bool confirmed = false}) async {
    applied.add(remedyId);
    return RemedyOutcome(
      remedyId: remedyId,
      status: RemedyStatus.applied,
      canUndo: remedyId == 'overrides.reset',
    );
  }

  @override
  Future<RemedyOutcome> undo(String remedyId) async {
    undone.add(remedyId);
    return RemedyOutcome(remedyId: remedyId, status: undoStatus);
  }

  @override
  Future<void> record(DiagnosticEvent event) async => recorded.add(event);
}

class _Actions implements FixActions {
  final calls = <String>[];
  bool failRestart = false;

  @override
  Future<void> updateProfile(int profileId) async =>
      calls.add('update $profileId');

  @override
  Future<void> activateProfile(int profileId) async =>
      calls.add('activate $profileId');

  @override
  Future<void> selectProxy(int profileId, String group, String node) async =>
      calls.add('select $profileId $group $node');

  @override
  Future<void> resetConnections() async => calls.add('reset');

  @override
  Future<void> restartCore() async {
    if (failRestart) throw StateError('restart failed');
    calls.add('restart');
  }
}

void main() {
  group('PersistedNonceStore', () {
    test('spends a nonce once and persists it until it expires', () async {
      var stored = <String>[];
      var now = fixtureNow;
      PersistedNonceStore store() => PersistedNonceStore(
        load: () async => stored,
        save: (entries) async => stored = entries,
        clock: () => now,
      );
      final expires = fixtureNow.add(const Duration(days: 1));
      expect(await store().consume('a', expires), isTrue);
      expect(await store().consume('a', expires), isFalse);
      expect(await store().isUsed('a'), isTrue);
      expect(stored, ['a ${expires.millisecondsSinceEpoch ~/ 1000}']);

      now = expires;
      expect(await store().isUsed('a'), isFalse);
      await store().consume('b', expires.add(const Duration(days: 1)));
      expect(stored, hasLength(1));
      expect(stored.single, startsWith('b '));
    });

    test('drops lines it cannot read', () async {
      final store = PersistedNonceStore(
        load: () async => ['broken', 'a notanumber', ' 1', 'b 99999999999'],
        save: (_) async {},
        clock: () => fixtureNow,
      );
      expect(await store.isUsed('b'), isTrue);
      expect(await store.isUsed('a'), isFalse);
    });
  });

  group('FixLinkService', () {
    late _Kernel kernel;
    late _Actions actions;
    late MemoryNonces nonces;

    Future<FixLinkService> service() async {
      nonces = MemoryNonces();
      return FixLinkService(
        verifier: await fixtureVerifier(nonces: nonces),
        kernel: kernel,
        actions: actions,
        clock: () => fixtureNow,
      );
    }

    setUp(() {
      kernel = _Kernel();
      actions = _Actions();
    });

    test('runs every action for the signing profile and journals it', () async {
      final fix = await service();
      final link = await signLink(
        fixturePayload(
          fix: [
            {'id': 'profile.update'},
            {'id': 'proxy.select', 'group': 'Auto', 'node': 'NL-1'},
            {'id': 'overrides.reset'},
            {'id': 'config.ruleMode'},
            {'id': 'connections.reset'},
          ],
        ),
      );
      final result = await fix.apply(link, provider: 'Example VPN');
      expect(actions.calls, ['update 1', 'select 1 Auto NL-1', 'reset']);
      expect(kernel.applied, ['overrides.reset', 'config.ruleMode']);
      expect(result.ok, isTrue);
      expect(result.canUndo, isTrue);
      expect(nonces.used, {'AAECAwQFBgcICQoL'});
      expect(
        result.summary,
        'RC-7K3F-92QD · fix applied · profile.update ok, proxy.select ok, '
        'overrides.reset ok, config.ruleMode ok, connections.reset ok',
      );
      final event = kernel.recorded.single;
      expect(event.kind, DiagnosticEventKind.supportFix);
      expect(event.subject, vectorReport);
      expect(event.outcome, 'applied');
      expect(event.detail, startsWith('Example VPN: profile.update'));
    });

    test('refuses the same link twice', () async {
      final fix = await service();
      await fix.apply(vectorLink, provider: 'Example VPN');
      await expectLater(
        fix.apply(vectorLink, provider: 'Example VPN'),
        throwsA(
          isA<FixLinkRejected>().having(
            (error) => error.reason,
            'reason',
            FixLinkRejection.replayed,
          ),
        ),
      );
      expect(actions.calls, hasLength(2));
    });

    test('keeps going past a failed step and reports it', () async {
      actions.failRestart = true;
      final fix = await service();
      final result = await fix.apply(
        await signLink(
          fixturePayload(
            fix: [
              {'id': 'core.restart'},
              {'id': 'profile.activate'},
            ],
          ),
        ),
        provider: 'Example VPN',
      );
      expect(actions.calls, ['activate 1']);
      expect(result.ok, isFalse);
      expect(result.canUndo, isFalse);
      expect(
        result.summary,
        'RC-7K3F-92QD · fix failed · core.restart failed, profile.activate ok',
      );
      expect(kernel.recorded.single.outcome, 'failed');
    });

    test('undoes only what the kernel can take back', () async {
      final fix = await service();
      final result = await fix.apply(
        await signLink(
          fixturePayload(
            fix: [
              {'id': 'overrides.reset'},
              {'id': 'core.restart'},
            ],
          ),
        ),
        provider: 'Example VPN',
      );
      expect(await fix.undo(result), isTrue);
      expect(kernel.undone, ['overrides.reset']);
      kernel.undoStatus = RemedyStatus.stale;
      expect(await fix.undo(result), isFalse);
    });
  });

  test(
    'ResetOverridesRemedy puts app-wide overrides back to defaults',
    () async {
      var config = defaultClashConfig.copyWith(
        mixedPort: 7999,
        socksPort: 7998,
        mode: Mode.global,
        dns: defaultDns.copyWith(useSystemHosts: false),
        dnsOverrideKeys: {DnsOverrideKey.useSystemHosts},
        tunOverrideKeys: {TunOverrideKey.mtu},
        generalOverrideKeys: {GeneralOverrideKey.ipv6},
      );
      final remedy = ResetOverridesRemedy(
        PatchConfigAccess(
          read: () => config,
          write: (change) => config = change(config),
        ),
      );
      expect(remedy.reach, RemedyReach.app);
      expect(remedy.undoable, isTrue);
      await remedy.apply(
        RemedyRequest(snapshot: DiagnosticSnapshot(takenAt: fixtureNow)),
      );
      const defaults = PatchClashConfig();
      expect(config.mixedPort, defaults.mixedPort);
      expect(config.socksPort, defaults.socksPort);
      expect(config.dns, defaults.dns);
      expect(config.dnsOverrideKeys, isEmpty);
      expect(config.tunOverrideKeys, isEmpty);
      expect(config.generalOverrideKeys, isEmpty);
      expect(config.mode, Mode.global);
    },
  );
}
