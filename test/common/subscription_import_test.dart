import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';

void main() {
  group('resolveSubscriptionImport', () {
    test('accepts and normalizes HTTP subscription URLs', () async {
      final target = await resolveSubscriptionImport(
        ' https://github.com/owner/repo/blob/main/config.yaml ',
      );

      expect(
        target?.url,
        'https://raw.githubusercontent.com/owner/repo/main/config.yaml',
      );
      expect(target?.client, SubscriptionClient.auto);
      expect(target?.localContent, isNull);
    });

    test('rejects credentials and non-HTTP URLs', () async {
      expect(
        await resolveSubscriptionImport('https://user@example.com/sub'),
        isNull,
      );
      expect(await resolveSubscriptionImport('ftp://example.com/sub'), isNull);
      expect(await resolveSubscriptionImport('not a URL'), isNull);
    });

    test('keeps share links separate from URL imports', () async {
      final target = await resolveSubscriptionImport(
        'vless://id@host:443#node',
      );

      expect(target?.url, isEmpty);
      expect(target?.localContent, isNotEmpty);
    });
  });
}
