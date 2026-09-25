import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_overview_parts.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _diagKinds = ['decision', 'switch', 'event', 'probe'];
const _maxLocalRows = 6000;

String _kindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'decision' => l10n.smartRoutingLogKindDecision,
  'switch' => l10n.smartRoutingLogKindSwitch,
  'event' => l10n.smartRoutingLogKindEvent,
  'probe' => l10n.smartRoutingLogKindProbe,
  _ => kind.toUpperCase(),
};

Color _kindColor(ColorScheme scheme, String kind) => switch (kind) {
  'decision' => scheme.primary,
  'switch' => scheme.tertiary,
  'probe' => scheme.secondary,
  _ => scheme.onSurfaceVariant,
};

sealed class _DiagRow {
  const _DiagRow();
}

class _EntryRow extends _DiagRow {
  const _EntryRow(this.entry);
  final RcxDiagEntry entry;
}

class _GapRow extends _DiagRow {
  const _GapRow(this.count);
  final int count;
}

class RoutingDiagView extends ConsumerStatefulWidget {
  const RoutingDiagView({super.key, this.logReader});

  @visibleForTesting
  final Future<RcxDiagBatch?> Function(int since)? logReader;

  @override
  ConsumerState<RoutingDiagView> createState() => _RoutingDiagViewState();
}

