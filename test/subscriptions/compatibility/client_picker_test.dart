import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/subscriptions/compatibility/client_picker.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('opens the preset menu and returns the selected client', (
    tester,
  ) async {
    var selected = SubscriptionClientPreset.auto;
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SubscriptionClientPresetRow(
            value: selected,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.subscriptionClientAuto),
      findsOneWidget,
    );

    await tester.tap(find.text(currentAppLocalizations.subscriptionClientAuto));
    await tester.pumpAndSettle();
    expect(find.text('FlClashX'), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.subscriptionClientHapp),
      findsOneWidget,
    );

    await tester.tap(find.text(currentAppLocalizations.subscriptionClientHapp));
    await tester.pumpAndSettle();
    expect(selected, SubscriptionClientPreset.happ);
  });

  testWidgets('limits custom user-agent input without owning its controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      TestApp(
        child: SubscriptionCustomUserAgentRow(
          controller: controller,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), 'a' * 513);
    expect(controller.text, hasLength(512));
    await tester.enterText(
      find.byType(TextFormField),
      'agent\r\nInjected: yes',
    );
    expect(controller.text, 'agentInjected: yes');
  });
}
