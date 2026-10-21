import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/editor_section.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';

SubscriptionCompatibilityView _view(SubscriptionClientPreset preset) =>
    SubscriptionCompatibilityView(
      preset: preset,
      error: null,
      lastSuccessful: SubscriptionClientPreset.happ,
      prepared: null,
      checking: false,
      saving: false,
      invalid: false,
      hasConsent: true,
      canCheck: true,
    );

void main() {
  testWidgets('picks a client tile and runs the check', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var preset = SubscriptionClientPreset.auto;
    var checks = 0;
    var forgotten = 0;
    final tick = ValueNotifier(0);
    final controller = TextEditingController();
    addTearDown(tick.dispose);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: SubscriptionCompatibilityPage(
          listenable: tick,
          read: () => _view(preset),
          userAgentController: controller,
          onPresetChanged: (value) {
            preset = value;
            tick.value++;
          },
          onUserAgentChanged: (_) {},
          onCheck: () => checks++,
          onCancel: () {},
          onApply: () {},
          onForgetConsent: () => forgotten++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = currentAppLocalizations;

    await tester.tap(find.text(l10n.subscriptionClientHapp).first);
    await tester.pumpAndSettle();
    expect(preset, SubscriptionClientPreset.happ);

    await tester.tap(find.text(l10n.subscriptionClientCustom));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.tap(find.text(l10n.subscriptionCompatibilityCheck));
    expect(checks, 1);
    await tester.tap(find.text(l10n.subscriptionCompatibilityForgetConsent));
    expect(forgotten, 1);
  });
}
