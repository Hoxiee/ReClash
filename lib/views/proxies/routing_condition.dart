import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _parseDelay = Duration(milliseconds: 400);

/// Edits one condition of [profile] as clauses or as text and returns the
/// new text; the Core owns the grammar, so both views go through it.
Future<String?> editCondition(
  BuildContext context, {
  required String title,
  required String text,
  required Map<String, Object?> profile,
  bool network = false,
}) {
  return BaseNavigator.push<String>(
    context,
    ConditionEditor(
      title: title,
      text: text,
      profile: profile,
      network: network,
    ),
  );
}

/// Every clause is edited in place: field, condition and value are menus on
/// the clause's own rows, so nothing opens on top of the editor.
class ConditionEditor extends ConsumerStatefulWidget {
  const ConditionEditor({
    super.key,
    required this.title,
    required this.text,
    required this.profile,
    required this.network,
  });

  final String title;
  final String text;
  final Map<String, Object?> profile;
  final bool network;

  @override
  ConsumerState<ConditionEditor> createState() => _ConditionEditorState();
}

class _ConditionEditorState extends ConsumerState<ConditionEditor> {
  late final _text = TextEditingController(text: widget.text);
  Timer? _debounce;
  RcxCondForm? _form;
  List<RcxField> _fields = const [];
  // Keys the clause rows, so their text fields survive an edit elsewhere.
  List<int> _ids = const [];
  int _nextId = 0;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_run({'text': widget.text}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  /// Answers out of order are dropped: only the latest edit may win.
  Future<void> _run(Map<String, Object?> request) async {
    final id = ++_request;
    final result = await ref.read(rcxRoutingActionProvider.notifier).studio({
      'op': 'cond',
      'profile': widget.profile,
      'network': widget.network,
      ...request,
    });
    if (!mounted || id != _request || result == null) return;
    setState(() {
      final fromText = !request.containsKey('form');
      _form = fromText
          ? result.form
          : _form?.copyWith(error: result.form?.error ?? '');
      _fields = result.fields;
      if (fromText) {
        _ids = [for (final _ in result.form?.clauses ?? const []) _nextId++];
      } else if (result.form?.error.isEmpty == true) {
        _text.text = result.text;
      }
    });
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_parseDelay, () => unawaited(_run({'text': text})));
  }

  void _applyForm(RcxCondForm form) {
    setState(() => _form = form);
    _debounce?.cancel();
    _debounce = Timer(_parseDelay ~/ 4, () {
      unawaited(_run({'form': form.toJson()}));
    });
  }

  void _setClause(int index, RcxClause clause) {
    final form = _form!;
    _applyForm(form.copyWith(clauses: [...form.clauses]..[index] = clause));
  }

  void _addClause() {
    final form = _form ?? const RcxCondForm(flat: true);
    final field = _fields.firstOrNull;
    if (field == null) return;
    _ids = [..._ids, _nextId++];
    _applyForm(form.copyWith(clauses: [...form.clauses, _blankClause(field)]));
  }

