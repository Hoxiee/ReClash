import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/edit.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/widgets/announcement_card.dart';

import 'registry.dart';

const _gap = 12.0;

/// The widgets page: the provider's notice, then the saved widgets; while
/// [editing], the same cards to drag and hide, and the hidden ones to add.
class SimpleWidgetList extends ConsumerWidget {
  const SimpleWidgetList({
    super.key,
    required this.editing,
    required this.onDone,
    required this.padding,
    this.leading = const [],
  });

  final bool editing;
  final VoidCallback onDone;
  final EdgeInsets padding;

  /// Cards above the widgets that are not widgets themselves, kept in place
  /// while the widgets are edited.
  final List<Widget> leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgets = ref.watch(
      appSettingProvider.select((state) => state.simpleDashboardWidgets),
    );
    if (editing) {
      return _Editor(
        widgets: widgets,
        padding: padding,
        leading: leading,
        onDone: onDone,
      );
    }
    final hasNotice = ref.watch(
      providerNoticeProvider.select((card) => card != null),
    );
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding,
          // Cards this uneven move a lazy list's scroll end as it lays them out.
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: _gap,
              children: [
                ...leading,
                if (hasNotice) const NoticeCard(),
                for (final widget in widgets)
                  RepaintBoundary(key: ValueKey(widget), child: widget.card),
                if (widgets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      context.appLocalizations.simpleDashboardEmpty,
                      textAlign: TextAlign.center,
                      style: DashboardText.label(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Editor extends ConsumerWidget {
  const _Editor({
    required this.widgets,
    required this.padding,
    required this.leading,
    required this.onDone,
  });

  final List<SimpleDashboardWidget> widgets;
  final EdgeInsets padding;
  final List<Widget> leading;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        if (leading.isNotEmpty)
          SliverPadding(
            padding: padding.copyWith(bottom: _gap),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: _gap,
                children: leading,
              ),
            ),
          ),
        DashboardCardEditor<SimpleDashboardWidget>(
          cards: widgets,
          candidates: SimpleDashboardWidget.values,
          cardOf: (widget) => widget.card,
          labelOf: (context, widget) => widget.label(context),
          glyphOf: (widget) => widget.glyph,
          padding: padding.copyWith(top: leading.isEmpty ? null : 0),
          gap: _gap,
          onDone: onDone,
          onChanged: (widgets) => ref
              .read(appSettingProvider.notifier)
              .update(
                (state) => state.copyWith(simpleDashboardWidgets: widgets),
              ),
        ),
      ],
    );
  }
}