class _RoutingDiagViewState extends ConsumerState<RoutingDiagView>
    with WidgetsBindingObserver, ActivePollingMixin<RoutingDiagView> {
  final List<_DiagRow> _rows = [];
  List<_DiagRow> _visible = const [];
  final Set<int> _expanded = {};
  final Set<String> _kinds = {..._diagKinds};
  final ScrollController _scrollController = ScrollController();
  int _cursor = 0;
  int _dropped = 0;
  bool _autoScroll = true;

  static const _followThreshold = 48.0;

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    // The core wipes its ring on the off->on edge, so mirror that reset here
    // to keep the local rows aligned with the fresh session.
    ref.listenManual(
      appSettingProvider.select((state) => state.smartRoutingDiagnostics),
      (prev, next) {
        if (prev == next || !next) return;
        _resetSession();
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetSession() {
    setState(() {
      _rows.clear();
      _expanded.clear();
      _cursor = 0;
      _dropped = 0;
      _rebuildVisible();
    });
  }

  // Release the tail pin once the user scrolls up so new rows stop yanking them down.
  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final atBottom =
        position.pixels >= position.maxScrollExtent - _followThreshold;
    if (atBottom == _autoScroll) return;
    setState(() => _autoScroll = atBottom);
  }

  void _rebuildVisible() {
    _visible = [
      for (final row in _rows)
        if (row is _GapRow ||
            (row is _EntryRow && _kinds.contains(row.entry.kind)))
          row,
    ];
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final reader = widget.logReader;
    final batch = reader != null
        ? await reader(_cursor)
        : await _core.smartRoutingDiagLog(_cursor);
    if (batch == null || !isCurrent()) return;
    _ingest(batch);
  }

  void _ingest(RcxDiagBatch batch) {
    if (!mounted) return;
    final hadDrop = batch.dropped > _dropped;
    if (!hadDrop && batch.entries.isEmpty) {
      if (batch.cursor > _cursor) _cursor = batch.cursor;
      return;
    }
    setState(() {
      if (hadDrop) {
        _rows.add(_GapRow(batch.dropped - _dropped));
        _dropped = batch.dropped;
      }
      for (final entry in batch.entries) {
        _appendEntry(entry);
      }
      if (batch.cursor > _cursor) {
        _cursor = batch.cursor;
      }
      if (_rows.length > _maxLocalRows) {
        _rows.removeRange(0, _rows.length - _maxLocalRows);
      }
      _rebuildVisible();
    });
    _maybeAutoScroll();
  }

  // A repeat re-emits as a fresh seq that matches the previous entry, so fold it
  // onto the last row instead of stacking a duplicate as the count climbs.
  void _appendEntry(RcxDiagEntry entry) {
    if (entry.repeat > 1) {
      final index = _rows.lastIndexWhere((row) => row is _EntryRow);
      if (index >= 0) {
        final last = (_rows[index] as _EntryRow).entry;
        if (last.kind == entry.kind &&
            last.msg == entry.msg &&
            last.from == entry.from &&
            last.to == entry.to) {
          _rows[index] = _EntryRow(entry);
          return;
        }
      }
    }
    _rows.add(_EntryRow(entry));
  }

  void _maybeAutoScroll() {
    if (!_autoScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _toggle(int seq) {
    setState(() {
      if (!_expanded.remove(seq)) {
        _expanded.add(seq);
      }
    });
  }

  void _toggleKind(String kind) {
    setState(() {
      if (!_kinds.remove(kind)) {
        _kinds.add(kind);
      }
      _rebuildVisible();
    });
    _maybeAutoScroll();
  }

  void _toggleAutoScroll() {
    final next = !_autoScroll;
    setState(() => _autoScroll = next);
    if (next) _maybeAutoScroll();
  }

  Future<void> _handleExport() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      final reader = widget.logReader;
      final batch = reader != null
          ? await reader(0)
          : await _core.smartRoutingDiagLog(0);
      if (batch == null || batch.entries.isEmpty) {
        return false;
      }
      final buffer = StringBuffer();
      for (final entry in batch.entries) {
        buffer.writeln(jsonEncode(entry.toJson()));
      }
      final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
      final name =
          'reclash-rcx-${DateTime.now().millisecondsSinceEpoch}.ndjson';
      final uri = await picker.saveFile(name, bytes);
      return uri != null;
    }, title: appLocalizations.smartRoutingLogExport);
    if (res != true) return;
    unawaited(
      dialogs.showMessage(
        title: appLocalizations.smartRoutingLogExport,
        message: TextSpan(text: appLocalizations.exportSuccess),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final enabled = ref.watch(
      appSettingProvider.select((state) => state.smartRoutingDiagnostics),
    );
    return CommonScaffold(
      title: appLocalizations.smartRoutingLog,
      floatBody: true,
      actions: enabled ? _buildActions(context) : const [],
      body: AppBarClearance(
        child: enabled ? _buildLog(context) : _buildOff(context),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupBox(
        popupBuilder: (_) => CommonPopupMenu(
          items: [
            for (final kind in _diagKinds)
              CommonPopupMenuItem(
                glyph: _kinds.contains(kind)
                    ? AppGlyphs.check
                    : AppGlyphs.checkboxBlank,
                label: _kindLabel(appLocalizations, kind),
                onPressed: () => _toggleKind(kind),
              ),
          ],
        ),
        targetBuilder: (open) {
          final filtered = _kinds.length != _diagKinds.length;
          const icon = GlyphIcon(AppGlyphs.filter);
          return filtered
              ? IconButton.filledTonal(
                  tooltip: appLocalizations.smartRoutingLogFilter,
                  onPressed: () => open(),
                  icon: icon,
                )
              : IconButton(
                  tooltip: appLocalizations.smartRoutingLogFilter,
                  onPressed: () => open(),
                  icon: icon,
                );
        },
      ),
      IconButton(
        tooltip: appLocalizations.smartRoutingLogAutoScroll,
        isSelected: _autoScroll,
        onPressed: _toggleAutoScroll,
        icon: const GlyphIcon(AppGlyphs.arrowDown),
      ),
      IconButton(
        tooltip: appLocalizations.smartRoutingLogClear,
        onPressed: _rows.isEmpty
            ? null
            : () => setState(() {
                _rows.clear();
                _expanded.clear();
                _rebuildVisible();
              }),
        icon: const GlyphIcon(AppGlyphs.delete),
      ),
      IconButton(
        tooltip: appLocalizations.smartRoutingLogExport,
        onPressed: _handleExport,
        icon: const GlyphIcon(AppGlyphs.save),
      ),
    ];
  }

  Widget _buildOff(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appLocalizations.smartRoutingLogOffTitle,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              appLocalizations.smartRoutingLogOffHint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => ref
                  .read(appSettingProvider.notifier)
                  .update(
                    (state) => state.copyWith(smartRoutingDiagnostics: true),
                  ),
              child: Text(appLocalizations.smartRoutingLogEnable),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLog(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final visible = _visible;
    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            _rows.isEmpty
                ? appLocalizations.smartRoutingLogWaiting
                : appLocalizations.smartRoutingLogEmpty,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 16 + BottomInsetScope.of(context)),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (_, index) {
        final row = visible[index];
        return switch (row) {
          _GapRow(:final count) => _GapTile(count: count),
          _EntryRow(:final entry) => _DiagEntryTile(
            entry: entry,
            expanded: _expanded.contains(entry.seq),
            onTap: () => _toggle(entry.seq),
          ),
        };
      },
    );
  }
}

String _formatTime(int millis) {
  if (millis <= 0) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  String two(int v) => v.toString().padLeft(2, '0');
  final ms = dt.millisecond.toString().padLeft(3, '0');
  return '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}.$ms';
}

class _GapTile extends StatelessWidget {
  const _GapTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      color: colorScheme.error.opacity12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        context.appLocalizations.smartRoutingLogDropped(count),
        textAlign: TextAlign.center,
        style: context.textTheme.labelSmall
            ?.copyWith(color: colorScheme.error)
            .toJetBrainsMono,
      ),
    );
  }
}

