import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/widgets/widgets.dart';

import 'connection_doctor_path.dart';

part 'connection_doctor_cards.dart';
part 'connection_doctor_console.dart';
part 'connection_doctor_labels.dart';

/// Opens the Connection Doctor from a dashboard card. On a phone it rides a
/// pushed sheet as before; on the two-pane desktop it hands the pane to the
/// Tools tab so the Doctor's own drill-ins (DNS, advanced) stay in that stack
/// instead of stacking a stray side sheet outside it.
void openConnectionDoctor(BuildContext context, WidgetRef ref) {
  if (context.isMobileView) {
    unawaited(
      showExtend(context, builder: (_) => const ConnectionDoctorView()),
    );
    return;
  }
  ref.read(toolsPaneRequestProvider.notifier).request(ToolsPaneTarget.doctor);
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