  void _removeClause(int index) {
    final form = _form!;
    _ids = [..._ids]..removeAt(index);
    _applyForm(form.copyWith(clauses: [...form.clauses]..removeAt(index)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final form = _form;
    final error = form?.error ?? '';
    return FormPage(
      title: widget.title,
      error: error.isEmpty ? null : error,
      onSave: error.isEmpty && form != null
          ? () => Navigator.of(context).pop(_text.text.trim())
          : null,
      children: [
        if (form != null && form.flat) ...[
          if (form.clauses.length > 1)
            generateSection(
              items: [
                ListItem<String>.options(
                  title: Text(l.rcxCondMatch),
                  options: const ['and', 'or'],
                  value: form.join,
                  textBuilder: (join) =>
                      join == 'and' ? l.rcxCondAll : l.rcxCondAny,
                  onChanged: (join) => _applyForm(form.copyWith(join: join)),
                ),
              ],
            ),
          for (final (index, clause) in form.clauses.indexed)
            _ClauseSection(
              key: ValueKey(_ids.elementAtOrNull(index) ?? -index - 1),
              index: index,
              clause: clause,
              fields: _fields,
              onChanged: (clause) => _setClause(index, clause),
              onRemove: () => _removeClause(index),
            ),
          if (form.clauses.isNotEmpty) const SizedBox(height: 16),
          generateSection(
            footer: form.clauses.isEmpty
                ? (widget.network ? l.rcxCondAlways : l.rcxCondAnyServer)
                : null,
            items: [
              FormRow(
                title: l.rcxCondAdd,
                leading: EntryButton.add(onPressed: _addClause),
                onPressed: _addClause,
              ),
            ],
          ),
        ] else if (form != null && form.error.isEmpty)
          generateSection(
            items: [DecorationListItem(title: Text(l.rcxCondTooComplex))],
          ),
        generateSection(
          title: l.rcxCondText,
          items: [
            DecorationListItem(
              title: TextField(
                controller: _text,
                maxLines: null,
                autocorrect: false,
                style: AppTextStyle.callout
                    .of(context)
                    .copyWith(fontFamily: FontFamily.jetBrainsMono.value),
                decoration: InputDecoration.collapsed(
                  hintText: widget.network
                      ? l.rcxCondAlways
                      : l.rcxCondAnyServer,
                ),
                onChanged: _onTextChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

RcxClause _blankClause(RcxField field) => RcxClause(
  field: field.name,
  op: field.ops.firstOrNull ?? '',
  values: field.values.isEmpty ? const [] : [field.values.first],
);

bool _named(RcxField? field) => switch (field?.kind) {
  'tag' || 'check' || 'diag' => true,
  _ => false,
};

/// A clause's condition with its negation folded in, so one menu says
/// "is", "is not", "one of", "not one of", "yes" or "no".
typedef _Test = ({String op, bool negated});

List<_Test> _testsOf(RcxField field) {
  if (field.ops.isEmpty) {
    return const [(op: '', negated: false), (op: '', negated: true)];
  }
  return [
    for (final op in field.ops) ...[
      (op: op, negated: false),
      // = and != already say both.
      if (op != '=' && op != '!=') (op: op, negated: true),
    ],
  ];
}

String _testLabel(AppLocalizations l, _Test test) {
  if (test.op.isEmpty) return test.negated ? l.no : l.yes;
  final label = rcxOpLabel(l, test.op);
  return test.negated ? '${l.rcxCondNotPrefix} $label' : label;
}

class _ClauseSection extends StatefulWidget {
  const _ClauseSection({
    super.key,
    required this.index,
    required this.clause,
    required this.fields,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final RcxClause clause;
  final List<RcxField> fields;
  final ValueChanged<RcxClause> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ClauseSection> createState() => _ClauseSectionState();
}

class _ClauseSectionState extends State<_ClauseSection> {
  late final _value = TextEditingController(text: _valueText(widget.clause));

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  static String _valueText(RcxClause clause) => clause.values.join(', ');

  RcxClause get _clause => widget.clause;

  RcxField? get _field =>
      widget.fields.where((f) => f.name == _clause.field).firstOrNull;

  void _setField(String name) {
    final field = widget.fields.firstWhere((f) => f.name == name);
    _value.clear();
    widget.onChanged(_blankClause(field));
  }

  void _setValues(String text) {
    final values = _clause.op == 'in'
        ? [
            for (final v in text.split(','))
              if (v.trim().isNotEmpty) v.trim(),
          ]
        : [if (text.trim().isNotEmpty) text.trim()];
    widget.onChanged(_clause.copyWith(values: values));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final field = _field;
    final tests = field == null ? const <_Test>[] : _testsOf(field);
    final test = (op: _clause.op, negated: _clause.negated);
    return generateSection(
      title: l.rcxCondClause(widget.index + 1),
      actions: [
        IconButtonData(
          glyph: AppGlyphs.delete,
          tooltip: l.delete,
          onPressed: widget.onRemove,
        ),
      ],
      items: [
        ListItem<String>.options(
          title: Text(l.rcxCondField),
          options: [for (final f in widget.fields) f.name],
          value: _clause.field,
          textBuilder: (name) => rcxFieldLabel(l, name),
          onChanged: (name) {
            if (name != _clause.field) _setField(name);
          },
        ),
        if (tests.length > 1)
          ListItem<_Test>.options(
            title: Text(l.rcxCondOp),
            options: tests,
            value: tests.contains(test) ? test : tests.first,
            textBuilder: (test) => _testLabel(l, test),
            onChanged: (test) => widget.onChanged(
              _clause.copyWith(op: test.op, negated: test.negated),
            ),
          ),
        if (_named(field))
          if (field!.values.isEmpty)
            DecorationListItem(title: Text(l.rcxCondNoNames))
          else
            ListItem<String>.options(
              title: Text(rcxFieldLabel(l, _clause.field)),
              options: field.values,
              value: _clause.values.firstOrNull ?? field.values.first,
              textBuilder: (name) => name,
              onChanged: (name) =>
                  widget.onChanged(_clause.copyWith(values: [name])),
            )
        else if (field?.kind != 'bool')
          FormRow(
            title: switch (_clause.op) {
              'in' => l.rcxCondValues,
              '~' => l.rcxCondPattern,
              _ => l.rcxCondValue,
            },
            trailing: FormRowTextField(
              controller: _value,
              autocorrect: false,
              hintText: l.required,
              keyboardType: field?.kind == 'number'
                  ? TextInputType.number
                  : null,
              onChanged: _setValues,
            ),
          ),
        if (_clause.op == '~')
          FormRow(
            title: l.rcxCondIgnoreCase,
            onPressed: () => widget.onChanged(
              _clause.copyWith(ignoreCase: !_clause.ignoreCase),
            ),
            trailing: Switch(
              value: _clause.ignoreCase,
              onChanged: (value) =>
                  widget.onChanged(_clause.copyWith(ignoreCase: value)),
            ),
          ),
      ],
    );
  }
}

String rcxFieldLabel(AppLocalizations l, String field) => switch (field) {
  'name' => l.rcxFieldName,
  'provider' => l.rcxFieldProvider,
  'type' => l.rcxFieldType,
  'server' => l.rcxFieldServer,
  'udp' => l.rcxFieldUdp,
  'alive' => l.rcxFieldAlive,
  'dead' => l.rcxFieldDead,
  'measured' => l.rcxFieldMeasured,
  'current' => l.rcxFieldCurrent,
  'latency' => l.rcxFieldLatency,
  'exit.country' => l.rcxFieldExit,
  'entry.country' => l.rcxFieldEntry,
  'network.kind' => l.rcxFieldKind,
  'network.transport' => l.rcxFieldTransport,
  'network.portal' => l.rcxFieldPortal,
  'metered' => l.rcxFieldMetered,
  'tag' => l.rcxFieldTag,
  'passes' => l.rcxFieldPasses,
  'fails' => l.rcxFieldFails,
  'diag' => l.rcxFieldDiag,
  _ => field,
};

String rcxOpLabel(AppLocalizations l, String op) => switch (op) {
  '=' => l.rcxOpIs,
  '!=' => l.rcxOpIsNot,
  'in' => l.rcxOpIn,
  '~' => l.rcxOpMatches,
  'ok' => l.rcxOpOk,
  'fail' => l.rcxOpFail,
  _ => op,
};

/// One clause as a phrase, e.g. "not Exit country is RU".
String rcxClauseText(AppLocalizations l, RcxClause clause) {
  // "not dead" is how profiles say "working"; read it that way.
  if (clause.negated && clause.op.isEmpty) {
    switch (clause.field) {
      case 'dead':
        return l.rcxFieldAlive;
      case 'alive':
        return l.rcxFieldDead;
    }
  }
  final values = clause.op == '~'
      ? '/${clause.values.firstOrNull ?? ''}/${clause.ignoreCase ? 'i' : ''}'
      : clause.values.join(', ');
  final parts = [
    if (clause.negated) l.rcxCondNotPrefix,
    rcxFieldLabel(l, clause.field),
    if (clause.field != 'diag' && clause.op.isNotEmpty)
      rcxOpLabel(l, clause.op),
    if (values.isNotEmpty) values,
    if (clause.field == 'diag') rcxOpLabel(l, clause.op),
  ];
  return parts.join(' ');
}
