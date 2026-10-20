import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

const _previewEntries = 6;

class ReleaseNotes extends StatefulWidget {
  const ReleaseNotes({
    super.key,
    required this.body,
    required this.tag,
    required this.fullReleaseUrl,
  });

  final String? body;
  final String tag;
  final String fullReleaseUrl;

  @override
  State<ReleaseNotes> createState() => _ReleaseNotesState();
}

class _ReleaseNotesState extends State<ReleaseNotes> {
  bool _expanded = false;

  @override
  void didUpdateWidget(ReleaseNotes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final version = parseReleaseChangelog(widget.body);
    if (version != null && version.tag == widget.tag) {
      return _structuredNotes(context, version);
    }

    final lines = _filterReleaseMarkdown(widget.body);
    if (lines.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            context.appLocalizations.updateNotesUnavailable,
            style: AppTextStyle.subheadline.of(context),
          ),
          _FullNotesLink(url: widget.fullReleaseUrl),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        _MarkdownBlocks(markdown: lines.join('\n')),
        _FullNotesLink(url: widget.fullReleaseUrl),
      ],
    );
  }

  Widget _structuredNotes(BuildContext context, ChangelogVersion version) {
    final visibleGroups = version.visibleGroups;
    final groups = [
      ...visibleGroups.where((group) => group.type == ChangelogType.breaking),
      ...visibleGroups.where((group) => group.type != ChangelogType.breaking),
    ];
    var remaining = _expanded
        ? groups.fold(0, (sum, group) => sum + group.entries.length)
        : _previewEntries;
    var omitted = false;
    final widgets = <Widget>[];
    for (final group in groups) {
      final entries = group.type == ChangelogType.breaking
          ? group.entries
          : group.entries.take(remaining).toList();
      omitted |= entries.length < group.entries.length;
      remaining = (remaining - entries.length).clamp(0, remaining);
      if (entries.isEmpty) continue;
      final breaking = group.type == ChangelogType.breaking;
      widgets.add(
        _NoteSection(
          title: changelogGroupTitle(context.appLocalizations, group.type),
          glyph: switch (group.type) {
            ChangelogType.breaking => AppGlyphs.warning,
            ChangelogType.feat => AppGlyphs.addCircle,
            ChangelogType.fix => AppGlyphs.wrench,
            ChangelogType.perf => AppGlyphs.proxies,
            ChangelogType.revert => AppGlyphs.undo,
            ChangelogType.unknown => AppGlyphs.info,
          },
          isWarning: breaking,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              for (final entry in entries) _NoteItem(text: entry.text),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        ...widgets,
        if (widgets.isEmpty)
          Text(
            context.appLocalizations.updateNotesUnavailable,
            style: AppTextStyle.subheadline.of(context),
          ),
        if (omitted)
          _NotesDisclosure(onPressed: () => setState(() => _expanded = true)),
        _FullNotesLink(url: widget.fullReleaseUrl),
      ],
    );
  }
}

List<String> _filterReleaseMarkdown(String? body) {
  final scoped = scopeReleaseNotes(
    body ?? '',
  ).replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
  final lines = <String>[];
  var skipSection = false;
  String? fence;
  for (final sourceLine in scoped.split('\n')) {
    final line = sourceLine.trim();
    if (fence != null) {
      lines.add(sourceLine);
      if (line.startsWith(fence)) fence = null;
      continue;
    }
    final heading = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(line);
    if (heading != null) {
      skipSection = RegExp(
        r'^(downloads?|download based on|installation|install|assets?|all changes|list of all changes|full changelog|license)(?:\s|:|$)',
        caseSensitive: false,
      ).hasMatch(heading[1]!);
      if (!skipSection) lines.add(line);
      continue;
    }
    if (skipSection) continue;
    final codeFence = RegExp(r'^(`{3,}|~{3,})').firstMatch(line);
    if (codeFence != null) {
      fence = codeFence[1]!;
      lines.add(sourceLine);
      continue;
    }
    if (line.startsWith('<') ||
        line.startsWith('|') ||
        line.contains('![') ||
        RegExp(
          r'(shields\.io|releases/download|CHANGELOG\.md|list of all changes|download based on your os|grab the build for your operating system)',
          caseSensitive: false,
        ).hasMatch(line)) {
      continue;
    }
    final cleaned = line.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (RegExp(r'^https?://\S+$').hasMatch(cleaned)) continue;
    if (cleaned.isEmpty && (lines.isEmpty || lines.last.isEmpty)) continue;
    lines.add(cleaned);
  }
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return lines;
}

