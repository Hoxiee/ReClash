import 'package:test/test.dart';

import '../../tool/check_format.dart';

void main() {
  test(
    'format gate covers source and tests without rewriting generated output',
    () {
      for (final path in [
        'lib/ui/list.dart',
        'test/tool/fork_sync_test.dart',
        'plugins/window/lib/window.dart',
        'setup.dart',
      ]) {
        expect(isHandwrittenDart(path), isTrue, reason: path);
      }
      for (final path in [
        'lib/l10n/l10n.dart',
        'lib/l10n/intl/messages_en.dart',
        'upstream_l10n/intl/messages_en.dart',
        'lib/providers/generated/action.g.dart',
        'lib/models/profile.freezed.dart',
        'plugins/rust_api/lib/frb_generated.dart',
        'lib/config.yaml',
      ]) {
        expect(isHandwrittenDart(path), isFalse, reason: path);
      }
    },
  );
}
