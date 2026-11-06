import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';

void main() {
  final fence = RegExp(r'```yaml\n(.*?)```', dotAll: true);
  const pages = ['manifest', 'README', 'request', 'rollout', 'support'];

  String read(String lang, String page) =>
      File('docs/$lang/providers/$page.md').readAsStringSync();

  String full(String lang) {
    final text = read(lang, 'manifest');
    final start = text.indexOf(
      RegExp(r'^## (Full example|Полный пример)$', multiLine: true),
    );
    expect(start, isNonNegative, reason: 'no full example heading');
    return fence.firstMatch(text.substring(start))!.group(1)!;
  }

  for (final lang in ['en', 'ru']) {
    test('$lang provider doc yaml blocks parse without warnings', () {
      for (final page in pages) {
        final blocks = fence
            .allMatches(read(lang, page))
            .map((m) => m.group(1)!)
            .toList();
        if (page == 'manifest') expect(blocks, isNotEmpty);
        for (final block in blocks) {
          final source = block.contains('version:')
              ? block
              : 'version: 1\n$block';
          final result = parseProviderConfig(source, lang);
          expect(result.config, isNotNull, reason: '$page: $block');
          expect(result.warnings, isEmpty, reason: '$page: $block');
        }
      }
    });

    test('$lang full example uses every section without a warning', () {
      final example = full(lang);
      final result = parseProviderConfig(example, lang);
      expect(result.config, isNotNull);
      expect(result.warnings, isEmpty);
      final config = result.config!;
      expect(config.cards, hasLength(3));
      expect(config.view, isNotEmpty);
      expect(config.powerButton, isNotEmpty);
      expect(config.wallpaper, isNotNull);
      expect(config.widgets, isNotEmpty);
      expect(config.routing, isNotNull);
      expect(config.fields.keys, contains('settings.restrictions'));
      expect(config.fields.keys, contains('settings.flags'));
      expect(config.fields.keys, contains('transport.newDomain'));
      for (final section in [
        'provider:',
        'reminders:',
        'settings:',
        'policy:',
        'apps:',
        'transport:',
        'support:',
        'view:',
        'power-button:',
        'wallpaper:',
        'widgets:',
        'cards:',
        'power-labels:',
        'routing:',
      ]) {
        expect(example, contains('\n$section'));
      }
    });

    test('$lang full example fails on any warning', () {
      final example = full(lang);
      for (final broken in [
        '$example\nrestrictions: [lockglobal]\n',
        example.replaceFirst('global: listed', 'global: maybe'),
        example.replaceFirst('connect-on-launch', 'autostart'),
        example.replaceFirst(
          'new-domain: new.example.net',
          'new-domain: [new.example.net]',
        ),
        example.replaceFirst(
          'fallback-hosts: [backup.example.net:8443]',
          'fallback-hosts: backup.example.net',
        ),
      ]) {
        expect(parseProviderConfig(broken, lang).warnings, isNotEmpty);
      }
    });
  }

  test('en and ru full examples carry the same sections', () {
    List<String> keys(String lang) => RegExp(
      r'^[a-z-]+:',
      multiLine: true,
    ).allMatches(full(lang)).map((m) => m.group(0)!).toList();
    expect(keys('ru'), keys('en'));
  });

  test('manifest.md is listed in the manifest', () {
    final manifest = File('docs/manifest.json').readAsStringSync();
    expect(jsonDecode(manifest), isNotNull);
    expect(manifest, contains('"manifest.md"'));
  });
}
