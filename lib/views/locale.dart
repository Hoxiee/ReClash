import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleView extends ConsumerWidget {
  const LocaleView({super.key});

  void _select(WidgetRef ref, Locale? locale) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(locale: locale?.toString()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final currentLocale = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    final options = <Locale?>[
      null,
      ...AppLocalizations.delegate.supportedLocales,
    ];
    return BaseScaffold(
      title: appLocalizations.language,
      body: ListView(
        children: [
          SettingSection(
            top: 16,
            items: [
              for (final locale in options)
                DecorationListItem(
                  isSelected: locale == currentLocale,
                  leading: Text(
                    locale?.flagEmoji ?? '🌐',
                    style: context.textTheme.titleLarge?.toLight.copyWith(
                      fontFamily: FontFamily.twEmoji.value,
                    ),
                  ),
                  title: Text(
                    locale?.nativeLabel ?? appLocalizations.defaultText,
                  ),
                  subtitle: Text(
                    locale?.englishLabel ?? 'System default',
                    style: context.textTheme.bodySmall?.toLighter,
                  ),
                  trailing: locale == currentLocale
                      ? Icon(
                          color: context.colorScheme.primary,
                          size: 20,
                          Icons.check,
                        )
                      : null,
                  onPressed: () => _select(ref, locale),
                ),
            ],
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}
