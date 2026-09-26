import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/views/config/editor.dart';
import 'package:reclash/views/profiles/overwrite/overwrite_selection_sheet.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _NtpUpdate<T> =
    PatchClashConfig Function(PatchClashConfig state, T value);

final _ntpOverrideKeysSelector = patchClashConfigProvider.select(
  (state) => state.ntpOverrideKeys,
);

ProviderListenable<T> _ntpSelector<T>(T Function(Ntp ntp) select) {
  return patchClashConfigProvider.select((state) => select(state.ntp));
}

ConfigWriter<T> _ntpWriter<T>(_NtpUpdate<T> update) {
  return (ref, value) => ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => update(state, value));
}

extension on NtpOverrideKey {
  String label(AppLocalizations l) => switch (this) {
    NtpOverrideKey.enable => l.status,
    NtpOverrideKey.server => l.server,
    NtpOverrideKey.port => l.port,
    NtpOverrideKey.interval => l.interval,
    NtpOverrideKey.dialerProxy => l.dialerProxy,
    NtpOverrideKey.writeToSystem => l.writeToSystem,
  };

  ConfigLabel? get description => switch (this) {
    NtpOverrideKey.enable => (l) => l.statusDesc,
    NtpOverrideKey.writeToSystem => (l) => l.writeToSystemDesc,
    _ => null,
  };
}

class NtpView extends ConsumerWidget {
  const NtpView({super.key});

  Future<void> _handleAdd(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final added = ref.read(_ntpOverrideKeysSelector);
    final remaining = NtpOverrideKey.values
        .where((key) => !added.contains(key))
        .toList();
    final key = await showSheet<NtpOverrideKey>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (context) => OverwriteSelectionSheet<NtpOverrideKey>(
        title: appLocalizations.addOverrideEntry,
        sections: [
          OverwriteSelectionSection(
            label: appLocalizations.options,
            items: remaining,
          ),
        ],
        labelBuilder: (key) => key.label(appLocalizations),
        selectedOf: (_) => null,
        onSelected: (key) => Navigator.of(context).pop(key),
      ),
    );
    if (key == null || !context.mounted) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) =>
              state.copyWith(ntpOverrideKeys: {...state.ntpOverrideKeys, key}),
        );
  }

  Future<void> _handleQuickEdit(BuildContext context, WidgetRef ref) {
    final config = ref.read(patchClashConfigProvider);
    final raw = config.ntp.overrideYaml(config.ntpOverrideKeys);
    return BaseNavigator.push(
      context,
      EditorPage(
        title: 'NTP',
        content: raw,
        onPop: (context, title, content) =>
            _handleQuickEditPop(ref, content, raw),
      ),
    );
  }

  Future<bool> _handleQuickEditPop(
    WidgetRef ref,
    String content,
    String raw,
  ) async {
    if (content == raw) {
      return true;
    }
    try {
      final result = ref
          .read(patchClashConfigProvider)
          .ntp
          .applyOverrideYaml(content);
      ref
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) =>
                state.copyWith(ntp: result.ntp, ntpOverrideKeys: result.keys),
          );
      return true;
    } catch (error) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text:
              '${compactError(error)}\n\n'
              '${currentAppLocalizations.discardChanges}',
        ),
      );
      return res == true;
    }
  }

  Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      dangerous: true,
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(ntp: defaultNtp));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final canAdd = ref.watch(
      _ntpOverrideKeysSelector.select(
        (keys) => keys.length < NtpOverrideKey.values.length,
      ),
    );
    return CommonScaffold(
      title: 'NTP',
      floatBody: true,
      menuItems: [
        CommonPopupMenuItem(
          glyph: AppGlyphs.add,
          label: appLocalizations.add,
          onPressed: canAdd ? () => _handleAdd(context, ref) : null,
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.compose,
          label: appLocalizations.quickEdit,
          onPressed: () => _handleQuickEdit(context, ref),
        ),
        CommonPopupMenuItem(
          glyph: AppGlyphs.replay,
          label: appLocalizations.reset,
          danger: true,
          onPressed: () => _handleReset(context, ref),
        ),
      ],
      body: const _OverrideList(),
    );
  }
}

class _OverrideList extends ConsumerWidget {
  const _OverrideList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final keys = ref.watch(_ntpOverrideKeysSelector);
    final entries = NtpOverrideKey.values.where(keys.contains).toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.contentTopPadding,
            bottom: entries.isEmpty ? 0 : 16,
          ),
          sliver: SliverList.list(
            children: [
              generateSectionV3(
                items: [
                  ConfigToggleItem(
                    title: (l) => l.overrideNtp,
                    selector: overrideNtpProvider,
                    onChanged: (ref, value) =>
                        ref.read(overrideNtpProvider.notifier).value = value,
                  ),
                ],
              ),
              if (entries.isNotEmpty)
                generateSectionV3(
                  title: appLocalizations.options,
                  items: [
                    for (final key in entries)
                      _OverrideItem(key: ValueKey(key), overrideKey: key),
                  ],
                ),
            ],
          ),
        ),
        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.overrideEntries),
              illustration: NullStatusIllustration.ntp,
            ),
          ),
      ],
    );
  }
}