class _FullNotesLink extends StatelessWidget {
  const _FullNotesLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: TextButton.icon(
      onPressed: () => unawaited(dialogs.openUrl(url)),
      icon: const GlyphIcon(AppGlyphs.openExternal, size: 16),
      label: Text(context.appLocalizations.updateSeeFullReleaseNotes),
    ),
  );
}

class _MarkdownBlocks extends StatefulWidget {
  const _MarkdownBlocks({required this.markdown});

  final String markdown;

  @override
  State<_MarkdownBlocks> createState() => _MarkdownBlocksState();
}

class _MarkdownBlocksState extends State<_MarkdownBlocks> {
  bool _expanded = false;

  @override
  void didUpdateWidget(_MarkdownBlocks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdown != widget.markdown) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.markdown.split('\n');
    final blocks = <Widget>[];
    final paragraph = <String>[];

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(_MarkdownInline(text: paragraph.join(' ')));
      paragraph.clear();
    }

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trimRight();
      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }
      final fence = RegExp(r'^(`{3,}|~{3,})').firstMatch(line.trimLeft());
      if (fence != null) {
        flushParagraph();
        final code = <String>[];
        index++;
        while (index < lines.length &&
            !lines[index].trimLeft().startsWith(fence[1]!)) {
          code.add(lines[index]);
          index++;
        }
        blocks.add(_CodeBlock(text: code.join('\n')));
        continue;
      }
      final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line.trim());
      if (heading != null) {
        flushParagraph();
        blocks.add(
          Text(
            heading[2]!,
            style:
                (heading[1]!.length <= 2
                        ? AppTextStyle.headline
                        : AppTextStyle.subheadline)
                    .of(context, emphasized: true),
          ),
        );
        continue;
      }
      final item = RegExp(r'^\s*[-*+]\s+(.*)$').firstMatch(line);
      if (item != null) {
        flushParagraph();
        blocks.add(_NoteItem(text: item[1]!));
        continue;
      }
      final ordered = RegExp(r'^\s*(\d+)[.)]\s+(.*)$').firstMatch(line);
      if (ordered != null) {
        flushParagraph();
        blocks.add(_NoteItem(text: ordered[2]!, marker: '${ordered[1]}.'));
        continue;
      }
      if (RegExp(r'^\s*>\s?').hasMatch(line)) {
        flushParagraph();
        final quote = <String>[];
        while (index < lines.length &&
            RegExp(r'^\s*>\s?').hasMatch(lines[index])) {
          quote.add(lines[index].replaceFirst(RegExp(r'^\s*>\s?'), ''));
          index++;
        }
        index--;
        final alert = RegExp(
          r'^\[!(WARNING|CAUTION|IMPORTANT|NOTE|TIP)\]$',
          caseSensitive: false,
        ).firstMatch(quote.first.trim());
        if (alert != null) quote.removeAt(0);
        final warning =
            alert != null &&
            {
              'WARNING',
              'CAUTION',
              'IMPORTANT',
            }.contains(alert[1]!.toUpperCase());
        blocks.add(
          _NoteSection(
            glyph: warning ? AppGlyphs.warning : AppGlyphs.info,
            isWarning: warning,
            child: _MarkdownInline(text: quote.join('\n')),
          ),
        );
        continue;
      }
      if (RegExp(r'^\s*([-*_]\s*){3,}$').hasMatch(line)) {
        flushParagraph();
        blocks.add(const Divider(height: 12));
        continue;
      }
      paragraph.add(line.replaceAll(RegExp(r'<[^>]*>'), '').trim());
    }
    flushParagraph();
    var visible = _expanded
        ? blocks.length
        : blocks.length.clamp(0, _previewEntries);
    if (visible < blocks.length && visible > 0 && blocks[visible - 1] is Text) {
      visible--;
    }
    final warnings = blocks
        .whereType<_NoteSection>()
        .where((block) => block.isWarning)
        .toList();
    final preview = blocks
        .take(visible)
        .where((block) => !warnings.contains(block));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 14,
      children: [
        ...warnings,
        ...preview,
        if (visible < blocks.length)
          _NotesDisclosure(onPressed: () => setState(() => _expanded = true)),
      ],
    );
  }
}

class _NotesDisclosure extends StatelessWidget {
  const _NotesDisclosure({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    key: const ValueKey('update-notes-expand'),
    onPressed: onPressed,
    icon: const GlyphIcon(AppGlyphs.chevronDown, size: 16),
    label: Text(context.appLocalizations.updateShowAllNotes),
  );
}

class _NoteItem extends StatelessWidget {
  const _NoteItem({required this.text, this.marker = '•'});

