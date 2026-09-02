import 'package:reclash/common/task.dart';
import 'package:reclash/models/profile.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/providers/action.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewProfileView extends ConsumerStatefulWidget {
  final Profile profile;

  const PreviewProfileView({super.key, required this.profile});

  @override
  ConsumerState<PreviewProfileView> createState() => _PreviewProfileViewState();
}

class _PreviewProfileViewState extends ConsumerState<PreviewProfileView> {
  final contentNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configMap = await ref
          .read(setupActionProvider.notifier)
          .getProfileWithId(widget.profile.id);
      final content = await encodeYamlTask(configMap);
      if (!mounted) {
        return;
      }
      contentNotifier.value = content;
    });
  }

  @override
  void dispose() {
    contentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: contentNotifier,
      builder: (_, content, _) {
        final title = widget.profile.realLabel;

        return EditorPage(
          key: const Key('content'),
          title: title,
          content: content,
        );
      },
    );
  }
}
