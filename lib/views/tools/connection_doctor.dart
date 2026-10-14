import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/appearance/appearance.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/widgets/widgets.dart';

import 'connection_doctor_path.dart';

part 'connection_doctor_cards.dart';
part 'connection_doctor_console.dart';
part 'connection_doctor_labels.dart';

/// Identifies the Doctor's own pane in the Tools two-pane stack, so a handoff
/// seeds the same root the Tools list opens.
const toolsDoctorPaneId = 'doctor';

/// The Doctor as the root entry of a Tools pane stack, so a handoff can seed it
/// and push drill-ins on top with a back-path to the diagnosis.
SettingsPaneSelection doctorRootPane(BuildContext context) {
  return SettingsPaneSelection(
    id: toolsDoctorPaneId,
    detail: const ConnectionDoctorView(),
    title: Text(context.appLocalizations.connectionDoctor),
  );
}

/// Opens the Connection Doctor from a dashboard card. On a phone it rides a
/// pushed sheet as before; on the two-pane desktop it hands the pane to the
/// Tools tab so the Doctor's own drill-ins (DNS, advanced) stay in that stack
/// instead of stacking a stray side sheet outside it.
///
/// The hero status line passes [asSheet] to keep the Doctor an overlay over the
/// dashboard instead of jumping into the Tools tab; its drill-ins still hand
/// off to the Tools tab from there, so a desktop never stacks a second sheet.
void openConnectionDoctor(
  BuildContext context,
  WidgetRef ref, {
  bool asSheet = false,
}) {
  if (asSheet || context.isMobileView) {
    unawaited(
      showExtend(context, builder: (_) => const ConnectionDoctorView()),
    );
    return;
  }
  ref.read(toolsPaneRequestProvider.notifier).request([
    doctorRootPane(context),
  ]);
  ref
      .read(currentPageLabelProvider.notifier)
      .toPage(PageLabel.tools, returnable: true);
}

class ConnectionDoctorView extends ConsumerStatefulWidget {
  const ConnectionDoctorView({super.key});

  @override
  ConsumerState<ConnectionDoctorView> createState() =>
      _ConnectionDoctorViewState();
}