  final String text;
  final String marker;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: marker.length > 2 ? 36 : 24,
        child: Text(
          marker,
          style: AppTextStyle.subheadline
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
      Expanded(
        child: _MarkdownInline(
          text: text.replaceFirstMapped(
            RegExp(r'^([^:\n`*\[\]]{2,48}):\s+'),
            (match) => '**${match[1]}:** ',
          ),
        ),
      ),
    ],
  );
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({
    this.title,
    required this.glyph,
    this.isWarning = false,
    required this.child,
  });

  final String? title;
  final Glyph glyph;
  final bool isWarning;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = isWarning
        ? context.colorScheme.error
        : context.colorScheme.onSurfaceVariant;
    final level = context.raisedSurfaceLevel;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: level.colorOf(context.colorScheme),
        shape: AppShape.xl,
      ),
      child: SurfaceScope(
        level: level,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            if (title case final title?)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  GlyphIcon(glyph, size: 20, color: color),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyle.subheadline
                          .of(context, emphasized: true)
                          .copyWith(
                            color: isWarning
                                ? color
                                : context.colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            if (title == null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  GlyphIcon(glyph, size: 20, color: color),
                  Expanded(child: child),
                ],
              )
            else
              child,
          ],
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: ShapeDecoration(
      color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
      shape: AppShape.md,
    ),
    child: SelectableText(
      text,
      style: AppTextStyle.footnote
          .of(context)
          .copyWith(fontFamily: 'JetBrainsMono'),
    ),
  );
}

class _MarkdownInline extends StatefulWidget {
  const _MarkdownInline({required this.text});

  final String text;

  @override
  State<_MarkdownInline> createState() => _MarkdownInlineState();
}

class _MarkdownInlineState extends State<_MarkdownInline> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final style = AppTextStyle.subheadline.of(context);
    return SelectableText.rich(
      TextSpan(style: style, children: _spans(widget.text, style)),
      style: style,
    );
  }

  List<InlineSpan> _spans(
    String text,
    TextStyle style, {
    int depth = 0,
    TapGestureRecognizer? recognizer,
  }) {
    if (depth >= 8) return [TextSpan(text: text, recognizer: recognizer)];
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'(\*\*[^*]+\*\*|__[^_]+__|`[^`]+`|\*[^*]+\*|_[^_]+_|\[[^\]]+\]\([^)]+\))',
    );
    var offset = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > offset) {
        spans.add(
          TextSpan(
            text: text.substring(offset, match.start),
            recognizer: recognizer,
          ),
        );
      }
      final token = match.group(0)!;
      final link = RegExp(r'^\[([^\]]+)\]\(([^)]+)\)$').firstMatch(token);
      if (link != null) {
        final uri = Uri.tryParse(link[2]!);
        final safe =
            uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty;
        final linkRecognizer = safe
            ? (TapGestureRecognizer()
                ..onTap = () => unawaited(dialogs.openUrl(uri.toString())))
            : null;
        if (linkRecognizer != null) _recognizers.add(linkRecognizer);
        final linkStyle = safe
            ? style.copyWith(
                color: context.colorScheme.primary,
                decoration: TextDecoration.underline,
              )
            : style;
        spans.add(
          TextSpan(
            children: _spans(
              link[1]!,
              linkStyle,
              depth: depth + 1,
              recognizer: linkRecognizer,
            ),
            style: linkStyle,
          ),
        );
      } else if (token.startsWith('**') || token.startsWith('__')) {
        final emphasized = AppTextStyle.subheadline
            .of(context, emphasized: true)
            .copyWith(
              color: style.color,
              fontStyle: style.fontStyle,
              decoration: style.decoration,
            );
        spans.add(
          TextSpan(
            children: _spans(
              token.substring(2, token.length - 2),
              emphasized,
              depth: depth + 1,
              recognizer: recognizer,
            ),
            style: emphasized,
          ),
        );
      } else if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            recognizer: recognizer,
            style: style.copyWith(
              fontFamily: 'JetBrainsMono',
              backgroundColor: context.raisedSurfaceLevel.colorOf(
                context.colorScheme,
              ),
            ),
          ),
        );
      } else {
        final italic = style.copyWith(fontStyle: FontStyle.italic);
        spans.add(
          TextSpan(
            children: _spans(
              token.substring(1, token.length - 1),
              italic,
              depth: depth + 1,
              recognizer: recognizer,
            ),
            style: italic,
          ),
        );
      }
      offset = match.end;
    }
    if (offset < text.length) {
      spans.add(TextSpan(text: text.substring(offset), recognizer: recognizer));
    }
    return spans;
  }
}
