import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/views/error_strings.dart';

/// Standalone app shown when [bootstrap] throws before the real app exists.
/// It owns its own theme and leans on no provider or navigator, because the
/// failure above means none of those are guaranteed to be ready. Locale is read
/// straight from the platform dispatcher, the same fallback the live app uses
/// when no explicit language is stored.
Widget buildInitErrorApp({
  required Object error,
  required StackTrace stack,
  required List<String> relaunchArgs,
}) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  ThemeData theme(Brightness brightness) =>
      ThemeData(brightness: brightness, useMaterial3: true).withAppShapes;

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [
      Locale('en'),
      Locale('ru'),
      Locale('zh', 'CN'),
      Locale('ja'),
      Locale('ko'),
    ],
    theme: theme(Brightness.light),
    darkTheme: theme(Brightness.dark),
    home: InitErrorScreen(
      error: error,
      stack: stack,
      relaunchArgs: relaunchArgs,
      locale: locale,
    ),
  );
}

enum _Diagnosis {
  preferences(_Repair.resetPrefs),
  database(_Repair.factoryReset),
  config(_Repair.resetConfig),
  core(_Repair.restart),
  unknown(_Repair.restart);

  const _Diagnosis(this.recommended);

  final _Repair recommended;

  static _Diagnosis of(Object error) {
    final text = error.toString().toLowerCase();
    bool has(List<String> keys) => keys.any(text.contains);
    if (has([
      'sharedpreferences',
      'shared_preferences',
      'preferences',
      'formatexception',
      'unexpected character',
      'json',
    ])) {
      return _Diagnosis.preferences;
    }
    if (has(['database', 'sqlite', 'drift', 'migration', 'schema'])) {
      return _Diagnosis.database;
    }
    if (has(['config.yaml', '.yaml', 'yaml', 'clash config'])) {
      return _Diagnosis.config;
    }
    if (has(['rustlib', 'core', 'ffi', 'dylib', 'permission denied'])) {
      return _Diagnosis.core;
    }
    return _Diagnosis.unknown;
  }
}

enum _Repair { restart, resetPrefs, resetConfig, openFolder, factoryReset }

class InitErrorScreen extends StatefulWidget {
  final Object error;
  final StackTrace stack;
  final List<String> relaunchArgs;
  final Locale? locale;

  const InitErrorScreen({
    super.key,
    required this.error,
    required this.stack,
    this.relaunchArgs = const [],
    this.locale,
  });

  @override
  State<InitErrorScreen> createState() => _InitErrorScreenState();
}

class _InitErrorScreenState extends State<InitErrorScreen> {
  _Repair? _busy;
  bool _detailsOpen = false;

  bool get _mobile => Platform.isAndroid || Platform.isIOS;

