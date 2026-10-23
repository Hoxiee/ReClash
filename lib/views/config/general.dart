import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/user_agents.dart';
import 'package:reclash/views/config/web_dashboard.dart';
import 'package:reclash/subscriptions/compatibility/settings_form.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'general/port_form.dart';

class GeneralSettings {
  static final all = <SettingSpec>[
    SettingSpec(
      id: 'general.port',
      keywords: [
        'mixed port',
        'http port',
        'socks port',
        'redir port',
        'tproxy port',
      ],
      page: ToolPage.general,
      title: (l) => l.port,
    ),
    SettingSpec(
      id: 'general.allowLan',
      page: ToolPage.general,
      title: (l) => l.allowLan,
    ),
    SettingSpec(
      id: 'general.externalController',
      page: ToolPage.general,
      title: (l) => l.externalController,
    ),
    SettingSpec(
      id: 'general.externalControllerSecret',
      condition: SettingCondition.controller,
      page: ToolPage.general,
      title: (l) => l.externalControllerSecret,
    ),
    webDashboardSetting,
    SettingSpec(
      id: 'general.authentication',
      page: ToolPage.general,
      title: (l) => l.authentication,
    ),
    SettingSpec(
      id: 'general.account',
      condition: SettingCondition.authentication,
      page: ToolPage.general,
      title: (l) => l.account,
    ),
    SettingSpec(
      id: 'general.password',
      condition: SettingCondition.authentication,
      page: ToolPage.general,
      title: (l) => l.password,
    ),
    SettingSpec(
      id: 'general.testUrl',
      page: ToolPage.general,
      title: (l) => l.testUrl,
    ),
    SettingSpec(
      id: 'general.unifiedDelay',
      page: ToolPage.general,
      title: (l) => l.unifiedDelay,
    ),
    SettingSpec(
      id: 'general.tcpConcurrent',
      page: ToolPage.general,
      title: (l) => l.tcpConcurrent,
    ),
    SettingSpec(
      id: 'general.findProcessMode',
      page: ToolPage.general,
      title: (l) => l.findProcessMode,
    ),
    SettingSpec(
      id: 'general.ipv6',
      page: ToolPage.general,
      title: (l) => 'IPv6',
    ),
    SettingSpec(
      id: 'general.hosts',
      page: ToolPage.general,
      title: (l) => 'Hosts',
    ),
    SettingSpec(
      id: 'general.appendSystemDns',
      page: ToolPage.general,
      title: (l) => l.appendSystemDns,
    ),
    SettingSpec(
      id: 'general.geodataLoader',
      page: ToolPage.general,
      title: (l) => l.geodataLoader,
    ),
    SettingSpec(
      id: 'general.userAgent',
      page: ToolPage.general,
      title: (l) => l.userAgent,
    ),
    SettingSpec(
      id: 'general.subscriptionIdentity',
      keywords: ['subscription', 'hwid', 'device identifier'],
      page: ToolPage.general,
      title: (l) => l.subscriptionIdentityTitle,
    ),
  ];

  static SettingSpec spec(String id) => all.firstWhere((item) => item.id == id);
}

class UaItem extends ConsumerWidget {
  const UaItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    return SettingTarget(
      spec: GeneralSettings.spec('general.userAgent'),
      child: ListItem.open(
        title: Text(appLocalizations.userAgent),
        subtitle: Text(globalUa ?? appLocalizations.defaultText),
        widget: const UserAgentsView(),
        forceFull: false,
        preferSheet: true,
      ),
    );
  }
}

class TestUrlItem extends ConsumerWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final testUrl = ref.watch(
      appSettingProvider.select((state) => state.testUrl),
    );
    return SettingTarget(
      spec: GeneralSettings.spec('general.testUrl'),
      child: ListItem.input(
        title: Text(appLocalizations.testUrl),
        subtitle: Text(testUrl),
        resetValue: defaultTestUrl,
        dialogTitle: appLocalizations.testUrl,
        value: testUrl,
        maxLength: TextInputLimits.url,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.testUrl);
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip(appLocalizations.testUrl);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(testUrl: value));
        },
      ),
    );
  }
}

class PortItem extends ConsumerWidget {
  const PortItem({super.key});

