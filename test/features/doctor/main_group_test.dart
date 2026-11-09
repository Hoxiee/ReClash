import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/account/fetch.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/probes/verify.dart';
import 'package:reclash/features/doctor/remedies/best_node.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../../helpers/test_profiles.dart';

const _groups = [
  Group(type: GroupType.Selector, name: 'Hidden', hidden: true),
  Group(type: GroupType.Selector, name: 'Proxy', hidden: false),
  Group(type: GroupType.URLTest, name: 'Auto', hidden: false),
];

class _NoKernel extends Mock implements DiagnosticKernel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
        resolveMainGroup(mode: Mode.rule, groups: _groups, serverGroup: 'auto'),
        'Auto',
      );
    });

    test('an unknown hint falls back to the first shown group', () {
      expect(
        resolveMainGroup(
          mode: Mode.rule,
          groups: _groups,
          serverGroup: 'Missing',
        ),
        'Proxy',
      );
    });

    test('a hidden group is never the main group', () {
      expect(
        resolveMainGroup(
          mode: Mode.rule,
          groups: _groups,
          serverGroup: 'Hidden',
        ),
        'Proxy',
      );
      expect(resolveMainGroup(mode: Mode.rule, groups: const []), isNull);
    });

    test('the dashboard picks the same group', () {
      for (final hint in [null, 'auto', 'Missing', 'Hidden']) {
        expect(
          resolveMainGroup(mode: Mode.rule, groups: _groups, serverGroup: hint),
          pickMainGroup(shownGroups(Mode.rule, _groups), hint)?.name,
        );
      }
    });
  });

  group('verifyCheck', () {
    test(
      'stays inconclusive without a main group instead of dialling',
      () async {
        final container = ProviderContainer(
          overrides: [profilesProvider.overrideWith(TestProfiles.new)],
        );
        addTearDown(container.dispose);
        final checks = container.read(
          Provider((ref) {
            return [
              for (final step in [PathStep.server, PathStep.internet])
                verifyCheck(ref, _NoKernel(), step)!,
            ];
          }),
        );
        for (final check in checks) {
          final result = await check.run(ProbeToken());
          expect(result.status, PathStepStatus.unknown);
        }
      },
    );
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
