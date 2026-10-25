import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'routing_condition.dart';
import 'routing_country.dart';
import 'routing_studio.dart';

const _badgeSize = 28.0;
const _rowInset = 16.0;
const _defaultLatency = 300;

/// The server order of a profile, program or route: steps top to bottom,
/// first step with a live server wins.
class RoutingLadderSection extends ConsumerStatefulWidget {
  const RoutingLadderSection({
    super.key,
    required this.steps,
    required this.onChanged,
    required this.scope,
    this.scenario = false,
    this.groupName,
    this.inherited = const [],
    this.title,
    this.footer,
    this.stranded,
  });

  final List<Map<String, Object?>> steps;
  final ValueChanged<List<Map<String, Object?>>> onChanged;
  final Map<String, Object?> scope;
  final bool scenario;
  final String? groupName;
  final List<Map<String, Object?>> inherited;
  final String? title;
  final String? footer;

  /// What the group does when no step has a working server, in words.
  final String? stranded;

  @override
  ConsumerState<RoutingLadderSection> createState() =>
      _RoutingLadderSectionState();
}

class _RoutingLadderSectionState extends ConsumerState<RoutingLadderSection> {
  var _sorting = false;
  var _next = 0;
  late var _ids = _freshIds(widget.steps.length);
  ScrollController? _scroll;

  List<int> _freshIds(int count) => [for (var i = 0; i < count; i++) _next++];

