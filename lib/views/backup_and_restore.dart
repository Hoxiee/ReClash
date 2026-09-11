import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/dav_client.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/dialog.dart';
import 'package:reclash/widgets/fade_box.dart';
import 'package:reclash/widgets/input.dart';
import 'package:reclash/widgets/list.dart';
import 'package:reclash/widgets/loading.dart';
import 'package:reclash/widgets/scaffold.dart';
import 'package:reclash/widgets/setting.dart';
import 'package:reclash/widgets/text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupAndRestore extends ConsumerStatefulWidget {
  const BackupAndRestore({super.key});

  @override
  ConsumerState<BackupAndRestore> createState() => _BackupAndRestoreState();
}

class _BackupAndRestoreState extends ConsumerState<BackupAndRestore>
    with UniqueKeyStateMixin {
  final _davConnection = DAVConnectionController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(davSettingProvider, (_, _) {
      _updateDAVClient();
    }, fireImmediately: true);
  }

  void _updateDAVClient() {
    unawaited(_davConnection.update(ref.read(davSettingProvider)));
  }

  @override
  void dispose() {
    _davConnection.dispose();
    super.dispose();
  }

  Future<void> _showAddWebDAV(DAVProps? dav) async {
    await dialogs.showCommonDialog<String>(
      child: WebDAVFormDialog(dav: dav?.copyWith()),
    );
  }

  Future<void> _backupOnWebDAV() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.loadingRun<bool>(
      () async {
        final client = _davConnection.client;
        if (client == null) {
          return false;
        }
        return ref
            .read(backupActionProvider.notifier)
            .consumeBackup(client.backup);
      },
      tag: LoadingTag.backup_restore,
      title: appLocalizations.backup,
    );
    if (res != true) return;
    unawaited(
      dialogs.showMessage(
        title: appLocalizations.backup,
        message: TextSpan(text: appLocalizations.backupSuccess),
      ),
    );
  }

  Future<void> _applyPrepared(PreparedRestore prepared) async {
    final appLocalizations = context.appLocalizations;
    final option = await dialogs.showCommonDialog<RestoreOption>(
      child: RestorePreviewDialog(summary: prepared.summary),
    );
    if (option == null) {
      await ref
          .read(backupActionProvider.notifier)
          .discardPreparedRestore(prepared);
      return;
    }
    final restored = await globalState.loadingRun<bool>(
      () async {
        await ref
            .read(backupActionProvider.notifier)
            .applyPreparedRestore(prepared, option);
        return true;
      },
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (restored != true) return;
    unawaited(
      dialogs.showMessage(
        title: appLocalizations.restore,
        message: TextSpan(text: appLocalizations.restoreSuccess),
      ),
    );
  }

  Future<void> _restoreOnWebDAV() async {
    final appLocalizations = context.appLocalizations;
    final prepared = await globalState.loadingRun<PreparedRestore?>(
      () async {
        final client = _davConnection.client;
        if (client == null) return null;
        await client.restore();
        return ref
            .read(backupActionProvider.notifier)
            .prepareRestoreFromPath(await appPath.backupFilePath);
      },
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (prepared == null || !mounted) return;
    await _applyPrepared(prepared);
  }

  Future<void> _backupOnLocal() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.loadingRun<bool>(
      () async {
        return ref.read(backupActionProvider.notifier).consumeBackup((
          path,
        ) async {
          final value = await picker.saveFileWithPath(
            getBackupFileName(),
            path,
          );
          return value != null;
        });
      },
      title: appLocalizations.backup,
      tag: LoadingTag.backup_restore,
    );
    if (res != true) return;
    unawaited(
      dialogs.showMessage(
        title: appLocalizations.backup,
        message: TextSpan(text: appLocalizations.backupSuccess),
      ),
    );
  }

  Future<void> _restoreOnLocal() async {
    final appLocalizations = context.appLocalizations;
    final prepared = await globalState.loadingRun<PreparedRestore?>(
      () => ref.read(backupActionProvider.notifier).preparePickedRestore(),
      tag: LoadingTag.backup_restore,
      title: appLocalizations.restore,
    );
    if (prepared == null || !mounted) return;
    await _applyPrepared(prepared);
  }

  void _handleChange(String? value, WidgetRef ref) {
    if (value == null) {
      return;
    }
    ref
        .read(davSettingProvider.notifier)
        .update((state) => state?.copyWith(fileName: value));
  }

  Future<void> _handleUpdateRestoreStrategy() async {
    final restoreStrategy = ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final res = await dialogs.showCommonDialog(
      child: OptionsDialog<RestoreStrategy>(
        title: currentAppLocalizations.restoreStrategy,
        options: RestoreStrategy.values,
        textBuilder: (mode) => mode.label,
        value: restoreStrategy,
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(restoreStrategy: res));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final dav = ref.watch(davSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.backup_restore));
    return CommonScaffold(
      isLoading: isLoading,
      title: appLocalizations.backupAndRestore,
      body: ListView(
        children: [
          SettingSection(
            top: 16,
            items: [
              if (dav == null)
                DecorationListItem(
                  leading: const Icon(Icons.account_box),
                  title: Text(appLocalizations.noInfo),
                  subtitle: Text(appLocalizations.pleaseBindWebDAV),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      _showAddWebDAV(dav);
                    },
                    child: Text(appLocalizations.bind),
                  ),
                )
              else ...[
                DecorationListItem(
                  leading: const Icon(Icons.account_box),
                  title: TooltipText(
                    text: Text(
                      dav.user,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(appLocalizations.connectivity),
                        _DavConnectionIndicator(connection: _davConnection),
                      ],
                    ),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      _showAddWebDAV(dav);
                    },
                    child: Text(appLocalizations.edit),
                  ),
                ),
                DecorationListItem.input(
                  title: Text(appLocalizations.file),
                  subtitle: Text(dav.fileName),
                  dialogTitle: appLocalizations.file,
                  value: dav.fileName,
                  resetValue: defaultDavFileName,
                  maxLength: TextInputLimits.fileName,
                  onChanged: (value) {
                    _handleChange(value, ref);
                  },
                ),
                DecorationListItem(
                  onPressed: () {
                    _backupOnWebDAV();
                  },
                  title: Text(appLocalizations.backup),
                  subtitle: Text(appLocalizations.remoteBackupDesc),
                ),
                DecorationListItem(
                  onPressed: () {
                    _restoreOnWebDAV();
                  },
                  title: Text(appLocalizations.restore),
                  subtitle: Text(appLocalizations.restoreFromWebDAVDesc),
                ),
              ],
            ],
          ),
          SettingSection(
            title: appLocalizations.local,
            items: [
              DecorationListItem(
                onPressed: () {
                  _backupOnLocal();
                },
                title: Text(appLocalizations.backup),
                subtitle: Text(appLocalizations.localBackupDesc),
              ),
              DecorationListItem(
                onPressed: () {
                  _restoreOnLocal();
                },
                title: Text(appLocalizations.restore),
                subtitle: Text(appLocalizations.restoreFromFileDesc),
              ),
            ],
            enterDelay: const Duration(milliseconds: 50),
          ),
          SettingSection(
            title: appLocalizations.options,
            items: [
              _RestoreStrategyItem(onPressed: _handleUpdateRestoreStrategy),
            ],
            enterDelay: const Duration(milliseconds: 100),
          ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

class _DavConnectionIndicator extends StatelessWidget {
  const _DavConnectionIndicator({required this.connection});

  final ValueNotifier<bool?> connection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: connection,
      builder: (context, isConnected, _) {
        return Center(
          child: FadeThroughBox(
            child: isConnected == null
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CommonCircleLoading(),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isConnected
                          ? context.colorScheme.error
                          : Colors.green.harmonizeWith(
                              context.colorScheme.primary,
                            ),
                    ),
                    width: 12,
                    height: 12,
                  ),
          ),
        );
      },
    );
  }
}

