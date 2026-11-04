import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/doctor/report/report.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/ui.dart';

/// What the start page leaves to its options: who reads the report, whether
/// the problem is recorded first, and which sections go in.
class ReportDraft extends ChangeNotifier {
  var _redaction = ReportRedaction.provider;
  var _reproduce = false;
  var _sections = {...ReportSection.values};

  ReportRedaction get redaction => _redaction;
  bool get reproduce => _reproduce;
  Set<ReportSection> get sections => _sections;

  set redaction(ReportRedaction value) {
    _redaction = value;
    notifyListeners();
  }

  set reproduce(bool value) {
    _reproduce = value;
    notifyListeners();
  }

  void include(ReportSection section, bool on) {
    _sections = on
        ? {..._sections, section}
        : ({..._sections}..remove(section));
    notifyListeners();
  }
}

String reportSectionLabel(AppLocalizations l, ReportSection section) =>
    switch (section) {
      ReportSection.findings => l.doctorIssues,
      ReportSection.path => l.doctorPathTitle,
      ReportSection.servers => l.reportSectionServers,
      ReportSection.services => l.simpleServicesTitle,
      ReportSection.environment => l.reportSectionEnvironment,
      ReportSection.profile => l.profile,
      ReportSection.history => l.rcxHistory,
      ReportSection.config => l.reportSectionConfig,
      ReportSection.logs => l.logs,
    };

String reportAudienceLabel(AppLocalizations l, ReportRedaction redaction) =>
    switch (redaction) {
      ReportRedaction.provider => l.reportAudienceProvider,
      ReportRedaction.public => l.reportAudiencePublic,
    };

class ReportOptionsPage extends StatelessWidget {
  const ReportOptionsPage({super.key, required this.draft});

  final ReportDraft draft;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return CommonScaffold(
      title: l.options,
      body: ListenableBuilder(
        listenable: draft,
        builder: (context, _) => ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            context.sectionsTopPadding,
            16,
            16 + context.bottomInset,
          ),
          children: [
            generateSection(
              title: l.reportAudience,
              footer: l.reportAudienceFooter,
              items: [
                for (final redaction in ReportRedaction.values)
                  DecorationListItem(
                    key: ValueKey(('report-audience', redaction)),
                    title: Text(reportAudienceLabel(l, redaction)),
                    trailing: draft.redaction == redaction
                        ? const SelectionCheck()
                        : null,
                    onPressed: () => draft.redaction = redaction,
                  ),
              ],
            ),
            generateSection(
              title: l.reportRecordingSection,
              footer: l.reportReproduceFooter,
              items: [
                ListItem.toggle(
                  key: const ValueKey('report-reproduce'),
                  title: Text(l.reportReproduce),
                  value: draft.reproduce,
                  onChanged: (value) => draft.reproduce = value,
                ),
              ],
            ),
            generateSection(
              title: l.reportContents,
              footer: l.reportContentsFooter,
              items: [
                for (final section in ReportSection.values)
                  ListItem.checkbox(
                    title: Text(reportSectionLabel(l, section)),
                    value: draft.sections.contains(section),
                    onChanged: (on) => draft.include(section, on ?? false),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
