import 'dart:io';

import 'package:test/test.dart';

import '../../tool/gen_provider_standard.dart';

/// Fails when a model file changed but the generated artefacts did not.
void main() {
  test('provider standard artefacts match the model files', () {
    final root = Directory.current.path;
    String read(String rel) => File('$root/$rel').readAsStringSync();

    final std = buildStandard(
      headers: read('lib/models/panel_headers.dart'),
      appearance: read('lib/models/panel_appearance.dart'),
      enums: read('lib/enum/enum.dart'),
    );

    const fix = 'run `dart run tool/gen_provider_standard.dart`';
    expect(read('provider_standard.g.json'), renderJson(std), reason: fix);
    expect(read('PROVIDER_HEADERS.md'), renderMarkdown(std), reason: fix);
  });
}
