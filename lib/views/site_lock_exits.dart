import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/chains/marks.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';

const siteLockMaxExits = 16;

String _kind(String type) {
  final kind = type.toLowerCase().replaceAll('-', '');
  return switch (kind) {
    'ss' => 'shadowsocks',
    'ssr' => 'shadowsocksr',
    _ => kind,
  };
}

bool _sameDefinition(SiteLockExit exit, SiteLockExitCandidate candidate) {
  if (_kind(exit.type) != _kind(candidate.type)) return false;
  if (exit.route.isNotEmpty) return exit.route == candidate.route;
  return exit.server.toLowerCase() == candidate.server.toLowerCase() &&
      exit.port == candidate.port;
}

String siteLockExitLabel(SiteLockExit exit) =>
    exit.name.isEmpty ? '${exit.server}:${exit.port}' : exit.name;

/// The candidate the core resolves [exit] to: its definition, or its name
/// once a refresh changed the definition.
SiteLockExitCandidate? siteLockCandidateOf(
  SiteLockExit exit,
  List<SiteLockExitCandidate> candidates,
) {
  for (final candidate in candidates) {
    if (_sameDefinition(exit, candidate)) return candidate;
  }
  if (exit.route.isEmpty || exit.name.isEmpty) return null;
  for (final candidate in candidates) {
    if (_kind(exit.type) == _kind(candidate.type) &&
        candidate.names.contains(exit.name)) {
      return candidate;
    }
  }
  return null;
}

SiteLockExit _exitOf(SiteLockExitCandidate candidate) => SiteLockExit(
  type: candidate.type,
  server: candidate.server,
  port: candidate.port,
  route: candidate.route,
  name: candidate.names.first,
);

/// One exit server: its flag and its name without the emoji tags providers
/// put around it.
class SiteLockExitRow extends StatelessWidget {
  const SiteLockExitRow({
    super.key,
    required this.name,
    this.subtitle,
    this.selected = false,
    this.onPressed,
  });

  final String name;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return DecorationListItem(
      isSelected: selected,
      onPressed: onPressed,
      leading: ShapeFlag(code: countryOfHopName(name), size: 32),
      title: EmojiText(
        serverTitle(name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: selected ? const SelectionCheck() : null,
    );
  }
}

/// Chooses a lock's exits among [candidates]; null when the user backs out.
Future<List<SiteLockExit>?> showSiteLockExitPicker(
  BuildContext context, {
  required List<SiteLockExitCandidate> candidates,
  required List<SiteLockExit> chosen,
}) => showInSheet<List<SiteLockExit>>(
  context,
  builder: (_) => _ExitPicker(candidates: candidates, chosen: chosen),
);

class _ExitPicker extends StatefulWidget {
  const _ExitPicker({required this.candidates, required this.chosen});

  final List<SiteLockExitCandidate> candidates;
  final List<SiteLockExit> chosen;

  @override
  State<_ExitPicker> createState() => _ExitPickerState();
}

class _ExitPickerState extends State<_ExitPicker> {
  late List<SiteLockExit> _chosen = widget.chosen;
  String _query = '';
  late final _search = [
    for (final candidate in widget.candidates)
      candidate.names.join('\n').toLowerCase(),
  ];

  void _toggle(SiteLockExitCandidate candidate, bool chosen) {
    if (!chosen && _chosen.length >= siteLockMaxExits) return;
    setState(() {
      _chosen = chosen
          ? [
              for (final exit in _chosen)
                if (!identical(
                  siteLockCandidateOf(exit, widget.candidates),
                  candidate,
                ))
                  exit,
            ]
          : [..._chosen, _exitOf(candidate)];
    });
  }

  void _drop(SiteLockExit exit) => setState(() {
    _chosen = [
      for (final item in _chosen)
        if (!identical(item, exit)) item,
    ];
  });

  String? _subtitle(AppLocalizations l, SiteLockExitCandidate candidate) =>
      candidate.names.length > 1
      ? l.siteLockExitMoreNames(candidate.names.length - 1)
      : null;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final candidates = widget.candidates;
    final resolved = [
      for (final exit in _chosen) (exit, siteLockCandidateOf(exit, candidates)),
    ];
    final chosen = Set<SiteLockExitCandidate>.identity()
      ..addAll([for (final (_, candidate) in resolved) ?candidate]);
    final query = _query.trim().toLowerCase();
    final full = _chosen.length >= siteLockMaxExits;
    final shown = [
      for (final (index, candidate) in candidates.indexed)
        if (query.isEmpty
            ? !chosen.contains(candidate)
            : _search[index].contains(query))
          candidate,
    ];
    final entries = <Widget Function()>[];
    void section(String title, List<Widget Function()> rows) {
      if (rows.isEmpty) return;
      entries.add(() => ListHeader(title: title));
      for (final (index, row) in rows.indexed) {
        final position = ItemPosition.get(index, rows.length);
        entries.add(
          () => ItemPositionProvider(position: position, child: row()),
        );
      }
    }

    if (query.isEmpty) {
      section(l.siteLockExitsChosen(_chosen.length, siteLockMaxExits), [
        for (final (exit, candidate) in resolved)
          () => candidate == null
              ? SiteLockExitRow(
                  name: siteLockExitLabel(exit),
                  subtitle: l.siteLockExitMissing,
                  selected: true,
                  onPressed: () => _drop(exit),
                )
              : SiteLockExitRow(
                  name: candidate.names.first,
                  subtitle: _subtitle(l, candidate),
                  selected: true,
                  onPressed: () => _toggle(candidate, true),
                ),
      ]);
    }
    section(l.siteLockExitsAll, [
      for (final candidate in shown)
        () {
          final selected = chosen.contains(candidate);
          return SiteLockExitRow(
            name: candidate.names.first,
            subtitle: _subtitle(l, candidate),
            selected: selected,
            onPressed: selected || !full
                ? () => _toggle(candidate, selected)
                : null,
          );
        },
    ]);
    return CommonScaffold(
      title: l.siteLockExitsTitle,
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: l.done,
        onPressed: () => Navigator.of(context).pop(_chosen),
      ),
      body: CustomScrollView(
        slivers: [
          if (candidates.length >= sheetSearchMinItemCount)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                context.sectionsTopPadding + 8,
                16,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SearchField(
                  hintText: l.siteLockExitsSearch,
                  fill: context.raisedSurfaceLevel.colorOf(context.colorScheme),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + context.bottomInset),
            sliver: entries.isEmpty
                ? SliverToBoxAdapter(
                    child: ListFooter(text: l.siteLockExitsNoMatch),
                  )
                : SliverList.builder(
                    itemCount: entries.length,
                    itemBuilder: (_, index) => entries[index](),
                  ),
          ),
        ],
      ),
    );
  }
}
