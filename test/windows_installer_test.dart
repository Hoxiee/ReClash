import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('installer removes both Helper services through system sc.exe', () {
    final source = File(
      p.join('windows', 'packaging', 'exe', 'inno_setup.iss'),
    ).readAsStringSync();

    expect(source, contains("ExpandConstant('{sys}\\\\sc.exe')"));
    expect(source, contains("RemoveHelperService('ReClashHelperService')"));
    expect(source, contains("RemoveHelperService('FlClashHelperService')"));
    expect(source, contains('ServiceMissing = 1060'));
    expect(source, contains('ServiceNotActive = 1062'));
    expect(source, contains('ServiceMarkedForDelete = 1072'));
    expect(
      source,
      isNot(contains("ExpandConstant('{app}\\\\ReClashHelperService.exe')")),
    );
    expect(source, contains('Name: "{app}\\\\ReClashHelperService.exe"'));
    expect(source, contains('Name: "{app}\\\\FlClashHelperService.exe"'));
  });
}
