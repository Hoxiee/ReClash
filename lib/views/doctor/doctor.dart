import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'finding.dart';
import 'path.dart';

const _historyRows = 30;
const _snoozeWeek = Duration(days: 7);

/// Opens the doctor; [check] puts that finding first, [cause] explains a
/// failure the user asked "why?" about.
Future<void> showDoctorSheet(
  BuildContext context, {
  String? check,
  FailureCause? cause,
}) {
  return showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(
      builder: (_) => DoctorSheet(check: check, cause: cause),
    ),
  );
}

String eventLabel(AppLocalizations l, DiagnosticEventKind kind) =>
    switch (kind) {
      DiagnosticEventKind.findingRaised => l.doctorEventFindingRaised,
      DiagnosticEventKind.findingCleared => l.doctorEventFindingCleared,
      DiagnosticEventKind.probeFailed => l.serviceFailed,
      DiagnosticEventKind.remedyApplied => l.doctorEventRemedyApplied,
      DiagnosticEventKind.remedyUndone => l.doctorEventRemedyUndone,
      DiagnosticEventKind.disconnected => l.disconnected,
      DiagnosticEventKind.pathFailed => l.doctorEventPathFailed,
      DiagnosticEventKind.pathRecovered => l.doctorEventPathRecovered,
    };

/// The whole kernel in one place: the path, every finding with its fix and
/// snooze, and the incident history.
class DoctorSheet extends ConsumerStatefulWidget {
  const DoctorSheet({super.key, this.check, this.cause});

  final String? check;
  final FailureCause? cause;

  @override
  ConsumerState<DoctorSheet> createState() => _DoctorSheetState();
}

class _DoctorSheetState extends ConsumerState<DoctorSheet> {
  bool _historyExpanded = false;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(diagnosticKernelProvider).runPath());
  }

  Future<void> _recheck() =>
      ref.read(diagnosticKernelProvider).runPath(force: true);

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final findings = [...?ref.watch(findingsProvider).value]
      ..sort(
        (a, b) =>
            (b.id == widget.check ? 1 : 0) - (a.id == widget.check ? 1 : 0),
      );
    final path = ref.watch(pathProvider).value;
    final history = ref.watch(incidentHistoryProvider).value ?? const [];
    final running = path != null && !path.complete;
    return CommonScaffold(
      title: l.toolsObservation,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: l.setupRepeat,
          isLoading: running,
          onPressed: running ? null : () => unawaited(_recheck()),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          context.contentTopPadding,
          16,
          16 + context.bottomInset,
        ),
        children: [
          if (widget.cause case final cause?) ...[
            _Explanation(cause: cause),
            const SizedBox(height: 16),
          ],
          generateSection(
            title: l.doctorPathTitle,
            items: [_PathRow(path: path)],
          ),
          const SizedBox(height: 16),
          generateSection(
            title: l.doctorIssues,
            items: findings.isEmpty
                ? [
                    DecorationListItem(
                      leading: GlyphIcon(
                        AppGlyphs.checkCircle,
                        color: context.colorScheme.success,
                      ),
                      title: Text(l.doctorAllSet),
                    ),
                  ]
                : [
                    for (final finding in findings)
                      _FindingItem(finding: finding),
                  ],
          ),
          generateAnimatedSection(
            items: [
              Semantics(
                key: const ValueKey('doctor-history-toggle'),
                button: true,
                expanded: _historyExpanded,
                child: DecorationListItem(
                  title: Text(l.rcxHistory),
                  subtitle: _historyExpanded
                      ? null
                      : Text(
                          history.isEmpty
                              ? l.doctorHistoryEmpty
                              : eventLabel(l, history.last.kind),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onPressed: () =>
                      setState(() => _historyExpanded = !_historyExpanded),
                  trailing: SizedBox.square(
                    dimension: kMinInteractiveDimension,
                    child: Center(
                      child: GlyphIcon(
                        _historyExpanded
                            ? AppGlyphs.chevronUp
                            : AppGlyphs.chevronDown,
                      ),
                    ),
                  ),
                ),
              ),
              if (_historyExpanded)
                if (history.isEmpty)
                  DecorationListItem(
                    key: const ValueKey('doctor-history-empty'),
                    title: Text(l.doctorHistoryEmpty),
                  )
                else
                  for (final (index, event)
                      in history.indexed.toList().reversed.take(_historyRows))
                    _EventItem(key: ValueKey((index, event)), event: event),
            ],
          ),
        ],
      ),
    );
  }
}

