import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/web_dashboard.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'general/port_dialog.dart';
part 'general/ua_dialog.dart';
part 'general/external_controller_dialog.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<LogLevel>(
      leading: const GlyphIcon(AppGlyphs.info),
      title: (l) => l.logLevel,
      options: LogLevel.values,
      textBuilder: (logLevel) => logLevel.name,
      selector: patchClashConfigProvider.select((state) => state.logLevel),
      onChanged: (ref, value) => ref
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(logLevel: value)),
    );
  }
}

class UaItem extends ConsumerWidget {
  const UaItem({super.key});

  Future<void> _handleShowUaDialog(WidgetRef ref) async {
    final result = await dialogs.showCommonDialog<_UaDialogResult>(
      child: _UaDialog(
        value: ref.read(patchClashConfigProvider).globalUa,
        customValue: ref.read(appSettingProvider).customUserAgent,
      ),
    );
    if (result == null) {
      return;
    }
    final userAgent = result.value.trim();
    if (result.isCustom) {
      ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(customUserAgent: userAgent));
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) =>
              state.copyWith(globalUa: userAgent.isEmpty ? null : userAgent),
        );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.computer),
      title: Text(appLocalizations.userAgent),
      subtitle: Text(globalUa ?? appLocalizations.defaultText),
      onPressed: () => _handleShowUaDialog(ref),
    );
  }
}

class KeepAliveIntervalItem extends ConsumerWidget {
  const KeepAliveIntervalItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final keepAliveInterval = ref.watch(
      patchClashConfigProvider.select((state) => state.keepAliveInterval),
    );
    return DecorationListItem.input(
      leading: const GlyphIcon(AppGlyphs.clock),
      title: Text(appLocalizations.keepAliveIntervalDesc),
      subtitle: Text(appLocalizations.secondsCount(keepAliveInterval)),
      dialogTitle: appLocalizations.keepAliveIntervalDesc,
      suffixText: appLocalizations.seconds,
      resetValue: '$defaultKeepAliveInterval',
      value: '$keepAliveInterval',
      maxLength: TextInputLimits.interval,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(appLocalizations.interval);
        }
        final intValue = int.tryParse(value);
        if (intValue == null) {
          return appLocalizations.numberTip(appLocalizations.interval);
        }
        return null;
      },
      onChanged: (String? value) {
        if (value == null) {
          return;
        }
        final intValue = int.parse(value);
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(keepAliveInterval: intValue));
      },
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
    return DecorationListItem.input(
      leading: const GlyphIcon(AppGlyphs.chart),
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
    );
  }
}

class PortItem extends ConsumerWidget {
  const PortItem({super.key});

  Future<void> handleShowPortDialog() async {
    await dialogs.showCommonDialog(child: const _PortDialog());
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.target),
      title: Text(appLocalizations.port),
      subtitle: Text('$mixedPort'),
      onPressed: () {
        handleShowPortDialog();
      },
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
    return DecorationListItem.open(
      leading: const GlyphIcon(AppGlyphs.list),
      title: const Text('Hosts'),
      subtitle: Text(appLocalizations.hostsDesc),
      blur: false,
      widget: MapInputPage(
        title: 'Hosts',
        map: hosts,
        keyMaxLength: TextInputLimits.domain,
        valueMaxLength: TextInputLimits.hostValue,
        titleBuilder: (item) => Text(item.key),
        subtitleBuilder: (item) => Text(item.value),
      ),
      onChanged: (value) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(hosts: value));
      },
    );
  }
}

class AuthenticationItem extends ConsumerWidget {
  const AuthenticationItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      leading: const GlyphIcon(AppGlyphs.key),
      title: (l) => l.authentication,
      subtitle: (l) => l.authenticationDesc,
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
      leading: const GlyphIcon(AppGlyphs.account),
      title: (l) => l.account,
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
      leading: const GlyphIcon(AppGlyphs.password),
      title: (l) => l.password,
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

ConfigToggleItem _clashToggle({
  required Glyph icon,
  required ConfigLabel title,
  required ConfigLabel subtitle,
  required bool Function(PatchClashConfig state) select,
  required PatchClashConfig Function(PatchClashConfig state, bool value) update,
}) {
  return ConfigToggleItem(
    leading: GlyphIcon(icon),
    title: title,
    subtitle: subtitle,
    selector: patchClashConfigProvider.select(select),
    onChanged: (ref, value) => ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => update(state, value)),
  );
}

