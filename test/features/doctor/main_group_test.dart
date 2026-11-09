import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/account/fetch.dart';
import 'package:reclash/features/doctor/probes/verify.dart';
import 'package:reclash/features/doctor/remedies/best_node.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

const _groups = [
  Group(type: GroupType.Selector, name: 'Hidden', hidden: true),
  Group(type: GroupType.Selector, name: 'Proxy'),
  Group(type: GroupType.URLTest, name: 'Auto'),
];

void main() {
  group('resolveMainGroup', () {
    test('direct mode has no main group', () {
      expect(
        resolveMainGroup(
          mode: Mode.direct,
          groups: _groups,
          serverGroup: 'Auto',
        ),
        isNull,
      );
    });

    test('global mode always dials GLOBAL', () {
      expect(resolveMainGroup(mode: Mode.global, groups: _groups), 'GLOBAL');
    });

    test('the provider hint wins in any case', () {
      expect(
        resolveMainGroup(
          mode: Mode.rule,
          groups: _groups,
          serverGroup: 'auto',
          currentGroup: 'Proxy',
        ),
        'Auto',
      );
    });

    test('an unknown hint falls back to the group the user opened', () {
      expect(
        resolveMainGroup(
          mode: Mode.rule,
          groups: _groups,
          serverGroup: 'Missing',
          currentGroup: 'Auto',
        ),
        'Auto',
      );
    });

    test('otherwise the first shown group carries the traffic', () {
      expect(
        resolveMainGroup(
          mode: Mode.rule,
          groups: _groups,
          currentGroup: 'Gone',
        ),
        'Proxy',
      );
      expect(resolveMainGroup(mode: Mode.rule, groups: const []), isNull);
    });
  });

  group('fastestNode', () {
    test('never picks a built-in outbound or a dead node', () {
      const nodes = [
        Proxy(name: 'DIRECT', type: 'Direct'),
        Proxy(name: 'Slow', type: 'Vless'),
        Proxy(name: 'Dead', type: 'Trojan'),
        Proxy(name: 'Fast', type: 'Hysteria2'),
      ];
      final delays = {'DIRECT': 1, 'Slow': 300, 'Dead': -1, 'Fast': 80};
      expect(fastestNode(nodes, (proxy) => delays[proxy.name]), 'Fast');
      expect(fastestNode(nodes.take(1).toList(), (_) => 1), isNull);
    });
  });

  group('profileUpdateFailed', () {
    final at = DateTime(2026, 11, 9);

    test('keeps the status of a refused link', () {
      final fact = profileUpdateFailed(
        3,
        const SubscriptionException(SubscriptionFailure.http, status: 410),
        at: at,
      );
      expect(fact.status, 410);
      expect(fact.error, 'http');
      expect(fact.ok, isFalse);
    });

    test('drops the status of a failure that says nothing about the link', () {
      final fact = profileUpdateFailed(
        3,
        const SubscriptionException(
          SubscriptionFailure.rateLimited,
          status: 429,
        ),
        at: at,
      );
      expect(fact.status, isNull);
      expect(fact.error, 'rateLimited');
    });

    test('names an unrecognised error as other', () {
      expect(profileUpdateFailed(3, StateError('x'), at: at).error, 'other');
    });
  });
}
