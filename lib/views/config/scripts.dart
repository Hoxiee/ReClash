import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/views/config/editor.dart';
import 'package:reclash/widgets/widgets.dart';

class ScriptsView extends ConsumerStatefulWidget {
  const ScriptsView({super.key});

  @override
  ConsumerState<ScriptsView> createState() => _ScriptsViewState();
}

class _ScriptsViewState extends ConsumerState<ScriptsView> {
  final _key = uniqueId;

  Future<void> _handleDelete() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.script),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedScriptIds = ref.read(itemsProvider(_key)).cast<int>();
    ref.read(scriptsProvider.notifier).delAll(selectedScriptIds);
    ref.read(itemsProvider(_key).notifier).value = {};
    for (final id in selectedScriptIds) {
      unawaited(_clearEffect(id));
    }
  }

  Future<void> _clearEffect(int id) async {
    final path = await appPath.getScriptPath(id.toString());
    await File(path).safeDelete();
  }

  void _handleSelected(int id) {
    ref.read(itemsProvider(_key).notifier).update((selectedScriptIds) {
      return Set<int>.from(selectedScriptIds)..addOrRemove(id);
    });
  }

  void _handleSelectAll() {
    final ids =
        ref.read(scriptsProvider).value?.map((item) => item.id).toSet() ?? {};
    ref.read(itemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Widget _buildContent(List<Script> scripts, Set<dynamic> selectedScriptIds) {
    final appLocalizations = context.appLocalizations;
    return NullStatusSwitcher(
      isEmpty: scripts.isEmpty,
      nullStatus: NullStatus(
        illustration: NullStatusIllustration.scripts,
        label: appLocalizations.nullTip(appLocalizations.script),
      ),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, context.appBarInset, 16, 16),
        itemCount: scripts.length,
        itemBuilder: (_, index) {
          final script = scripts[index];
          return ItemPositionProvider(
            position: ItemPosition.get(index, scripts.length),
            child: SelectedDecorationListItem(
              isSelected: selectedScriptIds.contains(script.id),
              isEditing: selectedScriptIds.isNotEmpty,
              title: Text(
                script.label,
                style: context.textTheme.bodyLarge,
                maxLines: 3,
              ),
              onSelected: () {
                _handleSelected(script.id);
              },
              onPressed: () {
                _handleToEditor(script.id);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleEditorSave(
    BuildContext editorContext,
    String title,
    String content, {
    Script? script,
  }) async {
    final appLocalizations = context.appLocalizations;
    var label = title.trim();
    if (label.isEmpty) {
      final res = await dialogs.showCommonDialog<String>(
        child: InputDialog(
          title: appLocalizations.save,
          value: '',
          hintText: appLocalizations.pleaseEnterScriptName,
          inputFormatters: TextInputLimits.limit(TextInputLimits.name),
          validator: (value) {
            final name = value?.trim() ?? '';
            if (name.isEmpty) {
              return appLocalizations.emptyTip(appLocalizations.name);
            }
            if (name != script?.label &&
                ref.read(scriptsProvider.notifier).isExits(name)) {
              return appLocalizations.existsTip(appLocalizations.name);
            }
            return null;
          },
        ),
      );
      if (res == null || res.trim().isEmpty || !mounted) {
        return;
      }
      label = res.trim();
    }
    if (!editorContext.mounted) {
      return;
    }
    if (label != script?.label &&
        ref.read(scriptsProvider.notifier).isExits(label)) {
      unawaited(
        dialogs.showMessage(
          message: TextSpan(
            text: appLocalizations.existsTip(appLocalizations.name),
          ),
        ),
      );
      return;
    }
    final newScript = await (script?.copyWith(label: label) ??
            Script.create(label: label))
        .save(content);
    if (!mounted) {
      return;
    }
    ref.read(scriptsProvider.notifier).put(newScript);
    if (editorContext.mounted) {
      Navigator.of(editorContext).pop();
    }
  }

  Future<bool> _handleEditorPop(
    BuildContext editorContext,
    String title,
    String content,
    String raw, {
    Script? script,
  }) async {
    final appLocalizations = context.appLocalizations;
    if (content == raw && title == (script?.label ?? '')) {
      return true;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == null) {
      return false;
    }
    if (!res) {
      return true;
    }
    if (mounted && editorContext.mounted) {
      await _handleEditorSave(editorContext, title, content, script: script);
    }
    return false;
  }

  void _handleToEditor([int? id]) async {
    final script = await ref.read(scriptProvider(id).future);
    final title = script?.label ?? '';
    late final String raw;
    if (!mounted) {
      return;
    }
    unawaited(
      BaseNavigator.push(
        context,
        EditorPage(
          titleEditable: true,
          title: title,
          supportRemoteDownload: true,
          onSave: (context, title, content) =>
              _handleEditorSave(context, title, content, script: script),
          onPop: (context, title, content) {
            return _handleEditorPop(
              context,
              title,
              content,
              raw,
              script: script,
            );
          },
          language: Language.javaScript,
          load: () async => raw = script == null
              ? scriptTemplate
              : await readTextFileTask(await script.path) ?? scriptTemplate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final scripts = ref.watch(scriptsProvider).value ?? [];
    final selectedScriptIds = ref.watch(itemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedScriptIds.isNotEmpty) {
          ref.read(itemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: CommonScaffold(
        actions: [
          if (selectedScriptIds.isNotEmpty)
            IconButton.filledTonal(
              tooltip: context.appLocalizations.delete,
              onPressed: _handleDelete,
              icon: const GlyphIcon(AppGlyphs.delete),
            ).withAppTooltip(),
          selectedScriptIds.isNotEmpty
              ? FilledButton(
                  onPressed: _handleSelectAll,
                  child: Text(appLocalizations.selectAll),
                )
              : FilledButton.tonal(
                  onPressed: () {
                    _handleToEditor();
                  },
                  child: Text(appLocalizations.add),
                ),
        ],
        body: _buildContent(scripts, selectedScriptIds),
        floatBody: true,
        title: appLocalizations.script,
      ),
    );
  }
}
