import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'action.dart';
import 'app.dart';
import 'config.dart';
import 'core.dart';
import 'database.dart';
import 'state.dart';

part 'generated/routing.g.dart';

/// Versions of a user profile kept for "restore".
const rcxProfileHistory = 10;

/// The routing engine's last reported state. The Core pushes it on change;
/// the host only asks when it has nothing yet.
@Riverpod(keepAlive: true)
class RcxStatusState extends _$RcxStatusState {
  @override
  RcxStatus? build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next == CoreStatus.connected) {
        _sendForeground(ref.read(appVisibleProvider));
        unawaited(refresh());
      } else {
        state = null;
      }
    });
    ref.listen(appVisibleProvider, (_, visible) => _sendForeground(visible));
    return null;
  }

  Future<void> refresh() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) return;
    try {
      apply(await ref.read(coreHandlerProvider).rcxStatus());
    } catch (error) {
      commonPrint.log('rcxStatus failed: $error', logLevel: LogLevel.warning);
    }
  }

  /// A pick the engine made is saved like a manual one, so the proxies page
  /// and a headless restart show and restore the node actually in use,
  /// through every nested selector it took.
  void apply(RcxStatus status) {
    state = status;
    final picks = <String, String>{};
    for (final group in status.groups) {
      if (group.control.isManual || group.now.isEmpty) continue;
      final chain = [group.name, ...group.via, group.now];
      for (var i = 0; i + 1 < chain.length; i++) {
        picks[chain[i]] = chain[i + 1];
      }
    }
    ref.read(profilesActionProvider.notifier).mergeCurrentSelectedMap(picks);
  }

  /// The Core also pauses per-request traffic reports on this hint, so it
  /// goes out on every connection, before the engine may be ready to take it.
  void _sendForeground(bool visible) {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) return;
    unawaited(
      Future.sync(
        () => ref.read(coreHandlerProvider).rcxHints({'foreground': visible}),
      ).catchError((_) => false),
    );
  }
}

/// The tunnel mode in force: the scenario's while it holds the mode, else
/// the user's own.
@riverpod
Mode effectiveMode(Ref ref) {
  final own = ref.watch(patchClashConfigProvider.select((state) => state.mode));
  final status = ref.watch(rcxStatusStateProvider);
  if (status == null || !status.autoMode) return own;
  return Mode.values.asNameMap()[status.tunnelMode] ?? own;
}

@riverpod
RcxGroupStatus? rcxGroup(Ref ref, String groupName) {
  return ref.watch(rcxStatusStateProvider.select((s) => s?.group(groupName)));
}

/// The layer the Core runs: the current profile's choices plus the user's
/// own profiles and the hosts its subscription came from.
@riverpod
RcxUserLayer currentRoutingLayer(Ref ref) {
  final profile = ref.watch(currentProfileProvider);
  final library = ref.watch(rcxProfilesProvider);
  final layer = profile?.overrides.routing ?? const RcxUserLayer();
  return layer.copyWith(
    profiles: {
      for (final MapEntry(:key, :value) in library.entries)
        if (value.kind != 'scenario') key: value.text,
    },
    scenarios: {
      for (final MapEntry(:key, :value) in library.entries)
        if (value.kind == 'scenario') key: value.text,
    },
    providerHosts: profile == null ? const [] : _providerHosts(profile),
  );
}

List<String> _providerHosts(Profile profile) {
  return {
    for (final url in [
      profile.url,
      profile.subscriptionSnapshot?.metadata.text('routing.bundleUrl'),
    ])
      if (Uri.tryParse(url ?? '')?.host case final host? when host.isNotEmpty)
        host,
  }.toList();
}

/// The profile library as the Core sees it; refetched whenever the Core
/// rebuilds it.
@riverpod
Future<List<RcxProfileInfo>> rcxLibrary(Ref ref) async {
  ref.watch(rcxStatusStateProvider.select((status) => status?.library));
  if (ref.read(coreStatusProvider) != CoreStatus.connected) return const [];
  try {
    return await ref.read(coreHandlerProvider).rcxProfiles();
  } catch (_) {
    return const [];
  }
}

@Riverpod(keepAlive: true)
class RcxRoutingAction extends _$RcxRoutingAction {
  @override
  void build() {}

