import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/pre_release_notice_dialog.dart';

Widget preview() => const _PreviewHost();

class _PreviewHost extends StatefulWidget {
  const _PreviewHost();

  @override
  State<_PreviewHost> createState() => _PreviewHostState();
}

class _PreviewHostState extends State<_PreviewHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        dialogs.showCommonDialog<void>(
          child: const PreReleaseNoticeDialog(version: '0.1.0-pre.13'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}
