part of '../general.dart';

class ExternalControllerItem extends ConsumerWidget {
  const ExternalControllerItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final externalController = ref.watch(
      patchClashConfigProvider.select((state) => state.externalController),
    );
    return DecorationListItem(
      leading: const GlyphIcon(AppGlyphs.api),
      title: Text(appLocalizations.externalController),
      subtitle: Text(
        externalController.isEmpty
            ? appLocalizations.externalControllerDesc
            : externalController,
      ),
      onPressed: () {
        dialogs.showCommonDialog<void>(
          child: const _ExternalControllerDialog(),
        );
      },
    );
  }
}

class _ExternalControllerDialog extends ConsumerStatefulWidget {
  const _ExternalControllerDialog();

  @override
  ConsumerState<_ExternalControllerDialog> createState() =>
      _ExternalControllerDialogState();
}

class _ExternalControllerDialogState
    extends ConsumerState<_ExternalControllerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _portController;
  late final TextEditingController _secretController;
  late bool _enabled;
  late bool _allowLan;

  @override
  void initState() {
    super.initState();
    final config = ref.read(patchClashConfigProvider);
    final externalController = config.externalController;
    _enabled = externalController.isNotEmpty;
    _allowLan = _enabled && !externalController.startsWith('$localhost:');
    final port = int.tryParse(externalController.split(':').last);
    _portController = TextEditingController(
      text: (port ?? defaultExternalControllerPort).toString(),
    );
    _secretController = TextEditingController(text: config.secret);
  }

  void _handleRandomSecret() {
    _secretController.text = generateRandomSecret(16);
  }

  void _handleCopySecret() {
    Clipboard.setData(ClipboardData(text: _secretController.text));
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            externalController: _enabled
                ? '${_allowLan ? '0.0.0.0' : localhost}:${_portController.text}'
                : '',
            secret: _secretController.text,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _portController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.externalController,
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(appLocalizations.enableExternalController),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(appLocalizations.allowLanAccess),
              subtitle: Text(appLocalizations.allowLanAccessDesc),
              value: _allowLan,
              onChanged: !_enabled
                  ? null
                  : (value) => setState(() => _allowLan = value),
            ),
            TextFormField(
              enabled: _enabled,
              keyboardType: TextInputType.number,
              maxLines: 1,
              minLines: 1,
              inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.port),
              controller: _portController,
              onFieldSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                labelText: appLocalizations.listeningPort,
              ),
              validator: (value) {
                if (!_enabled) {
                  return null;
                }
                final port = int.tryParse(value ?? '');
                if (port == null) {
                  return appLocalizations.numberTip(
                    appLocalizations.listeningPort,
                  );
                }
                if (port < _minPort || port > _maxPort) {
                  return appLocalizations.portTip(appLocalizations.listeningPort);
                }
                return null;
              },
            ),
            TextFormField(
              enabled: _enabled,
              maxLines: 1,
              minLines: 1,
              inputFormatters: TextInputLimits.limit(TextInputLimits.password),
              controller: _secretController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                labelText: appLocalizations.password,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: appLocalizations.random,
                      onPressed: _enabled ? _handleRandomSecret : null,
                      icon: const GlyphIcon(AppGlyphs.shuffle),
                    ),
                    IconButton(
                      tooltip: appLocalizations.copy,
                      onPressed: _handleCopySecret,
                      icon: const GlyphIcon(AppGlyphs.copy),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
