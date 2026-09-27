import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/plugins/companion.dart';
import 'package:reclash/widgets/widgets.dart';

// Phone pairing progress: submit the scanned offer, show the confirmation code to compare against
// the TV, then poll until the TV owner approves. A lost approval response never forces a re-pair —
// the token is already stored, so the poll simply reads 'approved' (S07).
class CompanionPairingView extends StatefulWidget {
  const CompanionPairingView({super.key, required this.raw});

  final String raw;

  @override
  State<CompanionPairingView> createState() => _CompanionPairingViewState();
}

enum _Stage { submitting, waiting, approved, failed }

class _CompanionPairingViewState extends State<CompanionPairingView> {
  final _client = CompanionClient.instance;
  _Stage _stage = _Stage.submitting;
  String? _deviceId;
  String? _confirmationCode;
  String? _errorCode;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final outcome = await _client.pair(widget.raw);
    if (!mounted) return;
    if (!outcome.ok) {
      setState(() {
        _stage = _Stage.failed;
        _errorCode = outcome.code;
      });
      return;
    }
    setState(() {
      _stage = _Stage.waiting;
      _deviceId = outcome.deviceId;
      _confirmationCode = outcome.confirmationCode;
    });
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => unawaited(_poll()));
  }

  Future<void> _poll() async {
    final deviceId = _deviceId;
    if (deviceId == null) return;
    final phase = await _client.pollPairing(deviceId);
    if (!mounted) return;
    switch (phase) {
      case 'approved':
        _timer?.cancel();
        setState(() => _stage = _Stage.approved);
      case 'pending':
        return;
      default:
        _timer?.cancel();
        setState(() {
          _stage = _Stage.failed;
          _errorCode = phase;
        });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _errorMessage(AppLocalizations l, String? code) => switch (code) {
    'pairingRejected' => l.companionPairingRejected,
    'pairingExpired' => l.companionPairingExpired,
    'accessRevoked' => l.companionAccessRevoked,
    'identityChanged' => l.companionIdentityChanged,
    'deviceLimit' => l.companionDeviceLimit,
    'outcomeUnknown' => l.companionOutcomeUnknown,
    _ => l.companionUnreachable,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return CommonScaffold(
      title: l.companionAddTelevision,
      body: Center(
        child: Padding(
          padding: AppInsets.xxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xl,
            children: [
              switch (_stage) {
                _Stage.submitting || _Stage.waiting =>
                  const SizedBox.square(
                    dimension: 64,
                    child: CommonCircleLoading(),
                  ),
                _Stage.approved => AppMedallion(
                  icon: AppGlyphs.checkCircle,
                  tone: colorScheme.primary,
                  size: 64,
                ),
                _Stage.failed => AppMedallion(
                  icon: AppGlyphs.error,
                  tone: colorScheme.error,
                  size: 64,
                ),
              },
              switch (_stage) {
                _Stage.submitting => Text(l.companionWaitingApproval),
                _Stage.waiting => Column(
                  spacing: AppSpacing.sm,
                  children: [
                    if (_confirmationCode != null)
                      Text(
                        l.companionConfirmCode(_confirmationCode!),
                        style: context.textTheme.headlineSmall,
                      ),
                    Text(l.companionConfirmOnTv, textAlign: TextAlign.center),
                  ],
                ),
                _Stage.approved => Text(l.companionPaired),
                _Stage.failed => Text(
                  _errorMessage(l, _errorCode),
                  textAlign: TextAlign.center,
                ),
              },
              if (_stage == _Stage.approved || _stage == _Stage.failed)
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_stage == _Stage.approved),
                  child: Text(l.confirm),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
