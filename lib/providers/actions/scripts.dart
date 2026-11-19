part of '../action.dart';

@Riverpod(keepAlive: true)
class ScriptsAction extends _$ScriptsAction {
  @override
  void build() {}

  void putScript(Script script) {
    ref.read(scriptsProvider.notifier).put(script);
    _applyIfInUse(script.id);
  }

  Future<void> updateScript(Script script) async {
    final updatingKeys = ref.read(updatingKeysProvider.notifier);
    final operation = updatingKeys.start(script.updatingKey);
    try {
      putScript(await script.update());
    } finally {
      updatingKeys.stop(script.updatingKey, operation);
    }
  }

  void deleteScript(int id) {
    final inUse = _isInUse(id);
    ref.read(scriptsProvider.notifier).del(id);
    if (inUse) _applyProfile();
  }

  bool _isInUse(int scriptId) {
    final profile = ref.read(currentProfileProvider);
    return profile?.extendType == ExtendType.script &&
        profile?.scriptId == scriptId;
  }

  void _applyIfInUse(int scriptId) {
    if (_isInUse(scriptId)) _applyProfile();
  }

  void _applyProfile() {
    ref.read(setupActionProvider.notifier).applyProfileDebounce(silence: true);
  }
}
