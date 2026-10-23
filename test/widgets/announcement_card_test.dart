import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/widgets/announcement_card.dart';

import '../helpers/test_app.dart';

ProviderContainer _container(Map<String, List<String>> headers) =>
    ProviderContainer(
      overrides: [
        providerHintsProvider.overrideWithValue(
          ProviderHints(readSubscriptionMetadata(headers).metadata),
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, ProviderContainer container) async {
  globalState.container = container;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [AnnouncementCard(), NoticeCard()],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('desktop announcement expands and returns on close or scrim', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 750);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final text = List.filled(30, 'Subscription news and details.').join('\n');
    final container = _container({
      'announce': [text],
      'reclash-announceurl': ['https://example.test/news'],
    });
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 250,
                height: 208,
                child: AnnouncementCard(expandable: true),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Scrollable), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
    expect(find.byTooltip('Learn more'), findsOneWidget);
    await tester.tap(find.text('Announcement'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.text('Read'), findsOneWidget);
    await tester.tap(find.text('Read'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      text,
    );
    expect(find.text('Learn more'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Read'), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 400));
    await tester.pumpAndSettle();
    expect(find.text('Read'), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('description has full selectable text and cannot be dismissed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final text = List.filled(
      12,
      'Your subscription includes every region.',
    ).join('\n');
    final container = _container({
      'announce': [text],
      'reclash-announceurl': ['https://example.test/plan'],
    });
    addTearDown(container.dispose);
    await _pump(tester, container);
    final description = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    expect(description.data, text);
    expect(description.maxLines, isNull);
    expect(find.byType(IconButton), findsNothing);
    expect(find.text('Learn more'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing a notice leaves the description visible', (
    tester,
  ) async {
    final container = _container({
      'announce': ['Plan description'],
      'reclash-notice': ['Maintenance tonight'],
    });
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(find.text('Maintenance tonight'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byKey(const ValueKey('provider-notice-card')), findsNothing);
    expect(find.text('Plan description'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notice without a link opens its full message', (tester) async {
    final container = _container({
      'reclash-notice': ['Maintenance tonight'],
    });
    addTearDown(container.dispose);
    await _pump(tester, container);
    await tester.tap(find.text('Maintenance tonight'));
    await tester.pumpAndSettle();
    expect(find.text('Maintenance tonight'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'notice and description links use the external link confirmation',
    (tester) async {
      final container = _container({
        'announce': ['Plan description'],
        'reclash-announceurl': ['https://example.test/plan'],
        'reclash-notice': ['Maintenance tonight'],
        'reclash-noticeurl': ['https://example.test/status'],
      });
      addTearDown(container.dispose);
      await _pump(tester, container);
      await tester.tap(find.text('Learn more'));
      await tester.pumpAndSettle();
      expect(find.text('https://example.test/plan'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maintenance tonight'));
      await tester.pumpAndSettle();
      expect(find.text('https://example.test/status'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Plan description'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('missing or blank messages render no cards', (tester) async {
    final container = _container({
      'announce': ['  '],
      'reclash-notice': ['  '],
    });
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(
      find.byKey(const ValueKey('provider-announcement-card')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('provider-notice-card')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
