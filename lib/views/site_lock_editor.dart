import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/site_lock_exits.dart';

const _maxEntries = 128;

final _ipv4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}(/\d{1,2})?$');
final _ipv6 = RegExp(r'^[0-9a-fA-F]*(:[0-9a-fA-F.]*){2,}(/\d{1,3})?$');
final _host = RegExp(r'^[\p{L}\p{N}_-]+(\.[\p{L}\p{N}_-]+)+$', unicode: true);
final _geosite = RegExp(r'^geosite:(.+)$', caseSensitive: false);
final _scheme = RegExp(r'^[a-z][a-z0-9+.-]*://', caseSensitive: false);

/// The host of a pasted address such as `https://user@host:443/path`.
String _hostOf(String url) {
  var host = url.substring(_scheme.firstMatch(url)!.end);
  host = host.split(RegExp('[/?#]')).first;
  host = host.substring(host.lastIndexOf('@') + 1);
  if (host.startsWith('[')) {
    final end = host.indexOf(']');
    return end < 0 ? host : host.substring(1, end);
  }
  final colon = host.indexOf(':');
  return colon < 0 ? host : host.substring(0, colon);
}

String _normalizeEntry(String line) {
  if (_scheme.hasMatch(line)) {
    final host = _hostOf(line);
    if (host.isNotEmpty) line = host;
  }
  final comma = line.indexOf(',');
  if (comma >= 0) {
    return '${line.substring(0, comma).trim().toUpperCase()},'
        '${line.substring(comma + 1).trim()}';
  }
  if (_geosite.firstMatch(line) case final match?) {
    return 'GEOSITE,${match[1]!.trim()}';
  }
  if (_ipv4.hasMatch(line)) {
    return 'IP-CIDR,${line.contains('/') ? line : '$line/32'},no-resolve';
  }
  if (_ipv6.hasMatch(line)) {
    return 'IP-CIDR6,${line.contains('/') ? line : '$line/128'},no-resolve';
  }
  final suffix = line.startsWith('*.')
      ? line.substring(2)
      : line.startsWith('.')
      ? line.substring(1)
      : null;
  if (suffix != null && _host.hasMatch(suffix)) {
    return 'DOMAIN-SUFFIX,${suffix.toLowerCase()}';
  }
  if (suffix == null && _host.hasMatch(line)) {
    return 'DOMAIN-SUFFIX,${line.toLowerCase()}';
  }
  return line;
}

/// One rule entry per line; what the core cannot read stays as typed, for it
/// to report.
List<String> normalizeSiteLockEntries(String text) {
  final entries = <String>{};
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isNotEmpty) entries.add(_normalizeEntry(line));
  }
  return entries.toList();
}

List<SiteLock> withSiteLock(List<SiteLock> locks, SiteLock edited) =>
    locks.any((item) => item.id == edited.id)
    ? [for (final item in locks) item.id == edited.id ? edited : item]
    : [...locks, edited];

enum _Field { match, exits }

/// Edits [lock] in a form sheet; null when the user backs out.
Future<SiteLock?> showSiteLockEditor(
  BuildContext context,
  SiteLock lock, {
  required bool isNew,
}) {
  return showFormSheet<SiteLock>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(
      builder: (_) => _SiteLockForm(lock: lock, isNew: isNew),
    ),
  );
}

class _SiteLockForm extends ConsumerStatefulWidget {
  const _SiteLockForm({required this.lock, required this.isNew});

  final SiteLock lock;
  final bool isNew;

  @override
  ConsumerState<_SiteLockForm> createState() => _SiteLockFormState();
}

