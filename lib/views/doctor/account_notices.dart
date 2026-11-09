import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/providers.dart';

/// Says why the account guard stopped the tunnel, or that a renewal let it
/// start again.
void listenAccountNotices(WidgetRef ref) {
  ref.listenManual(accountNoticesProvider, (_, next) {
    final notice = next.value;
    if (notice == null) return;
    final l = currentAppLocalizations;
    dialogs.showNotifier(
      switch (notice) {
        AccountNotice(kind: AccountNoticeKind.resumed) => l.powerNoticeResumed,
        AccountNotice(lock: AccountLock.exhausted) =>
          l.powerNoticeStoppedExhausted,
        _ => l.powerNoticeStoppedExpired,
      },
      level: notice.kind == AccountNoticeKind.resumed
          ? MessageLevel.success
          : MessageLevel.warning,
    );
  });
}
