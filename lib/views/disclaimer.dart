import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

const _googlePrivacyUrl = 'https://policies.google.com/privacy';
const _firebasePrivacyUrl = 'https://firebase.google.com/support/privacy';
const _maxContentWidth = 720.0;

class DisclaimerView extends ConsumerWidget {
  const DisclaimerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.disclaimer,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          context.contentTopPadding,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DisclaimerIntro(text: appLocalizations.disclaimerDesc),
                  _Term(
                    index: 1,
                    title: appLocalizations.disclaimerSoftwareTitle,
                    content: appLocalizations.disclaimerSoftwareContent,
                  ),
                  _Term(
                    index: 2,
                    title: appLocalizations.disclaimerResponsibilityTitle,
                    content: appLocalizations.disclaimerResponsibilityContent,
                  ),
                  _Term(
                    index: 3,
                    title: appLocalizations.disclaimerThirdPartyTitle,
                    content: appLocalizations.disclaimerThirdPartyContent,
                  ),
                  _Term(
                    index: 4,
                    title: appLocalizations.disclaimerNetworkTitle,
                    content: appLocalizations.disclaimerNetworkContent,
                  ),
                  _Term(
                    index: 5,
                    title: appLocalizations.disclaimerPrivacyTitle,
                    content: appLocalizations.disclaimerPrivacyContent,
                    children: [
                      if (system.isAndroid) ...[
                        _TermBody(
                          text: appLocalizations.disclaimerAndroidServicesIntro,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _DataServiceCard(
                          glyph: AppGlyphs.error,
                          title: 'Firebase Crashlytics',
                          content:
                              appLocalizations.disclaimerCrashlyticsContent,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _TermBody(
                          text:
                              appLocalizations.disclaimerDataProcessingContent,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _PolicyLink(
                              label: appLocalizations.disclaimerGooglePrivacy,
                              url: _googlePrivacyUrl,
                            ),
                            _PolicyLink(
                              label: appLocalizations.disclaimerFirebasePrivacy,
                              url: _firebasePrivacyUrl,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  _Term(
                    index: 6,
                    title: appLocalizations.disclaimerSubscriptionReportTitle,
                    content:
                        appLocalizations.disclaimerSubscriptionReportContent,
                  ),
                  _Term(
                    index: 7,
                    title: appLocalizations.disclaimerWarrantyTitle,
                    content: appLocalizations.disclaimerWarrantyContent,
                  ),
                  _Term(
                    index: 8,
                    title: appLocalizations.disclaimerLiabilityTitle,
                    content: appLocalizations.disclaimerLiabilityContent,
                  ),
                  _Term(
                    index: 9,
                    title: appLocalizations.disclaimerLicenseTitle,
                    content: appLocalizations.disclaimerLicenseContent,
                  ),
                  _Term(
                    index: 10,
                    title: appLocalizations.disclaimerChangesTitle,
                    content: appLocalizations.disclaimerChangesContent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerIntro extends StatelessWidget {
  const _DisclaimerIntro({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: AppInsets.xl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlyphIcon(
              AppGlyphs.gavel,
              size: 28,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Term extends StatelessWidget {
  const _Term({
    required this.index,
    required this.title,
    required this.content,
    this.children = const [],
  });

  final int index;
  final String title;
  final String content;
  final List<Widget> children;

  static const _badgeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: AppShape.full,
                ),
                child: SizedBox.square(
                  dimension: _badgeSize,
                  child: Center(
                    child: Text(
                      '$index',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TermBody(text: content),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _TermBody extends StatelessWidget {
  const _TermBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      height: 1.6,
    );
    final blocks = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (blockIndex, block) in blocks.indexed)
          Padding(
            padding: EdgeInsets.only(top: blockIndex == 0 ? 0 : AppSpacing.sm),
            child: _isBulletBlock(block)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final line in block.split('\n'))
                        _BulletLine(
                          text: line.replaceFirst('- ', ''),
                          style: style,
                        ),
                    ],
                  )
                : Text(block, style: style),
          ),
      ],
    );
  }

  static bool _isBulletBlock(String block) =>
      block.split('\n').every((line) => line.startsWith('- '));
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text('•', style: style),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

class _DataServiceCard extends StatelessWidget {
  const _DataServiceCard({
    required this.glyph,
    required this.title,
    required this.content,
  });

  final Glyph glyph;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainer,
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: AppInsets.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GlyphIcon(glyph, size: 20, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colorScheme.tertiaryContainer,
                    shape: AppShape.full,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      context.appLocalizations.disclaimerAndroidOnly,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _TermBody(text: content),
          ],
        ),
      ),
    );
  }
}

class _PolicyLink extends StatelessWidget {
  const _PolicyLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ElasticButton(
      child: TextButton.icon(
        onPressed: () => dialogs.openUrl(url),
        icon: const GlyphIcon(AppGlyphs.openExternal, size: 18),
        label: Text(label),
      ),
    );
  }
}

Future<void> showDisclaimerPage(BuildContext context) async {
  await BaseNavigator.push<void>(context, const DisclaimerView());
}
