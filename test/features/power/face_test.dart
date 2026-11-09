import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/account/standing.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/supervisor/health.dart';
import 'package:reclash/features/power/face.dart';

const _subscriptionEnded = Finding(
  id: 'profile.subscription',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.subscriptionExpired,
);

const _trafficUsedUp = Finding(
  id: 'profile.subscription',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.trafficExhausted,
);

const _revoked = Finding(
  id: 'profile.revoked',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.authRejected,
);

const _noServers = Finding(
  id: 'profile.noServers',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.noUpstream,
);

const _alwaysOn = Finding(
  id: 'tunnel.alwaysOn',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.tunnelTaken,
);

const _vpnPermission = Finding(
  id: 'tunnel.vpnPermission',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.tunnelDenied,
);

const _clockSkew = Finding(
  id: 'device.clockSkew',
  severity: CheckSeverity.critical,
  evidence: [],
  titleKey: '',
  detailKey: '',
  cause: FailureCause.clockSkew,
);

PowerInputs _inputs({
  PowerLink link = PowerLink.off,
  bool hasProfile = true,
  bool? online,
  List<Finding> findings = const [],
  ConnectionHealth health = ConnectionHealth.idle,
  AccountStanding account = AccountStanding.clear,
  AccountAttention? attention,
  AccountLinks links = const AccountLinks(),
  bool direct = false,
}) => PowerInputs(
  link: link,
  hasProfile: hasProfile,
  online: online,
  findings: findings,
  health: health,
  account: account,
  attention: attention,
  links: links,
  direct: direct,
);

void _expectFace(
  PowerFace face, {
  required PowerFaceState state,
  required PowerLink link,
  required PowerTone tone,
  required PowerAction? tap,
  required PowerAction? fix,
  bool verified = false,
}) {
  expect(face.state, state, reason: 'state');
  expect(face.link, link, reason: 'link');
  expect(face.tone, tone, reason: 'tone');
  expect(face.tap, tap, reason: 'tap');
  expect(face.fix, fix, reason: 'fix');
  expect(face.verified, verified, reason: 'verified');
}

