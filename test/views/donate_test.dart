import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/donate.dart';

import '../helpers/test_app.dart';

const _config = DonationConfig(
  links: {
    DonationRail.tribute: 'https://t.me/tribute/app?startapp=test',
    DonationRail.cloudTips: '',
    DonationRail.sponsors: 'https://github.com/sponsors/test',
  },
  wallets: [
    CryptoWallet(coin: 'USDT', network: 'TRC20', address: 'TUsdt'),
    CryptoWallet(coin: 'TON', network: 'TON', address: 'UQTon'),
    CryptoWallet(coin: 'XMR', network: 'Monero', address: ''),
  ],
);

Future<void> _pumpDonate(
  WidgetTester tester, {
  required String? regionCode,
  bool includeUnconfigured = false,
}) async {
  const size = Size(412, 2400);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  container
      .read(appSettingProvider.notifier)
      .update((state) => state.copyWith(regionCode: regionCode));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: DonateView(
          config: _config,
          includeUnconfigured: includeUnconfigured,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<String> _headers(WidgetTester tester) => tester
    .widgetList<ListHeader>(find.byType(ListHeader))
    .map((header) => header.title)
    .toList();

void main() {
  test('Russian cards lead with Russian rails', () {
    expect(donationRailOrder('RU'), [
      DonationRail.tribute,
      DonationRail.cloudTips,
      DonationRail.sponsors,
    ]);
    expect(donationRailOrder(null).first, DonationRail.sponsors);
    expect(donationPrefersCrypto('IR'), isTrue);
    expect(donationPrefersCrypto('CN'), isTrue);
    expect(donationPrefersCrypto('RU'), isFalse);
  });

  testWidgets('features the first regional rail above crypto in Russia', (
    tester,
  ) async {
    await _pumpDonate(tester, regionCode: 'RU');
    final l10n = AppLocalizations.current;

    expect(_headers(tester), [
      l10n.donateCards,
      l10n.donateCrypto,
      l10n.donateWithoutMoney,
    ]);
    expect(find.text(l10n.donateRecommended), findsOneWidget);
    expect(find.textContaining('Tribute'), findsOneWidget);
    expect(find.text(l10n.donateAction), findsOneWidget);
    expect(find.text('GitHub Sponsors'), findsOneWidget);
    expect(find.text('CloudTips'), findsNothing);
  });

  testWidgets('puts crypto first where local cards cannot pay abroad', (
    tester,
  ) async {
    await _pumpDonate(tester, regionCode: 'IR');
    final l10n = AppLocalizations.current;

    expect(_headers(tester), [
      l10n.donateCrypto,
      l10n.donateCards,
      l10n.donateWithoutMoney,
    ]);
    expect(find.text(l10n.donateAction), findsNothing);
    expect(find.text(l10n.donateCardsAbroad), findsOneWidget);
  });

  testWidgets('hides wallets without an address outside debug', (tester) async {
    await _pumpDonate(tester, regionCode: 'RU');

    expect(find.text('USDT'), findsWidgets);
    expect(find.text('TON'), findsWidgets);
    expect(find.text('XMR'), findsNothing);
  });

  testWidgets('shows unconfigured methods as placeholders in debug', (
    tester,
  ) async {
    await _pumpDonate(tester, regionCode: 'RU', includeUnconfigured: true);
    final l10n = AppLocalizations.current;

    expect(find.text('CloudTips'), findsOneWidget);
    expect(find.text('XMR'), findsOneWidget);
    expect(find.text(l10n.donateNotConfigured), findsOneWidget);
  });

  testWidgets('copies the address of the selected coin', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pumpDonate(tester, regionCode: 'RU');
    final l10n = AppLocalizations.current;

    expect(find.text('TUsdt'), findsOneWidget);
    await tester.tap(find.text('TON').first);
    await tester.pumpAndSettle();
    expect(find.text('UQTon'), findsOneWidget);
    expect(find.text('TUsdt'), findsNothing);

    await tester.tap(find.text(l10n.donateCopyAddress));
    await tester.pump();
    expect(copied, 'UQTon');
    expect(find.text(l10n.donateCopied), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text(l10n.donateCopyAddress), findsOneWidget);
  });
}
