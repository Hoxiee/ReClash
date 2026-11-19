import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/views/site_lock_exits.dart';

const _nl = SiteLockExitCandidate(
  type: 'vless',
  server: '1.2.3.4',
  port: 443,
  route: 'route-v1:nl',
  names: ['NL'],
);
const _de = SiteLockExitCandidate(
  type: 'vless',
  server: '1.2.3.4',
  port: 443,
  route: 'route-v1:de',
  names: ['DE', 'DE copy'],
);

void main() {
  test('an exit resolves to its definition, not to its shared address', () {
    const exit = SiteLockExit(
      type: 'Vless',
      server: '1.2.3.4',
      port: 443,
      route: 'route-v1:de',
      name: 'DE',
    );
    expect(siteLockCandidateOf(exit, [_nl, _de]), same(_de));
  });

  test('a changed definition falls back to the name', () {
    const exit = SiteLockExit(
      type: 'vless',
      server: '1.2.3.4',
      port: 443,
      route: 'route-v1:old',
      name: 'DE copy',
    );
    expect(siteLockCandidateOf(exit, [_nl, _de]), same(_de));
    expect(siteLockCandidateOf(exit.copyWith(name: 'US'), [_nl, _de]), isNull);
    expect(
      siteLockCandidateOf(exit.copyWith(server: '9.9.9.9'), [_nl, _de]),
      isNull,
    );
  });

  test('an exit without a route matches by address', () {
    const exit = SiteLockExit(type: 'ss', server: '5.6.7.8', port: 8388);
    const ss = SiteLockExitCandidate(
      type: 'shadowsocks',
      server: '5.6.7.8',
      port: 8388,
      route: 'route-v1:ss',
      names: ['SS'],
    );
    expect(siteLockCandidateOf(exit, [_nl, ss]), same(ss));
  });
}
