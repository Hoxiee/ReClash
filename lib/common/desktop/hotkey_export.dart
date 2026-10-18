import 'dart:convert';

import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';

int? linuxKeyvalForUsage(int usage) {
  return switch (usage) {
    >= 0x00070004 && <= 0x0007001d => 0x61 + usage - 0x00070004,
    >= 0x0007001e && <= 0x00070026 => 0x31 + usage - 0x0007001e,
    0x00070027 => 0x30,
    0x00070028 => 0xff0d,
    0x00070029 => 0xff1b,
    0x0007002a => 0xff08,
    0x0007002b => 0xff09,
    0x0007002c => 0x20,
    0x0007002d => 0x2d,
    0x0007002e => 0x3d,
    0x0007002f => 0x5b,
    0x00070030 => 0x5d,
    0x00070031 => 0x5c,
    0x00070033 => 0x3b,
    0x00070034 => 0x27,
    0x00070035 => 0x60,
    0x00070036 => 0x2c,
    0x00070037 => 0x2e,
    0x00070038 => 0x2f,
    0x00070039 => 0xffe5,
    >= 0x0007003a && <= 0x00070045 => 0xffbe + usage - 0x0007003a,
    0x00070046 => 0xff61,
    0x00070047 => 0xff14,
    0x00070048 => 0xff13,
    0x00070049 => 0xff63,
    0x0007004a => 0xff50,
    0x0007004b => 0xff55,
    0x0007004c => 0xffff,
    0x0007004d => 0xff57,
    0x0007004e => 0xff56,
    0x0007004f => 0xff53,
    0x00070050 => 0xff51,
    0x00070051 => 0xff54,
    0x00070052 => 0xff52,
    0x00070053 => 0xff7f,
    0x00070054 => 0xffaf,
    0x00070055 => 0xffaa,
    0x00070056 => 0xffad,
    0x00070057 => 0xffab,
    0x00070058 => 0xff8d,
    >= 0x00070059 && <= 0x00070061 => 0xffb1 + usage - 0x00070059,
    0x00070062 => 0xffb0,
    0x00070063 => 0xffae,
    0x00070065 => 0xff67,
    0x00070067 => 0xffbd,
    >= 0x00070068 && <= 0x00070073 => 0xffca + usage - 0x00070068,
    _ => null,
  };
}

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
