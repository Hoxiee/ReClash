import 'package:reclash/common/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolRegistrationPlan', () {
    test('separates the app ProgID from the shared scheme key', () {
      const plan = ProtocolRegistrationPlan(
        scheme: 'reclash',
        executable: r'C:\Program Files\ReClash\ReClash.exe',
      );
      expect(plan.protocolKey, r'Software\Classes\reclash');
      expect(plan.progIdKey, r'Software\Classes\ReClash.Url.reclash');
      expect(plan.applicationKey, r'Software\ReClash\UrlHandler');
      expect(plan.commandKey, r'shell\open\command');
      expect(plan.protocolValueName, 'URL Protocol');
      expect(plan.protocolValue, '');
      expect(plan.command, r'"C:\Program Files\ReClash\ReClash.exe" "%1"');
    });

    test('claims defaults only for Clash configuration schemes', () {
      for (final scheme in protocolSchemes) {
        final plan = ProtocolRegistrationPlan(
          scheme: scheme,
          executable: 'ReClash.exe',
        );
        expect(
          plan.claimsDefault,
          configProtocolSchemes.contains(scheme),
          reason: scheme,
        );
        expect(plan.progId, 'ReClash.Url.$scheme');
      }
    });
  });

  group('LinuxProtocolRegistrationPlan', () {
    const plan = LinuxProtocolRegistrationPlan(
      schemes: protocolSchemes,
      executable: '/home/me/Apps/ReClash.AppImage',
      applicationsDir: '/home/me/.local/share/applications',
    );

    test('advertises every supported scheme without becoming a visible app', () {
      expect(
        plan.desktopPath,
        '/home/me/.local/share/applications/reclash-url-handler.desktop',
      );
      expect(
        plan.desktopEntry,
        '[Desktop Entry]\nType=Application\nName=ReClash\n'
        'NoDisplay=true\nExec="/home/me/Apps/ReClash.AppImage" %u\n'
        'MimeType=${protocolSchemes.map((s) => 'x-scheme-handler/$s').join(';')};\n',
      );
    });

    test('sets defaults for config schemes but not third-party links', () {
      expect(plan.xdgMimeArguments, [
        'default',
        'reclash-url-handler.desktop',
        for (final scheme in configProtocolSchemes) 'x-scheme-handler/$scheme',
      ]);
      for (final scheme in [
        ...deepLinkProtocolSchemes,
        ...shareProtocolSchemes,
      ]) {
        expect(plan.mimeTypes, contains('x-scheme-handler/$scheme'));
        expect(
          plan.xdgMimeArguments,
          isNot(contains('x-scheme-handler/$scheme')),
        );
      }
    });

    test('escapes reserved characters in the executable path', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['reclash'],
        executable: r'/opt/my "apps"/$HOME/100%/Re`Clash\bin',
        applicationsDir: '/tmp',
      );
      expect(plan.exec, r'"/opt/my \"apps\"/\$HOME/100%%/Re\`Clash\\bin" %u');
    });
  });

  test('registered schemes are unique and cover all import families', () {
    expect(protocolSchemes.toSet(), hasLength(protocolSchemes.length));
    expect(
      protocolSchemes,
      containsAll([
        'reclash',
        'clash',
        'clashmeta',
        'incy',
        'happ',
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
      ]),
    );
  });
}
