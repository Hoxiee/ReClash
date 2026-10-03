import 'package:code_forge/code_forge.dart' show CodeForge;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/views/config/editor.dart';

import '../helpers/editor_native.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(1200, 1000),
);

void main() {
  setUpAll(initEditorNative);
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

    await tester.tap(find.byGlyph(AppGlyphs.more));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('External fetch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Import from URL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

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
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byType(CodeForge));
    await tester.pump();
    // A pop only runs onPop when the document is dirty; one delta makes it so.
    await typeInEditor(tester, ' world');
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(pops, 0);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(pops, 1);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    // Let the caret blink timer cancel after the editor loses focus so it is
    // not still pending when the tree is torn down.
    await tester.pump(const Duration(seconds: 1));
  });
}

void _noopSave(BuildContext context, String title, String content) {}
