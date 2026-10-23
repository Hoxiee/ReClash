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

  test('only notices are dismissible and changed content shows again', () {
    final container = _container({
      'announce': ['Plan description'],
      'reclash-notice': ['Maintenance tonight'],
      'reclash-noticeurl': ['https://status.example.test'],
    });
    addTearDown(container.dispose);
    final card = container.read(providerNoticeProvider)!;
    expect(card.announcement.text, 'Maintenance tonight');
    container.read(dismissedNoticesProvider.notifier).state = {card.id};
    expect(container.read(providerNoticeProvider), isNull);
    expect(
      container.read(providerAnnouncementProvider)?.text,
      'Plan description',
    );

    container.updateOverrides([
      providerHintsProvider.overrideWithValue(
        ProviderHints(
          readSubscriptionMetadata({
            'announce': ['Plan description'],
            'reclash-notice': ['Maintenance tomorrow'],
            'reclash-noticeurl': ['https://status.example.test'],
          }).metadata,
        ),
      ),
    ]);
    expect(
      container.read(providerNoticeProvider)?.announcement.text,
      'Maintenance tomorrow',
    );
  });

  test('a changed notice link shows again', () {
    final container = _container({
      'reclash-notice': ['Maintenance'],
      'reclash-noticeurl': ['https://status.example.test/one'],
    });
    addTearDown(container.dispose);
    final card = container.read(providerNoticeProvider)!;
    container.read(dismissedNoticesProvider.notifier).state = {card.id};
    container.updateOverrides([
      providerHintsProvider.overrideWithValue(
        ProviderHints(
          readSubscriptionMetadata({
            'reclash-notice': ['Maintenance'],
            'reclash-noticeurl': ['https://status.example.test/two'],
          }).metadata,
        ),
      ),
    ]);
    expect(
      container.read(providerNoticeProvider)?.announcement.link?.path,
      '/two',
    );
  });
}
