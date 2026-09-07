import 'package:emoji_regex/emoji_regex.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_info_card.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);

class Announce extends ConsumerWidget {
  const Announce({super.key});

  void _showAnnounceSheet(BuildContext context, String text) {
    showSheet(
      context: context,
      builder: (_) => AdaptiveSheetScaffold(
        title: context.appLocalizations.announce,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectionArea(child: AnnounceText(text: text, links: true)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announce = ref.watch(
      currentProfileProvider.select((state) => state?.panelMeta?.announce),
    );
    final text = announce?.trim();
    final hasAnnouncement = text != null && text.isNotEmpty;
    return DashboardInfoCard(
      height: getWidgetHeight(2),
      icon: Icons.campaign_rounded,
      label: context.appLocalizations.announce,
      action: hasAnnouncement
          ? const Icon(Icons.open_in_full_rounded, size: 18)
          : null,
      onPressed: hasAnnouncement
          ? () => _showAnnounceSheet(context, text)
          : null,
      child: Align(
        alignment: Alignment.topLeft,
        child: AnnounceText(
          text: hasAnnouncement
              ? text
              : context.appLocalizations.noAnnouncements,
          maxLines: 7,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: hasAnnouncement
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

/// Panel announcements mix plain text, emoji, and URLs; emoji gets the bundled
/// Twemoji face and URLs become tappable when [links] is set.
class AnnounceText extends StatefulWidget {
  const AnnounceText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.links = false,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool links;

  @override
  State<AnnounceText> createState() => _AnnounceTextState();
}

class _AnnounceTextState extends State<AnnounceText> {
  List<({String url, TapGestureRecognizer recognizer})> _links = const [];

  @override
  void initState() {
    super.initState();
    _links = _createLinks();
  }

  @override
  void didUpdateWidget(AnnounceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.links != widget.links) {
      _disposeLinks();
      _links = _createLinks();
    }
  }

  @override
  void dispose() {
    _disposeLinks();
    super.dispose();
  }

  List<({String url, TapGestureRecognizer recognizer})> _createLinks() {
    if (!widget.links) {
      return const [];
    }
    return _urlPattern
        .allMatches(widget.text)
        .map((match) => match.group(0)!)
        .map(
          (url) => (
            url: url,
            recognizer: TapGestureRecognizer()
              ..onTap = () => dialogs.openUrl(url),
          ),
        )
        .toList();
  }

  void _disposeLinks() {
    for (final link in _links) {
      link.recognizer.dispose();
    }
  }

  List<InlineSpan> _emojiSpans(String text, TextStyle? style) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in emojiRegex().allMatches(text)) {
      if (match.start > last) {
        spans.add(
          TextSpan(text: text.substring(last, match.start), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: style?.copyWith(fontFamily: FontFamily.twEmoji.value),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: style));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.textTheme.bodyMedium?.toLight;
    final linkStyle = style?.copyWith(color: context.colorScheme.primary);
    final spans = <InlineSpan>[];
    var linkIndex = 0;
    var lastIndex = 0;
    for (final match in _urlPattern.allMatches(widget.text)) {
      if (match.start > lastIndex) {
        spans.addAll(
          _emojiSpans(widget.text.substring(lastIndex, match.start), style),
        );
      }
      final url = match.group(0)!;
      if (linkIndex < _links.length) {
        spans.add(
          TextSpan(
            text: url,
            style: linkStyle,
            recognizer: _links[linkIndex].recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: url, style: style));
      }
      linkIndex++;
      lastIndex = match.end;
    }
    if (lastIndex < widget.text.length) {
      spans.addAll(_emojiSpans(widget.text.substring(lastIndex), style));
    }
    return Text.rich(
      TextSpan(children: spans),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
