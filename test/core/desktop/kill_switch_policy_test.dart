import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/kill_switch_policy.dart';
import 'package:reclash/enum/enum.dart';

const _tick = Duration(seconds: 15);
const _standard = (mode: KillSwitchMode.standard, tun: 'tun0', allowLan: true);

HelperKillSwitch _info({
  bool configured = false,
  KillSwitchMode? mode,
  String? tun,
  bool allowLan = true,
  bool armed = false,
}) => HelperKillSwitch(
  configured: configured,
  mode: mode,
  allowLan: allowLan,
  tun: tun,
  armed: armed,
  active: false,
);

HelperKillSwitch _configuredAs(KillSwitchConfig config, {bool armed = false}) =>
    _info(
      configured: true,
      mode: config.mode,
      tun: config.tun,
      allowLan: config.allowLan,
      armed: armed,
    );

final class _Helper {
  HelperReadiness readiness = HelperReadiness.ready;
  HelperKillSwitch info = _info();
  int readinessChecks = 0;
  final calls = <String>[];
  final puts = <KillSwitchConfig>[];
  final snapshots = <KillSwitchHostSnapshot>[];

  late final policy = KillSwitchHostPolicy(
    readiness: () async {
      readinessChecks++;
      return readiness;
    },
    read: () async {
      calls.add('read');
      return info;
    },
    put: (config) async {
      calls.add('put');
      puts.add(config);
      info = _configuredAs(config);
    },
    delete: () async {
      calls.add('delete');
      info = _info();
    },
    arm: () async {
      calls.add('arm');
      info = _configuredAs((
        mode: info.mode!,
        tun: info.tun!,
        allowLan: info.allowLan,
      ), armed: true);
    },
    onSnapshot: snapshots.add,
    interval: _tick,
  );
}

void _run(void Function(FakeAsync async, _Helper helper) body) {
  fakeAsync((async) {
    final helper = _Helper();
    body(async, helper);
    helper.policy.dispose();
  });
}

