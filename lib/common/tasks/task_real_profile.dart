part of 'task.dart';

// A profile that owns the name wins: our insertion is not worth overwriting it.
void appendDesyncProxy({
  required Map<dynamic, dynamic> rawConfig,
  required int port,
}) {
  final existing = rawConfig['proxies'];
  final proxies = existing is List ? existing : const [];
  final taken = proxies.map(
    (proxy) => proxy is Map ? proxy['name']?.toString() : null,
  );
  if (taken.contains(desyncOutboundName)) {
    return;
  }
  rawConfig['proxies'] = <Object?>[
    ...proxies,
    <String, Object?>{
      'name': desyncOutboundName,
      'type': 'socks5',
      'server': '127.0.0.1',
      'port': port,
      'udp': true,
    },
  ];
}

// A provider key pointing at the reserved name breaks that node's every dial
// while the feature is off: no outbound exists for the dialer to resolve.
void stripDesyncDialerProxy(Map<dynamic, dynamic> rawConfig) {
  final proxies = rawConfig['proxies'];
  if (proxies is! List) return;
  for (final proxy in proxies) {
    if (proxy is Map && proxy['dialer-proxy'] == desyncOutboundName) {
      proxy.remove('dialer-proxy');
    }
  }
}

List<String> desyncRules({
  required List<DesyncCategory> categories,
  required bool forceTcp,
}) {
  if (categories.isEmpty) {
    return const [];
  }
  return [
    if (forceTcp)
      for (final category in categories)
        'AND,((NETWORK,udp),(DST-PORT,443),(GEOSITE,${category.geosite})),REJECT',
    for (final category in categories)
      'GEOSITE,${category.geosite},$desyncOutboundName',
    for (final category in categories)
      for (final cidr in category.cidrs)
        if (forceTcp)
          'AND,((NETWORK,udp),(DST-PORT,443),(IP-CIDR,$cidr)),REJECT',
    for (final category in categories)
      for (final cidr in category.cidrs) 'IP-CIDR,$cidr,$desyncOutboundName',
  ];
}

// Only-dpi keeps the profile's own MATCH out of play: everything the engine
// cannot desync must reach the network the plain way, not die on its triggers.
List<String> desyncOnlyFallback() => ['MATCH,DIRECT'];

Future<({String yaml, String md5})> makeRealProfileTask(
  MakeRealProfileState data,
) async {
  return compute<MakeRealProfileState, ({String yaml, String md5})>(
    _makeRealProfileTask,
    data,
  );
}