class GeneralListView extends ConsumerWidget {
  const GeneralListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final authentication = ref.watch(
      networkSettingProvider.select((state) => state.authentication.enable),
    );
    return SettingsListView(
      children: [
        SettingSection(
          top: 16,
          items: [
            ConfigOptionsItem<AppRegion>(
              leading: const GlyphIcon(AppGlyphs.appRegion),
              title: (l) => l.appRegion,
              options: AppRegion.values,
              textBuilder: (region) => region.label(context),
              selector: appRegionProvider,
              onChanged: (ref, value) => selectAppRegion(ref.read, value),
            ),
          ],
        ),
        SettingSection(
          title: appLocalizations.network,
          items: [
            const PortItem(),
            _clashToggle(
              icon: AppGlyphs.hub,
              title: (l) => l.allowLan,
              subtitle: (l) => l.allowLanDesc,
              select: (state) => state.allowLan,
              update: (state, value) => state.copyWith(allowLan: value),
            ),
            const ExternalControllerItem(),
            const WebDashboardItem(),
            const AuthenticationItem(),
          ],
        ),
        if (authentication)
          SettingSection(
            title: appLocalizations.authentication,
            items: const [
              AuthenticationAccountItem(),
              AuthenticationPasswordItem(),
            ],
            enterDelay: const Duration(milliseconds: 50),
          ),
        SettingSection(
          title: appLocalizations.identity,
          items: [
            const UaItem(),
            ConfigToggleItem(
              leading: const GlyphIcon(AppGlyphs.deviceInfo),
              title: (l) => l.sendDeviceIdentity,
              subtitle: (l) => l.sendDeviceIdentityDesc,
              selector: appSettingProvider.select(
                (state) => state.sendDeviceIdentity,
              ),
              onChanged: (ref, value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(sendDeviceIdentity: value)),
            ),
          ],
          enterDelay: const Duration(milliseconds: 100),
        ),
        SettingSection(
          title: appLocalizations.other,
          items: [
            const LogLevelItem(),
            const TestUrlItem(),
            if (system.isDesktop) const KeepAliveIntervalItem(),
            const HostsItem(),
            ConfigToggleItem(
              leading: const GlyphIcon(AppGlyphs.dns),
              title: (l) => l.appendSystemDns,
              subtitle: (l) => l.appendSystemDnsTip,
              selector: networkSettingProvider.select(
                (state) => state.appendSystemDns,
              ),
              onChanged: (ref, value) => ref
                  .read(networkSettingProvider.notifier)
                  .update((state) => state.copyWith(appendSystemDns: value)),
            ),
            _clashToggle(
              icon: AppGlyphs.drop,
              title: (l) => 'IPv6',
              subtitle: (l) => l.ipv6Desc,
              select: (state) => state.ipv6,
              update: (state, value) => state.copyWith(ipv6: value),
            ),
            _clashToggle(
              icon: AppGlyphs.compress,
              title: (l) => l.unifiedDelay,
              subtitle: (l) => l.unifiedDelayDesc,
              select: (state) => state.unifiedDelay,
              update: (state, value) => state.copyWith(unifiedDelay: value),
            ),
            _clashToggle(
              icon: AppGlyphs.fastForward,
              title: (l) => l.tcpConcurrent,
              subtitle: (l) => l.tcpConcurrentDesc,
              select: (state) => state.tcpConcurrent,
              update: (state, value) => state.copyWith(tcpConcurrent: value),
            ),
            _clashToggle(
              icon: AppGlyphs.findProcess,
              title: (l) => l.findProcessMode,
              subtitle: (l) => l.findProcessModeDesc,
              select: (state) =>
                  state.findProcessMode == FindProcessMode.always,
              update: (state, value) => state.copyWith(
                findProcessMode: value
                    ? FindProcessMode.always
                    : FindProcessMode.off,
              ),
            ),
            _clashToggle(
              icon: AppGlyphs.memory,
              title: (l) => l.geodataLoader,
              subtitle: (l) => l.geodataLoaderDesc,
              select: (state) =>
                  state.geodataLoader == GeodataLoader.memconservative,
              update: (state, value) => state.copyWith(
                geodataLoader: value
                    ? GeodataLoader.memconservative
                    : GeodataLoader.standard,
              ),
            ),
          ],
          enterDelay: const Duration(milliseconds: 100),
        ),
        const SettingBottomInset(),
      ],
    );
  }
}
