import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/backup_and_restore.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _existing = DAVProps(
  uri: 'https://dav.example.com/remote',
  user: 'alice',
  password: 'secret',
  fileName: 'custom.zip',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1400);
    container.listen(davSettingProvider, (_, _) {}, fireImmediately: true);
  });

  tearDown(() => container.dispose());

  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: Scaffold(body: dialog)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RestorePreviewDialog', () {
    const summary = RestoreSummary(
      profiles: 3,
      scripts: 2,
      rules: 4,
      proxyGroups: 1,
      hasSettings: true,
    );

    Future<RestoreOption?> openPreview(
      WidgetTester tester, {
      String? choose,
      required String action,
    }) async {
      RestoreOption? result;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showDialog<RestoreOption>(
                      context: context,
                      builder: (_) =>
                          const RestorePreviewDialog(summary: summary),
                    );
                  },
                  child: const Text('open preview'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open preview'));
      await tester.pumpAndSettle();
      if (choose != null) {
        await tester.tap(find.text(choose));
        await tester.pump();
      }
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('shows the staged backup summary', (tester) async {
      await pumpDialog(tester, const RestorePreviewDialog(summary: summary));

      expect(find.text('Profiles: 3'), findsOneWidget);
      expect(find.text('Scripts: 2'), findsOneWidget);
      expect(find.text('Rules: 4'), findsOneWidget);
      expect(find.text('Proxy groups: 1'), findsOneWidget);
      expect(find.text('Settings included'), findsOneWidget);
    });

    testWidgets('cancelling returns no restore option', (tester) async {
      expect(await openPreview(tester, action: 'Cancel'), isNull);
    });

    testWidgets('confirms profiles only by default', (tester) async {
      expect(
        await openPreview(tester, action: 'Confirm'),
        RestoreOption.onlyProfiles,
      );
    });

    testWidgets('confirms the selected full restore', (tester) async {
      expect(
        await openPreview(
          tester,
          choose: 'Restore all data',
          action: 'Confirm',
        ),
        RestoreOption.all,
      );
    });
  });

  group('ClearDataConfirmDialog', () {
    Future<bool?> openClearData(
      WidgetTester tester, {
      required String action,
      Duration wait = Duration.zero,
    }) async {
      bool? result;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) => const ClearDataConfirmDialog(),
                    );
                  },
                  child: const Text('open clear data'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open clear data'));
      await tester.pumpAndSettle();
      if (wait != Duration.zero) {
        await tester.pump(wait);
      }
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('locks confirm behind a 3 second countdown', (tester) async {
      await pumpDialog(tester, const ClearDataConfirmDialog());

      expect(find.text('Confirm (3)'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Confirm (3)'))
            .onPressed,
        isNull,
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Confirm (2)'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Confirm'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Confirm'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('shows the irreversible warning and the backup hint', (
      tester,
    ) async {
      await pumpDialog(tester, const ClearDataConfirmDialog());

      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(
        find.textContaining('ReClash will permanently delete:'),
        findsOneWidget,
      );
      expect(find.textContaining('All profiles'), findsOneWidget);
      expect(
        find.textContaining('a backup is the only way back'),
        findsOneWidget,
      );
    });

    testWidgets('confirm turns red once the countdown ends', (tester) async {
      await pumpDialog(tester, const ClearDataConfirmDialog());

      final locked = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Confirm (3)'),
      );
      expect(locked.style?.foregroundColor, isNull);

      await tester.pump(ClearDataConfirmDialog.confirmDelay);

      final unlocked = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Confirm'),
      );
      expect(
        unlocked.style?.foregroundColor?.resolve({}),
        Theme.of(
          tester.element(find.widgetWithText(TextButton, 'Confirm')),
        ).colorScheme.error,
      );
    });

    testWidgets('cancelling returns false', (tester) async {
      expect(await openClearData(tester, action: 'Cancel'), isFalse);
    });

    testWidgets('confirming after the countdown returns true', (tester) async {
      expect(
        await openClearData(
          tester,
          action: 'Confirm',
          wait: ClearDataConfirmDialog.confirmDelay,
        ),
        isTrue,
      );
    });

    testWidgets('disposing before the countdown ends raises nothing', (
      tester,
    ) async {
      await pumpDialog(tester, const ClearDataConfirmDialog());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: SizedBox.shrink()),
        ),
      );
      await tester.pump(const Duration(seconds: 5));

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the Russian warning', (tester) async {
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            locale: Locale('ru'),
            child: Scaffold(body: ClearDataConfirmDialog()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Очистить данные'), findsOneWidget);
      expect(find.text('Это действие нельзя отменить.'), findsOneWidget);
      expect(find.textContaining('навсегда удалит:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('BackupAndRestore clear data row', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: BackupAndRestore()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the danger zone with the clear data row', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('Danger zone'), findsOneWidget);
      expect(find.text('Clear data'), findsOneWidget);
      expect(
        find.text(
          'Delete all profiles, settings and files. The app will close.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('clear data asks for confirmation and aborts on cancel', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.ensureVisible(find.text('Clear data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear data'));
      await tester.pumpAndSettle();

      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(
        find.textContaining('ReClash will permanently delete:'),
        findsOneWidget,
      );
      expect(find.text('Confirm (3)'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('This cannot be undone.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('WebDAVFormDialog', () {
    testWidgets('rejects an empty form and stores nothing', (tester) async {
      await pumpDialog(tester, const WebDAVFormDialog());

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(container.read(davSettingProvider), isNull);
      expect(find.byType(WebDAVFormDialog), findsOneWidget);
    });

    testWidgets('names the password toggle by what pressing it does', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormDialog());

      final toggle = find.descendant(
        of: find.widgetWithGlyph(TextFormField, AppGlyphs.password),
        matching: find.byType(IconButton),
      );
      expect(tester.widget<IconButton>(toggle).tooltip, 'Show password');

      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(tester.widget<IconButton>(toggle).tooltip, 'Hide password');
    });

    testWidgets('rejects a malformed address', (tester) async {
      await pumpDialog(tester, const WebDAVFormDialog());

      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.link),
        'not-a-url',
      );
      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.account),
        'alice',
      );
      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.password),
        'secret',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(container.read(davSettingProvider), isNull);
    });

    testWidgets('stores a valid binding with the default file name', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormDialog());

      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.link),
        'https://dav.example.com/remote',
      );
      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.account),
        'alice',
      );
      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.password),
        'secret',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      final dav = container.read(davSettingProvider);
      expect(dav?.uri, 'https://dav.example.com/remote');
      expect(dav?.user, 'alice');
      expect(dav?.password, 'secret');
      expect(dav?.fileName, defaultDavFileName);
    });

    testWidgets('editing preserves the previously chosen file name', (
      tester,
    ) async {
      container.read(davSettingProvider.notifier).update((_) => _existing);
      await pumpDialog(tester, const WebDAVFormDialog(dav: _existing));

      await tester.enterText(
        find.widgetWithGlyph(TextFormField, AppGlyphs.account),
        'bob',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      final dav = container.read(davSettingProvider);
      expect(dav?.user, 'bob');
      expect(dav?.fileName, 'custom.zip');
    });

    testWidgets('offers delete only when editing an existing binding', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormDialog());
      expect(find.widgetWithText(TextButton, 'Delete'), findsNothing);

      await pumpDialog(tester, const WebDAVFormDialog(dav: _existing));
      expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
    });

    testWidgets('delete clears the stored binding', (tester) async {
      container.read(davSettingProvider.notifier).update((_) => _existing);
      await pumpDialog(tester, const WebDAVFormDialog(dav: _existing));

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(container.read(davSettingProvider), isNull);
    });

    testWidgets('toggles password visibility', (tester) async {
      await pumpDialog(tester, const WebDAVFormDialog(dav: _existing));

      expect(find.byGlyph(AppGlyphs.eye), findsOneWidget);
      await tester.tap(find.byGlyph(AppGlyphs.eye));
      await tester.pumpAndSettle();
      expect(find.byGlyph(AppGlyphs.eyeOff), findsOneWidget);
    });
  });
}
