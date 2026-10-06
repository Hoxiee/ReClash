import 'package:flutter/widgets.dart' show Widget;
import 'package:reclash/enum/enum.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/nav_path.g.dart';

/// One level of a tab's logical navigation path. A level is data, not widget
/// state, so the path survives a layout-breakpoint crossing (phone <-> desktop)
/// instead of being torn down with the renderer that happened to own it.
class NavPaneEntry {
  const NavPaneEntry({
    required this.id,
    required this.detail,
    this.title,
    this.focusTarget,
    this.focusNonce = 0,
  });

  final String id;
  final Widget detail;
  final Widget? title;
  final String? focusTarget;

  /// Bumped only when a re-selection carries a [focusTarget], so the renderer
  /// can re-pulse the same pane without a key change tearing its element down.
  final int focusNonce;
}

/// A per-tab stack of [NavPaneEntry]: the single source of truth for how deep a
/// tab is drilled. Renderers lay the same stack out their own way (full-screen
/// pages on a phone, a list/detail column with breadcrumbs on desktop), so a
/// resize re-renders the path in place rather than resetting it.
@Riverpod(keepAlive: true)
class NavPath extends _$NavPath {
  int _focusSeq = 0;

  @override
  List<NavPaneEntry> build(PageLabel tab) {
    return const [];
  }

  int _nonce(String? focusTarget) => focusTarget == null ? 0 : ++_focusSeq;

  NavPaneEntry _entry(SettingsPaneSelection selection) {
    return NavPaneEntry(
      id: selection.id,
      detail: selection.detail,
      title: selection.title,
      focusTarget: selection.focusTarget,
      focusNonce: _nonce(selection.focusTarget),
    );
  }

  /// Replaces the whole path with [selection] as its root. A re-selection of
  /// the current root without a focus target is a no-op, so a stray re-tap does
  /// not collapse a drilled stack.
  void selectRoot(SettingsPaneSelection selection) {
    final sameRoot = state.length == 1 && state.first.id == selection.id;
    if (sameRoot && selection.focusTarget == null) {
      return;
    }
    state = [_entry(selection)];
  }

  /// Pushes a level, or re-targets the current top in place (same id) so its
  /// element survives with the actions it relayed to the shared bar.
  void push(SettingsPaneSelection selection) {
    final sameTop = state.isNotEmpty && state.last.id == selection.id;
    if (sameTop && selection.focusTarget == null) {
      return;
    }
    final entry = _entry(selection);
    state = sameTop
        ? [...state.sublist(0, state.length - 1), entry]
        : [...state, entry];
  }

  void pop() {
    if (state.length <= 1) {
      return;
    }
    state = state.sublist(0, state.length - 1);
  }

  void popToDepth(int depth) {
    if (depth < 1 || depth >= state.length) {
      return;
    }
    state = state.sublist(0, depth);
  }

  void clear() {
    state = const [];
  }
}
