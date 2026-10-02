import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/connection/dns_queries.dart';
import 'package:reclash/views/connection/tracker_info_item.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('compact record tags leave the standard tag geometry unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: const Wrap(
          children: [AppTag('status'), AppTag.compact('record')],
        ),
      ),
    );
    await tester.pump();

    final theme = Theme.of(tester.element(find.text('record'))).textTheme;
    final standard = tester.widget<Text>(find.text('status')).style!;
    final compact = tester.widget<Text>(find.text('record')).style!;
    expect(standard.fontSize, theme.labelSmall?.fontSize);
    expect(standard.fontWeight, FontWeight.w600);
    expect(compact.fontSize, theme.labelMedium?.fontSize);
    expect(compact.fontWeight, theme.labelMedium?.fontWeight);
    for (final (label, vertical) in [('status', 2.0), ('record', 1.0)]) {
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.widgetWithText(AppTag, label),
          matching: find.byType(Padding),
        ),
      );
      expect(
        padding.padding,
        EdgeInsets.symmetric(horizontal: 6, vertical: vertical),
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    for (final width in [320.0, 800.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'connection records fit $width pixels at ${scale}x in ${brightness.name}',
          (tester) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            var closed = 0;
            const closeKey = ValueKey('closeConnection');
            final tracker = TrackerInfo(
              id: 'record',
              start: DateTime(2026, 1, 1, 10, 30),
              metadata: const Metadata(
                network: 'tcp',
                host:
                    'a-very-long-service-hostname.for-a-connection.example.com',
                destinationIP: '2001:db8:1234:5678:90ab:cdef:1234:5678',
                destinationPort: '443',
                process: 'org.example.long_application_name',
                uid: 10001,
                sourceIP: '192.0.2.10',
                sourcePort: '58000',
              ),
              chains: const [
                'An unusually long node name that must not widen the list',
                'An unusually long proxy group name that must not widen the list',
              ],
              rule: 'DOMAIN-SUFFIX',
              rulePayload:
                  'a-very-long-rule-domain.for-a-connection.example.com',
              uploadSpeed: 123456789,
              downloadSpeed: 987654321,
            );
            await tester.pumpWidget(
              TestApp(
                overrides: [
                  patchClashConfigProvider.overrideWithValue(
                    const PatchClashConfig(
                      findProcessMode: FindProcessMode.off,
                    ),
                  ),
                ],
                homeBuilder: (child) => Theme(
                  data: ThemeData(brightness: brightness),
                  child: Scaffold(body: SingleChildScrollView(child: child)),
                ),
                child: Column(
                  children: [
                    DnsQueryItem(
                      dnsQuery: DnsQuery(
                        domain:
                            'a-very-long-service-hostname.for-a-dns-query.example.com',
                        type: 'AAAA',
                        initiator: DnsQueryInitiator.app,
                        upstream:
                            'https://a-very-long-upstream-resolver.example.com/dns-query',
                        answers: const [
                          '2001:db8:1234:5678:90ab:cdef:1234:5678',
                          '2001:db8:1234:5678:90ab:cdef:1234:5679',
                        ],
                        cached: true,
                        time: DateTime(2026, 1, 1, 10, 30),
                      ),
                      detailTitle: 'DNS details',
                    ),
                    DnsQueryItem(
                      dnsQuery: DnsQuery(
                        domain: 'timeout.example.com',
                        type: 'A',
                        rcode: 'SERVFAIL',
                        error:
                            'lookup timeout.example.com: all upstream DNS requests failed with an i/o timeout',
                        time: DateTime(2026, 1, 1, 10, 30),
                        delay: 5000,
                      ),
                      detailTitle: 'DNS details',
                    ),
                    TrackerInfoItem(
                      trackerInfo: tracker,
                      detailTitle: 'Request details',
                    ),
                    TrackerInfoItem(
                      trackerInfo: tracker,
                      isLive: true,
                      detailTitle: 'Connection details',
                      trailing: InkResponse(
                        key: closeKey,
                        onTap: () => closed++,
                        child: const SizedBox.square(
                          dimension: 28,
                          child: GlyphIcon(AppGlyphs.block, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
            await tester.pump();

            expect(find.byType(RecordListItem), findsNWidgets(4));
            expect(tester.takeException(), isNull);
            await tester.ensureVisible(find.byKey(closeKey));
            await tester.tap(find.byKey(closeKey));
            await tester.pump();
            expect(closed, 1);
            expect(find.byType(TrackerInfoDetailView), findsNothing);
            expect(tester.takeException(), isNull);

            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }
}
