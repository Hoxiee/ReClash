import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

import 'doctor.dart';
import 'finding.dart';

const _expandedRows = 3;

/// Runs every auto remedy the findings offer as one plan, verified by the
/// path while connected, and reports the count in one snackbar.
Future<void> fixEverything(
  BuildContext context,
  WidgetRef ref,
  List<Finding> findings,
) async {
  final kinds = ref.read(remedyKindsProvider);
  final targets = {
    for (final finding in findings)
      if (availableRemedy(kinds, finding.remedyIds) case final id?
          when kinds[id] == FixKind.auto)
        id: finding.id,
  };
  final kernel = ref.read(diagnosticKernelProvider);
  final outcome = await kernel.heal(
    HealPlan(
      id: 'doctor.fixEverything',
      remedyIds: targets.keys.toList(),
      findingIds: targets.values.toList(),
      verify: ref.read(isStartProvider) ? PathScope.full : null,
    ),
  );
  if (!context.mounted) return;
  final left = kernel.findings
      .where((finding) => targets.containsValue(finding.id))
      .length;
  context.showNotifier(
    context.appLocalizations.doctorFixAllResult(targets.length - left, left),
    level: left == 0 && (outcome.path?.passed ?? true)
        ? MessageLevel.success
        : MessageLevel.warning,
  );
}

int _autoCount(Map<String, FixKind> kinds, List<Finding> findings) => findings
    .where(
      (finding) =>
          kinds[availableRemedy(kinds, finding.remedyIds)] == FixKind.auto,
    )
    .length;

/// The doctor's verdict on the dashboard: all set, the issues collapsed to
/// their names or expanded with their buttons, or the one critical issue on
/// the error container.
class HealthCard extends ConsumerStatefulWidget {
  const HealthCard({super.key});

  @override
  ConsumerState<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends ConsumerState<HealthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final findings = ref.watch(findingsProvider).value ?? const <Finding>[];
    final critical = findings.firstOrNull?.severity == CheckSeverity.critical
        ? findings.first
        : null;
    final colorScheme = context.colorScheme;
    void open() => unawaited(showDoctorSheet(context, check: critical?.id));
    return DashboardCard(
      semanticLabel: l.toolsObservation,
      color: critical == null ? null : colorScheme.errorContainer,
      onTap: findings.isEmpty || critical != null || _expanded
          ? open
          : () => setState(() => _expanded = true),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            DashboardCardHeader(
              glyph: AppGlyphs.verified,
              title: l.toolsObservation,
              chevron: true,
            ),
            if (findings.isEmpty)
              const _AllSet()
            else if (critical != null)
              _Critical(finding: critical, others: findings.length - 1)
            else if (_expanded)
              _Expanded(findings: findings)
            else
              _Collapsed(findings: findings),
          ],
        ),
      ),
    );
  }
}

class _AllSet extends ConsumerWidget {
  const _AllSet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final checkedAt = ref.read(diagnosticKernelProvider).snapshot.takenAt;
    return Row(
      spacing: 8,
      children: [
        GlyphIcon(
          AppGlyphs.checkCircle,
          size: 20,
          color: DashboardColors.of(context).ok,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.doctorAllSet,
                style: AppTextStyle.subheadline.of(context, emphasized: true),
              ),
              Text(
                '${l.doctorChecksPassed(defaultRules.length)} · '
                '${checkedAt.getLastUpdateTimeDesc(context)}',
                style: DashboardText.label(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Collapsed extends StatelessWidget {
  const _Collapsed({required this.findings});

  final List<Finding> findings;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colors = DashboardColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          spacing: 8,
          children: [
            GlyphIcon(AppGlyphs.warning, size: 20, color: colors.warn),
            Text(
              l.doctorIssueCount(findings.length),
              style: AppTextStyle.subheadline.of(context, emphasized: true),
            ),
          ],
        ),
        Text(
          findingDetail(l, findings.first),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: DashboardText.label(context),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final finding in findings)
              _Chip(label: findingTitle(l, finding)),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: DashboardColors.of(context).track,
        shape: AppShape.full,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.caption1
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _Expanded extends ConsumerWidget {
  const _Expanded({required this.findings});

  final List<Finding> findings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final kinds = ref.watch(remedyKindsProvider);
    final hidden = findings.length - _expandedRows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        for (final finding in findings.take(_expandedRows))
          FindingCardRow(finding: finding),
        if (hidden > 0 || _autoCount(kinds, findings) > 1)
          Row(
            children: [
              if (hidden > 0)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () => unawaited(showDoctorSheet(context)),
                  child: Text(l.doctorShowMore(hidden)),
                ),
              const Spacer(),
              if (_autoCount(kinds, findings) > 1)
                FilledButton(
                  onPressed: () =>
                      unawaited(fixEverything(context, ref, findings)),
                  child: Text(l.doctorFixAll),
                ),
            ],
          ),
      ],
    );
  }
}

class _Critical extends StatelessWidget {
  const _Critical({required this.finding, required this.others});

  final Finding finding;
  final int others;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        FindingCardRow(finding: finding, onError: true),
        if (others > 0)
          Text(
            context.appLocalizations.doctorMoreIssues(others),
            style: DashboardText.label(
              context,
            ).copyWith(color: context.colorScheme.onErrorContainer),
          ),
      ],
    );
  }
}

/// One finding in a card: severity mark, title, consequence and its button.
class FindingCardRow extends ConsumerWidget {
  const FindingCardRow({
    super.key,
    required this.finding,
    this.onError = false,
  });

  final Finding finding;

  /// Sits on the error container, so text and marks take its `on` role.
  final bool onError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final kinds = ref.watch(remedyKindsProvider);
    final remedyId = availableRemedy(kinds, finding.remedyIds);
    final secondary = onError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: GlyphIcon(
            finding.severity.glyph,
            size: 20,
            color: onError
                ? colorScheme.onErrorContainer
                : finding.severity.color(colorScheme),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                findingTitle(l, finding),
                style: AppTextStyle.subheadline
                    .of(context, emphasized: true)
                    .copyWith(
                      color: onError ? colorScheme.onErrorContainer : null,
                    ),
              ),
              Text(
                findingDetail(l, finding),
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: secondary),
              ),
            ],
          ),
        ),
        if (remedyId != null)
          FindingFixButton(
            remedyId: remedyId,
            kind: kinds[remedyId]!,
            onError: onError,
          ),
      ],
    );
  }
}