class _SiteLockFormState extends ConsumerState<_SiteLockForm> {
  late final _name = TextEditingController(text: widget.lock.name);
  late final _match = TextEditingController(text: widget.lock.match.join('\n'));
  late final _except = TextEditingController(
    text: widget.lock.except.join('\n'),
  );
  late List<SiteLockExit> _exits = widget.lock.exits;
  late String _preset = widget.lock.preset;
  List<SiteLockExitCandidate>? _candidates;
  bool _loaded = false;
  bool _attempted = false;
  bool _saving = false;
  _Field? _invalid;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCandidates());
  }

  @override
  void dispose() {
    _name.dispose();
    _match.dispose();
    _except.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    List<SiteLockExitCandidate>? found;
    if (ref.read(coreStatusProvider) == CoreStatus.connected) {
      try {
        found = await ref.read(coreHandlerProvider).siteLockExits();
      } catch (_) {
        found = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _candidates = found;
      _loaded = true;
    });
  }

  void _check() {
    final l = context.appLocalizations;
    final count = _draft.entries.length;
    (_Field, String)? problem;
    if (count == 0) {
      problem = (_Field.match, l.siteLockErrorMatchEmpty);
    } else if (count > _maxEntries) {
      problem = (_Field.match, l.siteLockErrorTooMany(_maxEntries));
    } else if (_exits.isEmpty) {
      problem = (_Field.exits, l.siteLockErrorNoExit);
    }
    _invalid = problem?.$1;
    _error = problem?.$2;
  }

  SiteLock get _draft => widget.lock.copyWith(
    name: _name.text.trim(),
    match: normalizeSiteLockEntries(_match.text),
    except: normalizeSiteLockEntries(_except.text),
    exits: _exits,
    preset: _preset,
  );

  void _changed() {
    if (_attempted) _check();
  }

  // The core checks the list before the sheet closes, so a refused edit is
  // never saved while the core keeps enforcing the previous one.
  Future<void> _save() async {
    setState(() {
      _attempted = true;
      _check();
    });
    if (_error != null) return;
    final edited = _draft;
    if (ref.read(coreStatusProvider) == CoreStatus.connected) {
      setState(() => _saving = true);
      final report = await ref
          .read(siteLockReportStateProvider.notifier)
          .push(withSiteLock(ref.read(siteLocksProvider), edited));
      if (!mounted) return;
      setState(() => _saving = false);
      if (report == null) {
        setState(() => _error = currentAppLocalizations.siteLockWaiting);
        return;
      }
      if (!report.applied) {
        setState(() => _refuse(report.problems, edited));
        return;
      }
    }
    context.safeNestedPop(edited);
  }

  void _refuse(List<SiteLockProblem> problems, SiteLock edited) {
    final own = problems.where((problem) => problem.id == edited.id).toList();
    final shown = own.isEmpty ? problems : own;
    _invalid = shown.any((problem) => problem.field.startsWith('match'))
        ? _Field.match
        : shown.any((problem) => problem.field.startsWith('exits'))
        ? _Field.exits
        : null;
    _error = [
      for (final problem in shown) _describe(problem, edited),
    ].join('\n');
  }

  String _describe(SiteLockProblem problem, SiteLock edited) {
    final [field, ...rest] = problem.field.split('.');
    final index = rest.isEmpty ? null : int.tryParse(rest.first);
    final entries = switch (field) {
      'match' => edited.entries,
      'except' => edited.except,
      _ => const <String>[],
    };
    return index != null && index < entries.length
        ? '${entries[index]}: ${problem.message}'
        : problem.message;
  }

  Future<void> _choose(List<SiteLockExitCandidate> candidates) async {
    final chosen = await showSiteLockExitPicker(
      context,
      candidates: candidates,
      chosen: _exits,
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _exits = chosen;
      _changed();
    });
  }

  Widget _entries({
    required String title,
    required String hint,
    required String footer,
    required TextEditingController controller,
    required bool invalid,
  }) {
    return generateSection(
      title: title,
      footer: footer,
      items: [
        DecorationListItem(
          invalid: invalid,
          title: TextField(
            controller: controller,
            minLines: 3,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            autocorrect: false,
            onChanged: (_) => setState(_changed),
            decoration: InputDecoration.collapsed(
              border: const NoInputBorder(),
              hintText: hint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _presetSection(AppLocalizations l, SiteLockPreset preset) {
    return generateSection(
      title: l.siteLockPresetTitle,
      footer: l.siteLockPresetFooter,
      items: [
        ContextMenuRegion(
          menuItems: [
            CommonPopupMenuItem(
              glyph: AppGlyphs.copy,
              label: l.siteLockPresetUnlink,
              onPressed: () => setState(() {
                _match.text = {
                  ...normalizeSiteLockEntries(_match.text),
                  ...preset.match,
                }.join('\n');
                _preset = '';
                _changed();
              }),
            ),
          ],
          child: ListItem(
            leading: const GlyphIcon(AppGlyphs.sparkle),
            title: Text(preset.name),
            subtitle: Text(
              preset.match.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.footnote
                  .of(context)
                  .toJetBrainsMono
                  .copyWith(color: context.colorScheme.tertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exitRow(
    AppLocalizations l,
    SiteLockExit exit,
    List<SiteLockExitCandidate>? candidates,
  ) {
    final candidate = candidates == null
        ? null
        : siteLockCandidateOf(exit, candidates);
    final name = candidate?.names.first ?? siteLockExitLabel(exit);
    return ContextMenuRegion(
      menuItems: [
        CommonPopupMenuItem(
          danger: true,
          glyph: AppGlyphs.delete,
          label: l.remove,
          onPressed: () => setState(() {
            _exits = [
              for (final item in _exits)
                if (!identical(item, exit)) item,
            ];
            _changed();
          }),
        ),
      ],
      child: SiteLockExitRow(
        name: name,
        subtitle: candidates != null && candidate == null
            ? l.siteLockExitMissing
            : null,
        onPressed: candidates == null || candidates.isEmpty
            ? null
            : () => unawaited(_choose(candidates)),
      ),
    );
  }

  Widget _exitsSection(AppLocalizations l) {
    final candidates = _candidates;
    final available = candidates != null && candidates.isNotEmpty;
    return generateSection(
      title: l.siteLockExitsTitle,
      footer: candidates == null
          ? l.siteLockExitsOffline
          : candidates.isEmpty
          ? l.siteLockExitsEmpty
          : l.siteLockExitsFooter,
      items: [
        for (final exit in _exits) _exitRow(l, exit, candidates),
        DecorationListItem(
          invalid: _invalid == _Field.exits,
          leading: const GlyphIcon(AppGlyphs.add),
          title: Text(
            l.siteLockExitsChoose,
            style: available
                ? null
                : TextStyle(color: context.colorScheme.onSurfaceVariant),
          ),
          onPressed: available ? () => unawaited(_choose(candidates)) : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return FormPage(
      title: widget.isNew ? l.siteLockNew : l.siteLockEdit,
      onSave: () => unawaited(_save()),
      saving: _saving,
      error: _error,
      children: [
        generateSection(
          items: [
            FormRow(
              title: l.name,
              trailing: FormRowTextField(
                controller: _name,
                hintText: l.optional,
                inputFormatters: TextInputLimits.limit(TextInputLimits.name),
              ),
            ),
          ],
        ),
        if (siteLockPresetOf(_preset) case final preset?)
          _presetSection(l, preset),
        _entries(
          title: l.siteLockMatchTitle,
          hint: l.siteLockMatchHint,
          footer: l.siteLockMatchFooter,
          controller: _match,
          invalid: _invalid == _Field.match,
        ),
        _entries(
          title: l.siteLockExceptTitle,
          hint: l.siteLockExceptHint,
          footer: l.siteLockExceptFooter,
          controller: _except,
          invalid: false,
        ),
        if (_loaded) _exitsSection(l),
      ],
    );
  }
}
