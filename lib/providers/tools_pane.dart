import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/tools_pane.g.dart';

/// A one-shot handoff: any surface asks the Tools tab to open a pane stack. The
/// first entry is the root, the rest are pushed on top, so a caller can land
/// the reader a few steps deep with a back-path. The Tools view consumes the
/// request on its next build and clears it, so a return trip does not reopen
/// the panes on its own; a view too narrow for the two-pane stack drops it.
@Riverpod(keepAlive: true)
class ToolsPaneRequest extends _$ToolsPaneRequest
    with AutoDisposeNotifierMixin {
  @override
  List<SettingsPaneSelection>? build() {
    return null;
  }

  void request(List<SettingsPaneSelection> stack) {
    state = stack;
  }

  void clear() {
    state = null;
  }
}
