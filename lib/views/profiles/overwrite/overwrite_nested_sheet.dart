import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:riverpod/misc.dart' show Override;

import 'overwrite_stage_flow.dart';

Future<void> showOverwriteNestedSheet<T>({
  required BuildContext context,
  required int profileId,
  required List<Override> overrides,
  required T Function(WidgetRef ref) currentOf,
  required bool Function(BuildContext context, WidgetRef ref) save,
  required WidgetBuilder formBuilder,
}) {
  return showSheet(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) {
      return ProfileIdProvider(
        profileId: profileId,
        child: ProviderScope(
          overrides: overrides,
          child: OverwriteNestedSheet<T>(
            currentOf: currentOf,
            save: save,
            formBuilder: formBuilder,
          ),
        ),
      );
    },
  );
}

class OverwriteNestedSheet<T> extends ConsumerStatefulWidget {
  final T Function(WidgetRef ref) currentOf;
  final bool Function(BuildContext context, WidgetRef ref) save;
  final WidgetBuilder formBuilder;

  const OverwriteNestedSheet({
    super.key,
    required this.currentOf,
    required this.save,
    required this.formBuilder,
  });

  @override
  ConsumerState<OverwriteNestedSheet<T>> createState() =>
      _OverwriteNestedSheetState<T>();
}

class _OverwriteNestedSheetState<T>
    extends ConsumerState<OverwriteNestedSheet<T>> {
  late final T _origin;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _origin = widget.currentOf(ref);
  }

  Future<void> _handleClose(bool hasPushedPages) async {
    if (_closing) return;
    _closing = true;
    try {
      if (hasPushedPages) {
        final res = await dialogs.confirm(
          context.appLocalizations.confirmExitWindow,
        );
        if (!res) {
          return;
        }
      }
      if (context.mounted) {
        await _handleExit();
      }
    } finally {
      _closing = false;
    }
  }

  Future<void> _handleExit() async {
    flushPendingOverwriteStages();
    final current = widget.currentOf(ref);
    if (_origin == current) {
      Navigator.of(context).pop();
      return;
    }
    final res = await dialogs.confirm(context.appLocalizations.dataChangedSave);
    if (!mounted) {
      return;
    }
    if (!res) {
      Navigator.of(context).pop();
      return;
    }
    if (widget.save(context, ref)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedPagedSheet(
      onExit: () => unawaited(_handleClose(false)),
      onDismiss: _handleClose,
      builder: widget.formBuilder,
    );
  }
}