class _OverrideItem extends StatelessWidget {
  const _OverrideItem({super.key, required this.overrideKey});

  final NtpOverrideKey overrideKey;

  @override
  Widget build(BuildContext context) {
    final leading = _RemoveButton(overrideKey);
    final title = overrideKey.label;

    Widget toggle(bool Function(Ntp ntp) select, _NtpUpdate<bool> update) {
      return ConfigToggleItem(
        leading: leading,
        title: title,
        subtitle: overrideKey.description,
        selector: _ntpSelector(select),
        onChanged: _ntpWriter(update),
      );
    }

    Widget text(
      String Function(Ntp ntp) select,
      _NtpUpdate<String> update, {
      required int maxLength,
    }) {
      return ConfigTextItem(
        leading: leading,
        title: title,
        selector: _ntpSelector(select),
        onChanged: _ntpWriter(update),
        maxLength: maxLength,
      );
    }

    Widget number(
      int Function(Ntp ntp) select,
      _NtpUpdate<int> update, {
      required int maxLength,
      String? Function(int parsed, AppLocalizations l)? check,
    }) {
      return ConfigTextItem(
        leading: leading,
        title: title,
        selector: _ntpSelector((ntp) => '${select(ntp)}'),
        onChanged: _ntpWriter<String>(
          (state, value) => update(state, int.parse(value)),
        ),
        maxLength: maxLength,
        keyboardType: TextInputType.number,
        normalize: (value) => value.trim(),
        validator: (value, l) {
          final parsed = int.tryParse(value ?? '');
          if (parsed == null) {
            return l.numberTip(title(l));
          }
          return check?.call(parsed, l);
        },
      );
    }

    switch (overrideKey) {
      case NtpOverrideKey.enable:
        return toggle(
          (ntp) => ntp.enable,
          (state, value) => state.copyWith.ntp(enable: value),
        );
      case NtpOverrideKey.server:
        return text(
          (ntp) => ntp.server,
          (state, value) => state.copyWith.ntp(server: value),
          maxLength: TextInputLimits.domain,
        );
      case NtpOverrideKey.port:
        return number(
          (ntp) => ntp.port,
          (state, value) => state.copyWith.ntp(port: value),
          maxLength: TextInputLimits.port,
          check: (parsed, l) => parsed >= 1 && parsed <= 65535
              ? null
              : l.portTip(overrideKey.label(l)),
        );
      case NtpOverrideKey.interval:
        return number(
          (ntp) => ntp.interval,
          (state, value) => state.copyWith.ntp(interval: value),
          maxLength: TextInputLimits.interval,
          check: (parsed, l) =>
              parsed >= 1 ? null : l.numberTip(overrideKey.label(l)),
        );
      case NtpOverrideKey.dialerProxy:
        return _DialerProxyItem(leading: leading);
      case NtpOverrideKey.writeToSystem:
        return toggle(
          (ntp) => ntp.writeToSystem,
          (state, value) => state.copyWith.ntp(writeToSystem: value),
        );
    }
  }
}

class _DialerProxyItem extends ConsumerWidget {
  const _DialerProxyItem({required this.leading});

  final Widget leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final dialerProxy = ref.watch(_ntpSelector((ntp) => ntp.dialerProxy));
    final label = appLocalizations.dialerProxy;
    return DecorationListItem.input(
      leading: leading,
      title: Text(label),
      subtitle: Text(
        dialerProxy.isEmpty ? appLocalizations.dialerProxyDesc : dialerProxy,
      ),
      dialogTitle: label,
      value: dialerProxy,
      maxLength: TextInputLimits.dnsServer,
      onChanged: (value) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith.ntp(dialerProxy: value ?? ''));
      },
    );
  }
}

class _RemoveButton extends ConsumerWidget {
  const _RemoveButton(this.overrideKey);

  final NtpOverrideKey overrideKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonMinIconButtonTheme(
      child: ElasticButton(
        child: IconButton.filledTonal(
          tooltip: context.appLocalizations.remove,
          onPressed: () => ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith(
                  ntpOverrideKeys: {...state.ntpOverrideKeys}
                    ..remove(overrideKey),
                ),
              ),
          icon: const GlyphIcon(AppGlyphs.remove, size: 18, fill: 1),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
