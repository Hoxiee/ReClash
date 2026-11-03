import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/environment/healer.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/models/models.dart';

import 'finding.dart';

/// Announces each automatic repair of the environment, with Undo when the
/// remedy can be taken back.
void listenHealNotices(WidgetRef ref) {
  ref.listenManual(environmentHealNoticesProvider, (_, next) {
    final notice = next.value;
    if (notice != null) _announce(ref, notice);
  });
}

void _announce(WidgetRef ref, HealNotice notice) {
  final l = currentAppLocalizations;
  final title = findingTitle(
    l,
    Finding(
      id: notice.findingId,
      severity: CheckSeverity.tip,
      evidence: const [],
      titleKey: notice.titleKey,
      detailKey: '',
      args: notice.args,
    ),
  );
  dialogs.showNotifier(
    l.doctorHealedNotice(title),
    level: MessageLevel.success,
    actionState: notice.undoable
        ? MessageActionState(
            actionText: l.undo,
            action: () =>
                unawaited(ref.read(environmentHealerProvider).undo(notice)),
          )
        : null,
  );
}
