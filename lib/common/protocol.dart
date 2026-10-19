import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

import 'constant.dart' show shareLinkSchemes;
import 'print.dart';

const configProtocolSchemes = ['clash', 'clashmeta', 'reclash'];
const deepLinkProtocolSchemes = ['incy', 'happ'];
const shareProtocolSchemes = [...shareLinkSchemes];
const protocolSchemes = [
  ...configProtocolSchemes,
  ...deepLinkProtocolSchemes,
  ...shareProtocolSchemes,
];

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

  String get applicationKey => r'Software\ReClash\UrlHandler';

  String get progId => 'ReClash.Url.$scheme';

  String get progIdKey => 'Software\\Classes\\$progId';

  bool get claimsDefault => configProtocolSchemes.contains(scheme);
}

/// AppImages also need a desktop entry to appear among available handlers.
class LinuxProtocolRegistrationPlan {
  final List<String> schemes;
  final List<String> defaults;
  final String executable;
  final String applicationsDir;

  const LinuxProtocolRegistrationPlan({
    required this.schemes,
    this.defaults = configProtocolSchemes,
    required this.executable,
    required this.applicationsDir,
  });

  String get desktopId => 'reclash-url-handler.desktop';

  String get desktopPath => '$applicationsDir/$desktopId';

  List<String> get mimeTypes =>
      schemes.map((scheme) => 'x-scheme-handler/$scheme').toList();

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
    ...defaults.map((scheme) => 'x-scheme-handler/$scheme'),
  ];

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
    final application = CURRENT_USER.create(plan.applicationKey);
    try {
      application.setValue(
        'ApplicationName',
        const RegistryValue.string('ReClash'),
      );
      final associations = application.create('URLAssociations');
      try {
        associations.setValue(scheme, RegistryValue.string(plan.progId));
      } finally {
        associations.close();
      }
    } finally {
      application.close();
    }
    final registered = CURRENT_USER.create(r'Software\RegisteredApplications');
    try {
      registered.setValue('ReClash', RegistryValue.string(plan.applicationKey));
    } finally {
      registered.close();
    }
    final regKey = CURRENT_USER.create(plan.progIdKey);
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
    final choices = CURRENT_USER.create('${plan.protocolKey}\\OpenWithProgids');
    try {
      choices.setValue(plan.progId, const RegistryValue.none());
    } finally {
      choices.close();
    }
    if (plan.claimsDefault) {
      final key = CURRENT_USER.create(plan.protocolKey);
      try {
        key.setValue(plan.protocolValueName, const RegistryValue.string(''));
        final command = key.create(plan.commandKey);
        try {
          command.setValue('', RegistryValue.string(plan.command));
        } finally {
          command.close();
        }
      } finally {
        key.close();
      }
    }
  }

  Future<void> registerLinux(List<String> schemes) async {
    final env = Platform.environment;
    final home = env['HOME'];
    if (home == null || home.isEmpty) {
      return;
    }
    final dataHome = env['XDG_DATA_HOME'];
    final plan = LinuxProtocolRegistrationPlan(
      schemes: schemes,
      executable: env['APPIMAGE'] ?? Platform.resolvedExecutable,
      applicationsDir:
          '${dataHome?.isNotEmpty == true ? dataHome : '$home/.local/share'}/applications',
    );
    try {
      final file = File(plan.desktopPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(plan.desktopEntry);
      await _run('xdg-mime', plan.xdgMimeArguments);
      await _run('update-desktop-database', [file.parent.path]);
    } catch (e) {
      commonPrint.log('linux protocol registration failed: $e');
    }
  }

  Future<void> _run(String executable, List<String> arguments) async {
    try {
      final result = await Process.run(executable, arguments);
      if (result.exitCode != 0) commonPrint.log('$executable failed');
    } catch (_) {
      commonPrint.log('$executable is unavailable');
    }
  }
}

final protocol = Protocol();
