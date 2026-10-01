/// Search metadata an author co-locates on a settings row. Its presence is the
/// only signal that marks the row searchable; the generator reuses the row's own
/// `title:`/`label:` for the text and bakes [gate] as a token. Const only.
class SettingSearch {
  const SettingSearch({
    this.keywords = const [],
    this.gate = SettingGate.always,
  });

  final List<String> keywords;
  final SettingGate gate;
}

/// Conditions the generator can bake and the runtime can evaluate.
enum SettingGate {
  always,
  byeDpi,
  developerMode,
  android,
  desktop,
  mobile,
  windows,
  macos,
  linux,
}
