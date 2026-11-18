import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/views/site_lock_editor.dart';

void main() {
  group('normalizeSiteLockEntries', () {
    test('turns bare hosts into domain suffixes', () {
      expect(
        normalizeSiteLockEntries('ChatGPT.com\n*.openai.com\n.oaistatic.com'),
        [
          'DOMAIN-SUFFIX,chatgpt.com',
          'DOMAIN-SUFFIX,openai.com',
          'DOMAIN-SUFFIX,oaistatic.com',
        ],
      );
    });

    test('uppercases the rule type and trims around the comma', () {
      expect(
        normalizeSiteLockEntries('geosite, openai\n IP-CIDR ,1.2.3.0/24'),
        ['GEOSITE,openai', 'IP-CIDR,1.2.3.0/24'],
      );
    });

    test('completes addresses and tells the families apart', () {
      expect(
        normalizeSiteLockEntries('1.2.3.4\n10.0.0.0/8\n2001:db8::1\n::1/128'),
        [
          'IP-CIDR,1.2.3.4/32',
          'IP-CIDR,10.0.0.0/8',
          'IP-CIDR6,2001:db8::1/128',
          'IP-CIDR6,::1/128',
        ],
      );
    });

    test('drops blanks and duplicates and keeps the order', () {
      expect(
        normalizeSiteLockEntries('\n b.com \n\na.com\nDOMAIN-SUFFIX,b.com\n'),
        ['DOMAIN-SUFFIX,b.com', 'DOMAIN-SUFFIX,a.com'],
      );
    });

    test('reads the geosite: shorthand', () {
      expect(normalizeSiteLockEntries('geosite:openai'), ['GEOSITE,openai']);
    });

    test('leaves what it cannot read for the core to report', () {
      expect(normalizeSiteLockEntries('not a host\n*.\nopenai'), [
        'not a host',
        '*.',
        'openai',
      ]);
    });
  });
}
