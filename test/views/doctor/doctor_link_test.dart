import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/application.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/features/doctor/explain.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/doctor/doctor.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import 'doctor_fakes.dart';

class _Window extends Mock implements WindowPort {}

class _Setup extends SetupSession {
  @override
  SetupSessionState build() => const SetupSessionState(
    active: true,
    step: SetupStep.language,
    draft: SetupDraft(coverage: SetupCoverage.tun),
  );
}

class _LinkApplication extends Application {
  const _LinkApplication();

  @override
  ApplicationState createState() => _LinkApplicationState();
}

class _LinkApplicationState extends ApplicationState {
  @override
  Widget build(BuildContext context) =>
      const TestApp(locale: Locale('en'), child: SizedBox.shrink());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<String> links;
  late _Window window;

  setUpAll(() => mockPreferences());

  setUp(() {
    final previousStream = linkManager.stringLinkStream;
    final previousAttached = globalState.isAttach;
    final previousDoctor = openDoctorOnCause;
    final previousWindow = windowPort;
    links = StreamController<String>();
    window = _Window();
    when(window.show).thenAnswer((_) async {});
    linkManager.stringLinkStream = () => links.stream;
    globalState.isAttach = true;
    windowPort = window;
    addTearDown(() async {
      linkManager.destroy();
      await links.close();
      linkManager.stringLinkStream = previousStream;
      globalState.isAttach = previousAttached;
      openDoctorOnCause = previousDoctor;
      windowPort = previousWindow;
    });
  });

  for (final size in [const Size(412, 915), const Size(1200, 900)]) {
    for (final check in [null, 'device.batteryOptimization']) {
      final initial = check == null;
      testWidgets(
        '${initial ? 'initial' : 'streamed'} doctor link opens on the app '
        'navigator at ${size.width}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final kernel = FakeDoctorKernel();
          final input = initial
              ? 'reclash://doctor'
              : 'reclash://doctor?check=$check';
          if (initial) linkManager.seedInitialLink([input]);
          final container = ProviderContainer(
            overrides: [
              setupSessionProvider.overrideWith(_Setup.new),
              viewSizeProvider.overrideWithBuild((_, _) => size),
              ...doctorOverrides(
                kernel: kernel,
                findings: [directModeFinding, batteryFinding],
              ),
            ],
          );
          globalState.container = container;
          addTearDown(container.dispose);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const _LinkApplication(),
            ),
          );
          await tester.pumpAndSettle();
          if (!initial) links.add(input);
          for (var attempt = 0; attempt < 100; attempt++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 10)),
            );
            await tester.pump(const Duration(milliseconds: 25));
            if (find.byType(DoctorSheet).evaluate().isNotEmpty ||
                find
                    .text(currentAppLocalizations.urlScheme)
                    .evaluate()
                    .isNotEmpty) {
              break;
            }
          }
          await tester.pumpAndSettle();

          expect(
            find.byType(DoctorSheet),
            findsOneWidget,
            reason: tester
                .widgetList<RichText>(find.byType(RichText))
                .map((widget) => widget.text.toPlainText())
                .join('\n'),
          );
          expect(
            tester.widget<DoctorSheet>(find.byType(DoctorSheet)).check,
            check,
          );
          expect(globalState.navigatorKey.currentState!.canPop(), isTrue);
          expect(find.text(currentAppLocalizations.urlScheme), findsNothing);
          expect(kernel.applied, isEmpty);
          expect(kernel.snoozes, isEmpty);
          verify(window.show).called(1);
          expect(tester.takeException(), isNull);
          if (check != null) {
            expect(
              tester
                  .getTopLeft(
                    find.text(
                      currentAppLocalizations.doctorBatteryOptimizationTitle,
                    ),
                  )
                  .dy,
              lessThan(
                tester
                    .getTopLeft(
                      find.text(currentAppLocalizations.doctorDirectModeTitle),
                    )
                    .dy,
              ),
            );
          }

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
