import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';

void main() {
  final fence = RegExp(r'```yaml\n(.*?)```', dotAll: true);

  for (final lang in ['en', 'ru']) {
    test('$lang config.md yaml blocks parse without warnings', () {
      final text = File('docs/$lang/providers/config.md').readAsStringSync();
      final blocks = fence.allMatches(text).map((m) => m.group(1)!).toList();
      expect(blocks, isNotEmpty);
      for (final block in blocks) {
        final source = block.contains('version:')
            ? block
            : 'version: 1\n$block';
        final result = parseProviderConfig(source, 'en');
        expect(result.config, isNotNull, reason: block);
        expect(result.warnings, isEmpty, reason: block);
      }
    });
  }

  test('config.md is listed in the manifest', () {
    final manifest = File('docs/manifest.json').readAsStringSync();
    expect(jsonDecode(manifest), isNotNull);
    expect(manifest, contains('"config.md"'));
  });
}
