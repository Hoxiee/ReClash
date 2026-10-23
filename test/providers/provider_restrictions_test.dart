import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';

ProviderContainer _container(Map<String, List<String>> headers) =>
    ProviderContainer(
      overrides: [
        providerHintsProvider.overrideWithValue(
          ProviderHints(readSubscriptionMetadata(headers).metadata),
        ),
      ],
    );

void main() {
  test('noglobal removes the Global mode', () {
    final container = _container({
      'reclash-restrictions': ['noglobal'],
    });
    addTearDown(container.dispose);
    expect(container.read(availableModesProvider), [Mode.rule, Mode.direct]);
  });

  test('without restrictions every mode is offered', () {
    final container = _container({});
    addTearDown(container.dispose);
    expect(container.read(availableModesProvider), Mode.values);
  });

  test('the announcement shows until its text is dismissed', () {
    final container = _container({
      'announce': ['Maintenance tonight'],
    });
    addTearDown(container.dispose);
    final card = container.read(providerAnnouncementProvider)!;
    expect(card.announcement.text, 'Maintenance tonight');
    container.read(dismissedAnnouncementsProvider.notifier).state = {card.id};
    expect(container.read(providerAnnouncementProvider), isNull);
  });
}
