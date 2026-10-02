import 'dart:io';

import 'package:test/test.dart';

/// The one button that carries its label on an enclosing `AppTooltip` instead of
/// its own `tooltip:`. Nesting a second tooltip inside would fight it.
const _wrappedInTooltip = 'lib/views/dashboard/widgets/core_status_button.dart';

final _iconButton = RegExp(
  r'\bIconButton(?:\.(?:filled|filledTonal|outlined))?\(',
);

Iterable<File> _dartFilesIn(String root) sync* {
  final directory = Directory(root);
  if (!directory.existsSync()) {
    fail('$root no longer exists; update this test.');
  }
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.endsWith('.g.dart') &&
        !entity.path.endsWith('.freezed.dart') &&
        !entity.path.contains('/generated/')) {
      yield entity;
    }
  }
}

String _arguments(String source, int start) {
  var depth = 1;
  var index = start;
  while (index < source.length && depth > 0) {
    if (source[index] == '(') depth++;
    if (source[index] == ')') depth--;
    index++;
  }
  return source.substring(start, index - 1);
}

void main() {
  test('every icon-only IconButton carries a tooltip', () {
    final unlabelled = <String>[];

    for (final file in _dartFilesIn('lib')) {
      final source = file.readAsStringSync();
      if (file.path == _wrappedInTooltip) continue;

      for (final match in _iconButton.allMatches(source)) {
        final arguments = _arguments(source, match.end);
        if (RegExp(r'\btooltip\s*:').hasMatch(arguments)) continue;
        // An icon slot holding text is already its own visible label.
        if (RegExp(r'icon:\s*Text\(').hasMatch(arguments)) continue;

        final line = '\n'.allMatches(source.substring(0, match.start)).length;
        unlabelled.add(
          '${file.path}:${line + 1} — an icon has no accessible name, so '
          'TalkBack and VoiceOver announce nothing and the desktop build shows '
          'no hover hint.',
        );
      }
    }

    expect(unlabelled, isEmpty, reason: unlabelled.join('\n'));
  });

  test('labelled buttons use the shared tooltip behavior', () {
    final offenders = <String>[];
    final buttons = RegExp(
      r'\b(?:IconButton(?:\.(?:filled|filledTonal|outlined))?'
      r'|FloatingActionButton(?:\.(?:small|large|extended))?)\(',
    );
    for (final file in _dartFilesIn('lib')) {
      final source = file.readAsStringSync();
      for (final match in buttons.allMatches(source)) {
        final arguments = _arguments(source, match.end);
        if (!RegExp(r'\btooltip\s*:').hasMatch(arguments)) continue;
        final tail = source.substring(match.end + arguments.length + 1);
        if (tail.trimLeft().startsWith('.withAppTooltip()')) continue;
        offenders.add(
          '${file.path} — finish labelled buttons with .withAppTooltip().',
        );
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('standalone hints use AppTooltip rather than raw Material Tooltip', () {
    final offenders = <String>[];
    for (final file in _dartFilesIn('lib')) {
      if (file.path.startsWith('lib/l10n/')) continue;
      if (RegExp(r'\bTooltip\s*\(').hasMatch(file.readAsStringSync())) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test(
    'the exempted button still gets its label from an enclosing AppTooltip',
    () {
      final source = File(_wrappedInTooltip).readAsStringSync();

      expect(
        source,
        contains('AppTooltip('),
        reason:
            '$_wrappedInTooltip is exempted from the tooltip rule because an '
            'enclosing AppTooltip labels it. That wrapper is gone; either restore it '
            'or give the button its own tooltip and drop the exemption.',
      );
    },
  );
}
