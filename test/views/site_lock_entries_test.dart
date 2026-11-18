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
          'IP-CIDR,1.2.3.4/32,no-resolve',
          'IP-CIDR,10.0.0.0/8,no-resolve',
          'IP-CIDR6,2001:db8::1/128,no-resolve',
          'IP-CIDR6,::1/128,no-resolve',
        ],
      );
    });

    test('drops blanks and duplicates and keeps the order', () {
      expect(
        normalizeSiteLockEntries('\n b.com \n\na.com\nDOMAIN-SUFFIX,b.com\n'),
        ['DOMAIN-SUFFIX,b.com', 'DOMAIN-SUFFIX,a.com'],
      );
    });

    test('keeps only the host of a pasted address', () {
      expect(
        normalizeSiteLockEntries(
          'https://Chat.OpenAI.com/c/1?x=1\n'
          'http://user@claude.ai:8443\n'
          'https://[2001:db8::1]:443/\n'
          'https://203.0.113.7/path',
        ),
        [
          'DOMAIN-SUFFIX,chat.openai.com',
          'DOMAIN-SUFFIX,claude.ai',
          'IP-CIDR6,2001:db8::1/128,no-resolve',
          'IP-CIDR,203.0.113.7/32,no-resolve',
        ],
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
