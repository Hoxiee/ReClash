import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';

void main() {
  test('SiteLock survives a JSON round trip', () {
    const lock = SiteLock(
      id: 'a',
      name: 'Work',
      match: ['example.com'],
      except: ['skip.example.com'],
      exits: [SiteLockExit(type: 'ss', server: '1.2.3.4', port: 443)],
    );
    final wire = jsonDecode(jsonEncode(lock)) as Map<String, Object?>;
    expect(SiteLock.fromJson(wire), lock);
    expect(wire['except'], ['skip.example.com']);
  });

  test('SiteLock defaults fill missing fields', () {
    final lock = SiteLock.fromJson({'id': 'a'});
    expect(lock.enabled, isTrue);
    expect(lock.match, isEmpty);
    expect(lock.exits, isEmpty);
  });

  test('status strings map to SiteLockStatus', () {
    const expected = {
      'ready': SiteLockStatus.ready,
      'disabled': SiteLockStatus.disabled,
      'no-exit': SiteLockStatus.noExit,
      'exits-down': SiteLockStatus.exitsDown,
      'other': SiteLockStatus.unknown,
    };
    expected.forEach((raw, status) {
      final report = SiteLockReport.fromJson({
        'applied': true,
        'locks': [
          {'id': 'a', 'status': raw},
        ],
      });
      expect(report.locks.single.status, status);
    });
  });

  test('report carries warnings', () {
    final report = SiteLockReport.fromJson({
      'applied': true,
      'warnings': [
        {
          'code': 'core-only',
          'locks': ['a'],
        },
      ],
    });
    expect(report.warnings.single.code, 'core-only');
    expect(report.warnings.single.locks, ['a']);
    expect(SiteLockReport.fromJson({}).warnings, isEmpty);
  });

  test('SetupParams writes site-locks only when set', () {
    const base = SetupParams(selectedMap: {}, testUrl: 'u');
    expect(base.toJson().containsKey('site-locks'), isFalse);
    expect(base.copyWith(siteLocks: const []).toJson()['site-locks'], isEmpty);
    expect(
      base.copyWith(siteLocks: const []).toJson().containsKey('site-locks'),
      isTrue,
    );
  });

  test('SiteLockPolicy decodes null lists to defaults', () {
    final policy = SiteLockPolicy.fromJson({
      'revision': 'r',
      'addresses': null,
      'names': {
        'suffix': ['a.com'],
        'full': null,
      },
    });
    expect(policy.addresses, isEmpty);
    expect(policy.fakeRanges, isEmpty);
    expect(
      SiteLockPolicy.fromJson({
        'revision': 'r',
        'fakeRanges': ['198.18.0.0/16'],
      }).fakeRanges,
      ['198.18.0.0/16'],
    );
    expect(policy.names.suffix, ['a.com']);
    expect(policy.names.full, isEmpty);
    expect(
      SiteLockPolicy.fromJson({'revision': 'r', 'unchanged': true}).names,
      const SiteLockNames(),
    );
  });

  test('Config without siteLocks defaults to none', () {
    expect(const Config(themeProps: ThemeProps()).siteLocks, isEmpty);
  });
}
