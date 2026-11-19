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
    'GEOSITE,anthropic',
    'DOMAIN-SUFFIX,anthropic.com',
    'DOMAIN-SUFFIX,claude.ai',
    'DOMAIN-SUFFIX,claude.com',
    'DOMAIN-SUFFIX,claudeusercontent.com',
    'DOMAIN-SUFFIX,claudemcpclient.com',
    'DOMAIN-SUFFIX,claudemcpcontent.com',
    'DOMAIN-SUFFIX,clau.de',
    // Telemetry and error reports of Claude Code, sent from the same IP.
    'DOMAIN,http-intake.logs.us5.datadoghq.com',
    'DOMAIN,browser-intake-us5-datadoghq.com',
    'DOMAIN,o1158394.ingest.us.sentry.io',
    // Anthropic's published ranges catch connections made without a name.
    'IP-CIDR,160.79.104.0/21,no-resolve',
    'IP-CIDR,153.61.208.0/20,no-resolve',
    'IP-CIDR,153.61.224.0/22,no-resolve',
    'IP-CIDR6,2607:6bc0::/48,no-resolve',
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
