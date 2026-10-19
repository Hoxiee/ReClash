import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True only after "Agree"; any other way out declines.
Future<bool> requestDisclaimerConsent() async {
  return await BaseNavigator.push<bool>(
        rootNavigatorKey.currentContext!,
        const DisclaimerView(requireConsent: true),
      ) ??
      false;
}

class DisclaimerView extends StatelessWidget {
  final bool requireConsent;
  final VoidCallback? onAgree;
  final VoidCallback? onDecline;

  const DisclaimerView({
    super.key,
    this.requireConsent = false,
    this.onAgree,
    this.onDecline,
  });

  static const _maxContentWidth = 720.0;

  List<({String title, String content})> _terms(AppLocalizations l) => [
    (
      title: l.disclaimerSoftwareTitle,
      content:
          '${l.disclaimerSoftwareContent}\n\n${l.disclaimerNoServiceStatement}',
    ),
    (title: l.disclaimerUsageTitle, content: l.disclaimerUsageContent),
    (
      title: l.disclaimerResponsibilityTitle,
      content: l.disclaimerResponsibilityContent,
    ),
    (
      title: l.disclaimerThirdPartyTitle,
      content: l.disclaimerThirdPartyContent,
    ),
    (title: l.disclaimerWarrantyTitle, content: l.disclaimerWarrantyContent),
    (title: l.disclaimerLiabilityTitle, content: l.disclaimerLiabilityContent),
    (title: l.disclaimerPrivacyTitle, content: l.disclaimerPrivacyContent),
    (title: l.disclaimerLicenseTitle, content: l.disclaimerLicenseContent),
    (title: l.disclaimerChangesTitle, content: l.disclaimerChangesContent),
    (title: l.disclaimerAcceptTitle, content: l.disclaimerAcceptContent),
  ];

  static const _mobileGutter = 16.0;
  static const _desktopGutter = 24.0;
  static const _desktopTopPadding = 48.0;

  ListView _buildBody({
    required EdgeInsets padding,
    required List<Widget> children,
  }) {
    return ListView(
      padding: padding,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final terms = _buildTerms(appLocalizations);
    final body = _buildBody(
      padding: const EdgeInsets.symmetric(
        horizontal: _mobileGutter,
      ).copyWith(top: context.contentTopPadding, bottom: 32),
      children: terms,
    );
    if (!requireConsent) {
      return CommonScaffold(title: appLocalizations.disclaimer, body: body);
    }
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(isMobileViewProvider)) {
          return CommonScaffold(
            title: appLocalizations.disclaimer,
            body: _ConsentLayout(
              maxWidth: _maxContentWidth,
              gutter: _mobileGutter,
              compact: true,
              onAgree: onAgree,
              onDecline: onDecline,
              child: body,
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: _ConsentLayout(
              maxWidth: _maxContentWidth,
              gutter: _desktopGutter,
              compact: false,
              onAgree: onAgree,
              onDecline: onDecline,
              child: _buildBody(
                padding: const EdgeInsets.fromLTRB(
                  _desktopGutter,
                  _desktopTopPadding,
                  _desktopGutter,
                  32,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      appLocalizations.disclaimer,
                      style: AppTextStyle.title2.of(context, emphasized: true),
                    ),
                  ),
                  ...terms,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTerms(AppLocalizations appLocalizations) {
    return [
      _DisclaimerIntro(text: appLocalizations.disclaimerDesc),
      for (final (index, term) in _terms(appLocalizations).indexed)
        _DisclaimerTerm(
          index: index + 1,
          title: term.title,
          content: term.content,
        ),
    ];
  }
}

class _DisclaimerIntro extends StatelessWidget {
  final String text;

  const _DisclaimerIntro({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlyphIcon(AppGlyphs.gavel, size: 28, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(color: colorScheme.onSurfaceVariant, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerTerm extends StatelessWidget {
  final int index;
  final String title;
  final String content;

  const _DisclaimerTerm({
    required this.index,
    required this.title,
    required this.content,
  });

  static const _badgeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: context.raisedSurfaceLevel.colorOf(colorScheme),
                  shape: AppShape.full,
                ),
                child: SizedBox.square(
                  dimension: _badgeSize,
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTextStyle.caption1
                          .of(context, emphasized: true)
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: AppTextStyle.headline.of(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TermParagraphs(content),
        ],
      ),
    );
  }
}

class _TermParagraphs extends StatelessWidget {
  final String text;

  const _TermParagraphs(this.text);

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.subheadline
        .of(context)
        .copyWith(color: context.colorScheme.onSurfaceVariant, height: 1.6);
    final paragraphs = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, paragraph) in paragraphs.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
            child: Text(paragraph, style: style),
          ),
      ],
    );
  }
}

class _ConsentLayout extends StatefulWidget {
  final double maxWidth;
  final double gutter;
  final bool compact;
  final VoidCallback? onAgree;
  final VoidCallback? onDecline;
  final Widget child;

  const _ConsentLayout({
    required this.maxWidth,
    required this.gutter,
    required this.compact,
    this.onAgree,
    this.onDecline,
    required this.child,
  });

  @override
  State<_ConsentLayout> createState() => _ConsentLayoutState();
}

class _ConsentLayoutState extends State<_ConsentLayout> {
  Locale? _locale;
  static const _endTolerance = 1.0;

  bool _readToEnd = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != locale) {
      _locale = locale;
      _readToEnd = false;
    }
  }