Future<({String yaml, String md5})> _makeRealProfileTask(
  MakeRealProfileState data,
) async {
  final rawConfig = Map.from(data.rawConfig);
  final realPatchConfig = data.realPatchConfig;
  final profilesPath = data.profilesPath;
  final profileId = data.profileId;
  final overrideDns = data.overrideDns;
  final addedRules = data.addedRules;
  final appendSystemDns = data.appendSystemDns;
  final defaultUA = data.defaultUA;
  String getProvidersFilePathInner(String type, String key) {
    return join(
      profilesPath,
      providersDirectoryName,
      profileId.toString(),
      type,
      key.toMd5(),
    );
  }

  void confineProviders(String section, String type) {
    final providers = rawConfig[section];
    if (providers is! Map) {
      return;
    }
    for (final name in providers.keys) {
      final provider = providers[name];
      if (provider is! Map || provider['type'] == 'inline') {
        continue;
      }
      // Two providers may share a URL and differ only by header.
      final url = provider['url'];
      final hasUrl = url is String && url.isNotEmpty;
      final path = getProvidersFilePathInner(
        type,
        hasUrl ? '$name@$url' : '$section/$name',
      );
      provider['path'] = path;
    }
  }

  rawConfig['external-controller'] = realPatchConfig.externalController.value;
  // An external-ui the Core cannot read makes it download one instead, and it
  // does that synchronously inside every config apply.
  final homeDirPath = dirname(profilesPath);
  rawConfig['external-ui'] = isWebDashboardInstalledIn(homeDirPath)
      ? webDashboardDirName
      : '';
  switch (realPatchConfig.interfaceNameMode) {
    case InterfaceNameMode.clear:
      rawConfig['interface-name'] = '';
    case InterfaceNameMode.follow:
      break;
    case InterfaceNameMode.custom:
      rawConfig['interface-name'] = realPatchConfig.interfaceName;
  }
  rawConfig['external-ui-url'] = '';
  rawConfig['tcp-concurrent'] = realPatchConfig.tcpConcurrent;
  rawConfig['unified-delay'] = realPatchConfig.unifiedDelay;
  rawConfig['log-level'] = realPatchConfig.logLevel.name;
  rawConfig['keep-alive-interval'] = realPatchConfig.keepAliveInterval;
  // Keys the provider owns: a subscription value survives unless the user
  // opted into overriding it; the patch value only fills a missing key.
  void patchNetwork(String key, Object? value) {
    if (data.overrideNetwork || !rawConfig.containsKey(key)) {
      rawConfig[key] = value;
    }
  }

  patchNetwork('ipv6', realPatchConfig.ipv6);
  patchNetwork('mixed-port', realPatchConfig.mixedPort);
  patchNetwork('port', realPatchConfig.port);
  patchNetwork('socks-port', realPatchConfig.socksPort);
  patchNetwork('find-process-mode', realPatchConfig.findProcessMode.name);
  patchNetwork('allow-lan', realPatchConfig.allowLan);
  // redir/tproxy arm netfilter listeners the sandbox cannot.
  rawConfig['redir-port'] = realPatchConfig.redirPort;
  rawConfig['tproxy-port'] = realPatchConfig.tproxyPort;
  // The app owns local inbound authentication; a profile-provided
  // skip-auth-prefixes could silently exempt loopback and defeat it.
  rawConfig['authentication'] = data.authentication;
  rawConfig['skip-auth-prefixes'] = [];
  rawConfig['mode'] = realPatchConfig.mode.name;
  if (rawConfig['tun'] is! Map) {
    rawConfig['tun'] = {};
  }
  rawConfig['tun']['enable'] = realPatchConfig.tun.enable;
  rawConfig['tun']['device'] = realPatchConfig.tun.device;
  rawConfig['tun']['dns-hijack'] = realPatchConfig.tun.dnsHijack;
  if (data.overrideNetwork || rawConfig['tun']['stack'] == null) {
    rawConfig['tun']['stack'] = realPatchConfig.tun.stack.name;
  }
  rawConfig['tun']['route-address'] = realPatchConfig.tun.routeAddress;
  rawConfig['tun']['auto-route'] = realPatchConfig.tun.autoRoute;
  rawConfig['geodata-loader'] = realPatchConfig.geodataLoader.name;
  rawConfig['geo-auto-update'] = realPatchConfig.geoAutoUpdate;
  rawConfig['geo-update-interval'] = realPatchConfig.geoUpdateInterval;
  final sniffer = rawConfig['sniffer'];
  final sniff = sniffer is Map ? sniffer['sniff'] : null;
  if (sniff is Map) {
    for (final value in sniff.values) {
      if (value is Map && value['ports'] is List) {
        value['ports'] = (value['ports'] as List)
            .map((item) => item.toString())
            .toList();
      }
    }
  }
  if (rawConfig['profile'] is! Map) {
    rawConfig['profile'] = {};
  }
  confineProviders('proxy-providers', proxiesProviderDirectoryName);
  confineProviders('rule-providers', rulesProviderDirectoryName);
  rawConfig['profile']['store-selected'] = false;
  rawConfig['geox-url'] = realPatchConfig.geoXUrl.raw;
  rawConfig['global-ua'] = realPatchConfig.globalUa ?? defaultUA;
  if (rawConfig['hosts'] is! Map) {
    rawConfig['hosts'] = {};
  }
  for (final host in realPatchConfig.hosts.entries) {
    rawConfig['hosts'][host.key] = host.value.splitByMultipleSeparators;
  }
  final rawDns = rawConfig['dns'] is Map
      ? Map<String, dynamic>.from(rawConfig['dns'] as Map)
      : <String, dynamic>{};
  rawConfig['dns'] = rawDns;
  final isEnableDns = rawDns['enable'] == true;
  const systemDns = 'system://';
  if (overrideDns || !isEnableDns) {
    final dns = realPatchConfig.dns;
    final nameserverPolicy = <String, dynamic>{};
    for (final entry in dns.nameserverPolicy.entries) {
      nameserverPolicy[entry.key] = entry.value.splitByMultipleSeparators;
    }
    // Merged, not assigned: the model only covers the keys ReClash can edit.
    rawConfig['dns'] = {
      ...rawDns,
      ...dns.toJson(),
      'nameserver-policy': nameserverPolicy,
    };
  }
  if (appendSystemDns) {
    final List<String> nameserver = List<String>.from(
      rawConfig['dns']['nameserver'] ?? [],
    );
    if (!nameserver.contains(systemDns)) {
      rawConfig['dns']['nameserver'] = [...nameserver, systemDns];
    }
  }
  // Only-dpi has no domain rules for fake-ip to serve, and an unmapped fake
  // reaches the engine as a raw 198.18.x dial target the engine cannot route.
  if (data.desyncOnly) {
    rawConfig['dns']['enhanced-mode'] = 'redir-host';
  }
  List<String> rules = [];
  var userRuleCount = 0;
  if (data.rules.isEmpty) {
    final rawRules = rawConfig['rules'];
    if (rawRules is List) {
      rules = rawRules.map((rule) => '$rule').toList();
    }
    if (addedRules.isNotEmpty) {
      final hasMatchPlaceholder = addedRules.any(
        (item) => item.ruleTarget?.toUpperCase() == 'MATCH',
      );
      String? replacementTarget = data.matchTarget?.trim();
      if (replacementTarget?.isEmpty == true) {
        replacementTarget = null;
      }

      if (hasMatchPlaceholder && replacementTarget == null) {
        for (int i = rules.length - 1; i >= 0; i--) {
          final parsed = Rule.parse(rules[i]);
          if (parsed.ruleAction == RuleAction.MATCH) {
            final target = parsed.ruleTarget;
            if (target != null && target.isNotEmpty) {
              replacementTarget = target;
              break;
            }
          }
        }
      }
      final List<String> finalAddedRules;

      if (replacementTarget?.isNotEmpty == true) {
        finalAddedRules = [];
        for (int i = 0; i < addedRules.length; i++) {
          final parsed = addedRules[i];
          if (parsed.ruleTarget?.toUpperCase() == 'MATCH') {
            finalAddedRules.add(
              parsed.copyWith(ruleTarget: replacementTarget).rawValue,
            );
          } else {
            finalAddedRules.add(addedRules[i].rawValue);
          }
        }
      } else {
        finalAddedRules = addedRules.map((e) => e.rawValue).toList();
      }
      rules = [...finalAddedRules, ...rules];
      userRuleCount = finalAddedRules.length;
    }
  } else {
    // A custom overwrite replaces the rule list outright, so every entry here
    // is the user's own and outranks the skeleton's service rules.
    rules = data.rules.map((item) => item.rawValue).toList();
    userRuleCount = rules.length;
  }
  if (data.proxyGroups.isNotEmpty) {
    rawConfig['proxy-groups'] = data.proxyGroups;
  }
  if (data.smartRouting) {
    rules = injectRcxSkeleton(
      rawConfig: rawConfig,
      rules: rules,
      serviceRoutes: data.serviceRoutePolicies,
      serviceRules: data.serviceRules,
      userRuleCount: userRuleCount,
    );
  }
  // After the skeleton: an outbound present while it is built is ranked as a node.
  if (data.desync) {
    appendDesyncProxy(rawConfig: rawConfig, port: data.desyncPort);
    rules = [
      ...(data.desyncOnly
          ? [
              ...desyncRules(
                categories: data.desyncCategories,
                forceTcp: data.desyncForceTcp,
              ),
              ...desyncOnlyFallback(),
            ]
          : desyncRules(
              categories: data.desyncCategories,
              forceTcp: data.desyncForceTcp,
            )),
      ...rules,
    ];
  } else {
    stripDesyncDialerProxy(rawConfig);
  }
  rawConfig['rules'] = rules;
  final yaml = await _encodeYaml(Map<String, dynamic>.from(rawConfig));
  return (yaml: yaml, md5: yaml.toMd5());
}

