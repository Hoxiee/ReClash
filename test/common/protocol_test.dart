import 'package:reclash/common/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolRegistrationPlan', () {
    test('builds registry writes for URL protocol registration', () {
      const plan = ProtocolRegistrationPlan(
        scheme: 'reclash',
        executable: r'C:\Program Files\ReClash\ReClash.exe',
      );

      expect(plan.protocolKey, r'Software\Classes\reclash');
      expect(plan.commandKey, r'shell\open\command');
      expect(plan.protocolValueName, 'URL Protocol');
      expect(plan.protocolValue, '');
      expect(plan.command, r'"C:\Program Files\ReClash\ReClash.exe" "%1"');
    });
  });

  group('LinuxProtocolRegistrationPlan', () {
    const plan = LinuxProtocolRegistrationPlan(
      schemes: ['clash', 'reclash', 'vless'],
      defaults: ['clash', 'reclash'],
      executable: '/home/me/Apps/ReClash.AppImage',
      applicationsDir: '/home/me/.local/share/applications',
    );

    test('writes a hidden desktop entry advertising every scheme', () {
      expect(
        plan.desktopPath,
        '/home/me/.local/share/applications/reclash-url-handler.desktop',
      );
      expect(
        plan.desktopEntry,
        '[Desktop Entry]\n'
        'Type=Application\n'
        'Name=ReClash\n'
        'NoDisplay=true\n'
        'Exec="/home/me/Apps/ReClash.AppImage" %u\n'
        'MimeType=x-scheme-handler/clash;x-scheme-handler/reclash;'
        'x-scheme-handler/vless;\n',
      );
    });

    test('takes the default handler only for the schemes it owns', () {
      expect(plan.xdgMimeArguments, [
        'default',
        'reclash-url-handler.desktop',
        'x-scheme-handler/clash',
        'x-scheme-handler/reclash',
      ]);
    });

    test('escapes reserved characters in the executable path', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['reclash'],
        defaults: ['reclash'],
        executable: r'/opt/my "apps"/$HOME/100%/Re`Clash\bin',
        applicationsDir: '/tmp',
      );

      expect(plan.exec, r'"/opt/my \"apps\"/\$HOME/100%%/Re\`Clash\\bin" %u');
    });
  });
}
