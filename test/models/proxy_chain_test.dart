import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

void main() {
  const report = ChainReport(
    id: 1,
    group: 'A → B',
    status: ChainStatus.ok,
    members: {'A → B ⟶ B1': ChainMember(leaf: 'B1')},
    hidden: ['A → B ⟶ M', 'A → B ⟶ M1'],
  );
  final generated = ChainGeneratedNames.of([report]);

  test(
    'clones and hidden hop groups leave every list but their chain group',
    () {
      const groups = [
        Group(
          type: GroupType.Selector,
          name: 'GLOBAL',
          all: [
            Proxy(name: 'B1', type: 'ss'),
            Proxy(name: 'A → B ⟶ B1', type: 'ss'),
            Proxy(name: 'A → B ⟶ M', type: 'Selector'),
            Proxy(name: 'A → B ⟶ M1', type: 'ss'),
            Proxy(name: 'A → B', type: 'Selector'),
          ],
        ),
        Group(
          type: GroupType.Selector,
          name: 'A → B',
          all: [Proxy(name: 'A → B ⟶ B1', type: 'ss')],
        ),
      ];

      final visible = generated.visibleGroups(groups);

      expect(visible.first.all.map((proxy) => proxy.name), ['B1', 'A → B']);
      expect(visible.last, groups.last);
    },
  );

  test('sibling providers are generated, the original is not', () {
    expect(generated.isProvider('A → B/sub'), isTrue);
    expect(generated.isProvider('sub'), isFalse);
  });

  test('providerPending warns instead of blocking', () {
    expect(ChainIssueCode.providerPending.isError, isFalse);
    expect(ChainIssueCode.providerPending.isWarning, isTrue);
    expect(ChainIssueCode.unknown.isError, isFalse);
  });
}