void main() {
  test('arms a disarmed standard switch when the TUN comes up', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      async.flushMicrotasks();
      helper.calls.clear();

      helper.policy.observeTun(up: true);
      async.flushMicrotasks();

      expect(helper.calls, ['read', 'arm', 'read']);
      expect(helper.snapshots.last.info!.armed, isTrue);
    });
  });

  test('does not re-arm while the TUN stays up after a disarm', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      helper.policy.observeTun(up: true);
      async.flushMicrotasks();
      helper.info = _configuredAs(_standard);
      helper.calls.clear();

      helper.policy.observeTun(up: true);
      async.elapse(_tick);

      expect(helper.calls, isNot(contains('arm')));
    });
  });

  test('never arms always mode or a TUN going down', () {
    _run((async, helper) {
      const always = (mode: KillSwitchMode.always, tun: 'tun0', allowLan: true);
      helper.policy.update(always);
      helper.policy.observeTun(up: true);
      async.flushMicrotasks();
      helper.policy.update(_standard);
      helper.policy.observeTun(up: false);
      async.flushMicrotasks();

      expect(helper.calls, isNot(contains('arm')));
    });
  });

  test('writes a missing configuration once and reports the re-read state', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      async.flushMicrotasks();

      expect(helper.calls, ['read', 'put', 'read']);
      expect(helper.puts, [_standard]);
      expect(helper.snapshots.single.readiness, HelperReadiness.ready);
      expect(helper.snapshots.single.info!.configured, isTrue);
      expect(helper.snapshots.single.info!.mode, KillSwitchMode.standard);
    });
  });

  test('skips the write when the Helper already holds the configuration', () {
    _run((async, helper) {
      helper.info = _configuredAs(_standard);
      helper.policy.update(_standard);
      async.flushMicrotasks();

      expect(helper.puts, isEmpty);
      expect(helper.snapshots.single.info!.configured, isTrue);
    });
  });

  test('writes each changed mode, tun or allowLan', () {
    _run((async, helper) {
      const always = (mode: KillSwitchMode.always, tun: 'tun0', allowLan: true);
      const otherTun = (
        mode: KillSwitchMode.always,
        tun: 'tun1',
        allowLan: true,
      );
      const noLan = (mode: KillSwitchMode.always, tun: 'tun1', allowLan: false);
      for (final config in [_standard, always, otherTun, noLan]) {
        helper.policy.update(config);
        async.flushMicrotasks();
      }

      expect(helper.puts, [_standard, always, otherTun, noLan]);
    });
  });

  test('writes the configuration again after the Helper loses it', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      async.flushMicrotasks();
      helper.info = _info();
      async.elapse(_tick);

      expect(helper.puts, [_standard, _standard]);
      expect(helper.snapshots.last.info!.configured, isTrue);
    });
  });

  test(
    'does nothing while the Helper is not ready, then writes once it is',
    () {
      _run((async, helper) {
        helper.readiness = HelperReadiness.notReady;
        helper.policy.update(_standard);
        async.flushMicrotasks();

        expect(helper.calls, isEmpty);
        expect(helper.snapshots.single.readiness, HelperReadiness.notReady);
        expect(helper.snapshots.single.info, isNull);

        helper.readiness = HelperReadiness.ready;
        async.elapse(_tick);

        expect(helper.puts, [_standard]);
      });
    },
  );

  test('lifting reads, deletes once and then stops ticking', () {
    _run((async, helper) {
      helper.info = _configuredAs(_standard);
      helper.policy.update(null);
      async.flushMicrotasks();

      expect(helper.calls, ['read', 'delete', 'read']);

      helper.calls.clear();
      final checks = helper.readinessChecks;
      async.elapse(_tick * 4);

      expect(helper.calls, isEmpty);
      expect(helper.readinessChecks, checks);
    });
  });

  test('lifting an unconfigured Helper deletes nothing', () {
    _run((async, helper) {
      helper.policy.update(null);
      async.flushMicrotasks();
      async.elapse(_tick * 2);

      expect(helper.calls, ['read']);
      expect(helper.snapshots.last.info!.configured, isFalse);
    });
  });

  test('a lift waits for an unready Helper and deletes once it is ready', () {
    _run((async, helper) {
      helper.info = _configuredAs(_standard);
      helper.readiness = HelperReadiness.notReady;
      helper.policy.update(null);
      async.flushMicrotasks();
      async.elapse(_tick * 2);

      expect(helper.calls, isEmpty);

      helper.readiness = HelperReadiness.ready;
      async.elapse(_tick * 3);

      expect(helper.calls, ['read', 'delete', 'read']);
    });
  });

  test('a lift stops at a missing manifest without deleting', () {
    _run((async, helper) {
      helper.info = _configuredAs(_standard);
      helper.readiness = HelperReadiness.manifestMissing;
      helper.policy.update(null);
      async.flushMicrotasks();
      async.elapse(_tick * 3);

      expect(helper.readinessChecks, 1);
      expect(helper.calls, isEmpty);
    });
  });

  test('an equal configuration does not restart the work', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      async.flushMicrotasks();
      helper.readinessChecks = 0;
      helper.calls.clear();

      helper.policy.update(_standard);
      async.flushMicrotasks();

      expect(helper.readinessChecks, 0);
      expect(helper.calls, isEmpty);
    });
  });

  test('dispose stops the ticks and later updates do nothing', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      async.flushMicrotasks();
      helper.info = _info();
      helper.policy.dispose();
      helper.calls.clear();

      async.elapse(_tick * 3);
      helper.policy.update(_standard);
      async.flushMicrotasks();

      expect(helper.calls, isEmpty);
    });
  });

  test('only read, put and delete reach the Helper through a full cycle', () {
    _run((async, helper) {
      helper.policy.update(_standard);
      async.flushMicrotasks();
      helper.policy.update(null);
      async.flushMicrotasks();

      expect(helper.calls, ['read', 'put', 'read', 'read', 'delete', 'read']);
      expect(helper.puts, [_standard]);
    });
  });
}
