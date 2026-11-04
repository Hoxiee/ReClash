import 'package:reclash/l10n/l10n.dart';

import 'common.dart';

/// The sections an authored `release_notes/<tag>.md` may hold, in the order
/// the notes tool enforces them.
enum ReleaseNotesSection { breaking, added, improved, fixed, known }

const _sectionHeadings = <String, ReleaseNotesSection>{
  'breaking changes': ReleaseNotesSection.breaking,
  'new': ReleaseNotesSection.added,
  'improved': ReleaseNotesSection.improved,
  'fixed': ReleaseNotesSection.fixed,
  'known issues': ReleaseNotesSection.known,
};

class ReleaseNotesGroup {
  const ReleaseNotesGroup({required this.section, required this.entries});

  final ReleaseNotesSection section;
  final List<String> entries;
}

class ReleaseNotesDocument {
  const ReleaseNotesDocument({required this.lead, required this.groups});

  final String lead;
  final List<ReleaseNotesGroup> groups;

  List<String> get breaking => [
    for (final group in groups)
      if (group.section == ReleaseNotesSection.breaking) ...group.entries,
  ];

  bool get hasBreaking => breaking.isNotEmpty;

  int get entryCount =>
      groups.fold(0, (sum, group) => sum + group.entries.length);
}

String releaseNotesSectionTitle(
  AppLocalizations appLocalizations,
  ReleaseNotesSection section,
) => switch (section) {
  ReleaseNotesSection.breaking => appLocalizations.changelogBreaking,
  ReleaseNotesSection.added => appLocalizations.changelogFeatures,
  ReleaseNotesSection.improved => appLocalizations.changelogImproved,
  ReleaseNotesSection.fixed => appLocalizations.changelogFixes,
  ReleaseNotesSection.known => appLocalizations.changelogKnownIssues,
};

final _headingPattern = RegExp(r'^#{1,6}\s+(.*?)\s*$');
final _bulletPattern = RegExp(r'^-\s+(.*)$');

/// Reads the authored notes between the changelog markers of a release body.
/// A body that is not authored notes (no markers, a heading outside the fixed
/// set, nothing but loose bullets) returns null so the caller can fall back to
/// plain Markdown.
ReleaseNotesDocument? parseReleaseNotes(String? body) {
  if (body == null || !body.contains(releaseNotesBeginMarker)) return null;
  final scoped = scopeReleaseNotes(
    body,
  ).replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
  final lead = <String>[];
  final entries = <ReleaseNotesSection, List<String>>{};
  List<String>? current;
  for (final source in scoped.split('\n')) {
    final line = source.trimRight();
    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      final section = _sectionHeadings[heading[1]!.toLowerCase()];
      if (section == null) return null;
      current = entries.putIfAbsent(section, () => []);
      continue;
    }
    if (line.trim().isEmpty) continue;
    if (current == null) {
      if (!_bulletPattern.hasMatch(line)) lead.add(line.trim());
      continue;
    }
    final bullet = _bulletPattern.firstMatch(line);
    if (bullet != null) {
      current.add(bullet[1]!.trim());
    } else if (current.isNotEmpty && source.startsWith(' ')) {
      current[current.length - 1] = '${current.last} ${line.trim()}';
    }
  }
  final groups = [
    for (final section in ReleaseNotesSection.values)
      if (entries[section]?.isNotEmpty ?? false)
        ReleaseNotesGroup(section: section, entries: entries[section]!),
  ];
  if (groups.isEmpty && lead.isEmpty) return null;
  return ReleaseNotesDocument(lead: lead.join(' '), groups: groups);
}
