import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

import '../util/print.dart';

const configProtocolSchemes = ['clash', 'clashmeta', 'reclash'];

const deepLinkProtocolSchemes = ['incy', 'happ'];

const shareProtocolSchemes = [
  'vmess',
  'vless',
  'ss',
  'ssr',
  'trojan',
  'hysteria',
  'hysteria2',
  'hy2',
  'tuic',
  'anytls',
];

const androidProtocolHosts = <String, List<String>>{
  'clash': ['install-config'],
  'clashmeta': ['install-config'],
  'reclash': [
    'install-config',
    'connect',
    'disconnect',
    'toggle',
    'open',
    'close',
    'import',
    'add',
  ],
  'incy': ['crypt1', 'add', 'import'],
  'happ': ['add'],
};

const protocolSchemes = [...configProtocolSchemes, ...deepLinkProtocolSchemes];

const allProtocolSchemes = [...protocolSchemes, ...shareProtocolSchemes];

class ProtocolRegistrationPlan {
  final String scheme;
  final String executable;

  const ProtocolRegistrationPlan({
    required this.scheme,
    required this.executable,
  });

  String get protocolKey => 'Software\\Classes\\$scheme';

  String get commandKey => 'shell\\open\\command';

  String get protocolValueName => 'URL Protocol';

  String get protocolValue => '';

  String get command => '"$executable" "%1"';
}

/// A user-level desktop entry that claims the schemes for the running binary,
/// so an AppImage or a development build is reachable without a packaged
/// .desktop file. Rewritten on every launch, like the Windows registry keys.
class LinuxProtocolRegistrationPlan {
  final List<String> schemes;

  /// Forced as the handler, so only schemes ours by name belong here.
  final List<String> defaults;

  final String executable;
  final String applicationsDir;

  const LinuxProtocolRegistrationPlan({
    required this.schemes,
    required this.defaults,
    required this.executable,
    required this.applicationsDir,
  });

  String get desktopId => 'reclash-url-handler.desktop';

  String get desktopPath => '$applicationsDir/$desktopId';

  List<String> get mimeTypes => schemes.map(_mimeType).toList();

  String get exec => '"${_quoteExecArgument(executable)}" %u';

  String get desktopEntry => [
    '[Desktop Entry]',
    'Type=Application',
    'Name=ReClash',
    'NoDisplay=true',
    'Exec=$exec',
    'MimeType=${mimeTypes.join(';')};',
    '',
  ].join('\n');

  List<String> get xdgMimeArguments => [
    'default',
    desktopId,
    ...defaults.map(_mimeType),
  ];

  static String _mimeType(String scheme) => 'x-scheme-handler/$scheme';

  static String _quoteExecArgument(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll(r'$', r'\$')
        .replaceAll('`', r'\`')
        .replaceAll('%', '%%');
  }
}

class Protocol {
  static Protocol? _instance;

  Protocol._internal();

  factory Protocol() {
    _instance ??= Protocol._internal();
    return _instance!;
  }

  void register(String scheme) {
    final plan = ProtocolRegistrationPlan(
      scheme: scheme,
      executable: Platform.resolvedExecutable,
    );
    final regKey = CURRENT_USER.create(plan.protocolKey);
    try {
      regKey.setValue(
        plan.protocolValueName,
        RegistryValue.string(plan.protocolValue),
      );
      final commandKey = regKey.create(plan.commandKey);
      try {
        commandKey.setValue('', RegistryValue.string(plan.command));
      } finally {
        commandKey.close();
      }
    } finally {
      regKey.close();
    }
  }

  Future<void> registerLinux({
    required List<String> schemes,
    required List<String> defaults,
  }) async {
    final env = Platform.environment;
    final home = env['HOME'];
    if (home == null || home.isEmpty) {
      return;
    }
    final dataHome = env['XDG_DATA_HOME'];
    final plan = LinuxProtocolRegistrationPlan(
      schemes: schemes,
      defaults: defaults,
      executable: env['APPIMAGE'] ?? Platform.resolvedExecutable,
      applicationsDir:
          '${dataHome?.isNotEmpty == true ? dataHome : '$home/.local/share'}/applications',
    );
    final file = File(plan.desktopPath);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(plan.desktopEntry);
    } catch (e) {
      commonPrint.log('linux protocol registration failed: $e');
      return;
    }
    await _run('xdg-mime', plan.xdgMimeArguments);
    // Schemes we advertise without claiming stay inert until the cache sees them.
    await _run('update-desktop-database', [file.parent.path]);
  }

  Future<void> _run(String executable, List<String> arguments) async {
    try {
      final result = await Process.run(executable, arguments);
      if (result.exitCode != 0) {
        commonPrint.log('$executable failed: ${result.stderr}'.trim());
      }
    } catch (e) {
      commonPrint.log('$executable is unavailable: $e');
    }
  }
}

final protocol = Protocol();
