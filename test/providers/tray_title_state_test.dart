import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('disabled tray title ignores traffic updates', () async {
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: false));
    final states = <TrayTitleState>[];
    final subscription = container.listen(
      trayTitleStateProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    container
        .read(trafficsProvider.notifier)
        .addTraffic(const Traffic(up: 1, down: 2));
    await container.pump();

    expect(states, hasLength(1));
    expect(states.single.showTrayTitle, isFalse);
  });

  test('enabled tray title follows traffic updates', () async {
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: true));
    final states = <TrayTitleState>[];
    final subscription = container.listen(
      trayTitleStateProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    container
        .read(trafficsProvider.notifier)
        .addTraffic(const Traffic(up: 3, down: 4));
    await container.pump();

    expect(states, hasLength(2));
    expect(states.last.traffic, const Traffic(up: 3, down: 4));
  });
}
