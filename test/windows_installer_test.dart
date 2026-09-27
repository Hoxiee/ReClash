import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  final iss = File(
    p.join('windows', 'packaging', 'exe', 'inno_setup.iss'),
  ).readAsStringSync();
  final makeConfig = File(
    p.join('windows', 'packaging', 'exe', 'make_config.yaml'),
  ).readAsStringSync();

  test('installer clears the ReClash helper service through system sc.exe', () {
    expect(iss, contains("ExpandConstant('{sys}\\sc.exe')"));
    expect(iss, contains("RemoveHelperService('ReClashHelperService')"));
    expect(iss, contains('ServiceMissing = 1060'));
    expect(iss, contains('ServiceNotActive = 1062'));
    expect(iss, contains('ServiceMarkedForDelete = 1072'));
    expect(iss, contains('Name: "{app}\\ReClashHelperService.exe"'));
  });

  test('installer carries no FlClash identity', () {
    expect(iss, isNot(contains('FlClash')));
    expect(makeConfig, isNot(contains('FlClash')));
    // FlClash's inherited Inno AppId made setup reuse FlClash's install dir;
    // a re-sync from upstream must never drag that GUID back in.
    expect(makeConfig, isNot(contains('728B3532-C74B-4870-9068-BE70FE12A3E6')));
  });

  test('installer ships the four requested setup languages', () {
    for (final lang in ['en', 'ru', 'zh', 'ko']) {
      expect(makeConfig, contains('lang: $lang'));
    }
    expect(iss, contains('Name: "russian"'));
    expect(iss, contains('Name: "korean"'));
  });
}
