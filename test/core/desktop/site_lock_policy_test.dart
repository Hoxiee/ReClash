import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/site_lock_policy.dart';
import 'package:reclash/models/site_lock.dart';

const _tick = Duration(seconds: 15);

final class _Host {
  SiteLockPolicy? wanted = const SiteLockPolicy(
    revision: 'r1',
    tun: 'tun0',
    addresses: ['203.0.113.9/32'],
    fakeRanges: ['198.18.0.0/16'],
  );
  final known = <String>[];
  final puts_ = <SiteLockPolicy>[];
  HelperReadiness readiness = HelperReadiness.ready;
  Exception? putError;
  Exception? deleteError;
  Completer<void>? fetchGate;
  Completer<void>? deleteGate;
  final calls = <String>[];
  final statuses = <SiteLockHostStatus>[];

  late final policy = SiteLockHostPolicy(
    fetch: (value) async {
      calls.add('fetch');
      known.add(value);
      await fetchGate?.future;
      final current = wanted;
      if (current != null && current.revision == value) {
        return SiteLockPolicy(revision: value, unchanged: true);
      }
      return current;
    },
    put: (policy) async {
      puts_.add(policy);
      calls.add(
        'put ${policy.tun} ${policy.addresses.join(',')} '
        '${policy.fakeRanges.join(',')}',
      );
      if (putError != null) throw putError!;
    },
    delete: () async {
      calls.add('delete');
      await deleteGate?.future;
      if (deleteError != null) throw deleteError!;
    },
    readiness: () async => readiness,
    onStatus: statuses.add,
    interval: _tick,
  );

  List<String> get puts => calls.where((c) => c.startsWith('put')).toList();
}

void _run(void Function(FakeAsync async, _Host host) body) {
  fakeAsync((async) {
    final host = _Host();
    body(async, host);
    host.policy.dispose();
  });
}

