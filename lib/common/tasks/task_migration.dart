part of 'task.dart';

Future<MigrationData> oldToNowTask(Map<String, Object?> data) async {
  final homeDir = await appPath.homeDirPath;
  return compute<
    ({Map<String, Object?> configMap, String sourcePath, String targetPath}),
    MigrationData
  >(_oldToNowTask, (configMap: data, sourcePath: homeDir, targetPath: homeDir));
}

Future<MigrationData> _oldToNowTask(
  ({Map<String, Object?> configMap, String sourcePath, String targetPath}) data,
) {
  return migrateLegacyConfig(
    configMap: data.configMap,
    sourcePath: data.sourcePath,
    targetPath: data.targetPath,
  );
}

@visibleForTesting
Future<MigrationData> migrateLegacyConfig({
  required Map<String, Object?> configMap,
  required String sourcePath,
  required String targetPath,
}) async {
  final accessControlMap = configMap['accessControl'];
  final isAccessControl = configMap['isAccessControl'];
  if (accessControlMap != null) {
    (accessControlMap as Map)['enable'] = isAccessControl;
    if (configMap['vpnProps'] != null) {
      final vpnPropsRaw = configMap['vpnProps'] as Map;
      vpnPropsRaw['accessControl'] = accessControlMap;
    }
  }
  if (configMap['vpnProps'] != null) {
    final vpnPropsRaw = configMap['vpnProps'] as Map;
    vpnPropsRaw['accessControlProps'] = vpnPropsRaw['accessControl'];
  }
  configMap['davProps'] = configMap['dav'];
  final appSettingProps =
      configMap['appSetting'] as Map<String, dynamic>? ?? {};
  appSettingProps['restoreStrategy'] = appSettingProps['recoveryStrategy'];
  configMap['appSettingProps'] = appSettingProps;
  configMap['proxiesStyleProps'] = configMap['proxiesStyle'];
  List rawScripts = configMap['scripts'] as List<dynamic>? ?? [];
  if (rawScripts.isEmpty) {
    final scriptPropsJson = configMap['scriptProps'] as Map<String, dynamic>?;
    if (scriptPropsJson != null) {
      rawScripts = scriptPropsJson['scripts'] as List<dynamic>? ?? [];
    }
  }
  final Map<String, int> idMap = {};
  final List<Script> scripts = [];
  for (final rawScript in rawScripts) {
    final id = rawScript['id'] as String?;
    final content = rawScript['content'] as String?;
    final label = rawScript['label'] as String?;
    if (id == null || content == null || label == null) {
      continue;
    }
    final newId = idMap.updateCacheValue(rawScript['id'], () => snowflake.id);
    final path = _getScriptPath(targetPath, newId.toString());
    final file = File(path);
    await file.safeWriteAsString(content);
    scripts.add(
      Script(id: newId, label: label, lastUpdateTime: DateTime.now()),
    );
  }
  final List rawRules = configMap['rules'] as List<dynamic>? ?? [];
  final List<Rule> rules = [];
  final List<ProfileRuleLink> links = [];
  final List<ProxyGroup> proxyGroups = [];
  for (final rawRule in rawRules) {
    final id = idMap.updateCacheValue(rawRule['id'], () => snowflake.id);
    rawRule['id'] = id;
    final value = rawRule['value'] ?? '';
    rules.add(Rule.parse(value, id: id));
    links.add(ProfileRuleLink(ruleId: id));
  }
  final List rawProfiles = configMap['profiles'] as List<dynamic>? ?? [];
  final List<Profile> profiles = [];
  for (final rawProfile in rawProfiles) {
    final rawId = rawProfile['id'] as String?;
    if (rawId == null) {
      continue;
    }
    final profileId = idMap.updateCacheValue(rawId, () => snowflake.id);
    rawProfile['id'] = profileId;
    final overwrite = rawProfile['overwrite'] as Map?;
    if (overwrite != null) {
      final standardOverwrite = overwrite['standardOverwrite'] as Map?;
      if (standardOverwrite != null) {
        final addedRules = standardOverwrite['addedRules'] as List? ?? [];
        for (final addRule in addedRules) {
          final id = idMap.updateCacheValue(addRule['id'], () => snowflake.id);
          final value = addRule['value'] ?? '';
          rules.add(Rule.parse(value, id: id));
          links.add(
            ProfileRuleLink(
              profileId: profileId,
              ruleId: id,
              scene: RuleScene.added,
            ),
          );
        }
        final disabledRuleIds = standardOverwrite['disabledRuleIds'] as List?;
        if (disabledRuleIds != null) {
          for (final disabledRuleId in disabledRuleIds) {
            final newDisabledRuleId = idMap[disabledRuleId];
            if (newDisabledRuleId != null) {
              links.add(
                ProfileRuleLink(
                  profileId: profileId,
                  ruleId: newDisabledRuleId,
                  scene: RuleScene.disabled,
                ),
              );
            }
          }
        }
      }
      final scriptOverwrite = overwrite['scriptOverwrite'] as Map?;
      if (scriptOverwrite != null) {
        final scriptId = scriptOverwrite['scriptId'] as String?;
        rawProfile['scriptId'] = scriptId != null ? idMap[scriptId] : null;
      }
      rawProfile['overwriteType'] = overwrite['type'];
    }
    final overrideData = rawProfile['overrideData'];
    if (overrideData is Map && overrideData['enable'] == true) {
      final ruleData = overrideData['rule'];
      final customData = overrideData['custom'];
      final ruleType = ruleData is Map ? ruleData['type'] : null;
      if (ruleType == 'override' && ruleData is Map) {
        _addLegacyOverrideRules(
          ruleData['overrideRules'],
          profileId,
          RuleScene.custom,
          rules,
          links,
        );
        rawProfile['overwriteType'] = OverwriteType.custom.name;
      } else if (ruleType == 'added' && ruleData is Map) {
        _addLegacyOverrideRules(
          ruleData['addedRules'],
          profileId,
          RuleScene.added,
          rules,
          links,
        );
        rawProfile['overwriteType'] = OverwriteType.standard.name;
      } else if (ruleType == 'custom' && customData is Map) {
        _addLegacyOverrideRules(
          customData['rules'],
          profileId,
          RuleScene.custom,
          rules,
          links,
        );
        proxyGroups.addAll(
          _legacyProxyGroups(customData['proxyGroups'], profileId),
        );
        rawProfile['overwriteType'] = OverwriteType.custom.name;
      }
    }

    final sourceFile = File(_getProfilePath(sourcePath, rawId));
    final targetFilePath = _getProfilePath(targetPath, profileId.toString());
    await sourceFile.safeCopy(targetFilePath);
    profiles.add(Profile.fromJson(rawProfile));
  }
  final currentProfileId = configMap['currentProfileId'];
  configMap['currentProfileId'] = currentProfileId != null
      ? idMap[currentProfileId]
      : null;
  return MigrationData(
    configMap: configMap,
    profiles: profiles,
    rules: rules,
    scripts: scripts,
    links: links,
    proxyGroups: proxyGroups,
  );
}

void _addLegacyOverrideRules(
  Object? rawRules,
  int profileId,
  RuleScene scene,
  List<Rule> rules,
  List<ProfileRuleLink> links,
) {
  if (rawRules is! List) return;
  for (final rawRule in rawRules.whereType<Map>()) {
    final value = rawRule['value'];
    if (value is! String) continue;
    final rule = Rule.parse(value);
    rules.add(rule);
    links.add(
      ProfileRuleLink(profileId: profileId, ruleId: rule.id, scene: scene),
    );
  }
}

List<ProxyGroup> _legacyProxyGroups(Object? rawGroups, int profileId) {
  if (rawGroups is! List) return const [];
  return [
    for (final rawGroup in rawGroups.whereType<Map>())
      if (rawGroup['name'] is String && rawGroup['type'] is String)
        ProxyGroup.fromJson({
          ...Map<String, Object?>.from(rawGroup),
          'profileId': profileId,
          'type': GroupType.parse(rawGroup['type'] as String).value,
        }),
  ];
}

String _getScriptPath(String root, String fileName) {
  return join(root, 'scripts', '$fileName.js');
}

String _getProfilePath(String root, String fileName) {
  return join(root, 'profiles', '$fileName.yaml');
}