  bool _handleNotification(Notification notification) {
    if (_readToEnd) {
      return false;
    }
    final metrics = switch (notification) {
      ScrollNotification(depth: 0, :final metrics) ||
      ScrollMetricsNotification(depth: 0, :final metrics) => metrics,
      _ => null,
    };
    if (metrics != null && metrics.extentAfter <= _endTolerance) {
      setState(() {
        _readToEnd = true;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<Notification>(
            onNotification: _handleNotification,
            child: widget.child,
          ),
        ),
        _ConsentBar(
          maxWidth: widget.maxWidth,
          gutter: widget.gutter,
          compact: widget.compact,
          readToEnd: _readToEnd,
          onAgree: widget.onAgree,
          onDecline: widget.onDecline,
        ),
      ],
    );
  }
}

class _ConsentBar extends StatelessWidget {
  final double maxWidth;
  final double gutter;
  final bool compact;
  final bool readToEnd;
  final VoidCallback? onAgree;
  final VoidCallback? onDecline;

  const _ConsentBar({
    required this.maxWidth,
    required this.gutter,
    required this.compact,
    required this.readToEnd,
    this.onAgree,
    this.onDecline,
  });

  Widget _buildExitButton(BuildContext context) {
    return ElasticButton(
      child: OutlinedButton(
        onPressed: () {
          if (onDecline != null) {
            onDecline!();
          } else {
            Navigator.of(context).pop(false);
          }
        },
        child: Text(context.appLocalizations.exit),
      ),
    );
  }

  void _handleAgree(BuildContext context) {
    if (onAgree != null) {
      onAgree!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildAgreeButton(BuildContext context, {required String label}) {
    return ElasticButton(
      child: FilledButton(
        onPressed: readToEnd ? () => _handleAgree(context) : null,
        child: Text(label),
      ),
    );
  }

  Widget _buildCompactActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        Expanded(child: _buildExitButton(context)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAgreeButton(
            context,
            label: readToEnd
                ? appLocalizations.agree
                : appLocalizations.disclaimerReadToEnd,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Row(
      children: [
        Expanded(
          child: readToEnd
              ? const SizedBox.shrink()
              : Text(
                  appLocalizations.disclaimerReadToEnd,
                  style: AppTextStyle.subheadline
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
        ),
        const SizedBox(width: 12),
        _buildExitButton(context),
        const SizedBox(width: 12),
        _buildAgreeButton(context, label: appLocalizations.agree),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SurfaceLevel.page.colorOf(context.colorScheme),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 12),
              child: compact
                  ? _buildCompactActions(context)
                  : _buildActions(context),
            ),
          ),
        ),
      ),
    );
  }
}