  /// Saves the group's choice in the current profile and hands the whole
  /// layer to the running engine at once; a null binding turns the group
  /// back into a plain selector.
  Future<void> setBinding(String groupName, RcxBinding? binding) {
    return _updateLayer((routing) {
      final groups = Map<String, RcxBinding>.from(routing.groups);
      if (binding == null) {
        groups.remove(groupName);
      } else {
        groups[groupName] = binding;
      }
      return routing.copyWith(groups: groups);
    });
  }

  /// Picks the auto control scenario [id] for the current subscription, or
  /// turns auto control off with null. A new pick takes the mode back.
  Future<void> setScenario(String? id) {
    return _updateLayer(
      (routing) => id == null
          ? routing.copyWith(scenarioOff: true)
          : routing.copyWith(
              scenario: id,
              scenarioOff: false,
              manualMode: false,
            ),
    );
  }

  /// [manual]: the user's own mode wins over the scenario's.
  Future<void> setManualMode(bool manual) {
    final current = ref.read(currentProfileProvider)?.overrides.routing;
    if (current == null || current.manualMode == manual) {
      return Future.value();
    }
    return _updateLayer((routing) => routing.copyWith(manualMode: manual));
  }

  /// Lets the current subscription's profiles contact [hosts].
  Future<void> trust(List<String> hosts) {
    return _updateLayer(
      (routing) =>
          routing.copyWith(trusted: {...routing.trusted, ...hosts}.toList()),
    );
  }

  Future<void> _updateLayer(
    RcxUserLayer Function(RcxUserLayer routing) update,
  ) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    final layer = update(profile.overrides.routing);
    ref
        .read(profilesProvider.notifier)
        .put(
          profile.copyWith(
            overrides: profile.overrides.copyWith(routing: layer),
          ),
        );
    await _push();
  }

  /// Saves the user's profile [name], keeping the replaced text in its
  /// history; a null [profile] deletes it.
  Future<void> saveProfile(String name, RcxUserProfile? profile) async {
    final notifier = ref.read(rcxProfilesProvider.notifier);
    final profiles = Map<String, RcxUserProfile>.from(notifier.value);
    final previous = profiles[name];
    if (profile == null) {
      profiles.remove(name);
    } else {
      profiles[name] = previous == null || previous.text == profile.text
          ? profile
          : profile.copyWith(
              history: [
                RcxProfileVersion(at: DateTime.now(), text: previous.text),
                ...previous.history,
              ].take(rcxProfileHistory).toList(),
            );
    }
    notifier.value = profiles;
    await _push();
  }

  Future<void> _push() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) return;
    try {
      ref
          .read(rcxStatusStateProvider.notifier)
          .apply(
            await ref
                .read(coreHandlerProvider)
                .rcxSetPolicy(ref.read(currentRoutingLayerProvider)),
          );
    } catch (error) {
      commonPrint.log('rcxSetPolicy failed: $error', logLevel: LogLevel.error);
    }
  }

  /// One profile-editor operation in the Core; null when it is not running
  /// or the request is malformed.
  Future<RcxStudioResult?> studio(Map<String, Object?> request) async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) return null;
    try {
      return await ref.read(coreHandlerProvider).rcxStudio(request);
    } catch (error) {
      commonPrint.log('rcxStudio failed: $error', logLevel: LogLevel.warning);
      return null;
    }
  }

  Future<bool> act(String groupName, RcxAction action, {String? node}) async {
    try {
      await ref
          .read(coreHandlerProvider)
          .rcxAction(group: groupName, action: action, node: node);
      await ref.read(rcxStatusStateProvider.notifier).refresh();
      return true;
    } catch (error) {
      commonPrint.log(
        'rcxAction($groupName, ${action.name}) failed: $error',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<RcxExplanation?> explain(String groupName) async {
    try {
      return await ref.read(coreHandlerProvider).rcxExplain(groupName);
    } catch (_) {
      return null;
    }
  }

  Future<List<RcxJournalEntry>> journal(String groupName) async {
    try {
      return await ref
          .read(coreHandlerProvider)
          .rcxJournal(group: groupName, limit: 100);
    } catch (_) {
      return const [];
    }
  }
}
