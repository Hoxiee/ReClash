import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';

ProviderContainer _container(Map<String, List<String>> headers) =>
    ProviderContainer(
      overrides: [
        providerPolicyProvider.overrideWithValue(null),
        providerHintsProvider.overrideWithValue(
          ProviderHints(readSubscriptionMetadata(headers).metadata),
        ),
      ],
    );

void main() {
  test('closing provider-restricted ports preserves the other settings', () {
    const config = PatchClashConfig(
      mixedPort: 7890,
      port: 7891,
      socksPort: 7892,
      redirPort: 7893,
      tproxyPort: 7894,
      mode: Mode.global,
      allowLan: true,
      ipv6: false,
      secret: 'unchanged',
    );
    final effective = withoutLocalProxyPorts(config);
    expect(
      effective,
      config.copyWith(
        mixedPort: 0,
        port: 0,
        socksPort: 0,
        redirPort: 0,
        tproxyPort: 0,
      ),
    );
    expect(config.mixedPort, 7890);
    expect(withoutLocalProxyPorts(effective), effective);
  });
  test('noglobal removes the Global mode', () {
    final container = _container({
      'reclash-restrictions': ['noglobal'],
    });
    addTearDown(container.dispose);
    expect(container.read(availableModesProvider), [Mode.rule, Mode.direct]);
  });

  test('a required empty global allowlist removes Global', () {
    final container = ProviderContainer(
      overrides: [
        providerHintsProvider.overrideWithValue(ProviderHints.empty),
        providerPolicyProvider.overrideWithValue(
          const ProviderPolicy(globalAllow: []),
        ),
      ],
    );
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
      providerPolicyProvider.overrideWithValue(null),
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
      providerPolicyProvider.overrideWithValue(null),
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
