import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';

const _stackedIcons = 3;
const _iconSize = 24.0;
const _iconOverlap = 14.0;

/// Overlapping app icons that summarize the list on its row.
class DirectAppsStack extends StatelessWidget {
  const DirectAppsStack({super.key, required this.apps});

  final List<String> apps;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final shown = apps.take(_stackedIcons).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: _iconSize + 6 + (shown.length - 1) * _iconOverlap,
      height: _iconSize + 6,
      child: Stack(
        children: [
          for (var i = shown.length - 1; i >= 0; i--)
            Positioned(
              left: i * _iconOverlap,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: context.raisedSurfaceLevel.colorOf(colors),
                  shape: AppShape.sm,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: PackageIcon(packageName: shown[i], size: _iconSize),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showDirectAppsSheet(BuildContext context) => showFormSheet<void>(
  context: context,
  builder: (_) => const DirectAppsSheet(),
);

/// Lists the apps found for the region with a switch each. The list is fixed
/// when the sheet opens so a switched-off app stays to be switched back on.
class DirectAppsSheet extends ConsumerStatefulWidget {
  const DirectAppsSheet({super.key});

  @override
  ConsumerState<DirectAppsSheet> createState() => _DirectAppsSheetState();
}

class _DirectAppsSheetState extends ConsumerState<DirectAppsSheet> {
  late List<String> _listed;

  SetupSession get _session => ref.read(setupSessionProvider.notifier);

  @override
  void initState() {
    super.initState();
    _listed = ref.read(setupSessionProvider).draft.directApps ?? const [];
  }

  Future<void> _rescan() async {
    await _session.findDirectApps();
    if (!mounted) return;
    final apps = ref.read(setupSessionProvider).draft.directApps;
    if (apps != null) setState(() => _listed = apps);
  }

  void _clear() {
    _session.clearDirectApps();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colors = context.colorScheme;
    final state = ref.watch(setupSessionProvider);
    final active = state.draft.directApps?.toSet() ?? const <String>{};
    final scanning = state.scanningApps;
    final labels = {
      for (final package in ref.watch(packagesProvider))
        package.packageName: package.label,
    };
    final entries = [
      for (final package in _listed) (package, labels[package] ?? package),
    ]..sort((a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));
    return FormPage(
      title: l.setupDirectAppsTitle,
      saveLabel: l.done,
      onSave: () => Navigator.of(context).pop(),
      error: state.error,
      actions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: l.setupDirectAppsFind,
          isLoading: scanning,
          onPressed: scanning ? null : () => unawaited(_rescan()),
        ),
      ],
      children: [
        generateSection(
          title: l.setupDirectApps(active.length),
          footer: l.setupDirectAppsReview,
          items: entries.isEmpty
              ? [
                  DecorationListItem(
                    leading: const GlyphIcon(AppGlyphs.appsList),
                    title: Text(l.setupDirectAppsNone),
                  ),
                ]
              : [
                  for (final (package, label) in entries)
                    DecorationListItem(
                      key: ValueKey(package),
                      leading: PackageIcon(packageName: package, size: 32),
                      title: Text(label, maxLines: 1),
                      subtitle: Text(
                        package,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => _session.setDirectApp(
                        package,
                        bypass: !active.contains(package),
                      ),
                      trailing: CommonSwitch(
                        value: active.contains(package),
                        semanticLabel: label,
                        onChanged: (value) =>
                            _session.setDirectApp(package, bypass: value),
                      ),
                    ),
                ],
        ),
        generateSection(
          items: [
            DecorationListItem(
              title: Text(
                l.setupDirectAppsClear,
                style: TextStyle(color: colors.error),
              ),
              onPressed: _clear,
            ),
          ],
        ),
      ],
    );
  }
}
