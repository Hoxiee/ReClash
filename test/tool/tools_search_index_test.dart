import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_tools_search_index.dart';

void main() {
  test('generated tools search index matches the screens on disk', () {
    final root = Directory.current.path;
    final generated = File('$root/lib/views/tools/tools_search_index.g.dart');
    expect(
      generated.existsSync(),
      isTrue,
      reason:
          'Missing generated index; run '
          'dart run tool/gen_tools_search_index.dart --write',
    );
    expect(
      generated.readAsStringSync(),
      render(collectSettings(root)),
      reason:
          'tools_search_index.g.dart is stale; a settings screen gained or '
          'renamed a row. Regenerate with '
          'dart run tool/gen_tools_search_index.dart --write',
    );
  });
}
