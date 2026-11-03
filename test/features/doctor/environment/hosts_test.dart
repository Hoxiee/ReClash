import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/environment/domains.dart';
import 'package:reclash/features/doctor/environment/facts.dart';
import 'package:reclash/features/doctor/environment/hosts.dart';

const _domains = RelevantDomains(
  subscription: {'sub.example.net'},
  test: {'cp.cloudflare.com'},
);

void main() {
  test('keeps entries for relevant domains with their roles', () {
    final fact = parseHosts('/etc/hosts', '''
127.0.0.1 localhost
0.0.0.0 YouTube.com www.youtube.com other.org # blocked
1.2.3.4 sub.example.net
::1 cp.cloudflare.com
''', _domains);
    expect(fact.lineCount, 4);
    expect(fact.entries.map((e) => (e.line, e.domain, e.role)), [
      (2, 'youtube.com', DomainRole.service),
      (2, 'www.youtube.com', DomainRole.service),
      (3, 'sub.example.net', DomainRole.subscription),
      (4, 'cp.cloudflare.com', DomainRole.test),
    ]);
    expect(fact.entries.map((e) => e.blackhole), [true, true, false, true]);
    expect(
      fact.entries.first.text,
      '0.0.0.0 YouTube.com www.youtube.com other.org # blocked',
    );
  });

  test('ignores comments, blanks, invalid addresses and CRLF', () {
    final fact = parseHosts(
      'h',
      '# 1.1.1.1 youtube.com\r\n\r\nnot-an-ip youtube.com\r\n2001:db8::1\tdiscord.com\r\n',
      _domains,
    );
    expect(fact.entries, hasLength(1));
    expect(fact.entries.single.address, '2001:db8::1');
    expect(fact.entries.single.blackhole, isFalse);
  });

  test('caps and trims markers', () {
    final text = [
      for (var i = 0; i < 80; i++) '   # marker $i ${'x' * 200}',
    ].join('\n');
    final fact = parseHosts('h', text, _domains);
    expect(fact.markers, hasLength(50));
    expect(fact.markers.first.length, 120);
    expect(fact.markers.first, startsWith('# marker 0'));
  });

  test('filtering again with other domains needs only the text', () {
    const text = '1.1.1.1 example.org\n2.2.2.2 youtube.com';
    expect(parseHosts('h', text, _domains).entries, hasLength(1));
    expect(
      parseHosts(
        'h',
        text,
        const RelevantDomains(test: {'example.org'}, services: {}),
      ).entries,
      hasLength(1),
    );
  });
}
