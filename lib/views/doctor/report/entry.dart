import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

import 'report_sheet.dart';

/// The "Report a problem" row closing the doctor and a failed path.
class ReportProblemItem extends StatelessWidget {
  const ReportProblemItem({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecorationListItem(
      key: const ValueKey('report-problem'),
      leading: GlyphIcon(AppGlyphs.support, color: colorScheme.primary),
      title: Text(
        context.appLocalizations.reportProblem,
        style: TextStyle(color: colorScheme.primary),
      ),
      trailing: GlyphIcon(
        AppGlyphs.chevronForward,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      onPressed: () => unawaited(showReportSheet(context)),
    );
  }
}