  late final _Diagnosis _diagnosis = _Diagnosis.of(widget.error);
  late Locale? _locale = widget.locale;
  InitErrorStrings get _s => InitErrorStrings.of(_locale);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return _wideLayout(colorScheme);
            }
            return _narrowLayout(colorScheme);
          },
        ),
      ),
    );
  }

  Widget _narrowLayout(ColorScheme colorScheme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            _header(colorScheme),
            const SizedBox(height: AppSpacing.xl),
            _diagnosisCard(colorScheme),
            const SizedBox(height: AppSpacing.xl),
            _recoverySteps(colorScheme),
            const SizedBox(height: AppSpacing.md),
            _detailsSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _wideLayout(ColorScheme colorScheme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(colorScheme),
                    const SizedBox(height: AppSpacing.xl),
                    _diagnosisCard(colorScheme),
                    const SizedBox(height: AppSpacing.xl),
                    _detailsSection(colorScheme),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxl),
              Expanded(child: _recoverySteps(colorScheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recoverySteps(ColorScheme colorScheme) {
    final actions = <_Repair>[
      _Repair.restart,
      _Repair.resetPrefs,
      _Repair.resetConfig,
      if (system.isDesktop) _Repair.openFolder,
      _Repair.factoryReset,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(colorScheme, _s.recoverySteps),
        const SizedBox(height: AppSpacing.sm),
        for (final action in actions) ...[
          _RecoveryTile(
            spec: _specFor(action),
            recommended: action == _diagnosis.recommended,
            suggestedLabel: _s.suggested,
            busy: _busy == action,
            enabled: _busy == null,
            onTap: () => _run(action),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _header(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppInsets.md,
              decoration: ShapeDecoration(
                color: colorScheme.errorContainer.opacity50,
                shape: AppShape.lg,
              ),
              child: GlyphIcon(
                AppGlyphs.warning,
                color: colorScheme.error,
                size: 32,
              ),
            ),
            const Spacer(),
            _languageSelector(colorScheme),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _s.cantStart,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _s.intro,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _languageSelector(ColorScheme colorScheme) {
    final current = InitErrorStrings.languages.firstWhere(
      (entry) => entry.$1.languageCode == (_locale?.languageCode ?? 'en'),
      orElse: () => InitErrorStrings.languages.first,
    );
    return PopupMenuButton<Locale>(
      tooltip: '',
      position: PopupMenuPosition.under,
      onSelected: (locale) => setState(() => _locale = locale),
      itemBuilder: (context) => [
        for (final (locale, name) in InitErrorStrings.languages)
          PopupMenuItem(
            value: locale,
            child: Row(
              children: [
                Expanded(child: Text(name)),
                if (locale.languageCode == current.$1.languageCode) ...[
                  const SizedBox(width: AppSpacing.sm),
                  GlyphIcon(
                    AppGlyphs.check,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainerHigh,
          shape: AppShape.full,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlyphIcon(
              AppGlyphs.language,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(current.$2, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: AppSpacing.xxs),
            GlyphIcon(
              AppGlyphs.chevronDown,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _diagnosisCard(ColorScheme colorScheme) {
    final (title, detail) = _diagText();
    return Container(
      width: double.infinity,
      padding: AppInsets.lg,
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: AppShape.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlyphIcon(
                AppGlyphs.healthMonitor,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _diagText() => switch (_diagnosis) {
    _Diagnosis.preferences => (_s.diagPrefsTitle, _s.diagPrefsDetail),
    _Diagnosis.database => (_s.diagDbTitle, _s.diagDbDetail),
    _Diagnosis.config => (_s.diagConfigTitle, _s.diagConfigDetail),
    _Diagnosis.core => (_s.diagCoreTitle, _s.diagCoreDetail),
    _Diagnosis.unknown => (_s.diagUnknownTitle, _s.diagUnknownDetail),
  };

  Widget _sectionLabel(ColorScheme colorScheme, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _detailsSection(ColorScheme colorScheme) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: AppShape.md,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _detailsOpen = !_detailsOpen),
            child: Padding(
              padding: AppInsets.lg,
              child: Row(
                children: [
                  GlyphIcon(
                    AppGlyphs.code,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _s.technicalDetails,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _copyDetails,
                    icon: const GlyphIcon(AppGlyphs.copy, size: 18),
                    label: Text(_s.copy),
                  ),
                  GlyphIcon(
                    _detailsOpen ? AppGlyphs.chevronUp : AppGlyphs.chevronDown,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_detailsOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _codeBlock(colorScheme, widget.error.toString()),
                  const SizedBox(height: AppSpacing.sm),
                  _codeBlock(
                    colorScheme,
                    widget.stack.toString(),
                    monospace: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _codeBlock(
    ColorScheme colorScheme,
    String text, {
    bool monospace = false,
  }) {
    return Container(
      width: double.infinity,
      padding: AppInsets.md,
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerLowest,
        shape: AppShape.sm,
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontFamily: monospace ? 'monospace' : null,
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  _TileSpec _specFor(_Repair repair) {
    switch (repair) {
      case _Repair.restart:
        return _TileSpec(
          glyph: AppGlyphs.replay,
          title: _mobile ? _s.restartMobileTitle : _s.restartDesktopTitle,
          subtitle: _mobile
              ? _s.restartMobileSubtitle
              : _s.restartDesktopSubtitle,
        );
      case _Repair.resetPrefs:
        return _TileSpec(
          glyph: AppGlyphs.broom,
          title: _s.resetPrefsTitle,
          subtitle: _s.resetPrefsSubtitle,
        );
      case _Repair.resetConfig:
        return _TileSpec(
          glyph: AppGlyphs.refresh,
          title: _s.resetConfigTitle,
          subtitle: _s.resetConfigSubtitle,
        );
      case _Repair.openFolder:
        return _TileSpec(
          glyph: AppGlyphs.folder,
          title: _s.openFolderTitle,
          subtitle: _s.openFolderSubtitle,
        );
      case _Repair.factoryReset:
        return _TileSpec(
          glyph: AppGlyphs.delete,
          title: _s.factoryResetTitle,
          subtitle: _s.factoryResetSubtitle,
          destructive: true,
        );
    }
  }

  Future<void> _run(_Repair repair) async {
    switch (repair) {
      case _Repair.restart:
        await _restart();
      case _Repair.openFolder:
        await _openDataFolder();
      case _Repair.resetPrefs:
        await _repair(
          repair,
          _s.confirmResetPrefsTitle,
          _s.confirmResetPrefsMessage,
          () async => File(await appPath.sharedPreferencesPath).safeDelete(),
        );
      case _Repair.resetConfig:
        await _repair(
          repair,
          _s.confirmResetConfigTitle,
          _s.confirmResetConfigMessage,
          () async => File(await appPath.configFilePath).safeDelete(),
        );
      case _Repair.factoryReset:
        await _repair(
          repair,
          _s.confirmFactoryTitle,
          _s.confirmFactoryMessage,
          _factoryReset,
          destructive: true,
        );
    }
  }

  Future<void> _factoryReset() async {
    await File(await appPath.sharedPreferencesPath).safeDelete();
    await File(await appPath.configFilePath).safeDelete();
    await File(await appPath.databasePath).safeDelete();
    await safeDeletePath(await appPath.profilesPath);
  }

  Future<void> _repair(
    _Repair repair,
    String title,
    String message,
    Future<void> Function() action, {
    bool destructive = false,
  }) async {
    final confirmed = await _confirm(title, message, destructive: destructive);
    if (confirmed != true) return;
    setState(() => _busy = repair);
    try {
      await action();
      if (!mounted) return;
      await _offerRestart();
    } catch (error) {
      if (mounted) _snack('${_s.couldNotCompletePrefix}$error');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<bool?> _confirm(
    String title,
    String message, {
    bool destructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  )
                : null,
            child: Text(destructive ? _s.resetAction : _s.continueLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _offerRestart() async {
    final restart = await _confirm(
      _s.doneTitle,
      _mobile ? _s.doneRestartMobile : _s.doneRestartDesktop,
    );
    if (restart == true) {
      await _restart();
    }
  }

  Future<void> _restart() async {
    if (system.isDesktop) {
      try {
        // Under an AppImage, resolvedExecutable points inside the FUSE mount
        // that unmounts the moment this process exits, so relaunching it would
        // race the mount away and the app would just close. $APPIMAGE is the
        // outer .AppImage on disk and survives the unmount.
        final executable =
            Platform.environment['APPIMAGE'] ?? Platform.resolvedExecutable;
        await Process.start(
          executable,
          widget.relaunchArgs,
          mode: ProcessStartMode.detached,
        );
      } catch (_) {}
    }
    exit(0);
  }

  Future<void> _openDataFolder() async {
    try {
      final dir = await appPath.homeDirPath;
      if (Platform.isLinux) {
        await Process.run('xdg-open', [dir]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [dir]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [dir]);
      }
    } catch (error) {
      if (mounted) _snack('${_s.couldNotOpenFolderPrefix}$error');
    }
  }

  void _copyDetails() {
    final text =
        '=== ReClash init error ===\n'
        'platform: ${Platform.operatingSystem} '
        '${Platform.operatingSystemVersion}\n\n'
        '=== ERROR ===\n${widget.error}\n\n'
        '=== STACK TRACE ===\n${widget.stack}';
    Clipboard.setData(ClipboardData(text: text));
    _snack(_s.copied);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _TileSpec {
  final Glyph glyph;
  final String title;
  final String subtitle;
  final bool destructive;

  const _TileSpec({
    required this.glyph,
    required this.title,
    required this.subtitle,
    this.destructive = false,
  });
}

class _RecoveryTile extends StatelessWidget {
  final _TileSpec spec;
  final bool recommended;
  final String suggestedLabel;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  const _RecoveryTile({
    required this.spec,
    required this.recommended,
    required this.suggestedLabel,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = spec.destructive ? colorScheme.error : colorScheme.primary;
    final border = recommended
        ? BorderSide(color: accent.opacity50, width: 1.5)
        : BorderSide(color: colorScheme.outlineVariant.opacity50);

    return Opacity(
      opacity: enabled || busy ? 1 : 0.5,
      child: Material(
        color: colorScheme.surfaceContainer,
        shape: AppShape.md.copyWith(side: border),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: AppInsets.lg,
            child: Row(
              children: [
                Container(
                  padding: AppInsets.sm,
                  decoration: ShapeDecoration(
                    color: accent.opacity12,
                    shape: AppShape.sm,
                  ),
                  child: GlyphIcon(spec.glyph, color: accent, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              spec.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: spec.destructive
                                        ? colorScheme.error
                                        : null,
                                  ),
                            ),
                          ),
                          if (recommended) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _RecommendedBadge(
                              accent: accent,
                              label: suggestedLabel,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        spec.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox.square(
                  dimension: 20,
                  child: busy
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : GlyphIcon(
                          AppGlyphs.chevronForward,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  final Color accent;
  final String label;

  const _RecommendedBadge({required this.accent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: ShapeDecoration(
        color: accent.opacity12,
        shape: AppShape.full,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