  Future<void> handleShowPortForm(BuildContext context) async {
    await showFormSheet<void>(
      context: context,
      builder: (_) => const _PortForm(),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return SettingTarget(
      spec: GeneralSettings.spec('general.port'),
      child: ListItem(
        title: Text(appLocalizations.port),
        subtitle: Text('$mixedPort'),
        onTap: () {
          handleShowPortForm(context);
        },
      ),
    );
  }
}

class HostsItem extends ConsumerWidget {
  const HostsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final hosts = ref.watch(
      patchClashConfigProvider.select((state) => state.hosts),
    );
    return SettingTarget(
      spec: GeneralSettings.spec('general.hosts'),
      child: ListItem.open(
        title: const Text('Hosts'),
        subtitle: Text(
          hosts.isEmpty
              ? appLocalizations.none
              : appLocalizations.itemsCount(hosts.length),
        ),
        widget: MapEditView(
          title: 'Hosts',
          entries: hosts,
          keyMaxLength: TextInputLimits.domain,
          valueMaxLength: TextInputLimits.hostValue,
          titleBuilder: (item) => Text(item.key),
          subtitleBuilder: (item) => Text(item.value),
        ),
        forceFull: false,
        onChanged: (value) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith(hosts: value));
        },
      ),
    );
  }
}

class AuthenticationItem extends ConsumerWidget {
  const AuthenticationItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      title: (l) => l.authentication,
      setting: GeneralSettings.spec('general.authentication'),
      selector: networkSettingProvider.select(
        (state) => state.authentication.enable,
      ),
      onChanged: (ref, value) =>
          ref.read(networkSettingProvider.notifier).update((state) {
            var authentication = state.authentication.copyWith(enable: value);
            if (value && authentication.username.isEmpty) {
              authentication = authentication.copyWith(
                username: generateRandomSecret(8),
                password: generateRandomSecret(16),
              );
            }
            return state.copyWith(authentication: authentication);
          }),
    );
  }
}

class AuthenticationAccountItem extends ConsumerWidget {
  const AuthenticationAccountItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.account,
      setting: GeneralSettings.spec('general.account'),
      maxLength: TextInputLimits.userName,
      selector: networkSettingProvider.select(
        (state) => state.authentication.username,
      ),
      // mihomo and the Dart proxy string both split user:pass on the first
      // colon, so a colon in the username breaks authentication.
      normalize: (value) => value.trim().replaceAll(':', ''),
      onChanged: (ref, value) => ref
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith.authentication(username: value)),
    );
  }
}

class AuthenticationPasswordItem extends ConsumerWidget {
  const AuthenticationPasswordItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.password,
      setting: GeneralSettings.spec('general.password'),
      maxLength: TextInputLimits.password,
      selector: networkSettingProvider.select(
        (state) => state.authentication.password,
      ),
      normalize: (value) => value.trim(),
      onChanged: (ref, value) => ref
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith.authentication(password: value)),
    );
  }
}

class ExternalControllerSecretItem extends ConsumerWidget {
  const ExternalControllerSecretItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.externalControllerSecret,
      setting: GeneralSettings.spec('general.externalControllerSecret'),
      maxLength: TextInputLimits.password,
      selector: patchClashConfigProvider.select((state) => state.secret),
      normalize: (value) => value.trim(),
      onChanged: (ref, value) => ref
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(secret: value)),
    );
  }
}

ConfigToggleItem _clashToggle({
  required String id,
  required bool Function(PatchClashConfig state) select,
  required PatchClashConfig Function(PatchClashConfig state, bool value) update,
}) {
  final spec = GeneralSettings.spec(id);
  return ConfigToggleItem(
    title: spec.title,
    setting: spec,
    selector: patchClashConfigProvider.select(select),
    onChanged: (ref, value) => ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => update(state, value)),
  );
}

class _SubscriptionIdentityItem extends ConsumerStatefulWidget {
  const _SubscriptionIdentityItem();

  @override
  ConsumerState<_SubscriptionIdentityItem> createState() =>
      _SubscriptionIdentityItemState();
}