  @override
  void didUpdateWidget(covariant RoutingLadderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps.length != _ids.length) {
      _ids = _freshIds(widget.steps.length);
    }
    if (widget.steps.length < 2) _sorting = false;
  }

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  void _emit(List<Map<String, Object?>> steps, List<int> ids) {
    setState(() => _ids = ids);
    widget.onChanged(steps);
  }

  /// Editing an inherited order starts from a copy of it.
  (List<Map<String, Object?>>, List<int>) _base() {
    if (widget.steps.isNotEmpty) return (widget.steps, _ids);
    final copy = [for (final step in widget.inherited) rcxDeepCopy(step)];
    return (copy, _freshIds(copy.length));
  }

  Future<Map<String, Object?>?> _open(Map<String, Object?>? step, int index) {
    return pushRoutingPage<Map<String, Object?>>(
      context,
      RoutingStepEditor(
        step: step,
        number: index + 1,
        scope: widget.scope,
        scenario: widget.scenario,
        groupName: widget.groupName,
      ),
    );
  }

  Future<void> _add() async {
    final (steps, ids) = _base();
    final step = await _open(null, steps.length);
    if (step == null || step.isEmpty || !mounted) return;
    _emit([...steps, step], [...ids, _next++]);
  }

  Future<void> _edit(int index) async {
    final (steps, ids) = _base();
    final step = await _open(steps[index], index);
    if (step == null || !mounted) return;
    if (step.isEmpty) {
      _emit([...steps]..removeAt(index), [...ids]..removeAt(index));
    } else {
      _emit([...steps]..[index] = step, ids);
    }
  }

  void _delete(int index) {
    _emit([...widget.steps]..removeAt(index), [..._ids]..removeAt(index));
  }

  void _reorder(int from, int to) {
    _emit(widget.steps.copyAndReorder(from, to), _ids.copyAndReorder(from, to));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final inherited = widget.steps.isEmpty && widget.inherited.isNotEmpty;
    final steps = inherited ? widget.inherited : widget.steps;
    final queries = [
      for (final step in steps) RcxStepQuery.parse('${step['when'] ?? ''}'),
    ];
    final groupName = widget.groupName;
    final groups = groupName == null ? null : ref.watch(groupsProvider);
    final servers = groups == null ? null : rcxServersOf(groups, groupName);
    final counts = servers == null ? null : rcxStepCounts(queries, servers);
    final now = groups?.getGroup(groupName!)?.now;
    final current = servers?.where((s) => s.name == now).firstOrNull;
    final active = current == null
        ? -1
        : queries.indexWhere((q) => q.matches(current) ?? false);
    final known = queries.indexWhere((q) => !q.isLocal);

    Widget row(int index) => _StepRow(
      number: index + 1,
      step: steps[index],
      count: counts?[index],
      active: index == active && (known < 0 || index < known),
      muted: inherited,
      onPressed: () => unawaited(_edit(index)),
    );

    Widget menu(int index, Widget child) => ContextMenuRegion(
      menuItems: inherited
          ? null
          : [
              CommonPopupMenuItem(
                glyph: AppGlyphs.delete,
                label: l.delete,
                danger: true,
                onPressed: () => _delete(index),
              ),
            ],
      child: child,
    );

    final Widget body;
    if (steps.isEmpty) {
      body = ItemPositionProvider(
        position: ItemPosition.startAndEnd,
        child: DecorationListItem(
          contentPadding: const EdgeInsets.symmetric(horizontal: _rowInset),
          leading: const _Badge(glyph: AppGlyphs.add),
          title: Text(l.rcxLadderAnyWorking),
          subtitle: Text(l.rcxLadderEmptyHint),
          onPressed: () => unawaited(_add()),
          trailing: const DisclosureIndicator(),
        ),
      );
    } else if (_sorting) {
      final scroll = _scroll ??= sheetScrollController(context);
      Widget item(int index) => SortableItem(
        key: ValueKey(_ids[index]),
        index: index,
        child: ItemPositionProvider(
          position: ItemPosition.get(index, steps.length),
          child: row(index),
        ),
      );
      body = ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollController: scroll,
        buildDefaultDragHandles: false,
        itemCount: steps.length,
        itemBuilder: (_, index) => item(index),
        proxyDecorator: (_, index, animation) =>
            commonProxyDecorator(item(index), index, animation),
        onReorderItem: _reorder,
      );
    } else {
      final ids = inherited
          ? [for (var i = 0; i < steps.length; i++) -i - 1]
          : _ids;
      body = AnimatedEntries(
        children: [
          for (var index = 0; index < steps.length; index++)
            KeyedSubtree(
              key: ValueKey(ids[index]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (index > 0)
                    _Connector(
                      caption: index == 1 ? l.rcxLadderFallThrough : null,
                    ),
                  ItemPositionProvider(
                    position: ItemPosition.startAndEnd,
                    child: menu(index, row(index)),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    final stranded = widget.stranded;
    return CommonPopScope(
      onPop: _sorting
          ? (_) {
              setState(() => _sorting = false);
              return false;
            }
          : null,
      child: SortModeScope(
        sorting: _sorting,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListHeader(
              title: widget.title ?? l.rcxLadderTitle,
              actions: [
                if (_sorting || widget.steps.length > 1)
                  sortModeAction(
                    context,
                    sorting: _sorting,
                    onPressed: () => setState(() => _sorting = !_sorting),
                  ),
                IconButtonData(
                  glyph: AppGlyphs.addCircle,
                  tooltip: l.rcxLadderAdd,
                  onPressed: () => unawaited(_add()),
                ),
              ],
            ),
            body,
            if (stranded != null && steps.isNotEmpty && !_sorting) ...[
              const _Connector(),
              _StrandedLine(text: l.rcxLadderStranded(stranded)),
            ],
            if (inherited) ListFooter(text: l.rcxLadderInherited),
            if (widget.footer case final footer?) ListFooter(text: footer),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.step,
    required this.count,
    required this.active,
    required this.muted,
    required this.onPressed,
  });

  final int number;
  final Map<String, Object?> step;
  final int? count;
  final bool active;
  final bool muted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final label = '${step['label'] ?? ''}'.trim();
    final condition = rcxConditionSummary(l, '${step['when'] ?? ''}');
    final subtitle = [
      if (label.isNotEmpty) condition,
      if (step['last-resort'] == true) l.rcxLastResort,
    ].join(' · ');
    return DecorationListItem(
      contentPadding: const EdgeInsets.symmetric(horizontal: _rowInset),
      leading: _Badge(number: number, active: active),
      title: EmojiText(
        label.isEmpty ? condition : label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: muted ? TextStyle(color: colorScheme.onSurfaceVariant) : null,
      ),
      subtitle: subtitle.isEmpty
          ? null
          : EmojiText(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      onPressed: onPressed,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (count case final count?)
            Text(
              l.rcxCountryServers(count),
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(
                    color: count == 0
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
          const DisclosureIndicator(),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({this.number, this.glyph, this.active = false});

  final int? number;
  final Glyph? glyph;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foreground = active
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    return Container(
      width: _badgeSize,
      height: _badgeSize,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: AppShape.circle,
        color: active
            ? colorScheme.primary
            : SurfaceLevel.inset.colorOf(colorScheme),
      ),
      child: number != null
          ? Text(
              '$number',
              style: AppTextStyle.subheadline
                  .of(context, emphasized: true)
                  .copyWith(color: foreground),
            )
          : GlyphIcon(glyph!, size: 18, color: foreground),
    );
  }
}

/// The line from one step down to the next: the next is tried only when
/// this one has no working server.
class _Connector extends StatelessWidget {
  const _Connector({this.caption});

  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          const SizedBox(width: _rowInset + _badgeSize / 2 - 1),
          Container(
            width: 2,
            color: colorScheme.onSurface.withValues(alpha: 0.14),
          ),
          if (caption case final caption?) ...[
            const SizedBox(width: _badgeSize / 2 + 12),
            Text(
              caption,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _StrandedLine extends StatelessWidget {
  const _StrandedLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_rowInset, 2, _rowInset, 4),
      child: Row(
        spacing: 16,
        children: [
          const _Badge(glyph: AppGlyphs.info),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// One step summarized for a row or a card ("★ in name", "🇸🇪 Sweden").
String rcxStepSummary(AppLocalizations l, Map<String, Object?> step) {
  final label = '${step['label'] ?? ''}'.trim();
  return label.isNotEmpty
      ? label
      : rcxConditionSummary(l, '${step['when'] ?? ''}');
}

/// A server order in a few words: "1 ⚡ RU → 2 Any working server".
String rcxLadderSummary(AppLocalizations l, List<Map<String, Object?>> steps) {
  if (steps.isEmpty) return l.rcxLadderAnyWorking;
  return [
    for (final (index, step) in steps.indexed)
      '${index + 1} ${rcxStepSummary(l, step)}',
  ].join(' → ');
}

/// A step condition in words; what the quick builder cannot read stays as
/// written.
String rcxConditionSummary(AppLocalizations l, String when) {
  final query = RcxStepQuery.parse(when);
  final language = Intl.getCurrentLocale();
  final parts = [
    if (query.countries.isNotEmpty) _countriesText(l, language, query),
    if (query.name.isNotEmpty) l.rcxLadderNameHas(query.name),
    if (query.provider case final provider?) l.rcxLadderProvider(provider),
    if (query.type case final type?) type.toUpperCase(),
    if (query.tag case final tag?) l.rcxLadderTag(tag),
    if (query.udp) l.rcxLadderUdp,
    if (query.latency case final latency?) l.rcxLadderLatency(latency),
    for (final atom in query.other) _atomText(l, language, atom),
  ];
  return parts.isEmpty ? l.rcxLadderAnyWorking : parts.join(' · ');
}

String _countriesText(AppLocalizations l, String language, RcxStepQuery q) {
  final codes = q.countries;
  final text = codes.length > 2
      ? codes.map(rcxCountryFlag).join(' ')
      : codes.map((code) => rcxCountryNameIn(language, code)).join(', ');
  return q.notCountries ? l.rcxLadderNot(text) : text;
}

final _exitAtom = RegExp(r'^exit\.country\s*=\s*(\S+)$');

String _atomText(AppLocalizations l, String language, String atom) {
  if (_exitAtom.firstMatch(atom) case final match?) {
    if (_codeOf(match[1]!) case final code?) {
      return l.rcxExit(rcxCountryNameIn(language, code));
    }
  }
  return atom;
}

/// The servers each step takes, a server going to the first step it fits;
/// null from the first step whose condition only the Core can test.
List<int?> rcxStepCounts(List<RcxStepQuery> queries, List<Proxy> servers) {
  final known = queries.indexWhere((q) => !q.isLocal);
  final counts = <int?>[
    for (var i = 0; i < queries.length; i++)
      known >= 0 && i >= known ? null : 0,
  ];
  for (final server in servers) {
    for (var i = 0; i < queries.length; i++) {
      if (counts[i] == null) break;
      if (queries[i].matches(server) == true) {
        counts[i] = counts[i]! + 1;
        break;
      }
    }
  }
  return counts;
}

const _metacharacters = r'\^$.|?*+()[]{}/';
const _keywords = {'and', 'or', 'not', 'in', 'ok', 'fail'};
final _wordRune = RegExp(r'^[\p{L}\p{N}_\-.:]+$', unicode: true);
final _nameAtom = RegExp(r'^name\s*~\s*/((?:[^/\\]|\\.)*)/(i?)$');
final _countryIs = RegExp(r'^country\s*(!=|=)\s*(\S+)$');
final _countryIn = RegExp(r'^(not\s+)?country\s+in\s*\[(.*)\]$');
final _providerAtom = RegExp(r'^provider\s*=\s*(.+)$');
final _typeAtom = RegExp(r'^type\s*=\s*(.+)$');
final _tagAtom = RegExp(r'^tag\(\s*([^()\s]+)\s*\)$');
final _latencyAtom = RegExp(r'^latency\s*<\s*(\d+)$');

/// A step condition taken apart into what the quick builder edits: atoms
/// joined by `and`; anything else stays text the advanced editor owns.
class RcxStepQuery {
  RcxStepQuery();

  factory RcxStepQuery.parse(String when) {
    final query = RcxStepQuery();
    final text = when.trim();
    if (text.isEmpty) return query;
    final atoms = _splitAnd(text);
    if (atoms == null) return query..other.add(text);
    for (final atom in atoms) {
      if (!query._take(atom)) query.other.add(atom);
    }
    return query;
  }

  String name = '';
  List<String> countries = [];
  bool notCountries = false;
  String? provider;
  String? type;
  String? tag;
  bool udp = false;
  int? latency;
  bool working = false;
  List<String> other = [];

  /// Whether the app can test the condition itself, from names, providers
  /// and protocols alone.
  bool get isLocal => other.isEmpty && tag == null && !udp && latency == null;

  String get when {
    final parts = [
      if (name.isNotEmpty) 'name ~ /${_escape(name)}/i',
      if (countries.length == 1)
        'country ${notCountries ? '!=' : '='} ${_value(countries.first)}',
      if (countries.length > 1)
        '${notCountries ? 'not ' : ''}country in [${countries.map(_value).join(', ')}]',
      if (provider case final provider?) 'provider = ${_value(provider)}',
      if (type case final type?) 'type = ${_value(type)}',
      if (tag case final tag?) 'tag($tag)',
      if (udp) 'udp',
      if (latency case final latency?) 'latency < $latency',
      if (working) 'not dead',
    ];
    final alone = parts.isEmpty && other.length == 1;
    return [
      ...parts,
      for (final atom in other)
        alone || _splitAnd(atom) != null ? atom : '($atom)',
    ].join(' and ');
  }

  /// Whether [server] fits, or null when only the Core can tell.
  bool? matches(Proxy server) {
    if (!isLocal) return null;
    if (name.isNotEmpty &&
        !server.name.toLowerCase().contains(name.toLowerCase())) {
      return false;
    }
    if (countries.isNotEmpty) {
      final code = rcxCountryOfName(server.name);
      if (countries.contains(code) == notCountries) return false;
    }
    if (provider != null && server.providerName != provider) return false;
    if (type != null && server.type.toLowerCase() != type!.toLowerCase()) {
      return false;
    }
    return true;
  }

  bool _take(String atom) {
    final plain = atom.replaceAll(RegExp(r'\s+'), ' ');
    if (_nameAtom.firstMatch(atom) case final m? when name.isEmpty) {
      var pattern = m[1]!;
      var folded = m[2] == 'i';
      if (pattern.startsWith('(?i)')) {
        pattern = pattern.substring(4);
        folded = true;
      }
      final literal = _literalOf(pattern);
      if (literal == null || literal.isEmpty) return false;
      // Without case folding only a literal that has no case reads the same.
      if (!folded && literal.toLowerCase() != literal.toUpperCase()) {
        return false;
      }
      name = literal;
      return true;
    }
    if (countries.isEmpty) {
      if (_countryIs.firstMatch(atom) case final m?) {
        final code = _codeOf(m[2]!);
        if (code == null) return false;
        countries = [code];
        notCountries = m[1] == '!=';
        return true;
      }
      if (_countryIn.firstMatch(atom) case final m?) {
        final codes = [for (final v in m[2]!.split(',')) _codeOf(v)];
        if (codes.isEmpty || codes.contains(null)) return false;
        countries = codes.nonNulls.toList();
        notCountries = m[1] != null;
        return true;
      }
    }
    if (_providerAtom.firstMatch(atom) case final m? when provider == null) {
      provider = _unquote(m[1]!);
      return provider != null;
    }
    if (_typeAtom.firstMatch(atom) case final m? when type == null) {
      type = _unquote(m[1]!)?.toLowerCase();
      return type != null;
    }
    if (_tagAtom.firstMatch(atom) case final m? when tag == null) {
      tag = m[1];
      return true;
    }
    if (_latencyAtom.firstMatch(atom) case final m? when latency == null) {
      latency = int.tryParse(m[1]!);
      return latency != null;
    }
    switch (plain) {
      case 'udp' when !udp:
        udp = true;
        return true;
      case 'not dead' || 'alive' when !working:
        working = true;
        return true;
    }
    return false;
  }
}

/// Splits [text] at its top-level `and`s, or null when a top-level `or`
/// makes it more than a list of atoms.
List<String>? _splitAnd(String text) {
  final lower = text.toLowerCase();
  final atoms = <String>[];
  var depth = 0;
  var start = 0;
  String? quote;
  var pattern = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quote != null) {
      if (c == quote) quote = null;
      continue;
    }
    if (pattern) {
      if (c == r'\') {
        i++;
      } else if (c == '/') {
        pattern = false;
      }
      continue;
    }
    switch (c) {
      case "'" || '"':
        quote = c;
      case '/':
        pattern = true;
      case '(' || '[':
        depth++;
      case ')' || ']':
        depth--;
      default:
        if (depth != 0) continue;
        if (_wordAt(lower, i, 'or')) return null;
        if (_wordAt(lower, i, 'and')) {
          atoms.add(text.substring(start, i).trim());
          start = i + 3;
          i += 2;
        }
    }
  }
  atoms.add(text.substring(start).trim());
  return atoms.any((atom) => atom.isEmpty) ? null : atoms;
}

bool _wordAt(String text, int index, String word) {
  if (!text.startsWith(word, index)) return false;
  final end = index + word.length;
  return (index == 0 || !_wordRune.hasMatch(text[index - 1])) &&
      (end == text.length || !_wordRune.hasMatch(text[end]));
}

String? _literalOf(String pattern) {
  final out = StringBuffer();
  for (var i = 0; i < pattern.length; i++) {
    final c = pattern[i];
    if (c == r'\') {
      if (i + 1 == pattern.length ||
          !_metacharacters.contains(pattern[i + 1])) {
        return null;
      }
      out.write(pattern[++i]);
    } else if (_metacharacters.contains(c)) {
      return null;
    } else {
      out.write(c);
    }
  }
  return out.toString();
}

String _escape(String literal) => [
  for (final c in literal.split('')) _metacharacters.contains(c) ? '\\$c' : c,
].join();

String? _unquote(String value) {
  final text = value.trim();
  if (text.length >= 2 &&
      (text[0] == "'" || text[0] == '"') &&
      text[text.length - 1] == text[0]) {
    return text.substring(1, text.length - 1);
  }
  return _wordRune.hasMatch(text) ? text : null;
}

/// A value the Core reads back as itself: bare where it is one word.
String _value(String value) {
  if (_wordRune.hasMatch(value) && !_keywords.contains(value.toLowerCase())) {
    return value;
  }
  return value.contains("'") ? '"$value"' : "'$value'";
}

String? _codeOf(String value) {
  final code = _unquote(value)?.toUpperCase();
  return code != null && rcxIsCountry(code) ? code : null;
}

enum _Extra { provider, type, tag, udp, latency }

/// One step of a server order; pops the step, or an empty map to delete it.
class RoutingStepEditor extends ConsumerStatefulWidget {
  const RoutingStepEditor({
    super.key,
    required this.step,
    required this.number,
    required this.scope,
    required this.scenario,
    required this.groupName,
  });

  final Map<String, Object?>? step;
  final int number;
  final Map<String, Object?> scope;
  final bool scenario;
  final String? groupName;

  @override
  ConsumerState<RoutingStepEditor> createState() => _RoutingStepEditorState();
}

class _RoutingStepEditorState extends ConsumerState<RoutingStepEditor> {
  late var _query = RcxStepQuery.parse('${widget.step?['when'] ?? ''}');
  late final _label = TextEditingController(
    text: '${widget.step?['label'] ?? ''}',
  );
  late final _name = TextEditingController(text: _query.name);
  late final _latency = TextEditingController(
    text: _query.latency?.toString() ?? '',
  );
  late var _lastResort = widget.step?['last-resort'] == true;
  final _shown = <_Extra>{};

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    _latency.dispose();
    super.dispose();
  }

  bool _isSet(_Extra extra) => switch (extra) {
    _Extra.provider => _query.provider != null,
    _Extra.type => _query.type != null,
    _Extra.tag => _query.tag != null,
    _Extra.udp => _query.udp,
    _Extra.latency => _query.latency != null,
  };

  void _update(void Function(RcxStepQuery query) change) {
    setState(() => change(_query));
  }

  void _show(_Extra extra, List<Proxy> servers) {
    _update((q) {
      switch (extra) {
        case _Extra.provider:
          q.provider = _providersOf(servers).firstOrNull ?? '';
        case _Extra.type:
          q.type = _typesOf(servers).firstOrNull ?? 'vless';
        case _Extra.tag:
          q.tag = _tags.firstOrNull;
        case _Extra.udp:
          q.udp = true;
        case _Extra.latency:
          q.latency = _defaultLatency;
          _latency.text = '$_defaultLatency';
      }
      _shown.add(extra);
    });
  }

  void _hide(_Extra extra) {
    _update((q) {
      switch (extra) {
        case _Extra.provider:
          q.provider = null;
        case _Extra.type:
          q.type = null;
        case _Extra.tag:
          q.tag = null;
        case _Extra.udp:
          q.udp = false;
        case _Extra.latency:
          q.latency = null;
          _latency.clear();
      }
      _shown.remove(extra);
    });
  }

  List<String> get _tags => [
    ...rcxMap(widget.scope['tags']).keys,
    if (_query.tag case final tag?
        when !rcxMap(widget.scope['tags']).containsKey(tag))
      tag,
  ];

  List<String> _providersOf(List<Proxy> servers) => {
    for (final server in servers) ?server.providerName,
    ?_query.provider,
  }.toList();

  List<String> _typesOf(List<Proxy> servers) => {
    for (final server in servers) server.type.toLowerCase(),
    ?_query.type,
  }.toList();

  Future<void> _pickCountries() async {
    final codes = await pickCountries(
      context,
      selected: _query.countries,
      groupName: widget.groupName,
    );
    if (codes == null || !mounted) return;
    _update((q) {
      q.countries = codes;
      if (codes.isEmpty) q.notCountries = false;
    });
  }

  Future<void> _advanced() async {
    final l = context.appLocalizations;
    final text = await editCondition(
      context,
      title: l.rcxLadderStep(widget.number),
      text: _query.when,
      profile: widget.scope,
      scenario: widget.scenario,
    );
    if (text == null || !mounted) return;
    setState(() {
      _query = RcxStepQuery.parse(text);
      _name.text = _query.name;
      _latency.text = _query.latency?.toString() ?? '';
      _shown.clear();
    });
  }

  Map<String, Object?> _result() {
    final label = _label.text.trim();
    return {
      if (label.isNotEmpty) 'label': label,
      'when': _query.when,
      if (_lastResort) 'last-resort': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final groups = ref.watch(groupsProvider);
    final servers = rcxServersOf(groups, widget.groupName);
    final q = _query;
    final shown = [
      for (final extra in _Extra.values)
        if (_isSet(extra) || _shown.contains(extra)) extra,
    ];
    final addable = [
      for (final extra in _Extra.values)
        if (!shown.contains(extra) &&
            (extra != _Extra.tag || _tags.isNotEmpty) &&
            (extra != _Extra.provider || _providersOf(servers).isNotEmpty))
          extra,
    ];
    final fits = q.isLocal && servers.isNotEmpty
        ? servers.where((s) => q.matches(s) ?? false).length
        : null;
    return FormPage(
      title: widget.step == null
          ? l.rcxLadderAdd
          : l.rcxLadderStep(widget.number),
      actions: [
        if (widget.step != null)
          IconButtonData(
            glyph: AppGlyphs.delete,
            tooltip: l.delete,
            onPressed: () =>
                Navigator.of(context).pop(const <String, Object?>{}),
          ),
      ],
      onSave: () => Navigator.of(context).pop(_result()),
      children: [
        generateAnimatedSection(
          title: l.rcxLadderServersIn,
          footer: fits == null ? null : l.rcxLadderFits(fits),
          items: [
            KeyedSubtree(
              key: const ValueKey('name'),
              child: FormRow(
                title: l.rcxLadderNameContains,
                trailing: FormRowTextField(
                  controller: _name,
                  hintText: l.rcxAnyServer,
                  autocorrect: false,
                  onChanged: (text) => _update((q) => q.name = text.trim()),
                ),
              ),
            ),
            KeyedSubtree(
              key: const ValueKey('country'),
              child: DecorationListItem(
                title: Text(l.rcxLadderCountry),
                subtitle: EmojiText(
                  q.countries.isEmpty
                      ? l.rcxAnyServer
                      : _countriesText(
                          l,
                          Localizations.localeOf(context).languageCode,
                          RcxStepQuery()..countries = q.countries,
                        ),
                ),
                onPressed: () => unawaited(_pickCountries()),
                trailing: const DisclosureIndicator(),
              ),
            ),
            if (q.countries.isNotEmpty)
              KeyedSubtree(
                key: const ValueKey('except'),
                child: FormRow(
                  title: l.rcxLadderExceptCountries,
                  onPressed: () =>
                      _update((q) => q.notCountries = !q.notCountries),
                  trailing: Switch(
                    value: q.notCountries,
                    onChanged: (value) =>
                        _update((q) => q.notCountries = value),
                  ),
                ),
              ),
            for (final extra in shown)
              KeyedSubtree(
                key: ValueKey(extra),
                child: _extraRow(l, extra, servers),
              ),
            if (q.other.isNotEmpty)
              KeyedSubtree(
                key: const ValueKey('other'),
                child: DecorationListItem(
                  leading: EntryButton.remove(
                    onPressed: () => _update((q) => q.other = []),
                  ),
                  title: Text(l.rcxLadderOther),
                  subtitle: Text(
                    q.other.join(' and '),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => unawaited(_advanced()),
                  trailing: const DisclosureIndicator(),
                ),
              ),
            KeyedSubtree(
              key: const ValueKey('add'),
              child: CommonPopupBox(
                targetBuilder: (open) => FormRow(
                  title: l.rcxCondAdd,
                  leading: EntryButton.add(onPressed: open),
                  onPressed: open,
                ),
                popupBuilder: (_) => CommonPopupMenu(
                  items: [
                    for (final extra in addable)
                      CommonPopupMenuItem(
                        label: _extraLabel(l, extra),
                        onPressed: () => _show(extra, servers),
                      ),
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.code,
                      label: l.rcxLadderAdvanced,
                      onPressed: () => unawaited(_advanced()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        generateSection(
          footer: l.rcxLadderLastResortHint,
          items: [
            FormRow(
              title: l.rcxTierLabel,
              trailing: FormRowTextField(
                controller: _label,
                hintText: rcxConditionSummary(l, q.when),
              ),
            ),
            FormRow(
              title: l.rcxLastResort,
              onPressed: () => setState(() => _lastResort = !_lastResort),
              trailing: Switch(
                value: _lastResort,
                onChanged: (value) => setState(() => _lastResort = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _extraRow(AppLocalizations l, _Extra extra, List<Proxy> servers) {
    final remove = EntryButton.remove(onPressed: () => _hide(extra));
    final q = _query;
    Widget options(
      List<String> values,
      String? value,
      String Function(String) text,
      ValueChanged<String> onChanged,
    ) {
      return ListItem<String>.options(
        leading: remove,
        title: Text(_extraLabel(l, extra)),
        options: values,
        value: value ?? values.first,
        textBuilder: text,
        onChanged: onChanged,
      );
    }

    return switch (extra) {
      _Extra.provider => options(
        _providersOf(servers),
        q.provider,
        (v) => v,
        (v) => _update((q) => q.provider = v),
      ),
      _Extra.type => options(
        _typesOf(servers),
        q.type,
        (v) => v.toUpperCase(),
        (v) => _update((q) => q.type = v),
      ),
      _Extra.tag => options(
        _tags,
        q.tag,
        (v) => v,
        (v) => _update((q) => q.tag = v),
      ),
      _Extra.udp => FormRow(leading: remove, title: l.rcxFieldUdp),
      _Extra.latency => FormRow(
        leading: remove,
        title: l.rcxLadderLatencyUnder,
        trailing: FormRowTextField(
          controller: _latency,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (text) =>
              _update((q) => q.latency = int.tryParse(text) ?? q.latency),
        ),
      ),
    };
  }
}

String _extraLabel(AppLocalizations l, _Extra extra) => switch (extra) {
  _Extra.provider => l.rcxFieldProvider,
  _Extra.type => l.rcxFieldType,
  _Extra.tag => l.rcxFieldTag,
  _Extra.udp => l.rcxFieldUdp,
  _Extra.latency => l.rcxLadderLatencyUnder,
};
