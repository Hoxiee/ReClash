import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/milestones/seasonal.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';

class FindingPreviewView extends ConsumerWidget {
  const FindingPreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final preview = ref.watch(findingPreviewProvider);
    final controller = ref.read(findingPreviewProvider.notifier);
    return CommonScaffold(
      title: localizations.developerFindings,
      floatBody: true,
      body: !developerBuild
          ? Center(child: Text(localizations.developerMode))
          : ListView(
              padding: EdgeInsets.only(top: context.appBarInset),
              children: [
                SettingSection(
                  title: localizations.seasonalDecorations,
                  items: [
                    Padding(
                      padding: AppInsets.lg,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final season in <SeasonalMotif?>[
                            null,
                            ...SeasonalMotif.values,
                          ])
                            CommonChoiceChip(
                              label: switch (season) {
                                null => localizations.developerPreviewAutomatic,
                                SeasonalMotif.newYear =>
                                  localizations.developerSeasonNewYear,
                                SeasonalMotif.birthday =>
                                  localizations.developerSeasonBirthday,
                                SeasonalMotif.firstRun =>
                                  localizations.developerSeasonAnniversary,
                                SeasonalMotif.drift =>
                                  localizations.developerSeasonDrift,
                              },
                              selected: preview.season == season,
                              onSelected: () => controller.setSeason(season),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SettingBottomInset(),
              ],
            ),
    );
  }
}
