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
