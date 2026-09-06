import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  Profile profileWith({String? themeHex, required int id}) {
    return Profile.normal().copyWith(
      id: id,
      panelMeta: themeHex == null ? null : PanelMeta(themeHex: themeHex),
    );
  }

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(() => TestProfiles())],
    );
  });

  tearDown(() {
    container.dispose();
  });

  void switchTo(List<Profile> profiles, int? id) {
    for (final profile in profiles) {
      container.read(profilesProvider.notifier).put(profile);
    }
    container.read(currentProfileIdProvider.notifier).value = id;
  }

  test('dresses the panel theme over the user theme while active', () {
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(primaryColor: 0xFF123456));

    switchTo([profileWith(themeHex: '6E55F5:vibrant', id: 1)], 1);

    final effective = container.read(effectiveThemePropsProvider);
    expect(effective.primaryColor, 0xFF6E55F5);
    expect(effective.schemeVariant, DynamicSchemeVariant.vibrant);

    expect(
      container.read(themeSettingProvider).primaryColor,
      0xFF123456,
      reason: 'the user theme must stay untouched underneath',
    );
  });

  test('restores the user theme when the active profile has none', () {
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(primaryColor: 0xFF123456));

    switchTo([profileWith(themeHex: '6E55F5', id: 1), profileWith(id: 2)], 1);
    expect(container.read(effectiveThemePropsProvider).primaryColor, 0xFF6E55F5);

    container.read(currentProfileIdProvider.notifier).value = 2;
    expect(
      container.read(effectiveThemePropsProvider).primaryColor,
      0xFF123456,
    );
  });

  test('a profile without panel meta leaves the user theme alone', () {
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(pureBlack: true));

    switchTo([profileWith(id: 1)], 1);
    expect(container.read(effectiveThemePropsProvider).pureBlack, isTrue);
  });

  test('partial panel tokens only override what they carry', () {
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(pureBlack: true));

    switchTo([profileWith(themeHex: '6E55F5', id: 1)], 1);

    final effective = container.read(effectiveThemePropsProvider);
    expect(effective.primaryColor, 0xFF6E55F5);
    expect(effective.pureBlack, isTrue);
    expect(
      effective.schemeVariant,
      container.read(themeSettingProvider).schemeVariant,
    );
  });
}
