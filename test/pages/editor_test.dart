import 'package:reclash/pages/editor.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/database.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_editor/re_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(1200, 1000),
);

void main() {
  testWidgets('import from URL shows a translated network error message', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          _viewSizeOverride,
          profilesProvider.overrideWith(TestProfiles.new),
        ],
        child: const EditorPage(
          title: 'Editor',
          content: '',
          onSave: _noopSave,
          supportRemoteDownload: true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('External fetch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from URL'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'http://127.0.0.1/anything',
    );
    await tester.tap(find.text('Submit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // flutter_test's mocked HttpClient answers with HTTP 400, which maps to
    // the localized network exception message in the snackbar.
    expect(
      find.text('Network error, please check your connection and try again'),
      findsOneWidget,
    );
  });

  testWidgets('system back first leaves the editor, then pops', (tester) async {
    var pops = 0;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          _viewSizeOverride,
          profilesProvider.overrideWith(TestProfiles.new),
        ],
        child: EditorPage(
          title: 'Editor',
          content: 'hello',
          onSave: _noopSave,
          onPop: (context, title, content) async {
            pops++;
            return true;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(CodeEditor));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(pops, 0);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(pops, 1);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });
}

void _noopSave(BuildContext context, String title, String content) {}