void main() {
  test('puts the fetched pair once and skips an unchanged one', () {
    _run((async, host) {
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      async.elapse(_tick * 2);

      expect(host.puts, ['put tun0 203.0.113.9/32 198.18.0.0/16']);
      expect(host.statuses, [SiteLockHostStatus.applied]);
    });
  });

  test('puts a changed result on the next tick', () {
    _run((async, host) {
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.wanted = const SiteLockPolicy(revision: 'r2', tun: 'tun0');
      async.elapse(_tick);

      expect(host.puts, [
        'put tun0 203.0.113.9/32 198.18.0.0/16',
        'put tun0  ',
      ]);
      expect(host.known, ['', 'r1']);
    });
  });

  test('an unchanged answer does not put', () {
    _run((async, host) {
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      async.elapse(_tick);

      expect(host.known, ['', 'r1']);
      expect(host.puts, hasLength(1));
    });
  });

  test('names reach the put', () {
    _run((async, host) {
      host.wanted = const SiteLockPolicy(
        revision: 'r1',
        names: SiteLockNames(suffix: ['example.com']),
      );
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();

      expect(host.puts_.single.names.suffix, ['example.com']);
    });
  });

  test('a null fetch keeps the applied policy untouched', () {
    _run((async, host) {
      host.wanted = null;
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.elapse(_tick);

      expect(host.puts, isEmpty);
      expect(host.statuses, isEmpty);
    });
  });

  test('a disconnected core stops polling and never deletes', () {
    _run((async, host) {
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.calls.clear();
      host.policy.update(locksEnabled: true, coreConnected: false);
      async.elapse(_tick * 3);

      expect(host.calls, isEmpty);
    });
  });

  test('disabling deletes once and reports inactive', () {
    _run((async, host) {
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.policy.update(locksEnabled: false, coreConnected: true);
      async.flushMicrotasks();
      host.policy.update(locksEnabled: false, coreConnected: false);
      async.elapse(_tick * 2);

      expect(host.calls.where((c) => c == 'delete'), hasLength(1));
      expect(host.statuses.last, SiteLockHostStatus.inactive);
    });
  });

  test('the first update with locks disabled lifts a stale policy', () {
    _run((async, host) {
      host.policy.update(locksEnabled: false, coreConnected: false);
      async.flushMicrotasks();

      expect(host.calls, ['delete']);
      expect(host.statuses, [SiteLockHostStatus.inactive]);
    });
  });

  test('a failed delete is retried on the next tick until it lands', () {
    _run((async, host) {
      host.deleteError = Exception('nft');
      host.policy.update(locksEnabled: false, coreConnected: false);
      async.flushMicrotasks();
      host.deleteError = null;
      async.elapse(_tick * 3);

      expect(host.calls, ['delete', 'delete']);
      expect(host.statuses, [
        SiteLockHostStatus.failed,
        SiteLockHostStatus.inactive,
      ]);
    });
  });

  test('an unready helper keeps the lift pending until it returns', () {
    _run((async, host) {
      host.readiness = HelperReadiness.notReady;
      host.policy.update(locksEnabled: false, coreConnected: false);
      async.elapse(_tick * 2);
      expect(host.calls, isEmpty);
      expect(host.statuses.last, SiteLockHostStatus.helperUnavailable);

      host.readiness = HelperReadiness.ready;
      async.elapse(_tick * 3);
      expect(host.calls, ['delete']);
      expect(host.statuses.last, SiteLockHostStatus.inactive);
    });
  });

  test('a missing manifest keeps the lift pending', () {
    _run((async, host) {
      host.readiness = HelperReadiness.manifestMissing;
      host.policy.update(locksEnabled: false, coreConnected: false);
      async.elapse(_tick * 3);

      expect(host.calls, isEmpty);
      expect(host.statuses.last, SiteLockHostStatus.helperUnavailable);

      host.readiness = HelperReadiness.ready;
      async.elapse(_tick * 2);
      expect(host.calls, ['delete']);
      expect(host.statuses.last, SiteLockHostStatus.inactive);
    });
  });

  test('enabling during a lift keeps syncing and a later disable lifts', () {
    _run((async, host) {
      final gate = host.deleteGate = Completer<void>();
      host.policy.update(locksEnabled: false, coreConnected: true);
      async.flushMicrotasks();
      host.policy.update(locksEnabled: true, coreConnected: true);
      host.deleteGate = null;
      gate.complete();
      async.flushMicrotasks();
      host.policy.update(locksEnabled: false, coreConnected: true);
      async.flushMicrotasks();

      expect(host.calls.where((c) => c == 'delete'), hasLength(2));
      expect(host.puts, hasLength(1));
      expect(host.statuses.last, SiteLockHostStatus.inactive);
    });
  });

  test('an unready helper reports unavailable without put or delete', () {
    _run((async, host) {
      host.readiness = HelperReadiness.notReady;
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.policy.update(locksEnabled: false, coreConnected: true);
      async.flushMicrotasks();

      expect(host.calls, isEmpty);
      expect(host.statuses, [
        SiteLockHostStatus.helperUnavailable,
        SiteLockHostStatus.helperUnavailable,
      ]);
    });
  });

  test('a failed put reports failed and retries on the next tick', () {
    _run((async, host) {
      host.putError = Exception('nft');
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.putError = null;
      async.elapse(_tick);

      expect(host.puts, hasLength(2));
      expect(host.statuses, [
        SiteLockHostStatus.failed,
        SiteLockHostStatus.applied,
      ]);
    });
  });

  test('disabling during a sync never overlaps and ends with delete', () {
    _run((async, host) {
      host.fetchGate = Completer<void>();
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.policy.update(locksEnabled: false, coreConnected: true);
      async.flushMicrotasks();
      expect(host.calls, ['fetch']);

      host.fetchGate!.complete();
      async.flushMicrotasks();

      expect(host.calls.last, 'delete');
      expect(host.statuses.last, SiteLockHostStatus.inactive);
    });
  });

  test('nothing runs or is reported after dispose', () {
    _run((async, host) {
      host.fetchGate = Completer<void>();
      host.policy.update(locksEnabled: true, coreConnected: true);
      async.flushMicrotasks();
      host.policy.dispose();
      host.fetchGate!.complete();
      async.flushMicrotasks();
      host.policy.update(locksEnabled: false, coreConnected: true);
      async.elapse(_tick * 2);

      expect(host.calls, ['fetch']);
      expect(host.statuses, isEmpty);
    });
  });
}
