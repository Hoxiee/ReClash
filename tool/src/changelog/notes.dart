import 'dart:io';

import 'package:path/path.dart' show join;

import 'git.dart';

const releaseNotesDirectory = 'release_notes';

const changelogMarkdownPath = 'CHANGELOG.md';

/// Section headings a notes file may use, in the order they must appear.
const releaseNotesSections = <String>[
  'Breaking changes',
  'New',
  'Improved',
  'Fixed',
  'Known issues',
];

const _sourceLimit = 20000;

final _headingPattern = RegExp(r'^(#{1,6})\s+(.*?)\s*$');
final _bulletPattern = RegExp(r'^- \S');
final _commitReferencePattern = RegExp(r'\(\s*[0-9a-f]{7,40}\s*\)');

const _changelogHeader =
    '# Changelog\n\n'
    '<!-- Generated from release_notes/ by `dart run tool/changelog.dart '
    'changelog`. Edit the notes, not this file. -->\n';

/// Release notes authored for one tag: the Markdown shown on the GitHub
/// release page, in the update sheet details and in CHANGELOG.md.
class ReleaseNotes {
  const ReleaseNotes({required this.tag, required this.body});

  final VersionTag tag;
  final String body;
}

File releaseNotesFile(String root, String tag) =>
    File(join(root, releaseNotesDirectory, '$tag.md'));

ReleaseNotes? readReleaseNotes(String root, String tag) {
  final parsed = VersionTag.tryParse(tag);
  if (parsed == null || parsed.name != tag) {
    throw FormatException('Invalid release notes tag', tag);
  }
  final directory = Directory(join(root, releaseNotesDirectory));
  final file = releaseNotesFile(root, tag);
  final type = FileSystemEntity.typeSync(file.path, followLinks: false);
  if (type == FileSystemEntityType.notFound) return null;
  if (type != FileSystemEntityType.file ||
      file.resolveSymbolicLinksSync() !=
          join(directory.resolveSymbolicLinksSync(), '$tag.md')) {
    throw const FormatException('Release notes must be regular files');
  }
  final source = file.readAsStringSync();
  final problems = validateReleaseNotes(source);
  if (problems.isNotEmpty) {
    throw FormatException(problems.join('; '));
  }
  return ReleaseNotes(tag: parsed, body: source.trim());
}

/// Every problem with [source], empty when the notes can ship. The shape is
/// fixed so the page, the update sheet and CHANGELOG.md read the same way.
List<String> validateReleaseNotes(String source) {
  final problems = <String>[];
  if (source.trim().isEmpty) return const ['notes are empty'];
  if (source.length > _sourceLimit) {
    problems.add('notes exceed $_sourceLimit characters');
  }
  if (source.contains('<!--') || source.contains('-->')) {
    problems.add('HTML comments would break the release body markers');
  }
  if (_commitReferencePattern.hasMatch(source)) {
    problems.add('notes reference commit hashes; describe the change instead');
  }

  var lastSection = -1;
  var bulletsInSection = 0;
  String? section;
  void closeSection() {
    if (section != null && bulletsInSection == 0) {
      problems.add('section "$section" has no bullets');
    }
  }

  for (final line in source.split('\n')) {
    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      final title = heading[2]!;
      final index = releaseNotesSections.indexOf(title);
      if (heading[1] != '###' || index < 0) {
        problems.add(
          'unexpected heading "${line.trim()}"; use ### with one of '
          '${releaseNotesSections.join(', ')}',
        );
        continue;
      }
      if (index <= lastSection) {
        problems.add('section "$title" is repeated or out of order');
      }
      closeSection();
      lastSection = index;
      section = title;
      bulletsInSection = 0;
      continue;
    }
    if (line.trim().isEmpty) continue;
    if (section == null) {
      if (line.trimLeft().startsWith('- ')) {
        problems.add('bullets belong under a section heading');
      }
      continue;
    }
    if (_bulletPattern.hasMatch(line)) {
      bulletsInSection++;
    } else if (!line.startsWith('  ')) {
      problems.add(
        'section "$section" holds "${line.trim()}"; only "- " bullets and '
        'indented continuation lines belong there',
      );
    }
  }
  closeSection();
  if (lastSection < 0) problems.add('notes have no section');
  return problems;
}

List<ReleaseNotes> readAllReleaseNotes(String root) {
  final directory = Directory(join(root, releaseNotesDirectory));
  if (!directory.existsSync()) return const [];
  final notes = <ReleaseNotes>[
    for (final entry in directory.listSync(followLinks: false))
      if (entry.path.endsWith('.md') &&
          VersionTag.tryParse(_tagOf(entry)) != null)
        readReleaseNotes(root, _tagOf(entry))!,
  ]..sort((left, right) => right.tag.compareTo(left.tag));
  return notes;
}

List<String> verifyReleaseNotes(String root) {
  final directory = Directory(join(root, releaseNotesDirectory));
  if (!directory.existsSync()) return const [];
  final problems = <String>[];
  for (final entry in directory.listSync(followLinks: false)) {
    if (!entry.path.endsWith('.md')) continue;
    final tag = _tagOf(entry);
    if (VersionTag.tryParse(tag)?.name != tag) {
      if (tag != 'README') {
        problems.add('$releaseNotesDirectory/$tag.md is not named after a tag');
      }
      continue;
    }
    try {
      readReleaseNotes(root, tag);
    } on FormatException catch (error) {
      problems.add('$releaseNotesDirectory/$tag.md: ${error.message}');
    }
  }
  problems.sort();
  return problems;
}

/// Stable releases stay forever; prereleases stay only until their stable
/// ships, because the stable notes restate the whole cycle.
String renderChangelog(List<ReleaseNotes> notes) {
  final shipped = {
    for (final item in notes)
      if (!item.tag.isPrerelease) item.tag.version,
  };
  final buffer = StringBuffer(_changelogHeader);
  for (final item in notes) {
    if (item.tag.isPrerelease && shipped.contains(item.tag.version)) continue;
    buffer
      ..writeln()
      ..writeln('## ${item.tag.name}')
      ..writeln()
      ..writeln(item.body);
  }
  return buffer.toString();
}

String _tagOf(FileSystemEntity entry) {
  final name = entry.uri.pathSegments.lastWhere((part) => part.isNotEmpty);
  return name.substring(0, name.length - '.md'.length);
}
