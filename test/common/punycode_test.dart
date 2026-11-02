import 'package:reclash/common/punycode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes IDN labels without changing ASCII labels or separators', () {
    expect(decodeIdnHost('xn--d1acpjx3f.xn--p1ai'), 'яндекс.рф');
    expect(decodeIdnHost('www.xn--mnchen-3ya.de'), 'www.münchen.de');
    expect(decodeIdnHost('xn--bcher-kva.example.'), 'bücher.example.');
    expect(decodeIdnHost('XN--P1AI'), 'рф');
    expect(decodeIdnHost('xn--mgbh0fb.example'), 'مثال.example');
  });

  test('ordinary hosts, IP addresses and empty input remain unchanged', () {
    for (final host in [
      '',
      'EXAMPLE.com',
      '1.1.1.1',
      '2001:db8::1',
      'axn--b.com',
    ]) {
      expect(decodeIdnHost(host), host);
    }
  });

  test('invalid Punycode and non-Unicode scalars remain raw', () {
    for (final host in [
      'xn--',
      'xn--.example',
      'xn--ab!.example',
      'xn--99999999999.example',
      'xn--abc-.example',
      'xn--ib9b.example',
    ]) {
      expect(decodeIdnHost(host), host);
    }
  });

  test('controls, bidi overrides and invisible formatting remain raw', () {
    for (final host in [
      'xn--a.example',
      'xn--ab-g4t.example',
      'xn--ab-x0b.example',
      'xn--6a.example',
      'xn--266c.example',
      'xn--ls8h.example',
    ]) {
      expect(decodeIdnHost(host), host);
    }
  });

  test(
    'an invalid label does not prevent a safe adjacent label from decoding',
    () {
      expect(decodeIdnHost('xn--ab!.xn--p1ai'), 'xn--ab!.рф');
    },
  );

  test('bounds work by DNS label and host lengths', () {
    final label = 'xn--${'z' * 60}';
    expect(decodeIdnHost('$label.example'), '$label.example');
    final host = '${'a' * 245}.xn--p1ai';
    expect(host.length, 254);
    expect(decodeIdnHost('a$host'), 'a$host');
  });
}
