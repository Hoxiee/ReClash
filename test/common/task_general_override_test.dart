import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _profile = <String, dynamic>{
  'unified-delay': false,
  'tcp-concurrent': false,
  'ipv6': true,
  'geodata-loader': 'standard',
};

Future<YamlMap> _configOf(
  PatchClashConfig patchConfig, {
  Map<String, dynamic> profile = _profile,
}) async {
  final result = await makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: profile,
      realPatchConfig: patchConfig,
      overrides: const ProfileOverrides(),
      appendSystemDns: false,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'ReClash-Test',
    ),
  );
  return loadYaml(result.yaml) as YamlMap;
}

void main() {
  test('leaves the profile alone without picked keys', () async {
    final config = await _configOf(const PatchClashConfig());

    for (final MapEntry(:key, :value) in _profile.entries) {
      expect(config[key], value, reason: key);
    }
  });

  test('replaces only the picked keys', () async {
    final config = await _configOf(
      const PatchClashConfig(
        tcpConcurrent: true,
        geodataLoader: GeodataLoader.memconservative,
        generalOverrideKeys: {
          GeneralOverrideKey.tcpConcurrent,
          GeneralOverrideKey.geodataLoader,
        },
      ),
    );

    expect(config['tcp-concurrent'], true);
    expect(config['geodata-loader'], 'memconservative');
    expect(config['unified-delay'], false);
    expect(config['ipv6'], true);
  });

  test('turns unified delay on when the profile leaves it unset', () async {
    final config = await _configOf(const PatchClashConfig(), profile: {});

    expect(config['unified-delay'], true);
  });

  test('keeps the test URL out of the profile', () async {
    final config = await _configOf(
      const PatchClashConfig(
        testUrl: 'https://probe.test/204',
        generalOverrideKeys: {GeneralOverrideKey.testUrl},
      ),
    );

    expect(config.containsKey('test-url'), isFalse);
  });
}