class _Explanation extends ConsumerWidget {
  const _Explanation({required this.cause});

  final FailureCause cause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final kinds = ref.watch(remedyKindsProvider);
    final remedyId = availableRemedy(
      kinds,
      ref.read(diagnosticKernelProvider).explain(cause).remedyIds,
    );
    final finding = ref
        .watch(findingsProvider)
        .value
        ?.where((finding) => finding.cause == cause)
        .firstOrNull;
    return generateSection(
      title: l.doctorExplainTitle,
      items: [
        DecorationListItem(
          leading: GlyphIcon(AppGlyphs.error, color: context.colorScheme.error),
          title: Text(causeText(l, cause)),
          subtitle: finding == null ? null : Text(findingDetail(l, finding)),
          trailing: remedyId == null
              ? null
              : FindingFixButton(remedyId: remedyId, kind: kinds[remedyId]!),
        ),
      ],
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.path});

  final PathResult? path;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final path = this.path;
    final failed = path?.failed;
    return DecorationListItem(
      leading: GlyphIcon(
        switch (path) {
          PathResult(passed: true) => AppGlyphs.checkCircle,
          PathResult(complete: true) when failed != null => AppGlyphs.error,
          _ => AppGlyphs.status,
        },
        color: switch (path) {
          PathResult(passed: true) => colorScheme.success,
          PathResult(complete: true) when failed?.cause != null =>
            colorScheme.error,
          _ => colorScheme.onSurfaceVariant,
        },
      ),
      title: Text(switch (path) {
        null => l.doctorPathIdle,
        PathResult(passed: true) => l.doctorPathAllPass(
          path.duration.inMilliseconds,
        ),
        PathResult(cancelled: true) => l.doctorPathCancelled,
        PathResult(complete: false) => l.doctorPathChecking,
        _ => l.doctorPathFailedAt(failed?.step.label(l) ?? ''),
      }),
      subtitle: path != null && path.complete && failed != null
          ? Text(failureText(l, failed))
          : null,
      trailing: GlyphIcon(
        AppGlyphs.chevronForward,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      onPressed: () => unawaited(
        showInSheet<void>(context, builder: (_) => const PathSheet()),
      ),
    );
  }
}

class _FindingItem extends ConsumerWidget {
  const _FindingItem({required this.finding});

  final Finding finding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final kinds = ref.watch(remedyKindsProvider);
    final remedyId = availableRemedy(kinds, finding.remedyIds);
    final kernel = ref.read(diagnosticKernelProvider);
    return ContextMenuRegion(
      menuItems: finding.severity == CheckSeverity.critical
          ? null
          : [
              CommonPopupMenuItem(
                label: l.doctorSnoozeWeek,
                glyph: AppGlyphs.clock,
                onPressed: () => kernel.snooze(
                  finding.id,
                  until: DateTime.now().add(_snoozeWeek),
                ),
              ),
              CommonPopupMenuItem(
                label: l.doctorSnoozeForever,
                glyph: AppGlyphs.eyeOff,
                onPressed: () => kernel.snooze(finding.id),
              ),
            ],
      child: DecorationListItem(
        leading: GlyphIcon(
          finding.severity.glyph,
          color: finding.severity.color(context.colorScheme),
        ),
        title: Text(findingTitle(l, finding)),
        subtitle: Text(findingDetail(l, finding)),
        trailing: remedyId == null
            ? null
            : FindingFixButton(remedyId: remedyId, kind: kinds[remedyId]!),
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  const _EventItem({super.key, required this.event});

  final DiagnosticEvent event;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cause = event.cause;
    return DecorationListItem(
      title: Text(eventLabel(l, event.kind)),
      subtitle: switch ([
        if (cause != null) causeText(l, cause),
        ?event.detail,
      ]) {
        final parts when parts.isNotEmpty => Text(
          parts.join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        _ => null,
      },
      trailing: Text(
        event.at.getLastUpdateTimeDesc(context, compact: true),
        style: AppTextStyle.footnote
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
