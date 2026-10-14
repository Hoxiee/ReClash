import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/update_offer.dart';

import '../helpers/test_app.dart';

const _payload =
    '{"schemaVersion":2,"versions":[{"version":"0.9.0","tag":"v0.9.0",'
    '"date":"2026-10-07","prerelease":false,"groups":['
    '{"type":"feat","entries":[{"id":"1a2b3c4","text":"Smart routing"}]}]}]}';

String _body(String payload) =>
    '<!-- reclash:changelog:begin -->\n'
    '- Smart routing\n'
    '<!-- reclash:changelog:end -->\n'
    '\n<!-- reclash:changelog:json\n$payload\n-->\n';

Map<String, dynamic> _release() => <String, dynamic>{
  'tag_name': 'v0.9.0',
  'body': _body(_payload),
};

Future<void> _open(WidgetTester tester, List<UpdateOfferChoice> sink) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  sink.add(
                    await UpdateOfferScreen.show(
                      context,
                      release: _release(),
                      subtitle: 'Update first or continue',
                      primaryLabel: 'Install update',
                      skipLabel: 'Continue to setup',
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers the release notes with install and skip actions', (
    tester,
  ) async {
    await _open(tester, []);

    expect(find.text('New version found'), findsOneWidget);
    expect(find.text('v0.9.0'), findsOneWidget);
    expect(find.textContaining('Smart routing'), findsWidgets);
    expect(find.text('Install update'), findsOneWidget);
    expect(find.text('Continue to setup'), findsOneWidget);
  });

  testWidgets('install resolves to the install choice', (tester) async {
    final sink = <UpdateOfferChoice>[];
    await _open(tester, sink);
    await tester.tap(find.text('Install update'));
    await tester.pumpAndSettle();

    expect(sink, [UpdateOfferChoice.install]);
    expect(find.text('New version found'), findsNothing);
  });

  testWidgets('continuing to setup resolves to the skip choice', (
    tester,
  ) async {
    final sink = <UpdateOfferChoice>[];
    await _open(tester, sink);
    await tester.tap(find.text('Continue to setup'));
    await tester.pumpAndSettle();

    expect(sink, [UpdateOfferChoice.skip]);
    expect(find.text('New version found'), findsNothing);
  });
}
