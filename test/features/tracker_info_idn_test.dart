import 'package:reclash/features/connection/tracker_info_item.dart';
import 'package:reclash/features/connection/tracker_info_table.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _rawHost = 'xn--d1acpjx3f.xn--p1ai';
const _target = 'яндекс.рф:443 ($_rawHost)';

TrackerInfo _tracker({String host = _rawHost}) => TrackerInfo(
  id: 'idn-connection',
  start: DateTime(2026, 1, 1),
  metadata: Metadata(network: 'tcp', host: host, destinationPort: '443'),
  chains: const ['DIRECT'],
  rule: 'MATCH',
  rulePayload: '',
);

void main() {
  testWidgets(
    'the connection table shows Unicode and its original ASCII host',
    (tester) async {
      final tracker = _tracker();
      await tester.pumpWidget(
        TestApp(child: Scaffold(body: TrackerTargetText(tracker))),
      );
      await tester.pump();

      expect(find.text(_target), findsOneWidget);
      expect(tracker.metadata.host, _rawHost);
      expect(tracker.title, _rawHost);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'connection cards keep both host forms readable on a narrow view',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: Scaffold(
            body: TrackerInfoItem(
              trackerInfo: _tracker(),
              detailTitle: 'Connection',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(_target), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('technical details keep the original host for copying', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SheetProvider(
            type: SheetType.page,
            child: TrackerInfoDetailView(trackerInfo: _tracker()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(_rawHost), findsOneWidget);
    expect(find.textContaining('яндекс'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a rejected IDN stays raw in the connection table', (
    tester,
  ) async {
    const host = 'xn--ab-g4t.example';
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(body: TrackerTargetText(_tracker(host: host))),
      ),
    );
    await tester.pump();

    expect(find.text('$host:443'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
