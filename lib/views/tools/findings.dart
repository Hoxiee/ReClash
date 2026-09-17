import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _totalFindings = 14;

const _findingIcons = <String, IconData>{
  'vigil': Icons.nightlight_round,
  'auscultation': Icons.monitor_heart_outlined,
  'fullLadder': Icons.stairs_outlined,
  'silentAutopilot': Icons.route_outlined,
  'odometer': Icons.speed_outlined,
  'meridian': Icons.public_outlined,
  'porcelain': Icons.tonality_outlined,
  'crown': Icons.workspace_premium_outlined,
  'oscilloscope': Icons.show_chart_outlined,
  'marks': Icons.collections_bookmark_outlined,
  'pi': Icons.functions,
  'turn': Icons.rotate_right_outlined,
  'storm': Icons.thunderstorm_outlined,
  'loopback': Icons.sync_outlined,
};

class FindingsView extends ConsumerWidget {
  const FindingsView({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    if (ref.read(findingPreviewProvider).enabled) {
      ref.read(findingPreviewProvider.notifier).reset();
      return;
    }
    final localizations = context.appLocalizations;
    final confirmed = await dialogs.showCommonDialog<bool>(
      child: CommonDialog(
        title: localizations.resetFindingsTitle,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.reset),
          ),
        ],
        child: Text(localizations.resetFindingsConfirm),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(milestonesProvider.notifier).resetFindings();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(visibleMilestonesProvider);
    final preview = ref.watch(findingPreviewProvider).enabled;
    final entries =
        settings.revealedAt.entries
            .where((entry) => _findingIcons.containsKey(entry.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final localizations = context.appLocalizations;
    final materialLocalizations = MaterialLocalizations.of(context);
    return CommonScaffold(
      title: localizations.findings,
      body: CustomScrollView(
        slivers: [
          SettingSection.sliver(
            top: 12,
            items: [
              DecorationListItem(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(
                  localizations.findingsCount(entries.length, _totalFindings),
                ),
                subtitle: Text(localizations.findingsDesc),
              ),
            ],
          ),
          SettingSection.sliver(
            title: localizations.discoveredFindings,
            items: [
              for (final entry in entries)
                DecorationListItem(
                  leading: Icon(_findingIcons[entry.key]!),
                  title: Text(findingName(context, entry.key)),
                  subtitle: Text(findingDescription(context, entry.key)),
                  trailing: Text(
                    localizations.findingDiscoveredOn(
                      materialLocalizations.formatMediumDate(
                        DateTime.fromMillisecondsSinceEpoch(entry.value),
                      ),
                    ),
                    textAlign: TextAlign.end,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          SettingSection.sliver(
            items: [
              DecorationListItem(
                leading: const Icon(Icons.restart_alt_outlined),
                title: Text(
                  preview
                      ? localizations.developerPreviewReset
                      : localizations.resetFindings,
                ),
                subtitle: Text(
                  preview
                      ? localizations.developerFindingsDesc
                      : localizations.resetFindingsDesc,
                ),
                onPressed: () => _reset(context, ref),
              ),
            ],
          ),
          const SettingBottomInset.sliver(),
        ],
      ),
    );
  }
}

String findingName(BuildContext context, String id) => switch (id) {
  'vigil' => context.appLocalizations.findingVigil,
  'auscultation' => context.appLocalizations.findingAuscultation,
  'fullLadder' => context.appLocalizations.findingFullLadder,
  'silentAutopilot' => context.appLocalizations.findingSilentAutopilot,
  'odometer' => context.appLocalizations.findingOdometer,
  'meridian' => context.appLocalizations.findingMeridian,
  'porcelain' => context.appLocalizations.findingPorcelain,
  'crown' => context.appLocalizations.findingCrown,
  'oscilloscope' => context.appLocalizations.findingOscilloscope,
  'marks' => context.appLocalizations.findingMarks,
  'pi' => context.appLocalizations.findingPi,
  'turn' => context.appLocalizations.findingTurn,
  'storm' => context.appLocalizations.findingStorm,
  'loopback' => context.appLocalizations.findingLoopback,
  _ => id,
};

String findingDescription(BuildContext context, String id) => switch (id) {
  'vigil' => context.appLocalizations.milestoneRevealVigil,
  'auscultation' => context.appLocalizations.milestoneRevealAuscultation,
  'fullLadder' => context.appLocalizations.milestoneRevealFullLadder,
  'silentAutopilot' => context.appLocalizations.milestoneRevealSilentAutopilot,
  'odometer' => context.appLocalizations.milestoneRevealOdometer,
  'meridian' => context.appLocalizations.milestoneRevealMeridian,
  'porcelain' => context.appLocalizations.milestoneRevealPorcelain,
  'crown' => context.appLocalizations.milestoneRevealCrown,
  'oscilloscope' => context.appLocalizations.findingOscilloscopeDesc,
  'marks' => context.appLocalizations.findingMarksDesc,
  'pi' => context.appLocalizations.findingPiDesc,
  'turn' => context.appLocalizations.findingTurnDesc,
  'storm' => context.appLocalizations.findingStormDesc,
  'loopback' => context.appLocalizations.findingLoopbackDesc,
  _ => '',
};
