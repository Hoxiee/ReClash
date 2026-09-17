import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/common/seasonal.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/about.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/views/dashboard/widgets/traffic_usage.dart';
import 'package:reclash/views/tools/findings.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindingPreviewView extends ConsumerWidget {
  const FindingPreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final enabled = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    final preview = ref.watch(findingPreviewProvider);
    final controller = ref.read(findingPreviewProvider.notifier);
    return CommonScaffold(
      title: localizations.developerFindings,
      body: !enabled
          ? Center(child: Text(localizations.developerMode))
          : ListView(
              children: [
                SettingSection(
                  items: [
                    DecorationListItem(
                      leading: const Icon(Icons.science_outlined),
                      title: Text(localizations.developerFindings),
                      subtitle: Text(localizations.developerFindingsDesc),
                    ),
                    DecorationListItem(
                      title: Text(localizations.developerAllRewards),
                      onPressed: controller.showAllRewards,
                    ),
                    DecorationListItem(
                      title: Text(localizations.developerPreviewReset),
                      onPressed: controller.reset,
                    ),
                    DecorationListItem.open(
                      title: Text(localizations.findings),
                      widget: const FindingsView(),
                    ),
                  ],
                ),
                SettingSection(
                  title: localizations.seasonalDecorations,
                  items: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final season in <SeasonalMotif?>[
                            null,
                            ...SeasonalMotif.values,
                          ])
                            ChoiceChip(
                              label: Text(switch (season) {
                                null => localizations.developerPreviewAutomatic,
                                SeasonalMotif.newYear =>
                                  localizations.developerSeasonNewYear,
                                SeasonalMotif.birthday =>
                                  localizations.developerSeasonBirthday,
                                SeasonalMotif.firstRun =>
                                  localizations.developerSeasonAnniversary,
                                SeasonalMotif.drift =>
                                  localizations.developerSeasonDrift,
                              }),
                              selected: preview.season == season,
                              onSelected: (_) => controller.setSeason(season),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SettingSection(
                  title: localizations.developerPatina,
                  items: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final days in <int?>[null, 0, 14, 45, 120])
                            ChoiceChip(
                              label: Text(
                                days == null
                                    ? localizations.developerPreviewAutomatic
                                    : localizations.developerPatinaDays(days),
                              ),
                              selected: preview.patinaDays == days,
                              onSelected: (_) => controller.setPatinaDays(days),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SettingSection(
                  title: localizations.developerFindingEvents,
                  items: [
                    for (final id in findingIds)
                      DecorationListItem(
                        key: ValueKey('preview-finding-$id'),
                        leading: Icon(
                          preview.unlocked.contains(id)
                              ? Icons.check_circle_outline
                              : Icons.play_arrow_rounded,
                        ),
                        title: Text(findingName(context, id)),
                        subtitle: Text(findingDescription(context, id)),
                        onPressed: () {
                          controller.showFinding(id);
                          if (id == 'loopback') {
                            context.showNotifier(
                              localizations.findingLoopbackWarning,
                              level: MessageLevel.warning,
                            );
                          } else if (id == 'storm') {
                            showExtend(
                              context,
                              builder: (_) => const DoctorStormPreview(),
                            );
                          } else if (id == 'fullLadder' ||
                              id == 'auscultation') {
                            showExtend(
                              context,
                              builder: (_) => id == 'fullLadder'
                                  ? const DesyncLadderPreview()
                                  : const DoctorTimingPreview(),
                            );
                          } else if (id == 'odometer') {
                            showExtend(
                              context,
                              builder: (_) => CommonScaffold(
                                title: localizations.developerFindings,
                                body: const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: TrafficUsage(preview: true),
                                ),
                              ),
                            );
                          } else if (id == 'marks') {
                            showExtend(
                              context,
                              builder: (_) => const MarksView(),
                            );
                          } else {
                            context.showNotifier(
                              localizations.developerFindingQueued,
                            );
                          }
                        },
                      ),
                  ],
                ),
                const SettingBottomInset(),
              ],
            ),
    );
  }
}
