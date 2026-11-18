import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';

const _maxEntries = 128;
const _maxExits = 16;

final _ipv4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}(/\d{1,2})?$');
final _ipv6 = RegExp(r'^[0-9a-fA-F]*(:[0-9a-fA-F.]*){2,}(/\d{1,3})?$');
final _host = RegExp(r'^[\p{L}\p{N}_-]+(\.[\p{L}\p{N}_-]+)+$', unicode: true);
final _geosite = RegExp(r'^geosite:(.+)$', caseSensitive: false);

String _normalizeEntry(String line) {
  final comma = line.indexOf(',');
  if (comma >= 0) {
    return '${line.substring(0, comma).trim().toUpperCase()},'
        '${line.substring(comma + 1).trim()}';
  }
  if (_geosite.firstMatch(line) case final match?) {
    return 'GEOSITE,${match[1]!.trim()}';
  }
  if (_ipv4.hasMatch(line)) {
    return 'IP-CIDR,${line.contains('/') ? line : '$line/32'}';
  }
  if (_ipv6.hasMatch(line)) {
    return 'IP-CIDR6,${line.contains('/') ? line : '$line/128'}';
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

String _kind(String type) {
  final kind = type.toLowerCase().replaceAll('-', '');
  return switch (kind) {
    'ss' => 'shadowsocks',
    'ssr' => 'shadowsocksr',
    _ => kind,
  };
}

bool _isCandidate(SiteLockExit exit, SiteLockExitCandidate candidate) =>
    _kind(exit.type) == _kind(candidate.type) &&
    exit.server.toLowerCase() == candidate.server.toLowerCase() &&
    exit.port == candidate.port;

enum _Field { match, exits }

/// Edits [lock] in a form sheet; null when the user backs out.
Future<SiteLock?> showSiteLockEditor(
  BuildContext context,
  SiteLock lock, {
  required bool isNew,
}) {
  return showFormSheet<SiteLock>(
    context: context,
    builder: (_) => _SiteLockForm(lock: lock, isNew: isNew),
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
  List<SiteLockExitCandidate>? _candidates;
  bool _loaded = false;
  bool _attempted = false;
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
    final count = normalizeSiteLockEntries(_match.text).length;
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

  void _changed() {
    if (_attempted) _check();
  }

  void _save() {
    setState(() {
      _attempted = true;
      _check();
    });
    if (_error != null) return;
    Navigator.of(context).pop(
      widget.lock.copyWith(
        name: _name.text.trim(),
        match: normalizeSiteLockEntries(_match.text),
        except: normalizeSiteLockEntries(_except.text),
        exits: _exits,
      ),
    );
  }

  bool _chosen(SiteLockExitCandidate candidate) =>
      _exits.any((exit) => _isCandidate(exit, candidate));

  void _toggle(SiteLockExitCandidate candidate) {
    if (_chosen(candidate)) {
      _exits = [
        for (final exit in _exits)
          if (!_isCandidate(exit, candidate)) exit,
      ];
    } else if (_exits.length < _maxExits) {
      _exits = [
        ..._exits,
        SiteLockExit(
          type: candidate.type,
          server: candidate.server,
          port: candidate.port,
        ),
      ];
    } else {
      return;
    }
    setState(_changed);
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

  Widget _exitsSection(AppLocalizations l) {
    final candidates = _candidates;
    final orphans = [
      for (final exit in _exits)
        if (candidates == null ||
            !candidates.any((candidate) => _isCandidate(exit, candidate)))
          exit,
    ];
    final rows = <Widget>[
      for (final exit in orphans)
        ListItem(
          title: Text('${exit.server}:${exit.port}'),
          subtitle: Text(
            candidates == null ? exit.type : l.siteLockExitMissing,
          ),
          trailing: const SelectionCheck(),
          onTap: () {
            _exits = [
              for (final item in _exits)
                if (item != exit) item,
            ];
            setState(_changed);
          },
        ),
      for (final candidate in candidates ?? const <SiteLockExitCandidate>[])
        ListItem(
          title: Text(candidate.names.join(', ')),
          subtitle: Text(
            '${candidate.type} · ${candidate.server}:${candidate.port}',
          ),
          trailing: _chosen(candidate) ? const SelectionCheck() : null,
          onTap: () => _toggle(candidate),
        ),
    ];
    final note = candidates == null ? l.siteLockExitsOffline : null;
    return generateSection(
      title: l.siteLockExitsTitle,
      items: rows.isEmpty
          ? [
              ListItem(
                title: Text(
                  note ?? l.siteLockExitsEmpty,
                  style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            ]
          : rows,
      footer: rows.isEmpty || note == null ? l.siteLockExitsFooter : note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return FormPage(
      title: widget.isNew ? l.siteLockNew : l.siteLockEdit,
      onSave: _save,
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