void main() {
  group('no profile', () {
    test('asks for a profile whatever the link', () {
      for (final link in PowerLink.values) {
        final face = resolvePowerFace(
          _inputs(
            link: link,
            hasProfile: false,
            findings: const [_subscriptionEnded],
          ),
        );
        _expectFace(
          face,
          state: PowerFaceState.noProfile,
          link: PowerLink.off,
          tone: PowerTone.normal,
          tap: PowerAction.addProfile,
          fix: PowerAction.addProfile,
        );
      }
    });
  });

  group('transitions', () {
    test('connecting shows starting and taps stop', () {
      _expectFace(
        resolvePowerFace(_inputs(link: PowerLink.connecting)),
        state: PowerFaceState.starting,
        link: PowerLink.connecting,
        tone: PowerTone.normal,
        tap: PowerAction.stop,
        fix: null,
      );
    });

    test('paused shows paused and taps resume', () {
      _expectFace(
        resolvePowerFace(_inputs(link: PowerLink.paused)),
        state: PowerFaceState.paused,
        link: PowerLink.paused,
        tone: PowerTone.normal,
        tap: PowerAction.resume,
        fix: null,
      );
    });
  });

  group('stopped account lock', () {
    test('an expired lock outranks every finding', () {
      final face = resolvePowerFace(
        _inputs(
          account: const AccountStanding(lock: AccountLock.expired),
          online: false,
          findings: const [
            _revoked,
            _alwaysOn,
            _vpnPermission,
            _clockSkew,
            _subscriptionEnded,
          ],
          attention: const AccountAttention.days(1),
        ),
      );
      _expectFace(
        face,
        state: PowerFaceState.accountLocked,
        link: PowerLink.off,
        tone: PowerTone.failure,
        tap: PowerAction.accountSheet,
        fix: PowerAction.updateProfile,
      );
      expect(face.cause, FailureCause.subscriptionExpired);
    });

    test('an expired lock renews through the renew chain', () {
      const cases = <(AccountLinks, PowerAction)>[
        (AccountLinks(renew: true, support: true), PowerAction.renew),
        (AccountLinks(renew: true), PowerAction.renew),
        (AccountLinks(support: true), PowerAction.support),
        (AccountLinks(topUp: true), PowerAction.updateProfile),
        (AccountLinks(), PowerAction.updateProfile),
      ];
      for (final (links, fix) in cases) {
        final face = resolvePowerFace(
          _inputs(
            account: const AccountStanding(lock: AccountLock.expired),
            links: links,
          ),
        );
        _expectFace(
          face,
          state: PowerFaceState.accountLocked,
          link: PowerLink.off,
          tone: PowerTone.failure,
          tap: PowerAction.accountSheet,
          fix: fix,
        );
      }
    });

    test('an exhausted lock tops up, then falls back to the renew chain', () {
      const cases = <(AccountLinks, PowerAction)>[
        (
          AccountLinks(topUp: true, renew: true, support: true),
          PowerAction.topUp,
        ),
        (AccountLinks(renew: true), PowerAction.renew),
        (AccountLinks(support: true), PowerAction.support),
        (AccountLinks(), PowerAction.updateProfile),
      ];
      for (final (links, fix) in cases) {
        final face = resolvePowerFace(
          _inputs(
            account: const AccountStanding(lock: AccountLock.exhausted),
            findings: const [_revoked],
            links: links,
          ),
        );
        _expectFace(
          face,
          state: PowerFaceState.trafficLocked,
          link: PowerLink.off,
          tone: PowerTone.failure,
          tap: PowerAction.accountSheet,
          fix: fix,
        );
        expect(face.cause, FailureCause.trafficExhausted);
      }
    });
  });

  group('revoked and server findings', () {
    test('a revoked account asks for support when the provider has it', () {
      const cases = <(AccountLinks, PowerAction)>[
        (AccountLinks(support: true), PowerAction.support),
        (AccountLinks(renew: true), PowerAction.updateProfile),
        (AccountLinks(), PowerAction.updateProfile),
      ];
      for (final (links, fix) in cases) {
        _expectFace(
          resolvePowerFace(_inputs(findings: const [_revoked], links: links)),
          state: PowerFaceState.revoked,
          link: PowerLink.off,
          tone: PowerTone.failure,
          tap: PowerAction.accountSheet,
          fix: fix,
        );
      }
    });

    test('no servers sends the user to update the subscription', () {
      _expectFace(
        resolvePowerFace(_inputs(findings: const [_noServers])),
        state: PowerFaceState.noServers,
        link: PowerLink.off,
        tone: PowerTone.failure,
        tap: PowerAction.updateProfile,
        fix: PowerAction.updateProfile,
      );
    });
  });

  group('tunnel and network', () {
    test('an always-on VPN held by another app asks to open VPN settings', () {
      _expectFace(
        resolvePowerFace(_inputs(findings: const [_alwaysOn])),
        state: PowerFaceState.vpnTaken,
        link: PowerLink.off,
        tone: PowerTone.problem,
        tap: PowerAction.causeSheet,
        fix: PowerAction.openVpnSettings,
      );
    });

    test('a denied VPN permission asks to grant it', () {
      _expectFace(
        resolvePowerFace(_inputs(findings: const [_vpnPermission])),
        state: PowerFaceState.vpnDenied,
        link: PowerLink.off,
        tone: PowerTone.problem,
        tap: PowerAction.grantVpn,
        fix: PowerAction.grantVpn,
      );
    });

    test('a captive portal opens the portal at any severity', () {
      for (final severity in CheckSeverity.values) {
        final portal = Finding(
          id: 'network.captivePortal',
          severity: severity,
          evidence: const [],
          titleKey: '',
          detailKey: '',
          cause: FailureCause.captivePortal,
        );
        _expectFace(
          resolvePowerFace(_inputs(findings: [portal])),
          state: PowerFaceState.portal,
          link: PowerLink.off,
          tone: PowerTone.problem,
          tap: PowerAction.openPortal,
          fix: PowerAction.openPortal,
        );
      }
    });

    test('offline without a live link is quiet and taps start', () {
      _expectFace(
        resolvePowerFace(_inputs(online: false)),
        state: PowerFaceState.offline,
        link: PowerLink.off,
        tone: PowerTone.quiet,
        tap: PowerAction.start,
        fix: null,
      );
    });

    test('a clock skew asks to open date settings', () {
      _expectFace(
        resolvePowerFace(_inputs(findings: const [_clockSkew])),
        state: PowerFaceState.clock,
        link: PowerLink.off,
        tone: PowerTone.problem,
        tap: PowerAction.start,
        fix: PowerAction.openDateSettings,
      );
    });
  });

  group('stopped precedence', () {
    final pairs = <(String, PowerInputs, PowerFaceState)>[
      (
        'an expired lock beats a revoked account',
        _inputs(
          account: const AccountStanding(lock: AccountLock.expired),
          findings: const [_revoked],
        ),
        PowerFaceState.accountLocked,
      ),
      (
        'always-on beats the VPN permission',
        _inputs(findings: const [_vpnPermission, _alwaysOn]),
        PowerFaceState.vpnTaken,
      ),
      (
        'a captive portal beats offline',
        _inputs(
          online: false,
          findings: const [
            Finding(
              id: 'network.captivePortal',
              severity: CheckSeverity.warning,
              evidence: [],
              titleKey: '',
              detailKey: '',
              cause: FailureCause.captivePortal,
            ),
          ],
        ),
        PowerFaceState.portal,
      ),
      (
        'offline beats a clock skew',
        _inputs(online: false, findings: const [_clockSkew]),
        PowerFaceState.offline,
      ),
      (
        'a clock skew beats a subscription finding',
        _inputs(findings: const [_clockSkew, _subscriptionEnded]),
        PowerFaceState.clock,
      ),
    ];
    for (final (name, inputs, state) in pairs) {
      test(name, () {
        expect(resolvePowerFace(inputs).state, state);
      });
    }
  });

  group('stopped subscription', () {
    test('an ended plan shows expired and tapping starts a connection', () {
      const cases = <(AccountLinks, PowerAction)>[
        (AccountLinks(renew: true), PowerAction.renew),
        (AccountLinks(support: true), PowerAction.support),
        (AccountLinks(), PowerAction.updateProfile),
      ];
      for (final (links, fix) in cases) {
        _expectFace(
          resolvePowerFace(
            _inputs(findings: const [_subscriptionEnded], links: links),
          ),
          state: PowerFaceState.expired,
          link: PowerLink.off,
          tone: PowerTone.problem,
          tap: PowerAction.start,
          fix: fix,
        );
      }
    });

    test('a stale reading passes its checking flag through', () {
      for (final finding in [_subscriptionEnded, _trafficUsedUp]) {
        final checking = resolvePowerFace(
          _inputs(
            findings: [finding],
            account: const AccountStanding(checking: true),
          ),
        );
        expect(checking.checking, isTrue, reason: '${finding.cause}');
        final settled = resolvePowerFace(_inputs(findings: [finding]));
        expect(settled.checking, isFalse, reason: '${finding.cause}');
      }
    });

    test('an exhausted plan tops up, then falls back to the renew chain', () {
      const cases = <(AccountLinks, PowerAction)>[
        (AccountLinks(topUp: true, renew: true), PowerAction.topUp),
        (AccountLinks(renew: true), PowerAction.renew),
        (AccountLinks(support: true), PowerAction.support),
        (AccountLinks(), PowerAction.updateProfile),
      ];
      for (final (links, fix) in cases) {
        _expectFace(
          resolvePowerFace(
            _inputs(findings: const [_trafficUsedUp], links: links),
          ),
          state: PowerFaceState.exhausted,
          link: PowerLink.off,
          tone: PowerTone.problem,
          tap: PowerAction.start,
          fix: fix,
        );
      }
    });
  });

  group('stopped attention', () {
    test('a plan nearing its end offers the account link for its kind', () {
      final cases = <(AccountAttention, AccountLinks, PowerAction?)>[
        (
          const AccountAttention.days(2),
          const AccountLinks(renew: true, topUp: true),
          PowerAction.renew,
        ),
        (const AccountAttention.days(2), const AccountLinks(topUp: true), null),
        (
          const AccountAttention.days(2),
          const AccountLinks(support: true),
          PowerAction.support,
        ),
        (const AccountAttention.days(2), const AccountLinks(), null),
        (
          const AccountAttention.traffic(100),
          const AccountLinks(topUp: true),
          PowerAction.topUp,
        ),
        (
          const AccountAttention.traffic(100),
          const AccountLinks(renew: true),
          PowerAction.renew,
        ),
        (const AccountAttention.traffic(100), const AccountLinks(), null),
      ];
      for (final (attention, links, fix) in cases) {
        final face = resolvePowerFace(
          _inputs(attention: attention, links: links),
        );
        _expectFace(
          face,
          state: PowerFaceState.ending,
          link: PowerLink.off,
          tone: PowerTone.attention,
          tap: PowerAction.start,
          fix: fix,
        );
        expect(face.attention, attention);
      }
    });

    test('nothing to report is off', () {
      _expectFace(
        resolvePowerFace(_inputs()),
        state: PowerFaceState.off,
        link: PowerLink.off,
        tone: PowerTone.normal,
        tap: PowerAction.start,
        fix: null,
      );
    });
  });

  group('running', () {
    test('a dropped network shows waiting for the network', () {
      final cases = <PowerInputs>[
        _inputs(link: PowerLink.on, online: false),
        _inputs(
          link: PowerLink.on,
          online: true,
          health: const ConnectionHealth(phase: ConnectionPhase.waitingNetwork),
        ),
      ];
      for (final inputs in cases) {
        _expectFace(
          resolvePowerFace(inputs),
          state: PowerFaceState.waitingNetwork,
          link: PowerLink.on,
          tone: PowerTone.quiet,
          tap: PowerAction.stop,
          fix: null,
        );
      }
    });

    test('a connecting health verifies with a connecting link', () {
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(phase: ConnectionPhase.connecting),
          ),
        ),
        state: PowerFaceState.verifying,
        link: PowerLink.connecting,
        tone: PowerTone.normal,
        tap: PowerAction.stop,
        fix: null,
      );
    });

    test('a recovering health shows recovering', () {
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(phase: ConnectionPhase.recovering),
          ),
        ),
        state: PowerFaceState.recovering,
        link: PowerLink.on,
        tone: PowerTone.normal,
        tap: PowerAction.stop,
        fix: null,
      );
    });

    test('a broken clock asks to open date settings', () {
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(
              phase: ConnectionPhase.broken,
              cause: FailureCause.clockSkew,
            ),
          ),
        ),
        state: PowerFaceState.brokenClock,
        link: PowerLink.on,
        tone: PowerTone.failure,
        tap: PowerAction.stop,
        fix: PowerAction.openDateSettings,
      );
    });

    test('a broken captive portal opens the portal', () {
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(
              phase: ConnectionPhase.broken,
              cause: FailureCause.captivePortal,
            ),
          ),
        ),
        state: PowerFaceState.brokenPortal,
        link: PowerLink.on,
        tone: PowerTone.failure,
        tap: PowerAction.stop,
        fix: PowerAction.openPortal,
      );
    });

    test(
      'a broken connection with a subscription finding offers the account link',
      () {
        const cases =
            <(List<Finding>, AccountLinks, PowerAction, FailureCause)>[
              (
                [_subscriptionEnded],
                AccountLinks(renew: true, topUp: true),
                PowerAction.renew,
                FailureCause.subscriptionExpired,
              ),
              (
                [_trafficUsedUp],
                AccountLinks(topUp: true, renew: true),
                PowerAction.topUp,
                FailureCause.trafficExhausted,
              ),
              (
                [_trafficUsedUp],
                AccountLinks(renew: true),
                PowerAction.renew,
                FailureCause.trafficExhausted,
              ),
            ];
        for (final (findings, links, fix, cause) in cases) {
          final face = resolvePowerFace(
            _inputs(
              link: PowerLink.on,
              findings: findings,
              links: links,
              health: ConnectionHealth(
                phase: ConnectionPhase.broken,
                cause: cause,
              ),
            ),
          );
          _expectFace(
            face,
            state: PowerFaceState.broken,
            link: PowerLink.on,
            tone: PowerTone.failure,
            tap: PowerAction.stop,
            fix: fix,
          );
          expect(face.cause, cause);
        }
      },
    );

    test('a broken connection repairs, or explains once repair failed', () {
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(
              phase: ConnectionPhase.broken,
              cause: FailureCause.timeout,
            ),
          ),
        ),
        state: PowerFaceState.broken,
        link: PowerLink.on,
        tone: PowerTone.failure,
        tap: PowerAction.stop,
        fix: PowerAction.repair,
      );
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(
              phase: ConnectionPhase.broken,
              cause: FailureCause.timeout,
              repairFailed: true,
            ),
          ),
        ),
        state: PowerFaceState.broken,
        link: PowerLink.on,
        tone: PowerTone.failure,
        tap: PowerAction.stop,
        fix: PowerAction.causeSheet,
      );
    });

    test('direct mode asks for the rule mode and keeps the verified check', () {
      for (final phase in [ConnectionPhase.idle, ConnectionPhase.verified]) {
        _expectFace(
          resolvePowerFace(
            _inputs(
              link: PowerLink.on,
              direct: true,
              health: ConnectionHealth(phase: phase),
            ),
          ),
          state: PowerFaceState.direct,
          link: PowerLink.on,
          tone: PowerTone.attention,
          tap: PowerAction.stop,
          fix: PowerAction.ruleMode,
          verified: phase == ConnectionPhase.verified,
        );
      }
    });

    test('a subscription finding while running is a grace period', () {
      const cases = <(List<Finding>, AccountLinks, PowerAction)>[
        ([_subscriptionEnded], AccountLinks(renew: true), PowerAction.renew),
        (
          [_trafficUsedUp],
          AccountLinks(topUp: true, renew: true),
          PowerAction.topUp,
        ),
      ];
      for (final (findings, links, fix) in cases) {
        _expectFace(
          resolvePowerFace(
            _inputs(link: PowerLink.on, findings: findings, links: links),
          ),
          state: PowerFaceState.grace,
          link: PowerLink.on,
          tone: PowerTone.attention,
          tap: PowerAction.stop,
          fix: fix,
        );
      }
    });

    test('an attention plan while running is ending', () {
      final cases = <(AccountAttention, AccountLinks, PowerAction?)>[
        (
          const AccountAttention.days(2),
          const AccountLinks(renew: true),
          PowerAction.renew,
        ),
        (
          const AccountAttention.traffic(100),
          const AccountLinks(topUp: true),
          PowerAction.topUp,
        ),
        (const AccountAttention.days(2), const AccountLinks(), null),
      ];
      for (final (attention, links, fix) in cases) {
        final face = resolvePowerFace(
          _inputs(link: PowerLink.on, attention: attention, links: links),
        );
        _expectFace(
          face,
          state: PowerFaceState.ending,
          link: PowerLink.on,
          tone: PowerTone.attention,
          tap: PowerAction.stop,
          fix: fix,
        );
        expect(face.attention, attention);
      }
    });

    test('a healthy run is on, verified only once the check passed', () {
      for (final phase in [ConnectionPhase.idle, ConnectionPhase.unknown]) {
        _expectFace(
          resolvePowerFace(
            _inputs(
              link: PowerLink.on,
              health: ConnectionHealth(phase: phase),
            ),
          ),
          state: PowerFaceState.on,
          link: PowerLink.on,
          tone: PowerTone.normal,
          tap: PowerAction.stop,
          fix: null,
        );
      }
      _expectFace(
        resolvePowerFace(
          _inputs(
            link: PowerLink.on,
            health: const ConnectionHealth(phase: ConnectionPhase.verified),
          ),
        ),
        state: PowerFaceState.on,
        link: PowerLink.on,
        tone: PowerTone.normal,
        tap: PowerAction.stop,
        fix: null,
        verified: true,
      );
    });

    test('every running state taps stop', () {
      final running = <PowerInputs>[
        _inputs(link: PowerLink.on, online: false),
        _inputs(
          link: PowerLink.on,
          health: const ConnectionHealth(phase: ConnectionPhase.connecting),
        ),
        _inputs(
          link: PowerLink.on,
          health: const ConnectionHealth(phase: ConnectionPhase.recovering),
        ),
        _inputs(
          link: PowerLink.on,
          health: const ConnectionHealth(
            phase: ConnectionPhase.broken,
            cause: FailureCause.clockSkew,
          ),
        ),
        _inputs(link: PowerLink.on, direct: true),
        _inputs(link: PowerLink.on, findings: const [_subscriptionEnded]),
        _inputs(link: PowerLink.on, attention: const AccountAttention.days(1)),
        _inputs(link: PowerLink.on),
      ];
      for (final inputs in running) {
        expect(resolvePowerFace(inputs).tap, PowerAction.stop);
      }
    });
  });

  group('PowerFace.plain', () {
    test('maps each link to its bare look', () {
      const cases = <(PowerLink, PowerFaceState, PowerAction)>[
        (PowerLink.off, PowerFaceState.off, PowerAction.start),
        (PowerLink.connecting, PowerFaceState.starting, PowerAction.stop),
        (PowerLink.on, PowerFaceState.on, PowerAction.stop),
        (PowerLink.paused, PowerFaceState.paused, PowerAction.resume),
      ];
      for (final (link, state, tap) in cases) {
        final face = PowerFace.plain(link);
        expect(face.link, link);
        expect(face.state, state);
        expect(face.tap, tap);
        expect(face.tone, PowerTone.normal);
        expect(face.fix, isNull);
      }
    });
  });

  group('PowerInputs.withLink', () {
    test('changes only the link', () {
      const original = PowerInputs(
        link: PowerLink.off,
        hasProfile: false,
        online: true,
        findings: [_clockSkew],
        health: ConnectionHealth(phase: ConnectionPhase.broken),
        account: AccountStanding(lock: AccountLock.expired),
        attention: AccountAttention.days(1),
        links: AccountLinks(renew: true),
        direct: true,
      );
      final copy = original.withLink(PowerLink.on);
      expect(copy.link, PowerLink.on);
      expect(copy.hasProfile, isFalse);
      expect(copy.online, isTrue);
      expect(copy.findings, same(original.findings));
      expect(copy.health, same(original.health));
      expect(copy.account, same(original.account));
      expect(copy.attention, same(original.attention));
      expect(copy.links, same(original.links));
      expect(copy.direct, isTrue);
    });
  });

  group('AccountLinks', () {
    test('truth table for the renew, top-up and attention actions', () {
      const cases =
          <
            (AccountLinks, PowerAction, PowerAction, PowerAction?, PowerAction?)
          >[
            (
              AccountLinks(),
              PowerAction.updateProfile,
              PowerAction.updateProfile,
              null,
              null,
            ),
            (
              AccountLinks(support: true),
              PowerAction.support,
              PowerAction.support,
              PowerAction.support,
              PowerAction.support,
            ),
            (
              AccountLinks(renew: true),
              PowerAction.renew,
              PowerAction.renew,
              PowerAction.renew,
              PowerAction.renew,
            ),
            (
              AccountLinks(topUp: true),
              PowerAction.updateProfile,
              PowerAction.topUp,
              null,
              PowerAction.topUp,
            ),
            (
              AccountLinks(renew: true, support: true),
              PowerAction.renew,
              PowerAction.renew,
              PowerAction.renew,
              PowerAction.renew,
            ),
            (
              AccountLinks(topUp: true, support: true),
              PowerAction.support,
              PowerAction.topUp,
              PowerAction.support,
              PowerAction.topUp,
            ),
            (
              AccountLinks(renew: true, topUp: true, support: true),
              PowerAction.renew,
              PowerAction.topUp,
              PowerAction.renew,
              PowerAction.topUp,
            ),
          ];
      for (final (links, renew, topUp, days, traffic) in cases) {
        expect(links.renewAction, renew, reason: '$links renew');
        expect(links.topUpAction, topUp, reason: '$links topUp');
        expect(
          links.accountAction(byTraffic: false),
          days,
          reason: '$links days',
        );
        expect(
          links.accountAction(byTraffic: true),
          traffic,
          reason: '$links traffic',
        );
      }
    });
  });
}
