import 'package:reclash/common/update_summary.dart';

import 'notes.dart';

const releaseBeginMarker = '<!-- reclash:changelog:begin -->';
const releaseEndMarker = '<!-- reclash:changelog:end -->';

const _telegramLimit = 3000;

/// Continuation lines are joined because the update sheet renders each line alone.
String renderRelease(ReleaseNotes notes, {ReleaseSummary? summary}) {
  if (summary != null && summary.tag != notes.tag.name) {
    throw const FormatException('Release summary must match the release tag');
  }
  final buffer = StringBuffer()
    ..writeln(releaseBeginMarker)
    ..writeln(notes.body.replaceAll(RegExp(r'\n {2,}'), ' '))
    ..writeln()
    ..writeln(releaseEndMarker)
    ..writeln();
  if (summary != null) buffer.write(renderReleaseSummary(summary));
  return buffer.toString();
}

/// HTML parse mode, because legacy Markdown has no escape for a lone `*` or `_`
/// and an unescaped `<` makes Telegram reject the whole post.
String escapeTelegramHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

String renderTelegram(ReleaseSummary summary) {
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
  if (_telegramVisibleLength(text) > _telegramLimit) {
    throw const FormatException('Telegram release summary is too long');
  }
  return text;
}

int _telegramVisibleLength(String markup) => markup
    .replaceAll(RegExp('<[^>]*>'), '')
    .replaceAll(RegExp('&[a-z]+;'), '&')
    .length;
