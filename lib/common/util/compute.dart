import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

Map<String, Group> _indexGroups(Iterable<Group> groups) {
  final groupMap = <String, Group>{};
  for (final group in groups) {
    groupMap.putIfAbsent(group.name, () => group);
  }
  return groupMap;
}

List<Group> computeSort({
  required List<Group> groups,
  required ProxiesSortType sortType,
  required DelayMap delayMap,
  required Map<String, String> selectedMap,
  required String defaultTestUrl,
}) {
  final groupMap = _indexGroups(groups);

  List<Proxy> sortOfDelay({
    required List<Proxy> proxies,
    required String testUrl,
  }) {
    final delayStateByName = <String, DelayState>{};
    DelayState delayState(String proxyName) {
      return delayStateByName.putIfAbsent(
        proxyName,
        () => _computeProxyDelayState(
          proxyName: proxyName,
          testUrl: testUrl,
          groupMap: groupMap,
          selectedMap: selectedMap,
          delayMap: delayMap,
        ),
      );
    }

    return List.from(proxies)
      ..sort((a, b) => delayState(a.name).compareTo(delayState(b.name)));
  }

  List<Proxy> sortOfName(List<Proxy> proxies) {
    return List.of(proxies)..sort((a, b) => a.name.compareTo(b.name));
  }

  return groups.map((group) {
    final proxies = group.all;
    final newProxies = switch (sortType) {
      ProxiesSortType.none => proxies,
      ProxiesSortType.delay => sortOfDelay(
        proxies: proxies,
        testUrl: group.testUrl.takeFirstValid([defaultTestUrl]),
      ),
      ProxiesSortType.name => sortOfName(proxies),
    };
    return group.copyWith(all: newProxies);
  }).toList();
}

SelectedProxyState getRealSelectedProxyState(
  SelectedProxyState state, {
  required List<Group> groups,
  required Map<String, String> selectedMap,
}) {
  return _getRealSelectedProxyState(
    state,
    groupMap: _indexGroups(groups),
    selectedMap: selectedMap,
  );
}

SelectedProxyState _getRealSelectedProxyState(
  SelectedProxyState state, {
  required Map<String, Group> groupMap,
  required Map<String, String> selectedMap,
}) {
  var current = state;
  final visited = <String>{};
  while (current.proxyName.isNotEmpty) {
    if (!visited.add(current.proxyName)) {
      return current.copyWith(group: true);
    }
    final group = groupMap[current.proxyName];
    current = current.copyWith(group: true);
    if (group == null) {
      return current;
    }
    final currentSelectedName = group.getCurrentSelectedName(
      selectedMap[current.proxyName] ?? '',
    );
    if (currentSelectedName.isEmpty) {
      return current;
    }
    current = current.copyWith(
      proxyName: currentSelectedName,
      testUrl: group.testUrl,
    );
  }
  return current;
}

SelectedProxyState computeRealSelectedProxyState(
  String proxyName, {
  required List<Group> groups,
  required Map<String, String> selectedMap,
}) {
  return getRealSelectedProxyState(
    SelectedProxyState(proxyName: proxyName),
    groups: groups,
    selectedMap: selectedMap,
  );
}

String delayTestKey(String testUrl, String proxyName) {
  return '$testUrl\u0000$proxyName';
}

DelayState computeProxyDelayState({
  required String proxyName,
  required String testUrl,
  required List<Group> groups,
  required Map<String, String> selectedMap,
  required DelayMap delayMap,
}) {
  return _computeProxyDelayState(
    proxyName: proxyName,
    testUrl: testUrl,
    groupMap: _indexGroups(groups),
    selectedMap: selectedMap,
    delayMap: delayMap,
  );
}

DelayState _computeProxyDelayState({
  required String proxyName,
  required String testUrl,
  required Map<String, Group> groupMap,
  required Map<String, String> selectedMap,
  required DelayMap delayMap,
}) {
  final state = _getRealSelectedProxyState(
    SelectedProxyState(proxyName: proxyName),
    groupMap: groupMap,
    selectedMap: selectedMap,
  );
  final currentDelayMap =
      delayMap[state.testUrl.takeFirstValid([testUrl])] ?? {};
  final delay = currentDelayMap[state.proxyName];
  return DelayState(delay: delay ?? 0, group: state.group);
}
