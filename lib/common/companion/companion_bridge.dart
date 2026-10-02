import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';

// Answers companion reads/commands from the retained engine's container, so a controlled device
// with no Activity still converges (I15). A subscription URL, credentials and raw YAML never leave
// through here (I08/I16): snapshots carry only labels, quotas and selection names.
void registerCompanionBridge() {
  const channel = MethodChannel('$packageName/companion_bridge');
  channel.setMethodCallHandler((call) async {
    final container = globalState.container;
    switch (call.method) {
      case 'readState':
      case 'readProfiles':
      case 'readGroups':
        // A read off a half-initialized container must surface as unreachable, not a raw
        // PlatformException; the command path already guards itself below.
        try {
          return switch (call.method) {
            'readState' => _readState(container),
            'readProfiles' => _readProfiles(container),
            _ => _readGroups(container),
          };
        } catch (error) {
          throw PlatformException(code: 'appUnavailable');
        }
      case 'command':
        final args = (call.arguments as Map).cast<String, dynamic>();
        return _runCommand(container, args);
      default:
        throw MissingPluginException();
    }
  });
}

Map<String, dynamic> _readState(ProviderContainer container) {
  final running = container.read(isStartProvider);
  final profile = container.read(currentProfileProvider);
  final groups = container.read(currentGroupsStateProvider).value;
  final traffic = container.read(totalTrafficProvider);
  final currentGroupName = profile?.currentGroupName;
  final currentGroup = currentGroupName == null
      ? null
      : groups.firstWhereOrNull((group) => group.name == currentGroupName);
  final currentNode = currentGroup == null
      ? null
      : container.read(selectedProxyNameProvider(currentGroup.name));
  final info = profile?.subscriptionInfo;
  return {
    'running': running,
    'profileLabel': profile?.label ?? '',
    'groupName': currentGroup?.name,
    'nodeName': currentNode,
    'trafficUp': traffic.up.toInt(),
    'trafficDown': traffic.down.toInt(),
    'subscription': info == null || !info.hasFacts
        ? null
        : {
            'upload': info.upload,
            'download': info.download,
            'total': info.total,
            'expire': info.expire,
          },
    'outboundMode': container.read(uiOutboundModeProvider).name,
    'revision': _stateRevision(
      running,
      profile,
      currentGroup?.name,
      currentNode,
      container.read(uiOutboundModeProvider),
    ),
  };
}

// A content hash of the volatile fields so a poller can tell "nothing changed" cheaply.
int _stateRevision(
  bool running,
  Profile? profile,
  String? groupName,
  String? nodeName,
  UiOutboundMode mode,
) => Object.hash(
  running,
  profile?.id,
  profile?.label,
  groupName,
  nodeName,
  mode,
);

List<Map<String, dynamic>> _readProfiles(ProviderContainer container) {
  final profiles = container.read(profilesProvider);
  final currentId = container.read(currentProfileIdProvider);
  return profiles
      .map(
        (profile) => {
          'id': profile.id,
          'label': profile.label,
          'active': profile.id == currentId,
          'lastUpdate': profile.lastUpdateDate?.millisecondsSinceEpoch,
        },
      )
      .toList();
}

List<Map<String, dynamic>> _readGroups(ProviderContainer container) {
  final groups = container.read(currentGroupsStateProvider).value;
  return groups
      .map(
        (group) => {
          'name': group.name,
          'type': group.type.name,
          'selected': container.read(selectedProxyNameProvider(group.name)),
          'options': group.all
              .map(
                (proxy) => {
                  'name': proxy.name,
                  'type': proxy.type,
                  'delayMs': container.read(
                    delayProvider(
                      proxyName: proxy.name,
                      testUrl: group.testUrl,
                    ),
                  ),
                },
              )
              .toList(),
        },
      )
      .toList();
}

