import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

Profile _profile(int id, {String? view}) => Profile(
  id: id,
  autoUpdateDuration: Duration.zero,
  panelMeta: view == null ? null : PanelMeta(proxiesView: view),
);

void main() {
  ProviderContainer buildContainer(List<Profile> profiles, int currentId) {
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(() => TestProfiles(profiles))],
    );
    container.read(currentProfileIdProvider.notifier).value = currentId;
    addTearDown(container.dispose);
    return container;
  }

  final profiles = [_profile(1, view: 'type:list; card:min'), _profile(2)];

  test('the panel view dresses the page of its own subscription', () {
    final container = buildContainer(profiles, 1);
    final style = container.read(effectiveProxiesStyleProvider);
    expect(style.type, ProxiesType.list);
    expect(style.cardType, ProxyCardType.min);
  });

  test('switching away from that subscription restores the user own view', () {
    final container = buildContainer(profiles, 1);
    container.read(currentProfileIdProvider.notifier).value = 2;
    final style = container.read(effectiveProxiesStyleProvider);
    const user = ProxiesStyleProps();
    expect(style.type, user.type);
    expect(style.cardType, user.cardType);
  });

  test('a field the user claimed outranks the panel', () {
    final container = buildContainer(profiles, 1);
    container
        .read(proxiesStyleSettingProvider.notifier)
        .value = const ProxiesStyleProps()
        .claim(ProxiesStyleField.cardType)
        .copyWith(cardType: ProxyCardType.shrink);
    final style = container.read(effectiveProxiesStyleProvider);
    expect(style.cardType, ProxyCardType.shrink);
    expect(style.type, ProxiesType.list);
  });

  test('the panel is ignored once the user stops following it', () {
    final container = buildContainer(profiles, 1);
    container.read(proxiesStyleSettingProvider.notifier).value =
        const ProxiesStyleProps(followPanel: false);
    expect(
      container.read(effectiveProxiesStyleProvider),
      const ProxiesStyleProps(followPanel: false),
    );
  });
}
