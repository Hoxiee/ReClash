import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/edit.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/app_paths.dart';
import '../helpers/preferences.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';
import '../plugins/code_forge/support.dart';

class _NoopSetupAction extends SetupAction {
  @override
  void autoApplyProfile() {}
}

void main() {
  late Directory tempDir;
  late Profile profile;
  late ProviderContainer container;

  setUpAll(() async {
    await initEditorNative();
    tempDir = Directory.systemTemp.createTempSync('profile_editor_navigation');
    await useAppPaths(tempDir);
    await mockPreferences();
    globalState.packageInfo = PackageInfo(
      appName: 'ReClash',
      packageName: 'com.reclash',
      version: '1.0.0',
      buildNumber: '1',
    );
  });

  setUp(() async {
    profile = Profile.normal(label: 'Example');
    final file = await profile.file;
    await file.writeAsString('proxies: []\nrules: []\n');
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  for (final isMobile in [true, false]) {
    testWidgets(
      'profile file editor uses the hosting navigator and preserves the sheet '
      'state${isMobile ? ' on mobile' : ' on desktop'}',
      (tester) async {
        final size = isMobile ? const Size(412, 915) : const Size(1280, 800);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final hostKey = GlobalKey<NavigatorState>();
        late BuildContext openerContext;
        container = ProviderContainer(
          overrides: [
            setupActionProvider.overrideWith(() => _NoopSetupAction()),
            profilesProvider.overrideWith(() => TestProfiles([profile])),
            viewSizeProvider.overrideWithBuild((_, _) => size),
          ],
        );
        globalState.container = container;
        addTearDown(container.dispose);
        addTearDown(() async => tester.pumpWidget(const SizedBox()));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              includeNavigatorKey: false,
              child: Builder(
                builder: (context) {
                  openerContext = context;
                  return isMobile
                      ? const SizedBox.expand()
                      : Row(
                          children: [
                            const SizedBox(
                              width: 240,
                              child: Text('Navigation'),
                            ),
                            Expanded(
                              child: Navigator(
                                key: hostKey,
                                onGenerateInitialRoutes: (_, _) => [
                                  MaterialPageRoute<void>(
                                    builder: (context) {
                                      openerContext = context;
                                      return const SizedBox.expand();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        );
        await tester.pump();

        final host = isMobile
            ? Navigator.of(openerContext)
            : hostKey.currentState!;
        final hostBox = tester.getRect(find.byWidget(host.widget));
        unawaited(
          showSheet<void>(
            context: openerContext,
            props: nestedPagedSheetProps,
            builder: (_) => NestedPagedSheet(
              builder: (_) => EditProfileView(profile: profile),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();

        final label = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.controller?.text == 'Example',
        );
        expect(label, findsOneWidget);
        await tester.enterText(label, 'Remembered name');
        await tester.pump();

        final row = find.widgetWithText(
          DecorationListItem,
          currentAppLocalizations.profile,
        );
        for (var i = 0; i < 20 && row.evaluate().isEmpty; i++) {
          await tester.drag(
            find
                .descendant(
                  of: find.byType(EditProfileView),
                  matching: find.byType(ListView),
                )
                .first,
            const Offset(0, -300),
          );
          await tester.pump();
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
        }
        expect(row, findsOneWidget);
        final profileState = tester.state(find.byType(EditProfileView));
        await tester.ensureVisible(row);
        await settle(tester, 8);
        await tester.tap(row);
        await settle(tester, 12);

        expect(find.byType(EditorPage), findsOneWidget);
        expect(Navigator.of(tester.element(find.byType(EditorPage))), host);
        expect(
          find.byType(SheetPagesNavigator, skipOffstage: false),
          findsWidgets,
        );
        expect(tester.getRect(find.byType(EditorPage)), hostBox);
        expect(
          tester
              .state<EditorViewState>(find.byType(EditorView))
              .controller
              ?.text,
          'proxies: []\nrules: []\n',
        );

        await tester.tap(find.byTooltip(currentAppLocalizations.back));
        await settle(tester, 12);
        expect(find.byType(EditorPage), findsNothing);
        expect(find.byType(EditProfileView), findsOneWidget);
        expect(tester.state(find.byType(EditProfileView)), same(profileState));
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is TextField &&
                widget.controller?.text == 'Remembered name',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
