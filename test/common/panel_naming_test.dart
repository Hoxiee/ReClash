import 'dart:convert';

import 'package:reclash/common/panel_naming.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decodePanelTitle', () {
    test('decodes the base64-prefixed form', () {
      expect(decodePanelTitle('base64:UmVtbmF3YXZl'), 'Remnawave');
    });

    test('accepts a comma after the prefix', () {
      expect(decodePanelTitle('base64,UmVtbmF3YXZl'), 'Remnawave');
    });

    test('keeps plain text as is', () {
      expect(decodePanelTitle('My Service'), 'My Service');
    });

    test('falls back to raw text on broken payloads', () {
      expect(decodePanelTitle('base64:!!!!'), 'base64:!!!!');
    });

    test('decodes utf-8 payloads', () {
      final encoded = base64Encode(utf8.encode('Сервис'));
      expect(decodePanelTitle('base64:$encoded'), 'Сервис');
    });
  });

  group('isGenericPanelTitle', () {
    test('rejects default panel titles', () {
      for (final value in [
        'Remnawave',
        'subscription',
        'Subscription',
        'subscription.json',
        'subscription.yaml',
        'profile',
        'support',
      ]) {
        expect(isGenericPanelTitle(value), isTrue, reason: value);
      }
    });

    test('rejects telegram channel pointers', () {
      for (final value in [
        '@channelname',
        't.me/channelname',
        'https://t.me/channelname',
        'https://telegram.me/channelname',
      ]) {
        expect(isGenericPanelTitle(value), isTrue, reason: value);
      }
    });

    test('accepts real names', () {
      expect(isGenericPanelTitle('My VPN'), isFalse);
      expect(isGenericPanelTitle(null), isTrue);
      expect(isGenericPanelTitle(''), isTrue);
    });
  });

  group('isAccountUsername', () {
    test('matches tg-provisioned usernames', () {
      expect(isAccountUsername('550704498_s07ef90'), isTrue);
      expect(isAccountUsername('550704498-s07ef90'), isTrue);
      expect(isAccountUsername('123456_abcd'), isTrue);
    });

    test('rejects normal names and ids', () {
      expect(isAccountUsername('My VPN'), isFalse);
      expect(isAccountUsername('42'), isFalse);
      expect(isAccountUsername(null), isFalse);
      expect(isAccountUsername('abcdef_ghijkl'), isFalse);
    });
  });

  group('PanelKind.detect', () {
    test('detects by host', () {
      expect(PanelKind.detect('panel.remnawave.app', {}), PanelKind.remnawave);
      expect(PanelKind.detect('sub.marzban.io', {}), PanelKind.marzban);
      expect(PanelKind.detect('marzneshin.example.com', {}), PanelKind.marzneshin);
      expect(PanelKind.detect('panel.3x-ui.host', {}), PanelKind.threeXui);
      expect(PanelKind.detect('x-ui.example.com', {}), PanelKind.threeXui);
      expect(PanelKind.detect('subconverter.example.dev', {}), PanelKind.subconverter);
      expect(PanelKind.detect('plain.host', {}), PanelKind.other);
    });

    test('detects remnawave by wire headers', () {
      expect(
        PanelKind.detect('sub.example.com', {
          'x-hwid-active': ['true'],
        }),
        PanelKind.remnawave,
      );
    });

    test('detects 3x-ui by base64d announce', () {
      expect(
        PanelKind.detect('sub.example.com', {
          'x-hwid-not-supported': ['true'],
          'announce': ['base64:YW5ub3VuY2U='],
        }),
        PanelKind.threeXui,
      );
    });
  });

  group('ProfileNaming.fromResponse', () {
    ProfileNaming name({
      String? host = 'sub.example.com',
      Map<String, List<String>> headers = const {},
      String? title,
      String? filename,
    }) {
      return ProfileNaming.fromResponse(
        headers: headers,
        host: host,
        profileTitle: title,
        dispositionFilename: filename,
      );
    }

    test('prefixed panel username becomes "service (tg_id-sub-id)"', () {
      final naming = name(
        host: 'panel.remnawave.app',
        filename: '550704498_s07ef90',
      );
      expect(naming.label, 'Remnawave (550704498_s07ef90)');
      expect(naming.serviceName, 'Remnawave');
      expect(naming.username, '550704498_s07ef90');
    });

    test('generic profile-title falls through to the username', () {
      final naming = name(
        host: 'panel.marzban.io',
        title: 'base64:U3Vic2NyaXB0aW9u',
        filename: '550704498_s07ef90',
      );
      expect(naming.label, 'Marzban (550704498_s07ef90)');
    });

    test('a real profile-title wins', () {
      final naming = name(
        host: 'panel.marzban.io',
        title: 'base64:TXkgVk4=',
        filename: '550704498_s07ef90',
      );
      expect(naming.label, 'My VN');
    });

    test('a plain username without a known panel stays as is', () {
      final naming = name(filename: '550704498_s07ef90');
      expect(naming.label, '550704498_s07ef90');
      expect(naming.serviceName, isNull);
    });

    test('a human filename stays as is', () {
      final naming = name(host: 'panel.3x-ui.host', filename: 'My Sub');
      expect(naming.label, 'My Sub');
    });

    test('the 3x-ui clash-route filename is used', () {
      final naming = name(host: 'panel.3x-ui.host', filename: 'Best Panel');
      expect(naming.label, 'Best Panel');
    });

    test('username title also composes with the service name', () {
      final naming = name(
        host: 'panel.remnawave.app',
        title: '550704498_s07ef90',
      );
      expect(naming.label, 'Remnawave (550704498_s07ef90)');
    });

    test('telegram handle titles are dropped for the username', () {
      final naming = name(
        host: 'panel.remnawave.app',
        title: '@channelname',
        filename: '550704498_s07ef90',
      );
      expect(naming.label, 'Remnawave (550704498_s07ef90)');
    });

    test('nothing usable yields a null label', () {
      final naming = name(title: 'subscription', filename: 'subscription.json');
      expect(naming.label, isNull);
    });
  });
}
