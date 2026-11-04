import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'options.dart';
import 'stage.dart';

const _chipHeight = 32.0;

List<String> _symptoms(AppLocalizations l) => [
  l.reportSymptomNoConnection,
  l.reportSymptomSlow,
  l.reportSymptomSomeSites,
  l.reportSymptomDrops,
];

/// "What went wrong?": the note, with ready phrases for those who would
/// rather tap than type, and the one button that starts everything.
class ReportStartView extends StatelessWidget {
  const ReportStartView({
    super.key,
    required this.note,
    required this.draft,
    required this.onCreate,
    required this.onOptions,
  });

  final TextEditingController note;
  final ReportDraft draft;
  final VoidCallback onCreate;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonScaffold(
      title: l.reportProblem,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.sliders,
          tooltip: l.options,
          onPressed: onOptions,
        ),
      ],
      body: ListenableBuilder(
        listenable: draft,
        builder: (context, _) => ReportStageLayout(
          hero: ReportHero(
            badge: ReportBadge(
              color: colorScheme.primary,
              child: const GlyphIcon(AppGlyphs.support),
            ),
            title: l.reportStartTitle,
            subtitle: Text(l.reportStartSubtitle),
          ),
          body: [_NoteComposer(controller: note)],
          primary: FilledButton(
            key: const ValueKey('report-create'),
            onPressed: onCreate,
            child: Text(draft.reproduce ? l.reportRecordStart : l.reportCreate),
          ),
          secondary: _FootNote(
            glyph: draft.reproduce ? AppGlyphs.clock : AppGlyphs.lock,
            text: [
              if (draft.reproduce) l.reportRecordNote,
              switch (draft.redaction) {
                ReportRedaction.provider => l.reportPrivacyNote,
                ReportRedaction.public => l.reportPrivacyNotePublic,
              },
            ].join('\n'),
          ),
        ),
      ),
    );
  }
}

class _FootNote extends StatelessWidget {
  const _FootNote({required this.glyph, required this.text});

  final Glyph glyph;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = context.colorScheme.onSurfaceVariant;
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: GlyphIcon(glyph, size: 14, color: muted),
            ),
          ),
          TextSpan(text: text),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppTextStyle.footnote.of(context).copyWith(color: muted),
    );
  }
}

/// A text area on a card, the phrases at its foot: a tapped phrase goes in
/// on a line of its own and a second tap takes it out.
class _NoteComposer extends StatefulWidget {
  const _NoteComposer({required this.controller});

  final TextEditingController controller;

  @override
  State<_NoteComposer> createState() => _NoteComposerState();
}

class _NoteComposerState extends State<_NoteComposer> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  List<String> get _lines => widget.controller.text.split('\n');

  void _toggle(String phrase) {
    final lines = _lines;
    final text = lines.contains(phrase)
        ? (lines..remove(phrase)).join('\n').trim()
        : [
            if (widget.controller.text.trim().isNotEmpty)
              widget.controller.text.trimRight(),
            phrase,
          ].join('\n');
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final level = context.raisedSurfaceLevel;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: level.colorOf(colorScheme),
        shape: AppShape.xl.copyWith(
          side: _focus.hasFocus
              ? BorderSide(color: colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
      ),
      child: SurfaceScope(
        level: level,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _focus.requestFocus,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: TextField(
                  key: const ValueKey('report-note'),
                  controller: widget.controller,
                  focusNode: _focus,
                  minLines: 2,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyle.body.of(context),
                  decoration: InputDecoration.collapsed(
                    hintText: l.reportNoteHint,
                    hintStyle: AppTextStyle.body
                        .of(context)
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  final lines = _lines;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final phrase in _symptoms(l))
                        _PhraseChip(
                          label: phrase,
                          selected: lines.contains(phrase),
                          onPressed: () => _toggle(phrase),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhraseChip extends StatelessWidget {
  const _PhraseChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: _chipHeight,
      child: CommonCard(
        isSelected: selected,
        fillsSelection: true,
        shape: AppShape.full,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onPressed: onPressed,
        child: Text(
          label,
          maxLines: 1,
          style: AppTextStyle.subheadline
              .of(context, emphasized: true)
              .copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