Future<List<String>> shakingProfileTask(
  ({Iterable<int> profileIds, Iterable<int> scriptIds}) data,
) async {
  return compute<
    ({
      Iterable<int> profileIds,
      Iterable<int> scriptIds,
      RootIsolateToken token,
    }),
    List<String>
  >(_shakingProfileTask, (
    profileIds: data.profileIds,
    scriptIds: data.scriptIds,
    token: RootIsolateToken.instance!,
  ));
}

Future<List<String>> _shakingProfileTask(
  ({Iterable<int> profileIds, Iterable<int> scriptIds, RootIsolateToken token})
  data,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
  return shakeOrphanFiles(
    profileIds: data.profileIds,
    scriptIds: data.scriptIds,
    profilesDirPath: await appPath.profilesPath,
    providersDirPath: await appPath.getProvidersRootPath(),
    scriptsDirPath: await appPath.scriptsDirPath,
  );
}

@visibleForTesting
List<String> shakeOrphanFiles({
  required Iterable<int> profileIds,
  required Iterable<int> scriptIds,
  required String profilesDirPath,
  required String providersDirPath,
  required String scriptsDirPath,
}) {
  final List<String> targets = [];
  void scanDirectory(
    Directory dir,
    Iterable<int> baseNames, {
    bool includeDirectories = false,
  }) {
    if (!dir.existsSync()) return;
    final entities = dir.listSync(recursive: false, followLinks: false);

    for (final entity in entities) {
      final selected =
          entity is File || (includeDirectories && entity is Directory);
      if (!selected) {
        continue;
      }
      final id = basenameWithoutExtension(entity.path);
      if (!baseNames.contains(int.tryParse(id))) {
        targets.add(entity.path);
      }
    }
  }

  scanDirectory(Directory(profilesDirPath), profileIds);
  scanDirectory(
    Directory(providersDirPath),
    profileIds,
    includeDirectories: true,
  );
  scanDirectory(Directory(scriptsDirPath), scriptIds);
  return targets;
}
