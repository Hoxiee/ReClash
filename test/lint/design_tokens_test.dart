import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _generatedL10n = ['lib/l10n/l10n.dart', 'lib/l10n/intl/'];

bool _isGenerated(String path) {
  return path.contains('/generated/') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      _generatedL10n.any(path.startsWith);
}

Iterable<File> _dartFiles(List<String> roots) sync* {
  for (final root in roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) {
      fail('$root no longer exists; update the roots.');
    }
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        yield entity;
      }
    }
  }
}

final _radiusLiteral = RegExp(r'(BorderRadius|Radius)\.circular\(\s*[0-9]');

void main() {
  test('screen shape comes from AppRadius/AppShape, not raw literals', () {
    final offenders = <String>[];
    for (final file in _dartFiles(const ['lib/views', 'lib/widgets'])) {
      final relative = p.relative(file.path);
      if (_isGenerated(relative)) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) {
          continue;
        }
        if (_radiusLiteral.hasMatch(line)) {
          offenders.add(
            '$relative:${i + 1} — raw radius literal; take it from '
            'AppRadius/AppCorner (a value derived from another radius may '
            'pass a variable to circular()).',
          );
        }
        if (line.contains('RoundedRectangleBorder(')) {
          offenders.add(
            '$relative:${i + 1} — use AppShape (superellipse), not '
            'RoundedRectangleBorder.',
          );
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('the caution amber lives only in common/ui/color.dart', () {
    final source = p.join('lib', 'common', 'ui', 'color.dart');
    final offenders = <String>[];
    for (final file in _dartFiles(const ['lib'])) {
      final relative = p.relative(file.path);
      if (_isGenerated(relative) || relative == source) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].toUpperCase().contains('0XFFC57F0A')) {
          offenders.add(
            '$relative:${i + 1} — use cautionColor from color.dart.',
          );
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('spacing on the token scale comes from AppSpacing/AppInsets', () {
    final all = RegExp(r'EdgeInsets\.all\(\s*(2|4|8|12|16|20|24|32)\s*\)');
    final box = RegExp(
      r'SizedBox\(\s*(height|width):\s*(2|4|8|12|16|20|24|32)\s*\)',
    );
    final offenders = <String>[];
    for (final file in _dartFiles(const ['lib/views', 'lib/widgets'])) {
      final relative = p.relative(file.path);
      if (_isGenerated(relative)) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) {
          continue;
        }
        if (all.hasMatch(line) || box.hasMatch(line)) {
          offenders.add(
            '$relative:${i + 1} — on-scale spacing literal; take it from '
            'AppInsets/AppSpacing (an off-grid value like 10/14 may stay raw).',
          );
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('status greens/oranges come from colorScheme.success/warning', () {
    final harmonized = RegExp(
      r'Colors\.(green|orange)\.harmonizeWith\([^)]*\.primary',
    );
    final source = p.join('lib', 'common', 'ui', 'color.dart');
    final offenders = <String>[];
    for (final file in _dartFiles(const ['lib/views', 'lib/widgets'])) {
      final relative = p.relative(file.path);
      if (_isGenerated(relative) || relative == source) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) {
          continue;
        }
        if (harmonized.hasMatch(line)) {
          offenders.add(
            '$relative:${i + 1} — green/orange harmonized against primary is '
            'colorScheme.success/warning; use the named token.',
          );
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
