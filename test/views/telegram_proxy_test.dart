import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/telegram_proxy.dart';

void main() {
  test('Core knows the value that picks the profile rules', () {
    expect(
      File('core/telegram_proxy.go').readAsStringSync(),
      contains('telegramOutboundRules = "$telegramProxyOutboundRules"'),
    );
    expect(const TelegramProxyProps().outbound, isEmpty);
  });

  test('the link carries the padded-intermediate marker and the secret', () {
    const props = TelegramProxyProps(port: 1443, secret: 'ab12');
    expect(
      telegramProxyLink(props),
      'tg://proxy?server=127.0.0.1&port=1443&secret=ddab12',
    );
  });

  group('a data center merges its regular and media connections', () {
    const idle = TelegramProxyDc(dc: 2);
    const failed = TelegramProxyDc(dc: -2, route: 'unavailable');
    const direct = TelegramProxyDc(dc: 2, route: 'websocket');

    test('with no connection it reports nothing', () {
      expect(mergeTelegramProxyDc(1, const [direct]), isNull);
    });

    test('a working route outranks a failed one', () {
      expect(mergeTelegramProxyDc(2, const [failed, direct]), direct);
    });

    test('a failure outranks an idle connection', () {
      expect(mergeTelegramProxyDc(2, const [idle, failed]), failed);
    });
  });
}
