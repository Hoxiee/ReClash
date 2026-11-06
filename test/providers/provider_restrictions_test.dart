import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';

import '../helpers/provider_presentation.dart';

ProviderContainer _container(Map<String, Object?> sections) =>
    ProviderContainer(
      overrides: [
        providerPolicyProvider.overrideWithValue(null),
        providerHintsProvider.overrideWithValue(
          ProviderHints(manifestMetadata(sections)),
        ),
      ],
    );

Map<String, Object?> _provider(
  String? announce,
  String notice, [
  String link = 'https://status.example.test',
]) => {
  'provider': {
    'announce': ?announce == null ? null : {'text': announce},
    'notice': {'text': notice, 'url': link},
  },
};

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
  test('policy global off removes the Global mode', () {
    final container = _container({
      'policy': {'global': 'off'},
    });
    addTearDown(container.dispose);
    expect(container.read(availableModesProvider), [Mode.rule, Mode.direct]);
  });

  test('a listed global policy with no nodes removes Global', () {
    final container = ProviderContainer(
      overrides: [
        providerHintsProvider.overrideWithValue(ProviderHints.empty),
        providerPolicyProvider.overrideWithValue(
          const ProviderPolicy(lockGlobal: true, globalEmpty: true),
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
    final container = _container(
      _provider('Plan description', 'Maintenance tonight'),
    );
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
          manifestMetadata(
            _provider('Plan description', 'Maintenance tomorrow'),
          ),
        ),
      ),
    ]);
    expect(
      container.read(providerNoticeProvider)?.announcement.text,
      'Maintenance tomorrow',
    );
  });

  test('a changed notice link shows again', () {
    final container = _container(
      _provider(null, 'Maintenance', 'https://status.example.test/one'),
    );
    addTearDown(container.dispose);
    final card = container.read(providerNoticeProvider)!;
    container.read(dismissedNoticesProvider.notifier).state = {card.id};
    container.updateOverrides([
      providerPolicyProvider.overrideWithValue(null),
      providerHintsProvider.overrideWithValue(
        ProviderHints(
          manifestMetadata(
            _provider(null, 'Maintenance', 'https://status.example.test/two'),
          ),
        ),
      ),
    ]);
    expect(
      container.read(providerNoticeProvider)?.announcement.link?.path,
      '/two',
    );
  });
}