// A toggle that could not be confirmed reports outcomeUnknown, never succeeded (I13).
Future<Map<String, dynamic>> _runCommand(
  ProviderContainer container,
  Map<String, dynamic> args,
) async {
  final kind = args['kind'] as String?;
  final arguments = (args['arguments'] as Map?)?.cast<String, dynamic>() ?? {};
  try {
    switch (kind) {
      case 'connection.setRunning':
        final target = arguments['running'] as bool? ?? false;
        final ok = await container
            .read(setupActionProvider.notifier)
            .setRunning(target, initialize: target);
        return {
          'status': ok ? 'succeeded' : 'outcomeUnknown',
          'effectState': 'applied',
        };
      case 'groups.select':
        final groupName = arguments['groupName'] as String?;
        final proxyName = arguments['proxyName'] as String?;
        if (groupName == null || proxyName == null) {
          return _commandError('invalidInput');
        }
        final message = await container
            .read(proxiesActionProvider.notifier)
            .changeProxyChecked(groupName: groupName, proxyName: proxyName);
        return message == null
            ? {'status': 'succeeded', 'effectState': 'applied'}
            : _commandError('applyFailed');
      case 'profiles.select':
        final id = (arguments['id'] as num?)?.toInt();
        if (id == null ||
            !container.read(profilesProvider).any((item) => item.id == id)) {
          return _commandError('invalidInput');
        }
        container.read(currentProfileIdProvider.notifier).value = id;
        container.read(profilesActionProvider.notifier).markProfileUsed(id);
        final selected = await container
            .read(setupActionProvider.notifier)
            .scheduleFullSetup();
        return {
          'status': 'succeeded',
          'effectState': selected ? 'applied' : 'pending',
        };
      case 'profiles.importUrl':
      case 'profiles.update':
        final url = arguments['url'] as String?;
        if (url == null || url.isEmpty) return _commandError('invalidInput');
        final name = arguments['name'] as String?;
        // Re-importing a known URL switches to it and refreshes, never stacking a duplicate.
        final existing = container
            .read(profilesProvider)
            .firstWhereOrNull((item) => item.url == url);
        if (existing != null) {
          container.read(currentProfileIdProvider.notifier).value = existing.id;
          if (name != null && name.isNotEmpty && name != existing.label) {
            // userLabel keeps the rename from being overwritten by the subscription label on refresh.
            container
                .read(profilesProvider.notifier)
                .updateProfile(
                  existing.id,
                  (profile) => profile.copyWith(label: name, userLabel: true),
                );
          }
          await container
              .read(profilesActionProvider.notifier)
              .updateProfile(existing);
          final refreshed = await container
              .read(setupActionProvider.notifier)
              .scheduleFullSetup();
          return {
            'status': 'succeeded',
            'effectState': refreshed ? 'applied' : 'pending',
          };
        }
        final imported = await container
            .read(profilesActionProvider.notifier)
            .importProfileHeadless(ProfileLinkImportRequest(url, name: name));
        if (imported == null) return _commandError('applyFailed');
        container.read(currentProfileIdProvider.notifier).value = imported.id;
        final applied = await container
            .read(setupActionProvider.notifier)
            .scheduleFullSetup();
        return {
          'status': 'succeeded',
          'effectState': applied ? 'applied' : 'pending',
        };
      case 'settings.setOutboundMode':
        final modeName = arguments['mode'] as String?;
        final mode = UiOutboundMode.values.firstWhereOrNull(
          (value) => value.name == modeName,
        );
        if (mode == null) return _commandError('invalidInput');
        container.read(setupActionProvider.notifier).changeUiMode(mode);
        final applied = await container
            .read(setupActionProvider.notifier)
            .scheduleFullSetup();
        return {
          'status': 'succeeded',
          'effectState': applied ? 'applied' : 'pending',
        };
      case 'profiles.updateCurrent':
        final profile = container.read(currentProfileProvider);
        if (profile == null || profile.type != ProfileType.url) {
          return _commandError('invalidInput');
        }
        await container
            .read(profilesActionProvider.notifier)
            .updateProfile(profile);
        final refreshed = await container
            .read(setupActionProvider.notifier)
            .scheduleFullSetup();
        return {
          'status': 'succeeded',
          'effectState': refreshed ? 'applied' : 'pending',
        };
      default:
        return _commandError('invalidInput');
    }
  } catch (error) {
    commonPrint.log(
      'Companion command $kind failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
    return _commandError('applyFailed');
  }
}

Map<String, dynamic> _commandError(String code) => {
  'status': 'failed',
  'effectState': 'configured',
  'error': code,
};
