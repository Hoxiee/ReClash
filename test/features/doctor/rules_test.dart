import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/plugins/doctor.dart';

final _now = DateTime(2026, 10, 29, 12);

DiagnosticSnapshot _snapshot() => DiagnosticSnapshot(takenAt: _now);

void main() {
  group('clockSkewRule', () {
    test('stays silent for a skew under thirty seconds', () {
      final snapshot = _snapshot().withFact(
        Facts.clockSkew,
        Fact(const Duration(seconds: 10), at: _now),
      );

      expect(clockSkewRule(snapshot), isNull);
    });

    test('warns when the device runs ahead by 45 seconds', () {
      final snapshot = _snapshot().withFact(
        Facts.clockSkew,
        Fact(const Duration(seconds: 45), at: _now),
      );

      final finding = clockSkewRule(snapshot)!;

      expect(finding.id, 'device.clockSkew');
      expect(finding.severity, CheckSeverity.warning);
      expect(finding.detailKey, 'doctorClockSkewAhead');
      expect(finding.args, {'seconds': 45});
      expect(finding.cause, FailureCause.clockSkew);
      expect(finding.remedyIds, ['device.openDateSettings']);
    });

    test('is critical when the device runs 120 seconds behind', () {
      final snapshot = _snapshot().withFact(
        Facts.clockSkew,
        Fact(const Duration(seconds: -120), at: _now),
      );

      final finding = clockSkewRule(snapshot)!;

      expect(finding.severity, CheckSeverity.critical);
      expect(finding.detailKey, 'doctorClockSkewBehind');
      expect(finding.args, {'seconds': 120});
    });

    test('ignores a skew measured longer ago than its ttl', () {
      final snapshot = _snapshot().withFact(
        Facts.clockSkew,
        Fact(
          const Duration(seconds: 120),
          at: _now.subtract(const Duration(minutes: 11)),
          ttl: const Duration(minutes: 10),
        ),
      );

      expect(clockSkewRule(snapshot), isNull);
    });

    test('stays silent without a clock fact', () {
      expect(clockSkewRule(_snapshot()), isNull);
    });
  });

  group('batteryOptimizationRule', () {
    test('warns while battery optimization is not ignored', () {
      final snapshot = _snapshot().withFact(
        Facts.batteryOptimizationIgnored,
        Fact(false, at: _now),
      );

      final finding = batteryOptimizationRule(snapshot)!;

      expect(finding.id, 'device.batteryOptimization');
      expect(finding.severity, CheckSeverity.warning);
      expect(finding.remedyIds, ['device.ignoreBatteryOptimization']);
    });

    test('stays silent once battery optimization is ignored', () {
      final snapshot = _snapshot().withFact(
        Facts.batteryOptimizationIgnored,
        Fact(true, at: _now),
      );

      expect(batteryOptimizationRule(snapshot), isNull);
    });

    test('stays silent without a battery fact', () {
      expect(batteryOptimizationRule(_snapshot()), isNull);
    });
  });

  group('subscriptionRule', () {
    test('is critical once the subscription expired', () {
      final snapshot = _snapshot().withFact(
        Facts.subscription,
        Fact(
          SubscriptionFact(
            profileId: 7,
            expiresAt: _now.subtract(const Duration(days: 1)),
          ),
          at: _now,
        ),
      );

      final finding = subscriptionRule(snapshot)!;

      expect(finding.severity, CheckSeverity.critical);
      expect(finding.cause, FailureCause.subscriptionExpired);
      expect(finding.args['profileId'], 7);
      expect(finding.remedyIds, ['profile.update']);
    });

    test('stays silent while the subscription runs with traffic left', () {
      final snapshot = _snapshot().withFact(
        Facts.subscription,
        Fact(
          SubscriptionFact(
            profileId: 7,
            expiresAt: _now.add(const Duration(days: 1)),
            used: 1,
            total: 10,
          ),
          at: _now,
        ),
      );

      expect(subscriptionRule(snapshot), isNull);
    });

    test('is critical once all traffic is used', () {
      final snapshot = _snapshot().withFact(
        Facts.subscription,
        Fact(
          const SubscriptionFact(profileId: 7, used: 10, total: 10),
          at: _now,
        ),
      );

      final finding = subscriptionRule(snapshot)!;

      expect(finding.severity, CheckSeverity.critical);
      expect(finding.cause, FailureCause.trafficExhausted);
    });

    test('ignores a quota of zero', () {
      final snapshot = _snapshot().withFact(
        Facts.subscription,
        Fact(const SubscriptionFact(profileId: 7, used: 3), at: _now),
      );

      expect(subscriptionRule(snapshot), isNull);
    });
  });

  group('directModeRule', () {
    test('warns while the core runs in direct mode', () {
      final snapshot = _snapshot().withFact(
        Facts.mode,
        Fact(Mode.direct, at: _now),
      );

      final finding = directModeRule(snapshot)!;

      expect(finding.id, 'config.directMode');
      expect(finding.severity, CheckSeverity.warning);
      expect(finding.remedyIds, ['config.ruleMode']);
    });

    test('stays silent in rule mode', () {
      final snapshot = _snapshot().withFact(
        Facts.mode,
        Fact(Mode.rule, at: _now),
      );

      expect(directModeRule(snapshot), isNull);
    });
  });

  group('vpnPermissionRule', () {
    test('is critical once the VPN permission was revoked', () {
      final snapshot = _snapshot().withFact(
        Facts.vpnPermission,
        Fact(VpnPermission.revoked, at: _now),
      );

      final finding = vpnPermissionRule(snapshot)!;

      expect(finding.id, 'tunnel.vpnPermission');
      expect(finding.severity, CheckSeverity.critical);
      expect(finding.cause, FailureCause.tunnelDenied);
      expect(finding.remedyIds, contains('device.requestVpnPermission'));
    });

    test('stays silent while granted, never asked or unknown', () {
      for (final permission in [
        VpnPermission.granted,
        VpnPermission.notAsked,
      ]) {
        final snapshot = _snapshot().withFact(
          Facts.vpnPermission,
          Fact(permission, at: _now),
        );

        expect(vpnPermissionRule(snapshot), isNull, reason: permission.name);
      }
      expect(vpnPermissionRule(_snapshot()), isNull);
    });
  });

  group('otherVpnRule', () {
    test('is critical while another VPN owns the tunnel', () {
      final snapshot = _snapshot().withFact(
        Facts.otherVpn,
        Fact(true, at: _now),
      );

      final finding = otherVpnRule(snapshot)!;

      expect(finding.id, 'tunnel.otherVpn');
      expect(finding.severity, CheckSeverity.critical);
      expect(finding.cause, FailureCause.tunnelTaken);
      expect(finding.remedyIds, ['device.openVpnSettings']);
    });

    test('stays silent when no other VPN is up', () {
      final snapshot = _snapshot().withFact(
        Facts.otherVpn,
        Fact(false, at: _now),
      );

      expect(otherVpnRule(snapshot), isNull);
      expect(otherVpnRule(_snapshot()), isNull);
    });
  });

  group('alwaysOnVpnRule', () {
    DiagnosticSnapshot withAlwaysOn(String app) =>
        _snapshot().withFact(Facts.alwaysOnVpnApp, Fact(app, at: _now));

    test('is critical while another app is the always-on VPN', () {
      final finding = alwaysOnVpnRule(withAlwaysOn('com.example.vpn'))!;

      expect(finding.id, 'tunnel.alwaysOn');
      expect(finding.severity, CheckSeverity.critical);
      expect(finding.cause, FailureCause.tunnelTaken);
      expect(finding.titleKey, 'doctorAlwaysOnOtherTitle');
    });

    test('is only a tip when no always-on VPN is set', () {
      final finding = alwaysOnVpnRule(withAlwaysOn(''))!;

      expect(finding.severity, CheckSeverity.tip);
      expect(finding.cause, isNull);
      expect(finding.titleKey, 'doctorAlwaysOnOffTitle');
    });

    test('stays silent when the system hides the setting or ReClash holds '
        'it', () {
      expect(alwaysOnVpnRule(_snapshot()), isNull);
      expect(alwaysOnVpnRule(withAlwaysOn(packageName)), isNull);
    });
  });

  group('privateDnsRule', () {
    test('warns under strict Private DNS and names the resolver host', () {
      final snapshot = _snapshot()
          .withFact(Facts.privateDns, Fact(PrivateDnsMode.strict, at: _now))
          .withFact(Facts.privateDnsHost, Fact('dns.example.net', at: _now));

      final finding = privateDnsRule(snapshot)!;

      expect(finding.id, 'network.privateDns');
      expect(finding.severity, CheckSeverity.warning);
      expect(finding.cause, isNull);
      expect(finding.args, {'host': 'dns.example.net'});
      expect(finding.remedyIds, ['device.openPrivateDnsSettings']);
    });

    test('stays silent in off and opportunistic modes', () {
      for (final mode in [PrivateDnsMode.off, PrivateDnsMode.opportunistic]) {
        final snapshot = _snapshot().withFact(
          Facts.privateDns,
          Fact(mode, at: _now),
        );

        expect(privateDnsRule(snapshot), isNull, reason: mode.name);
      }
    });
  });

  group('captivePortalRule', () {
    test('warns behind a captive portal and offers its page', () {
      final snapshot = _snapshot().withFact(
        Facts.captivePortal,
        Fact(true, at: _now),
      );

      final finding = captivePortalRule(snapshot)!;

      expect(finding.id, 'network.captivePortal');
      expect(finding.severity, CheckSeverity.warning);
      expect(finding.cause, FailureCause.captivePortal);
      expect(finding.remedyIds, ['network.openCaptivePortal']);
    });

    test('stays silent on an open network', () {
      final snapshot = _snapshot().withFact(
        Facts.captivePortal,
        Fact(false, at: _now),
      );

      expect(captivePortalRule(snapshot), isNull);
    });
  });

  group('evaluateRules and RuleEngine', () {
    DiagnosticSnapshot mixedSnapshot() => _snapshot()
        .withFact(Facts.clockSkew, Fact(const Duration(seconds: 45), at: _now))
        .withFact(Facts.batteryOptimizationIgnored, Fact(false, at: _now))
        .withFact(
          Facts.subscription,
          Fact(
            SubscriptionFact(
              profileId: 7,
              expiresAt: _now.subtract(const Duration(days: 1)),
            ),
            at: _now,
          ),
        )
        .withFact(Facts.mode, Fact(Mode.direct, at: _now));

    test('sorts critical findings first and ties by id', () {
      final findings = evaluateRules(mixedSnapshot(), defaultRules);

      expect(findings.map((finding) => finding.id), [
        'profile.subscription',
        'config.directMode',
        'device.batteryOptimization',
        'device.clockSkew',
      ]);
    });

    test('evaluates off the UI isolate to the same findings', () async {
      final snapshot = mixedSnapshot();

      final inline = await const RuleEngine(defaultRules).evaluate(snapshot);
      final isolated = await const RuleEngine(
        defaultRules,
        isolateWeight: 0,
      ).evaluate(snapshot);

      expect(inline, isNotEmpty);
      expect(isolated, inline);
    });
  });

  group('FailureCause.fromWire', () {
    test('treats a null or empty id as no failure', () {
      expect(FailureCause.fromWire(null), isNull);
      expect(FailureCause.fromWire(''), isNull);
    });

    test('maps a known id to its cause', () {
      expect(FailureCause.fromWire('timeout'), FailureCause.timeout);
    });

    test('keeps an unrecognised id as an unknown failure', () {
      expect(FailureCause.fromWire('bogus'), FailureCause.unknown);
    });
  });
}
