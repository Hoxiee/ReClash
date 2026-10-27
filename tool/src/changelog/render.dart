import 'dart:convert';

import 'package:reclash/common/update_summary.dart';

import 'models.dart';

const changelogTitle = '# Changelog';

/// Everything below this marker predates the structured pipeline and is kept
/// verbatim. The generator never writes past it.
const changelogFrozenMarker = '<!-- changelog:frozen -->';

const changelogFrozenNote =
    '<!-- Entries below predate the structured pipeline. Their wording is kept as '
    'written; only the heading and list style were normalized. -->';

const releaseBeginMarker = '<!-- reclash:changelog:begin -->';
const releaseEndMarker = '<!-- reclash:changelog:end -->';

/// Opens the HTML comment that carries the structured entries to the app. The
/// update dialog reads them from the release GitHub already returns, so the
/// notes cost no request of their own and stay invisible on the release page.
const releaseJsonBeginMarker = '<!-- reclash:changelog:json';
const releaseJsonEndMarker = '-->';

const telegramLimit = 900;

const emptyVersionNote = 'Internal improvements only.';

String renderMarkdown(Changelog changelog) {
  final buffer = StringBuffer()
    ..writeln(changelogTitle)
    ..writeln();
  for (final version in changelog.versions) {
    buffer
      ..writeln(_heading(version))
      ..writeln();
    if (version.isEmpty) {
      buffer
        ..writeln(emptyVersionNote)
        ..writeln();
    }
    for (final group in version.groups) {
      buffer
        ..writeln('**${group.type.title}**')
        ..writeln();
      for (final entry in group.entries) {
        buffer.writeln('- ${_prefix(entry)}${entry.text} (${entry.id})');
      }
      buffer.writeln();
    }
  }
  buffer
    ..writeln(changelogFrozenMarker)
    ..writeln(changelogFrozenNote)
    ..writeln();
  return buffer.toString();
}

String renderRelease(ChangelogVersion version, {ReleaseSummary? summary}) {
  if (summary != null && summary.tag != version.tag) {
    throw const FormatException('Release summary must match the release tag');
  }
  final buffer = StringBuffer()..writeln(releaseBeginMarker);
  if (summary != null) {
    _writeOverview(buffer, summary.locales['en']!);
  } else {
    if (version.isEmpty) {
      buffer.writeln('- $emptyVersionNote');
    }
    for (final group in version.groups) {
      buffer.writeln('### ${group.type.title}');
      for (final entry in group.entries) {
        buffer.writeln('- ${_prefix(entry)}${entry.text}');
      }
      buffer.writeln();
    }
  }
  buffer
    ..writeln(releaseEndMarker)
    ..writeln()
    ..write(renderReleaseJson(version));
  if (summary != null) buffer.write(renderReleaseSummary(summary));
  return buffer.toString();
}

/// The release page shows the authored overview; the commit list stays in the
/// hidden JSON and in CHANGELOG.md, so the download block stays on screen.
void _writeOverview(StringBuffer buffer, ReleaseSummaryLocale content) {
  buffer
    ..writeln('**${content.headline}**')
    ..writeln();
  for (final highlight in content.highlights) {
    buffer.writeln('- **${highlight.title}**: ${highlight.description}');
  }
  for (final warning in content.warnings) {
    buffer.writeln('- ⚠️ **${warning.title}**: ${warning.description}');
  }
  buffer.writeln();
}

/// The same version as machine readable JSON, wrapped in an HTML comment so it
/// travels with the release body without showing up on the release page.
///
/// `>` is escaped so no entry can close the comment early, which keeps a
/// changelog line containing `-->` from truncating the payload.
String renderReleaseJson(ChangelogVersion version) {
  final payload = jsonEncode(
    Changelog(versions: <ChangelogVersion>[version]).toJson(),
  ).replaceAll('>', r'\u003e');
  return '$releaseJsonBeginMarker\n$payload\n$releaseJsonEndMarker\n';
}

/// The caption is sent with a parse mode, so entry text is markup, not text: a
/// commit subject carrying a `<` is a malformed tag and Telegram rejects the
/// whole upload. HTML rather than Markdown because it is the one
/// Telegram parse mode with a defined escape — legacy Markdown has none, and a
/// subject containing a lone `*` or `_` cannot be made safe in it.
String escapeTelegramHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

/// Authored summaries preserve warnings; fallback captions fit Telegram limits.
String renderTelegram(
  ChangelogVersion version, {
  String? moreUrl,
  ReleaseSummary? summary,
}) {
  if (summary != null) {
    if (summary.tag != version.tag) {
      throw const FormatException('Release summary must match the release tag');
    }
    final content = summary.locales['en']!;
    final text = [
      '<b>${escapeTelegramHtml(content.headline)}</b>',
      '',
      '<b>${escapeTelegramHtml(content.spotlight.title)}</b>',
      escapeTelegramHtml(content.spotlight.description),
      if (content.highlights.isNotEmpty) '',
      for (final highlight in content.highlights)
        '• ${escapeTelegramHtml(highlight.title)}',
      for (final warning in content.warnings) ...[
        '',
        '<blockquote>⚠️ <b>${escapeTelegramHtml(warning.title)}</b>\n${escapeTelegramHtml(warning.description)}</blockquote>',
      ],
    ].join('\n');
    if (_telegramVisibleLength(text) > 3000) {
      throw const FormatException('Telegram release summary is too long');
    }
    return text;
  }
  final buffer = StringBuffer();
  if (version.isEmpty) {
    buffer.writeln('• ${escapeTelegramHtml(emptyVersionNote)}');
  }
  for (final group in version.groups) {
    buffer.writeln('<b>${escapeTelegramHtml(group.type.title)}</b>');
    for (final entry in group.entries) {
      buffer.writeln('• ${escapeTelegramHtml(entry.text)}');
    }
    buffer.writeln();
  }
  final text = buffer.toString().trimRight();
  if (_telegramVisibleLength(text) <= telegramLimit) {
    return text;
  }
  final kept = StringBuffer();
  var length = 0;
  for (final line in text.split('\n')) {
    length += _telegramVisibleLength(line) + 1;
    if (length > telegramLimit) {
      break;
    }
    kept.writeln(line);
  }
  final more = moreUrl == null ? '' : '\n$moreUrl';
  return '${kept.toString().trimRight()}\n\n…$more';
}

int _telegramVisibleLength(String markup) => markup
    .replaceAll(RegExp('<[^>]*>'), '')
    .replaceAll(RegExp('&[a-z]+;'), '&')
    .length;

/// Version headings stay the only `##` level; groups are bold lines because a
/// release carries a handful of entries and an `###` per group outweighs them.
String _heading(ChangelogVersion version) => version.date.isEmpty
    ? '## ${version.tag}'
    : '## ${version.tag} (${version.date})';

String _prefix(ChangelogEntry entry) =>
    entry.scope == null ? '' : '**${entry.scope}** ';
