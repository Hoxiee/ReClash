import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

List<int> _parts(String version) =>
    version.split('.').map(int.parse).toList(growable: false);

int _compare(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  for (var i = 0; i < left.length && i < right.length; i++) {
    if (left[i] != right[i]) {
      return left[i].compareTo(right[i]);
    }
  }
  return left.length.compareTo(right.length);
}

String? _flutterVersion(Object? value) {
  if (value is YamlMap) {
    final direct = value['flutter-version'];
    if (direct is String) return direct;
    for (final entry in value.entries) {
      final found = _flutterVersion(entry.value);
      if (found != null) return found;
    }
  } else if (value is YamlList) {
    for (final entry in value) {
      final found = _flutterVersion(entry);
      if (found != null) return found;
    }
  }
  return null;
}

void main() {
  test('release builds pin a Flutter whose Linux engine draws without '
      'glBlitFramebuffer in place', () {
    final workflow =
        loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
            as YamlMap;
    final pinned = (workflow['env'] as YamlMap)['FLUTTER_VERSION'] as String;

    expect(
      _compare(pinned, '3.50.1'),
      greaterThanOrEqualTo(0),
      reason:
          'Flutter 3.50.0 shifts the Linux window content by half its size '
          'on drivers without glBlitFramebuffer, all NVIDIA ones included '
          '(flutter/flutter#195885, fixed in 3.50.1)',
    );
  });
  test('maintenance runs the same Flutter as release builds', () {
    final build =
        loadYaml(File('.github/workflows/build.yaml').readAsStringSync())
            as YamlMap;
    final maintenance =
        loadYaml(
              File(
                '.github/workflows/fork-maintenance.yaml',
              ).readAsStringSync(),
            )
            as YamlMap;
    expect(
      _flutterVersion(maintenance),
      (build['env'] as YamlMap)['FLUTTER_VERSION'],
    );
  });
}
