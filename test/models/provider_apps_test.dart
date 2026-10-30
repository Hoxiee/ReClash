import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

void main() {
  const apps = ProviderApps(
    excluded: {'com.bank.app', 'ru.gov.app'},
    included: {'com.work.app'},
  );

  test('exclusions apply with access control off', () {
    final props = const AccessControlProps().withProviderApps(apps);
    expect(props.enable, isTrue);
    expect(props.mode, AccessControlMode.rejectSelected);
    expect(props.rejectList, ['com.bank.app', 'ru.gov.app']);
  });

  test('no provider apps leave access control off', () {
    expect(
      const AccessControlProps().withProviderApps(const ProviderApps()),
      const AccessControlProps(),
    );
  });

  test('the blacklist adds provider exclusions to the user list', () {
    final props = const AccessControlProps(
      enable: true,
      mode: AccessControlMode.rejectSelected,
      rejectList: ['com.mine.app'],
    ).withProviderApps(apps);
    expect(props.rejectList, ['com.bank.app', 'com.mine.app', 'ru.gov.app']);
  });

  test('an app the user took back into the tunnel stays released', () {
    final props = const AccessControlProps(
      enable: true,
      mode: AccessControlMode.rejectSelected,
      rejectReleased: ['com.bank.app'],
    ).withProviderApps(apps);
    expect(props.rejectList, ['ru.gov.app']);
  });

  test('the whitelist takes provider inclusions and never exclusions', () {
    final props = const AccessControlProps(
      enable: true,
      mode: AccessControlMode.acceptSelected,
      acceptList: ['com.mine.app'],
    ).withProviderApps(apps);
    expect(props.acceptList, ['com.mine.app', 'com.work.app']);
    expect(props.rejectList, isEmpty);
  });

  test('the whitelist honours released inclusions', () {
    final props = const AccessControlProps(
      enable: true,
      mode: AccessControlMode.acceptSelected,
      acceptReleased: ['com.work.app'],
    ).withProviderApps(apps);
    expect(props.acceptList, isEmpty);
  });

  for (final mode in AccessControlMode.values) {
    for (final enabled in [false, true]) {
      test('required exclusions win in $mode with access enabled=$enabled', () {
        const required = ProviderApps(
          included: {'com.bank.app', 'com.work.app'},
          requiredExcluded: {'com.bank.app'},
        );
        final original = AccessControlProps(
          enable: enabled,
          mode: mode,
          acceptList: ['com.bank.app', 'com.user.app'],
          rejectReleased: ['com.bank.app'],
        );
        final effective = original.withProviderApps(required);
        expect(effective.enable, isTrue);
        if (enabled && mode == AccessControlMode.acceptSelected) {
          expect(effective.acceptList, ['com.user.app', 'com.work.app']);
        } else {
          expect(effective.mode, AccessControlMode.rejectSelected);
          expect(effective.rejectList, contains('com.bank.app'));
        }
        expect(original.acceptList, contains('com.bank.app'));
        expect(
          original.withProviderApps(const ProviderApps()).acceptList,
          contains('com.bank.app'),
        );
      });
    }
  }

  test('the VPN checks actual exclusions, not a planned provider list', () {
    const running = VpnOptions(
      enable: true,
      port: 0,
      ipv6: false,
      dnsHijacking: false,
      accessControlProps: AccessControlProps(),
      allowBypass: false,
      systemProxy: false,
      bypassDomain: [],
      stack: 'gvisor',
    );
    expect(running.excludesRequiredApps({'com.bank.app'}), isFalse);
    expect(
      running
          .copyWith(requiredExcludedApps: ['com.bank.app'])
          .excludesRequiredApps({'com.bank.app'}),
      isTrue,
    );
    expect(
      running
          .copyWith(
            accessControlProps: const AccessControlProps(
              enable: true,
              mode: AccessControlMode.acceptSelected,
              acceptList: ['com.other.app'],
            ),
          )
          .excludesRequiredApps({'com.bank.app'}),
      isTrue,
    );
    expect(
      running
          .copyWith(enable: false, requiredExcludedApps: ['com.bank.app'])
          .excludesRequiredApps({'com.bank.app'}),
      isFalse,
    );
    expect(
      running.copyWith(requiredExcludedApps: ['com.bank.app']).effective,
      isNot(running.effective),
    );
  });

  test('released lists survive JSON', () {
    final props = AccessControlProps.fromJson(
      const AccessControlProps(
        rejectReleased: ['com.bank.app'],
        acceptReleased: ['com.work.app'],
      ).toJson(),
    );
    expect(props.rejectReleased, ['com.bank.app']);
    expect(props.acceptReleased, ['com.work.app']);
  });
}
