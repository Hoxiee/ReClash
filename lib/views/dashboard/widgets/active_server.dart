import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeServerProvider = Provider<ActiveServerInfo>((ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  final smartRouting =
      mode == Mode.rule && ref.watch(smartRoutingSettingProvider).enabled;
  final routingStatus = smartRouting
      ? ref.watch(smartRoutingStatusProvider)
      : null;
  final engineNode = routingStatus?.node ?? '';
  final engineDecided = smartRouting && engineNode.isNotEmpty;
  final serverInfoHeader = ref.watch(
    currentProfileProvider.select((state) => state?.panelMeta?.serverInfoGroup),
  );
  final selected = ref.watch(
    groupsProvider.select(
      (state) => _selectServerInfo(switch (mode) {
        Mode.direct => const <Group>[],
        Mode.global => state.toList(),
        Mode.rule =>
          state
              .where((item) => item.hidden == false)
              .where((item) => item.name != GroupName.GLOBAL.name)
              .toList(),
      }, serverInfoHeader),
    ),
  );
  final serverName = engineDecided ? engineNode : selected.serverName;
  final testUrl = selected.testUrl;
  final delay = engineDecided
      ? (routingStatus!.delay > 0 ? routingStatus.delay : null)
      : serverName.isEmpty
      ? null
      : ref.watch(delayProvider(proxyName: serverName, testUrl: testUrl));
  final measuring =
      !engineDecided &&
      serverName.isNotEmpty &&
      ref.watch(
        delayTestPendingProvider(proxyName: serverName, testUrl: testUrl),
      );
  final otherCodes = engineDecided
      ? _trailCodes(ref.watch(smartRoutingTrailProvider), engineNode)
      : selected.flags.isEmpty
      ? const <String>[]
      : selected.flags.split(',');
  final otherLocations = engineDecided
      ? _enginePoolSize(routingStatus!)
      : selected.otherLocations;
  return ActiveServerInfo(
    name: serverName,
    displayName: stripLeadingEmoji(serverName),
    countryCode: flagToCountryCode(serverName),
    testUrl: testUrl,
    delay: delay,
    measuring: measuring,
    otherCodes: otherCodes,
    otherLocations: otherLocations,
    smartRouting: smartRouting,
  );
});

class ActiveServerInfo {
  const ActiveServerInfo({
    required this.name,
    required this.displayName,
    required this.countryCode,
    required this.testUrl,
    required this.delay,
    required this.measuring,
    required this.otherCodes,
    required this.otherLocations,
    required this.smartRouting,
  });

  final String name;
  final String displayName;
  final String? countryCode;
  final String? testUrl;
  final int? delay;
  final bool measuring;
  final List<String> otherCodes;
  final int otherLocations;
  final bool smartRouting;
}

typedef _SelectedServer = ({
  String serverName,
  String? testUrl,
  String flags,
  int otherLocations,
});

_SelectedServer _selectServerInfo(
  List<Group> groups,
  String? serverInfoHeader,
) {
  var serverName = '';
  String? testUrl;
  Group? activeGroup;
  if (serverInfoHeader != null && serverInfoHeader.isNotEmpty) {
    final group = groups.getGroup(serverInfoHeader.trim());
    if (group != null) {
      activeGroup = group;
      serverName = _resolveToDisplayName(groups, group.name);
      testUrl = group.testUrl;
    }
  }
  if (serverName.isEmpty) {
    for (final group in groups) {
      final now = group.realNow;
      if (now.isNotEmpty && now != 'DIRECT' && now != 'REJECT') {
        activeGroup = group;
        serverName = _resolveToDisplayName(groups, group.name);
        testUrl = group.testUrl;
        break;
      }
    }
  }
  final activeCode = flagToCountryCode(serverName)?.toUpperCase();
  final groupCodes = activeGroup == null
      ? const <String>[]
      : _collectGroupFlags(groups, activeGroup);
  final otherCodes = groupCodes
      .where((code) => code.toUpperCase() != activeCode)
      .toList();
  final rawOther = otherCodes.isNotEmpty
      ? otherCodes.length
      : activeGroup == null
      ? 0
      : activeGroup.all.length - 1;
  return (
    serverName: serverName,
    testUrl: testUrl,
    flags: otherCodes.join(','),
    otherLocations: rawOther < 0 ? 0 : rawOther,
  );
}

String _resolveToDisplayName(List<Group> groups, String proxyName) {
  final group = groups.getGroup(proxyName);
  if (group == null) return proxyName;
  final now = group.now;
  if (now == null || now.isEmpty) return group.name;
  return now;
}

List<String> _collectGroupFlags(List<Group> groups, Group group) {
  final seen = <String>{};
  final codes = <String>[];

  void walk(Group current, int depth) {
    if (depth > 4) return;
    for (final proxy in current.all) {
      final code = flagToCountryCode(proxy.name);
      if (code != null) {
        if (seen.add(code)) codes.add(code);
      } else {
        final child = groups.getGroup(proxy.name);
        if (child != null) walk(child, depth + 1);
      }
    }
  }

  walk(group, 0);
  return codes;
}

String? flagToCountryCode(String text) {
  final runes = text.runes.toList();
  for (var index = 0; index < runes.length - 1; index++) {
    final first = runes[index];
    final second = runes[index + 1];
    if (first >= 0x1F1E6 &&
        first <= 0x1F1FF &&
        second >= 0x1F1E6 &&
        second <= 0x1F1FF) {
      return String.fromCharCodes([
        first - 0x1F1E6 + 0x41,
        second - 0x1F1E6 + 0x41,
      ]);
    }
  }
  return null;
}

String stripLeadingEmoji(String text) {
  bool isEmojiRune(int rune) =>
      (rune >= 0x1F000 && rune <= 0x1FAFF) ||
      (rune >= 0x2600 && rune <= 0x27BF) ||
      (rune >= 0x2190 && rune <= 0x21FF) ||
      (rune >= 0x2B00 && rune <= 0x2BFF) ||
      (rune >= 0x2300 && rune <= 0x23FF) ||
      rune == 0x200D ||
      rune == 0xFE0F;
  bool isSpace(int rune) =>
      rune == 0x20 || rune == 0x09 || rune == 0xA0 || rune == 0x0A;

  final runes = text.runes.toList();
  var start = 0;
  while (start < runes.length &&
      (isEmojiRune(runes[start]) || isSpace(runes[start]))) {
    start++;
  }
  return String.fromCharCodes(
    runes.sublist(start),
  ).replaceAll(RegExp(r'\s+'), ' ').trim();
}

List<String> _trailCodes(List<String> trail, String current) {
  final codes = <String>[];
  for (final node in trail) {
    if (node == current) continue;
    final code = flagToCountryCode(node);
    if (code != null) codes.add(code);
  }
  return codes;
}

int _enginePoolSize(RcxStatus status) {
  final pool = status.eligible > 0 ? status.eligible : status.candidates;
  return pool > 1 ? pool - 1 : 0;
}
