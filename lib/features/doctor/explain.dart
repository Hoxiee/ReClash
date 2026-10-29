import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';

import 'cause.dart';
import 'kernel.dart';

/// Set by the app shell: the doctor sheet lives in the view tree, which
/// the error paths here must not import.
void Function(FailureCause cause)? openDoctorOnCause;

/// "Why?" on an error snackbar, offered only when the doctor can name the
/// cause; it opens the doctor on that cause and its fix.
MessageActionState? explainAction(Object error) {
  final cause = failureCauseOf(error);
  final open = openDoctorOnCause;
  if (cause == FailureCause.unknown || open == null) return null;
  return MessageActionState(
    actionText: currentAppLocalizations.doctorWhy,
    action: () => open(cause),
  );
}
