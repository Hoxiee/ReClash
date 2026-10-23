import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageView extends ConsumerWidget {
  const LanguageView({super.key});

  void _select(WidgetRef ref, Locale? locale) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(locale: locale?.toString()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final currentLocale = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    final options = <Locale?>[
      null,
      ...AppLocalizations.delegate.supportedLocales,
    ];
    return BaseScaffold(
      title: l.language,
      body: SettingsPageScroll(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.appBarInset, bottom: 20),
          child: Column(
            spacing: 12,
            children: [
              generateSection(
                items: [
                  for (final locale in options)
                    DecorationListItem(
                      isSelected: locale == currentLocale,
                      leading: Text(
                        locale?.flagEmoji ?? '🌐',
                        style: AppTextStyle.title3
                            .of(context)
                            .toLight
                            .copyWith(fontFamily: FontFamily.twEmoji.value),
                      ),
                      title: Text(locale?.nativeLabel ?? l.defaultText),
                      subtitle: Text(locale?.englishLabel ?? l.followSystem),
                      trailing: locale == currentLocale
                          ? const SelectionCheck()
                          : null,
                      onPressed: () => _select(ref, locale),
                    ),
                ],
              ),
              const _TranslationSuggestion(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslationSuggestion extends StatelessWidget {
  const _TranslationSuggestion();

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: TextButton.icon(
        onPressed: () {
          dialogs.openUrl(
            'https://github.com/$repository/issues/new?template=translation.yml',
          );
        },
        icon: const GlyphIcon(AppGlyphs.language, size: 18),
        label: Text(l.translationSuggestFix),
      ),
    );
  }
}
