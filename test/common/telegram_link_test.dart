import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/telegram_link.dart';

void main() {
  test('keeps Telegram HTTPS destinations and their query parameters', () {
    final link = TelegramLink.tryParse(
      'https://t.me/example_bot?start=campaign&param=keep',
    );
    expect(
      link?.uri.toString(),
      'https://t.me/example_bot?start=campaign&param=keep',
    );
    expect(link?.destination, 'example_bot');
    expect(link?.webFallback, link?.uri);
  });

  test('converts resolvable tg links without losing parameters', () {
    final resolve = TelegramLink.tryParse(
      'tg://resolve?domain=example_bot&start=campaign&startgroup=group',
    );
    expect(
      resolve?.webFallback.toString(),
      'https://t.me/example_bot?start=campaign&startgroup=group',
    );
    final join = TelegramLink.tryParse('tg://join?invite=Abc_123');
    expect(join?.webFallback.toString(), 'https://t.me/+Abc_123');
  });

  test('rejects malformed or non-Telegram destinations', () {
    expect(TelegramLink.tryParse('https://example.com/path'), isNull);
    expect(TelegramLink.tryParse('https://t.me@evil.example/path'), isNull);
    expect(TelegramLink.tryParse('tg://resolve?domain=bad/path'), isNull);
    expect(TelegramLink.tryParse('tg://resolve?domain=one&domain=two'), isNull);
    expect(TelegramLink.tryParse('javascript:alert(1)'), isNull);
  });
}
