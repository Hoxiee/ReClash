import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/tools.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/tools.g.dart';

class ToolsState {
  const ToolsState({
    this.path = const [],
    this.query = '',
    this.focusNonce = 0,
    this.searchNonce = 0,
    this.pinned = const [],
    this.pendingCommand,
  });

  final List<ToolRoute> path;
  final String query;
  final int focusNonce;
  final int searchNonce;
  final List<String> pinned;
  final ToolCommand? pendingCommand;

  ToolsState copyWith({
    List<ToolRoute>? path,
    String? query,
    int? focusNonce,
    int? searchNonce,
    List<String>? pinned,
    ToolCommand? pendingCommand,
    bool clearCommand = false,
  }) => ToolsState(
    path: path ?? this.path,
    query: query ?? this.query,
    focusNonce: focusNonce ?? this.focusNonce,
    searchNonce: searchNonce ?? this.searchNonce,
    pinned: pinned ?? this.pinned,
    pendingCommand: clearCommand ? null : pendingCommand ?? this.pendingCommand,
  );
}

@Riverpod(keepAlive: true)
class ToolsSession extends _$ToolsSession {
  var _loaded = false;
  final _pendingPins = <String>[];
  Future<void> _save = Future.value();

  @override
  ToolsState build() {
    unawaited(_load());
    return const ToolsState();
  }

  Future<void> _load() async {
    final saved = await preferences.getPinnedTools();
    if (!ref.mounted) return;
    final pinned = [...saved];
    for (final id in _pendingPins) {
      if (!pinned.remove(id)) pinned.add(id);
    }
    state = state.copyWith(pinned: List.unmodifiable(pinned));
    _pendingPins.clear();
    _loaded = true;
    _persist();
  }

  void requestCommand(ToolCommand command) =>
      state = state.copyWith(pendingCommand: command);

  ToolCommand? takeCommand() {
    final command = state.pendingCommand;
    if (command != null) state = state.copyWith(clearCommand: true);
    return command;
  }

  void search(String query) => state = state.copyWith(query: query);

  void focusSearch() =>
      state = state.copyWith(searchNonce: state.searchNonce + 1);

  void open(ToolRoute route, {bool push = false}) {
    final path = state.path;
    final same = path.isNotEmpty && path.last.page == route.page;
    state = state.copyWith(
      path: List.unmodifiable(
        same
            ? [...path.take(path.length - 1), route]
            : push
            ? [...path, route]
            : [for (final page in route.page.ancestors) ToolRoute(page), route],
      ),
      focusNonce: state.focusNonce + 1,
    );
  }

  void pop() {
    if (state.path.isEmpty) return;
    state = state.copyWith(
      path: List.unmodifiable(state.path.take(state.path.length - 1)),
    );
  }

  void popTo(int depth) {
    if (depth < 0 || depth >= state.path.length) return;
    state = state.copyWith(path: List.unmodifiable(state.path.take(depth)));
  }

  void togglePin(String id) {
    if (!_loaded) _pendingPins.add(id);
    state = state.copyWith(
      pinned: state.pinned.contains(id)
          ? state.pinned.where((item) => item != id).toList()
          : [...state.pinned, id],
    );
    _persist();
  }

  void _persist() {
    if (!_loaded) return;
    final pinned = state.pinned;
    _save = _save
        .catchError((Object _) {})
        .then((_) => preferences.savePinnedTools(pinned));
    unawaited(
      _save.catchError((Object error) {
        commonPrint.log('Tools pins: $error');
      }),
    );
  }
}
