import 'package:test/test.dart';

import '../../tool/update_client_uas.dart';

const _sample = '''
const legacyClashUserAgent = 'ClashForAndroid/2.5.12';
const metaClashUserAgent = 'ClashMetaForAndroid/2.11.7.Meta';
const _v2rayngUa = 'v2rayNG/1.9.24';
''';

GithubLatest _githubFor(String key) =>
    entries.firstWhere((entry) => entry.key == key).source as GithubLatest;

void main() {
  test('stripLeadingV drops a single v prefix', () {
    expect(stripLeadingV('v2.11.34'), '2.11.34');
    expect(stripLeadingV('2.2.6'), '2.2.6');
  });

  test('readConstValue extracts the quoted literal', () {
    expect(readConstValue(_sample, 'metaClashUserAgent'),
        'ClashMetaForAndroid/2.11.7.Meta');
    expect(readConstValue(_sample, 'missing'), isNull);
  });

  test('replaceConstValue rewrites only the target constant', () {
    final updated = replaceConstValue(
      _sample,
      'metaClashUserAgent',
      'ClashMetaForAndroid/2.11.34.Meta',
    );
    expect(readConstValue(updated, 'metaClashUserAgent'),
        'ClashMetaForAndroid/2.11.34.Meta');
    expect(readConstValue(updated, '_v2rayngUa'), 'v2rayNG/1.9.24');
  });

  test('renderers turn an upstream tag into the wire User-Agent', () {
    expect(_githubFor('clashMeta').render('v2.11.34'),
        'ClashMetaForAndroid/2.11.34.Meta');
    expect(_githubFor('v2rayng').render('2.2.6'), 'v2rayNG/2.2.6');
    expect(_githubFor('singbox').render('v1.2.25.2802'), 'Karing/1.2.25.2802');
  });
}
