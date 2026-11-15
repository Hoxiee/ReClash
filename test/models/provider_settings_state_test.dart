import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/provider_settings.dart';

import '../helpers/provider_presentation.dart';

const _providerFile = 'fedcba9876543210fedcba9876543210.png';

/// State saved before the background opacity became its own setting.
Map<String, Object?> _savedBeforeOpacitySplit() =>
    jsonDecode(
          jsonEncode({
            'applied': {
              'proxies.type': 'list',
              'background': {
                'enabled': true,
                'fileName': _providerFile,
                'opacity': 0.2,
              },
            },
            'userBaseline': {
              'proxies.type': 'tab',
              'background': {
                'enabled': false,
                'fileName': null,
                'opacity': 0.5,
              },
            },
            'userOwned': <String>[],
          }),
        )
        as Map<String, Object?>;

void main() {
  test('saved background opacity leaves applied and baseline', () {
    final state = ProviderSettingsState.safeFromJson(
      _savedBeforeOpacitySplit(),
    );

    expect(state.applied, {
      'proxies.type': 'list',
      'background': {'enabled': true, 'fileName': _providerFile},
    });
    expect(state.userBaseline, {
      'proxies.type': 'tab',
      'background': {'enabled': false, 'fileName': null},
    });
    expect(state.userOwned, isEmpty);
  });

  test('a provider background saved with its opacity is not a user change', () {
    final saved = ProviderSettingsState.safeFromJson(
      _savedBeforeOpacitySplit(),
    );
    final base = Config.realFromJson(null);
    final config = base.copyWith(
      themeProps: base.themeProps.copyWith(
        wallpaper: const WallpaperProps(
          enabled: true,
          fileName: _providerFile,
          opacity: 0.2,
        ),
      ),
      providerSettings: saved,
    );
    final input = ProviderSettingsInput(
      presentedHints({
        'wallpaper': {'url': 'https://img.example.test/bg.png', 'opacity': 22},
      }),
      backgroundFile: _providerFile,
    );

    final applied = applyProviderSettings(config, input);

    expect(applied.providerSettings.userOwned, isNot(contains('background')));
    expect(isProviderManaged(applied, 'background'), isTrue);
    expect(applied.themeProps.wallpaper.fileName, _providerFile);
    expect(applied.themeProps.wallpaper.opacity, 0.22);
  });
}
