import 'git.dart';
import 'models.dart';
import 'notes.dart';
import 'parser.dart';
import 'summary.dart';

/// Raw material for authoring the notes of [target], never published as is.
class ReleaseDigest {
  const ReleaseDigest({
    required this.target,
    required this.from,
    required this.groups,
    required this.other,
    required this.earlierNotes,
    required this.warnings,
  });

  final VersionTag target;

  final String? from;
  final List<ChangelogGroup> groups;

  /// Subjects outside the user facing groups: a refactor can still change behavior.
  final List<String> other;

  /// For a stable target, the notes of its own prereleases: the stable notes
  /// restate the cycle from them instead of from hundreds of commits.
  final List<ReleaseNotes> earlierNotes;
  final List<String> warnings;
}

ReleaseDigest buildDigest(Git git, String root, VersionTag target) {
  final reachable = git
      .versionTags()
      .where((tag) => tag.compareTo(target) < 0)
      .toList();
  final cycle = target.isPrerelease
      ? const <VersionTag>[]
      : reachable
            .where((tag) => tag.isPrerelease && tag.version == target.version)
            .toList();
  final previous = target.isPrerelease
      ? reachable.firstOrNull
      : cycle.firstOrNull ??
            reachable.where((tag) => !tag.isPrerelease).firstOrNull;

  final commits = git.commits(from: previous?.name, to: 'HEAD').reversed;
  final parser = ChangelogParser();
  final items = <ChangelogItem>[];
  final other = <String>[];
  for (final commit in commits) {
    final parsed = parser.parse(commit);
    if (parsed.isEmpty) {
      other.add('${commit.shortHash} ${commit.subject}');
    }
    items.addAll(parsed);
  }

  final warnings = [...parser.warnings];
  if (previous == null) {
    warnings.add(
      'no earlier release tag is reachable; the range is all history',
    );
  }
  final earlierNotes = <ReleaseNotes>[];
  for (final tag in cycle) {
    final notes = readReleaseNotes(root, tag.name) ?? _fromSummary(root, tag);
    if (notes == null) {
      warnings.add(
        '${tag.name} has neither notes nor a summary; '
        'read `gh release view ${tag.name}`',
      );
    } else {
      earlierNotes.add(notes);
    }
  }

  return ReleaseDigest(
    target: target,
    from: previous?.name,
    groups: groupItems(items),
    other: other,
    earlierNotes: earlierNotes,
    warnings: warnings,
  );
}

/// Prereleases from before authored notes existed still carry the app summary,
/// which is the closest thing to their notes.
ReleaseNotes? _fromSummary(String root, VersionTag tag) {
  final summary = readReleaseSummary(root, tag.name)?.locales['en'];
  if (summary == null) return null;
  return ReleaseNotes(
    tag: tag,
    body: [
      '(app summary) ${summary.headline}',
      for (final item in [summary.spotlight, ...summary.highlights])
        '- ${item.title}: ${item.description}',
    ].join('\n'),
  );
}

String renderDigest(ReleaseDigest digest) {
  final buffer = StringBuffer()
    ..writeln('# Digest for ${digest.target.name}')
    ..writeln()
    ..writeln(
      'Range: ${digest.from == null ? 'all history' : '${digest.from}..HEAD'}, '
      'oldest first. Raw material for release_notes/${digest.target.name}.md: '
      'merge, net out and rewrite; never paste it.',
    );
  for (final warning in digest.warnings) {
    buffer.writeln('! $warning');
  }
  for (final notes in digest.earlierNotes.reversed) {
    buffer
      ..writeln()
      ..writeln('## Notes of ${notes.tag.name}')
      ..writeln()
      ..writeln(notes.body);
  }
  for (final group in digest.groups) {
    buffer
      ..writeln()
      ..writeln('## ${group.type.title}')
      ..writeln();
    for (final entry in group.entries) {
      final scope = entry.scope == null ? '' : '[${entry.scope}] ';
      buffer.writeln('- $scope${entry.text} (${entry.id})');
    }
  }
  if (digest.other.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Other commits')
      ..writeln();
    for (final line in digest.other) {
      buffer.writeln('- $line');
    }
  }
  return buffer.toString();
}
