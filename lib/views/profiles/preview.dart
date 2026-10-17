import 'package:reclash/models/profile.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/providers/action.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewProfileView extends ConsumerWidget {
  final Profile profile;

  const PreviewProfileView({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditorPage(
      title: profile.realLabel,
      load: () =>
          ref.read(setupActionProvider.notifier).getProfileWithId(profile.id),
    );
  }
}
