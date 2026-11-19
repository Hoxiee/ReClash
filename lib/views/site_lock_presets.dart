import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

/// A service whose account checks tie it to one IP; [name] is a proper noun.
class SiteLockPreset {
  const SiteLockPreset(this.name, this.match);

  final String name;
  final List<String> match;
}

const siteLockPresets = [
  SiteLockPreset('Claude', [
    'DOMAIN-SUFFIX,anthropic.com',
    'DOMAIN-SUFFIX,claude.ai',
    'DOMAIN-SUFFIX,claude.com',
    'DOMAIN-SUFFIX,claudeusercontent.com',
    'DOMAIN-SUFFIX,clau.de',
  ]),
  SiteLockPreset('ChatGPT', [
    'GEOSITE,openai',
    'DOMAIN-SUFFIX,chatgpt.com',
    'DOMAIN-SUFFIX,oaistatic.com',
    'DOMAIN-SUFFIX,oaiusercontent.com',
    'DOMAIN-SUFFIX,openai.com',
  ]),
  SiteLockPreset('Gemini', ['GEOSITE,google-gemini']),
  SiteLockPreset('Grok', ['DOMAIN-SUFFIX,x.ai', 'DOMAIN-SUFFIX,grok.com']),
  SiteLockPreset('Perplexity', ['GEOSITE,perplexity']),
  SiteLockPreset('DeepSeek', ['GEOSITE,deepseek']),
  SiteLockPreset('Cursor', ['GEOSITE,cursor']),
];

Future<SiteLockPreset?> showSiteLockPresetSheet(BuildContext context) =>
    showSheet<SiteLockPreset>(
      context: context,
      builder: (_) => const _SiteLockPresetSheet(),
    );

class _SiteLockPresetSheet extends StatelessWidget {
  const _SiteLockPresetSheet();

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return CommonScaffold(
      title: l.siteLockFromPreset,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.contentTopPadding,
          bottom: 20 + context.bottomInset,
        ),
        children: [
          generateSection(
            items: [
              for (final preset in siteLockPresets)
                ListItem(
                  leading: const GlyphIcon(AppGlyphs.sparkle),
                  title: Text(preset.name),
                  subtitle: Text(
                    preset.match.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.footnote
                        .of(context)
                        .toJetBrainsMono
                        .copyWith(color: context.colorScheme.tertiary),
                  ),
                  onTap: () => Navigator.of(context).pop(preset),
                ),
            ],
            footer: l.siteLockPresetsFooter,
          ),
        ],
      ),
    );
  }
}