class _DiagEntryTile extends StatelessWidget {
  const _DiagEntryTile({
    required this.entry,
    required this.expanded,
    required this.onTap,
  });

  final RcxDiagEntry entry;
  final bool expanded;
  final VoidCallback onTap;

  bool get _expandable => entry.ctx != null || entry.cands.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final accent = _kindColor(colorScheme, entry.kind);
    return InkWell(
      onTap: _expandable ? onTap : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 10, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _KindBadge(kind: entry.kind, accent: accent),
                  if (entry.repeat > 1)
                    Text(
                      context.appLocalizations.smartRoutingLogRepeat(
                        entry.repeat,
                      ),
                      style: context.textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)
                          .toJetBrainsMono,
                    ),
                  const Spacer(),
                  Text(
                    _formatTime(entry.at),
                    style: context.textTheme.labelSmall
                        ?.copyWith(color: colorScheme.outline)
                        .toJetBrainsMono,
                  ),
                  if (_expandable)
                    GlyphIcon(
                      expanded ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SelectableText(
                entry.msg,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface, height: 1.35)
                    .toJetBrainsMono,
              ),
              if (entry.kind == 'switch' &&
                  (entry.from.isNotEmpty || entry.to.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${entry.from.isEmpty ? '—' : entry.from} → ${entry.to.isEmpty ? '—' : entry.to}',
                    style: context.textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)
                        .toJetBrainsMono,
                  ),
                ),
              if (expanded && entry.ctx != null) ...[
                const SizedBox(height: 10),
                _ContextGrid(ctx: entry.ctx!),
              ],
              if (expanded && entry.cands.isNotEmpty) ...[
                const SizedBox(height: 10),
                _CandidateList(candidates: entry.cands),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.kind, required this.accent});

  final String kind;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.opacity12,
      shape: AppShape.xs,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          _kindLabel(context.appLocalizations, kind).toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _ContextGrid extends StatelessWidget {
  const _ContextGrid({required this.ctx});

  final RcxDiagContext ctx;

  List<(String, String)> _tokens() {
    final tokens = <(String, String)>[
      ('terrain', ctx.terrain),
      ('env', ctx.env),
      ('strategy', ctx.strategy),
      ('preset', ctx.preset),
      ('mode', ctx.mode),
      ('incumbent', ctx.incumbent),
      ('incumbentMs', '${ctx.incumbentMs}'),
      ('sinceMs', '${ctx.sinceMs}'),
      ('pin', ctx.pin),
      ('transport', ctx.transport),
      ('reachF', ctx.reachF),
      ('reachD', ctx.reachD),
      ('direct', ctx.direct),
      ('probesLeft', '${ctx.probesLeft}'),
      ('candidates', '${ctx.candidates}'),
      ('eligible', '${ctx.eligible}'),
      ('incidentConns', '${ctx.incidentConns}'),
      ('frozenNodes', '${ctx.frozenNodes}'),
      ('screenOff', '${ctx.screenOff}'),
      ('suspended', '${ctx.suspended}'),
      ('probing', '${ctx.probing}'),
      ('deep', '${ctx.deep}'),
      ('portal', '${ctx.portal}'),
      ('metered', '${ctx.metered}'),
      ('validated', '${ctx.validated}'),
    ];
    return [
      for (final token in tokens)
        if (token.$2.isNotEmpty) token,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.appLocalizations.smartRoutingLogState,
          style: context.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (key, value) in _tokens())
              _Token(label: key, value: value),
          ],
        ),
      ],
    );
  }
}

