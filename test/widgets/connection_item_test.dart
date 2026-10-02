import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/views.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

TrackerInfo _tracker({
  String rule = 'DOMAIN-SUFFIX',
  String rulePayload = '',
  String process = '',
  String processPath = '',
  int uid = 0,
  String sourceIP = '',
  String sourcePort = '',
  String destinationIP = '',
  String destinationPort = '',
  String host = '',
  List<String> chains = const [],
}) {
  return TrackerInfo(
    id: '1',
    start: DateTime(2026, 1, 1, 10, 30),
    metadata: Metadata(
      network: 'tcp',
      process: process,
      processPath: processPath,
      uid: uid,
      sourceIP: sourceIP,
      sourcePort: sourcePort,
      destinationIP: destinationIP,
      destinationPort: destinationPort,
      host: host,
    ),
    chains: chains,
    rule: rule,
    rulePayload: rulePayload,
  );
}

void main() {
  testWidgets('TrackerInfoDetailView renders formatted connection fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: _tracker(
              rule: 'DOMAIN-SUFFIX',
              rulePayload: 'example.com',
              process: 'chrome',
              uid: 1000,
              sourceIP: '1.2.3.4',
              sourcePort: '8080',
              destinationIP: '5.6.7.8',
              destinationPort: '443',
              host: 'example.com',
              chains: const ['DIRECT'],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('DOMAIN-SUFFIX(example.com)'), findsOneWidget);
    expect(find.text('chrome(1000)'), findsOneWidget);
    expect(find.text('1.2.3.4:8080'), findsOneWidget);
    expect(find.text('5.6.7.8:443'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('DIRECT'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('DIRECT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoDetailView omits empty fields', (tester) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(trackerInfo: _tracker()),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('('), findsNothing);
    expect(find.text('tcp'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem shows all chains and forwards their clicks', (
    tester,
  ) async {
    final clicked = <String>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(chains: const ['Proxy A', 'Proxy B']),
          detailTitle: 'detail',
          onClickKeyword: clicked.add,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Proxy A'), findsOneWidget);
    expect(find.text('Proxy B'), findsOneWidget);

    await tester.tap(find.text('Proxy A'));
    await tester.pump();
    await tester.tap(find.text('Proxy B'));
    await tester.pump();

    expect(clicked, ['Proxy A', 'Proxy B']);
    expect(find.byType(TrackerInfoDetailView), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'TrackerInfoItem reads from the rule through the group to the node',
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          homeBuilder: (child) => Scaffold(body: child),
          child: TrackerInfoItem(
            trackerInfo: _tracker(
              rulePayload: 'example.com',
              process: 'chrome',
              uid: 1000,
              sourceIP: '1.2.3.4',
              sourcePort: '8080',
              destinationIP: '5.6.7.8',
              destinationPort: '443',
              host: 'example.com',
              chains: const ['Node', 'Group'],
            ),
            detailTitle: 'detail',
          ),
        ),
      );
      await tester.pump();

      final rule = tester.getCenter(find.text('DOMAIN-SUFFIX(example.com)'));
      final group = tester.getCenter(find.text('Group'));
      final node = tester.getCenter(find.text('Node'));
      expect(rule.dx, lessThan(group.dx));
      expect(group.dx, lessThan(node.dx));
      expect(find.text('example.com:443  5.6.7.8'), findsOneWidget);
      expect(find.text('chrome(1000)  ·  1.2.3.4:8080'), findsOneWidget);
      expect(find.text('TCP'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'TrackerInfoItem uses full timestamps for history and live speeds otherwise',
    (tester) async {
      Future<void> pumpItem({required bool isLive}) async {
        await tester.pumpWidget(
          TestApp(
            wrapInProviderScope: true,
            homeBuilder: (child) => Scaffold(body: child),
            child: TrackerInfoItem(
              key: ValueKey(isLive),
              trackerInfo: _tracker(
                host: 'example.com',
              ).copyWith(uploadSpeed: 2048, downloadSpeed: 4096),
              isLive: isLive,
              trailing: const SizedBox(key: ValueKey('action')),
              detailTitle: 'detail',
            ),
          ),
        );
        await tester.pump();
      }

      await pumpItem(isLive: false);
      expect(find.text(DateTime(2026, 1, 1, 10, 30).showFull), findsOneWidget);
      expect(find.textContaining('/s'), findsNothing);

      await pumpItem(isLive: true);
      expect(find.text(DateTime(2026, 1, 1, 10, 30).showFull), findsNothing);
      expect(find.textContaining('2KB/s'), findsOneWidget);
      expect(find.textContaining('4KB/s'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RecordHeader),
          matching: find.byKey(const ValueKey('action')),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('idle live connections do not replace zero speed with totals', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(
            host: 'example.com',
          ).copyWith(upload: 2048, download: 4096),
          isLive: true,
          detailTitle: 'detail',
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('0B/s'), findsOneWidget);
    expect(find.textContaining('2KB'), findsNothing);
    expect(find.textContaining('4KB'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final isLive in [false, true]) {
    testWidgets(
      'the ${isLive ? 'active' : 'history'} list selects its row presentation',
      (tester) async {
        final items = [_tracker(host: 'example.com')];
        await tester.pumpWidget(
          TestApp(
            wrapInProviderScope: true,
            homeBuilder: (child) => Scaffold(body: child),
            child: isLive
                ? TrackerInfoAnimatedList(
                    trackerInfos: items,
                    detailTitle: 'detail',
                  )
                : TrackerInfoList(trackerInfos: items, detailTitle: 'detail'),
          ),
        );
        await tester.pump();

        expect(
          tester.widget<TrackerInfoItem>(find.byType(TrackerInfoItem)).isLive,
          isLive,
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('desktop process icons retain keyword filtering in the body', (
    tester,
  ) async {
    final clicked = <String>[];
    await tester.pumpWidget(
      TestApp(
        overrides: [
          patchClashConfigProvider.overrideWithValue(
            const PatchClashConfig(findProcessMode: FindProcessMode.always),
          ),
        ],
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(
            process: 'reclash-test-app',
            processPath: '/missing/reclash-test-app',
            host: 'example.com',
          ),
          detailTitle: 'detail',
          onClickKeyword: clicked.add,
        ),
      ),
    );
    await tester.pump();

    final icon = tester.widget<ProcessIcon>(find.byType(ProcessIcon));
    expect(icon.processPath, '/missing/reclash-test-app');
    expect(icon.size, 40);
    await tester.tap(
      find
          .ancestor(
            of: find.byType(ProcessIcon),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pump();
    expect(clicked, ['reclash-test-app']);
    expect(find.byType(TrackerInfoDetailView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  }, skip: !system.isDesktop);

  testWidgets('TrackerInfoDetailView lists every chain hop', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoDetailView(
          trackerInfo: _tracker(chains: const ['Proxy A', 'Proxy B']),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Proxy A'), findsOneWidget);
    expect(find.text('Proxy B'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
