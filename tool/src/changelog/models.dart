library;

enum ChangelogType {
  breaking('breaking', 'Breaking Changes'),
  feat('feat', 'Features'),
  fix('fix', 'Bug Fixes'),
  perf('perf', 'Performance'),
  revert('revert', 'Reverts');

  const ChangelogType(this.id, this.title);

  final String id;
  final String title;

  static ChangelogType? fromId(String value) {
    for (final type in values) {
      if (type.id == value) {
        return type;
      }
    }
    return null;
  }
}

class RawCommit {
  const RawCommit({
    required this.hash,
    required this.subject,
    required this.body,
  });

  final String hash;
  final String subject;
  final String body;

  String get shortHash => hash.length > 7 ? hash.substring(0, 7) : hash;
}

class ChangelogEntry {
  const ChangelogEntry({required this.id, required this.text, this.scope});

  final String id;
  final String? scope;
  final String text;
}

class ChangelogGroup {
  const ChangelogGroup({required this.type, required this.entries});

  final ChangelogType type;
  final List<ChangelogEntry> entries;
}