class _Token extends StatelessWidget {
  const _Token({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.xs.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label ',
                style: TextStyle(color: colorScheme.outline),
              ),
              TextSpan(
                text: value,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
          style: context.textTheme.labelSmall?.toJetBrainsMono,
        ),
      ),
    );
  }
}

class _CandidateList extends StatelessWidget {
  const _CandidateList({required this.candidates});

  final List<RcxCandidateReport> candidates;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final sorted = [...candidates]..sort((a, b) => a.order.compareTo(b.order));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.smartRoutingLogCandidates,
          style: context.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        for (final candidate in sorted) _CandidateRow(candidate: candidate),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.candidate});

  final RcxCandidateReport candidate;

  String _headline(AppLocalizations l10n) {
    final parts = <String>['#${candidate.order}', candidate.node];
    if (candidate.country.isNotEmpty) {
      parts.add('[${candidate.country}]');
    }
    parts.add(routingBlockLabel(l10n, candidate));
    parts.add(routingEvidenceLabel(l10n, candidate.evidence));
    if (candidate.latencyMs > 0) {
      parts.add('${candidate.latencyMs}ms');
    }
    return parts.join('  ');
  }

  String _detail() {
    final flags = <String>[
      'origin=${candidate.origin}',
      'trust=${candidate.trust}',
      'conf=${candidate.confidence}',
      'homeRisk=${candidate.homeRisk}',
      'recurrence=${candidate.recurrence}',
      'band=${candidate.band}',
      'delay=${candidate.delay}',
      'hostDelay=${candidate.hostDelay}',
      'fails=${candidate.fails}',
      'coolFor=${candidate.coolFor}',
    ];
    if (candidate.exit.isNotEmpty) flags.insert(1, 'exit=${candidate.exit}');
    if (candidate.unproven) flags.add('unproven');
    if (candidate.degraded) flags.add('degraded');
    if (candidate.confirmed) flags.add('confirmed');
    if (candidate.breaker) flags.add('breaker');
    if (candidate.udp) flags.add('udp');
    return flags.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final accent = candidate.current
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: candidate.current ? colorScheme.primary.opacity12 : null,
        border: Border(left: BorderSide(color: accent, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _headline(appLocalizations),
            style: context.textTheme.labelMedium
                ?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: candidate.current
                      ? FontWeight.w600
                      : FontWeight.w400,
                )
                .toJetBrainsMono,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _detail(),
            style: context.textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)
                .toJetBrainsMono,
          ),
        ],
      ),
    );
  }
}
