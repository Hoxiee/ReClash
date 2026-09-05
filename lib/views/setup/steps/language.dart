import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

class SetupLanguageStep extends ConsumerWidget {
  const SetupLanguageStep({super.key, required this.onNext});

  final VoidCallback onNext;

  void _select(WidgetRef ref, Locale? locale) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(locale: locale?.toString()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final selected = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    final options = <Locale?>[
      null,
      ...AppLocalizations.delegate.supportedLocales,
    ];
    return SetupStepScaffold(
      header: const SetupLogo(),
      title: appName,
      subtitle: appLocalizations.setupWelcome,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appLocalizations.setupLanguageTitle,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appLocalizations.setupLanguageDesc,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SetupCard(
            child: RadioGroup<Locale?>(
              groupValue: selected,
              onChanged: (value) => _select(ref, value),
              child: Column(
                children: [
                  for (final locale in options)
                    ListItem<Locale?>.radio(
                      title: Text(
                        locale?.nativeLabel ?? appLocalizations.defaultText,
                      ),
                      subtitle: locale == null
                          ? null
                          : Text(locale.englishLabel),
                      value: locale,
                      onTap: () => _select(ref, locale),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        SetupPrimaryButton(label: appLocalizations.setupNext, onPressed: onNext),
      ],
    );
  }
}
