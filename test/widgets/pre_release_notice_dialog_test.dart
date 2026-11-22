import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/pre_release_notice_dialog.dart';

import '../helpers/test_app.dart';

Future<void> _pumpHost(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 800));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        locale: Locale('ru'),
        child: Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _settleDialog(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  testWidgets('shows once and opens both support links', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    await _pumpHost(tester);

    final result = dialogs.showCommonDialog<Object?>(
      child: const PreReleaseNoticeDialog(version: '0.1.0-pre.13'),
    );
    await _settleDialog(tester);

    expect(find.text(l10n.preReleaseNoticeTitle), findsOneWidget);
    expect(find.text(l10n.updateChannelPre), findsOneWidget);
    expect(find.textContaining('0.1.0-pre.13'), findsOneWidget);
    expect(find.text(l10n.preReleaseNoticeTelegramChat), findsOneWidget);
    expect(find.text(l10n.preReleaseNoticeGithubIssues), findsOneWidget);
    expect(find.text(l10n.updateGotIt), findsOneWidget);

    await tester.tap(find.text(l10n.preReleaseNoticeTelegramChat));
    await _settleDialog(tester);
    expect(find.text(l10n.telegramLinkTitle), findsOneWidget);
    await tester.tap(find.text(l10n.cancel));
    await _settleDialog(tester);

    await tester.tap(find.text(l10n.preReleaseNoticeGithubIssues));
    await _settleDialog(tester);
    expect(find.text(l10n.externalLink), findsOneWidget);
    expect(find.textContaining(repositoryIssuesUrl), findsOneWidget);
    await tester.tap(find.text(l10n.cancel));
    await _settleDialog(tester);

    await tester.tap(find.text(l10n.updateGotIt));
    await _settleDialog(tester);
    expect(await result, isNull);
  });
}
