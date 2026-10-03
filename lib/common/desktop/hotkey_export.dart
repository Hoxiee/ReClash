import 'dart:convert';

import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';

extension DesktopHotAction on HotAction {
  String get desktopAction => switch (this) {
    HotAction.start => 'toggle',
    HotAction.view => 'toggle-window',
    HotAction.mode => 'toggle-mode',
    HotAction.proxy => 'toggle-system-proxy',
    HotAction.tun => 'toggle-tun',
    HotAction.ruleMode => 'mode-rule',
    HotAction.globalMode => 'mode-global',
    HotAction.directMode => 'mode-direct',
    HotAction.delayTest => 'test-delay',
    HotAction.updateProfiles => 'update-profiles',
    HotAction.copyEnv => 'copy-env',
    HotAction.exit => 'quit',
  };

  String desktopCommand(String applicationId) {
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_.-]*$').hasMatch(applicationId)) {
      throw ArgumentError.value(applicationId, 'applicationId');
    }
    return 'gapplication action $applicationId $desktopAction';
  }
}

enum HotkeyExportFormat {
  sway('Sway', 'sway.conf'),
  hyprland('Hyprland', 'hyprland.conf'),
  niri('niri', 'niri.kdl');

  const HotkeyExportFormat(this.label, this.fileName);

  final String label;
  final String fileName;

  String? includeDirective(String directory) {
    final path = '$directory/$fileName';
    if (RegExp(r'[\r\n$#]').hasMatch(path)) return null;
    return switch (this) {
      HotkeyExportFormat.sway ||
      HotkeyExportFormat.niri => 'include ${jsonEncode(path)}',
      HotkeyExportFormat.hyprland => 'source = $path',
    };
  }
}

class HotkeyExport {
  const HotkeyExport({required this.text, this.unsupported = const []});

  final String text;
  final List<HotAction> unsupported;
}

HotkeyExport exportHotkeys({
  required HotkeyExportFormat format,
  required String applicationId,
  required List<HotKeyAction> bindings,
  required Map<int, String> keyNames,
}) {
  final lines = <String>[];
  final unsupported = <HotAction>[];
  for (final binding in bindings) {
    final key = binding.key;
    if (key == null || binding.modifiers.isEmpty) continue;
    final name = keyNames[key];
    if (name == null ||
        !RegExp(r'^[A-Za-z0-9_]+$').hasMatch(name) ||
        binding.modifiers.any(
          (modifier) =>
              modifier == KeyboardModifier.fn ||
              modifier == KeyboardModifier.capsLock,
        )) {
      unsupported.add(binding.action);
      continue;
    }
    final keyName = name.length == 1 ? name.toLowerCase() : name;
    final modifiers = [
      for (final modifier in const [
        KeyboardModifier.control,
        KeyboardModifier.alt,
        KeyboardModifier.shift,
        KeyboardModifier.meta,
      ])
        if (binding.modifiers.contains(modifier))
          _modifierName(format, modifier),
    ];
    final command = binding.action.desktopCommand(applicationId);
    final action = binding.action.desktopAction;
    lines.add(switch (format) {
      HotkeyExportFormat.sway =>
        'bindsym --no-repeat ${[...modifiers, keyName].join('+')} exec $command',
      HotkeyExportFormat.hyprland =>
        'bind = ${modifiers.join(' ')}, $keyName, exec, $command',
      HotkeyExportFormat.niri =>
        '    ${[...modifiers, keyName].join('+')} repeat=false { '
            'spawn "gapplication" "action" "$applicationId" "$action"; }',
    });
  }
  return HotkeyExport(
    text: format == HotkeyExportFormat.niri
        ? 'binds {\n${lines.join('\n')}\n}\n'
        : '${lines.join('\n')}\n',
    unsupported: unsupported,
  );
}

String _modifierName(HotkeyExportFormat format, KeyboardModifier modifier) {
  return switch ((format, modifier)) {
    (HotkeyExportFormat.sway, KeyboardModifier.control) => 'Ctrl',
    (HotkeyExportFormat.sway, KeyboardModifier.alt) => 'Mod1',
    (HotkeyExportFormat.sway, KeyboardModifier.shift) => 'Shift',
    (HotkeyExportFormat.sway, KeyboardModifier.meta) => 'Mod4',
    (HotkeyExportFormat.hyprland, KeyboardModifier.control) => 'CTRL',
    (HotkeyExportFormat.hyprland, KeyboardModifier.alt) => 'ALT',
    (HotkeyExportFormat.hyprland, KeyboardModifier.shift) => 'SHIFT',
    (HotkeyExportFormat.hyprland, KeyboardModifier.meta) => 'SUPER',
    (HotkeyExportFormat.niri, KeyboardModifier.control) => 'Ctrl',
    (HotkeyExportFormat.niri, KeyboardModifier.alt) => 'Alt',
    (HotkeyExportFormat.niri, KeyboardModifier.shift) => 'Shift',
    (HotkeyExportFormat.niri, KeyboardModifier.meta) => 'Super',
    _ => throw ArgumentError.value(modifier, 'modifier'),
  };
}