class _SubscriptionIdentityItemState
    extends ConsumerState<_SubscriptionIdentityItem> {
  bool _enabled = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _regionDefault =>
      sendsDeviceIdentityByDefault(ref.read(appSettingProvider).regionCode);

  Future<void> _load() async {
    try {
      final enabled = await (await DeviceIdentityStore.create())
          .globalSendEnabled(byDefault: _regionDefault);
      if (mounted) setState(() => _enabled = enabled);
    } on Object {
      if (mounted) setState(() => _enabled = _regionDefault);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setEnabled(bool value) async {
    if (_loading || _saving) return;
    if (!value &&
        !await confirmDeviceIdentityOff(
          context,
          ref.read(appSettingProvider).regionCode,
        )) {
      return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      await (await DeviceIdentityStore.create()).setGlobalSendEnabled(value);
      if (mounted) setState(() => _enabled = value);
    } on Object catch (error) {
      await globalState.safeRun<void>(() async => throw error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return SettingTarget(
      spec: GeneralSettings.spec('general.subscriptionIdentity'),
      child: ListItem.toggle(
        title: Text(l10n.subscriptionIdentityTitle),
        value: _enabled,
        onChanged: _loading || _saving ? null : _setEnabled,
      ),
    );
  }
}

class GeneralView extends ConsumerWidget {
  const GeneralView({super.key});

  List<Widget> _inboundItems({
    required bool authentication,
    required bool externalController,
  }) {
    return [
      const PortItem(),
      _clashToggle(
        id: 'general.allowLan',
        select: (state) => state.allowLan,
        update: (state, value) => state.copyWith(allowLan: value),
      ),
      _clashToggle(
        id: 'general.externalController',
        select: (state) =>
            state.externalController == ExternalControllerStatus.open,
        update: (state, value) => state
            .copyWith(
              externalController: value
                  ? ExternalControllerStatus.open
                  : ExternalControllerStatus.close,
            )
            .ensureControllerSecret(),
      ),
      if (externalController) const ExternalControllerSecretItem(),
      const WebDashboardItem(),
      const AuthenticationItem(),
      if (authentication) ...const [
        AuthenticationAccountItem(),
        AuthenticationPasswordItem(),
      ],
    ];
  }

  List<Widget> _connectionItems() {
    return [
      const TestUrlItem(),
      _clashToggle(
        id: 'general.unifiedDelay',
        select: (state) => state.unifiedDelay,
        update: (state, value) => state.copyWith(unifiedDelay: value),
      ),
      _clashToggle(
        id: 'general.tcpConcurrent',
        select: (state) => state.tcpConcurrent,
        update: (state, value) => state.copyWith(tcpConcurrent: value),
      ),
      _clashToggle(
        id: 'general.findProcessMode',
        select: (state) => state.findProcessMode == FindProcessMode.always,
        update: (state, value) => state.copyWith(
          findProcessMode: value ? FindProcessMode.always : FindProcessMode.off,
        ),
      ),
    ];
  }

  List<Widget> _coreItems() {
    return [
      const UaItem(),
      _clashToggle(
        id: 'general.ipv6',
        select: (state) => state.ipv6,
        update: (state, value) => state.copyWith(ipv6: value),
      ),
      const HostsItem(),
      ConfigToggleItem(
        title: (l) => l.appendSystemDns,
        setting: GeneralSettings.spec('general.appendSystemDns'),
        selector: networkSettingProvider.select(
          (state) => state.appendSystemDns,
        ),
        onChanged: (ref, value) => ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(appendSystemDns: value)),
      ),
      _clashToggle(
        id: 'general.geodataLoader',
        select: (state) => state.geodataLoader == GeodataLoader.memconservative,
        update: (state, value) => state.copyWith(
          geodataLoader: value
              ? GeodataLoader.memconservative
              : GeodataLoader.standard,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final authentication = ref.watch(
      networkSettingProvider.select((state) => state.authentication.enable),
    );
    final externalController = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.externalController == ExternalControllerStatus.open,
      ),
    );
    return BaseScaffold(
      title: appLocalizations.general,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.appBarInset, bottom: 16),
          child: Column(
            children: [
              generateSection(
                title: appLocalizations.inbound,
                items: _inboundItems(
                  authentication: authentication,
                  externalController: externalController,
                ),
                footer: [
                  appLocalizations.externalControllerDesc,
                  appLocalizations.authenticationDesc,
                ].join('\n'),
              ),
              generateSection(
                title: appLocalizations.connection,
                items: _connectionItems(),
              ),
              generateSection(
                title: appLocalizations.subscriptionIdentitySettingsTitle,
                items: const [_SubscriptionIdentityItem()],
              ),
              generateSection(
                title: appLocalizations.core,
                items: _coreItems(),
                footer: appLocalizations.ipv6Desc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