class _RestoreStrategyItem extends ConsumerWidget {
  const _RestoreStrategyItem({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreStrategy = ref.watch(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    return DecorationListItem(
      onPressed: onPressed,
      title: Text(context.appLocalizations.restoreStrategy),
      trailing: FilledButton(
        onPressed: onPressed,
        child: Text(restoreStrategy.label),
      ),
    );
  }
}

class RestorePreviewDialog extends StatefulWidget {
  const RestorePreviewDialog({super.key, required this.summary});

  final RestoreSummary summary;

  @override
  State<RestorePreviewDialog> createState() => _RestorePreviewDialogState();
}

class _RestorePreviewDialogState extends State<RestorePreviewDialog> {
  RestoreOption _option = RestoreOption.onlyProfiles;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final summary = widget.summary;
    return CommonDialog(
      title: appLocalizations.restorePreviewTitle,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_option),
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLocalizations.restorePreviewDescription),
            const SizedBox(height: 12),
            Text(appLocalizations.restoreProfilesCount(summary.profiles)),
            Text(appLocalizations.restoreScriptsCount(summary.scripts)),
            Text(appLocalizations.restoreRulesCount(summary.rules)),
            Text(appLocalizations.restoreProxyGroupsCount(summary.proxyGroups)),
            Text(
              summary.hasSettings
                  ? appLocalizations.restoreSettingsIncluded
                  : appLocalizations.restoreSettingsNotIncluded,
            ),
            const SizedBox(height: 12),
            RadioGroup<RestoreOption>(
              groupValue: _option,
              onChanged: (value) {
                if (value != null) setState(() => _option = value);
              },
              child: Column(
                children: [
                  ListItem<RestoreOption>.radio(
                    title: Text(appLocalizations.restoreOnlyConfig),
                    value: RestoreOption.onlyProfiles,
                    onTap: () =>
                        setState(() => _option = RestoreOption.onlyProfiles),
                  ),
                  ListItem<RestoreOption>.radio(
                    title: Text(appLocalizations.restoreAllData),
                    value: RestoreOption.all,
                    onTap: () => setState(() => _option = RestoreOption.all),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebDAVFormDialog extends ConsumerStatefulWidget {
  final DAVProps? dav;

  const WebDAVFormDialog({super.key, this.dav});

  @override
  ConsumerState<WebDAVFormDialog> createState() => _WebDAVFormDialogState();
}

class _WebDAVFormDialogState extends ConsumerState<WebDAVFormDialog> {
  late TextEditingController _uriController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  final _obscureController = ValueNotifier<bool>(true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _uriController = TextEditingController(text: widget.dav?.uri);
    _userController = TextEditingController(text: widget.dav?.user);
    _passwordController = TextEditingController(text: widget.dav?.password);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(davSettingProvider.notifier)
        .update(
          (_) => DAVProps(
            uri: _uriController.text,
            user: _userController.text,
            password: _passwordController.text,
            fileName: widget.dav?.fileName ?? defaultDavFileName,
          ),
        );
    Navigator.pop(context);
  }

  void _delete() {
    ref.read(davSettingProvider.notifier).update((_) => null);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _obscureController.dispose();
    _uriController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.webDAVConfiguration,
      actions: [
        if (widget.dav != null)
          TextButton(onPressed: _delete, child: Text(appLocalizations.delete)),
        TextButton(onPressed: _submit, child: Text(appLocalizations.save)),
      ],
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              controller: _uriController,
              inputFormatters: TextInputLimits.limit(TextInputLimits.uri),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link),
                labelText: appLocalizations.address,
                helperText: appLocalizations.addressHelp,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty || !value.isUrl) {
                  return appLocalizations.addressTip;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _userController,
              inputFormatters: TextInputLimits.limit(TextInputLimits.userName),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_circle),
                labelText: appLocalizations.account,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.account);
                }
                return null;
              },
            ),
            ValueListenableBuilder(
              valueListenable: _obscureController,
              builder: (_, obscure, _) {
                return TextFormField(
                  controller: _passwordController,
                  inputFormatters: TextInputLimits.limit(
                    TextInputLimits.password,
                  ),
                  obscureText: obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _submit();
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    suffixIcon: IconButton(
                      tooltip: obscure
                          ? context.appLocalizations.showPassword
                          : context.appLocalizations.hidePassword,
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        _obscureController.value = !obscure;
                      },
                    ),
                    labelText: appLocalizations.password,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.emptyTip(
                        appLocalizations.password,
                      );
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
