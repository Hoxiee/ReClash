import 'dart:async';
import 'package:reclash/icons/icons.dart';
import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/feedback/activate_box.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  StreamSubscription<Object?>? _subscription;
  bool _handled = false;
  double _zoomOnScaleStart = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenBarcodes();
    unawaited(_startScanner());
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (!mounted || _handled) {
      return;
    }
    final value = barcodeCapture.barcodes.firstOrNull?.rawValue;
    if (value?.isProfileImportLink ?? false) {
      _handled = true;
      unawaited(_subscription?.cancel());
      _subscription = null;
      Navigator.pop<String>(context, value);
    }
  }

  // start() reports a busy camera through controller.value instead of throwing, so poll isRunning and retry: a fresh controller usually loses the first race with the previous session's background camera teardown and comes back not running.
  Future<void> _startScanner() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      if (!mounted || controller.value.isRunning) {
        return;
      }
      await controller.start();
      if (!mounted || controller.value.isRunning) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  void _listenBarcodes() {
    unawaited(_subscription?.cancel());
    _subscription = controller.barcodes.listen(_handleBarcode);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _zoomOnScaleStart = controller.value.zoomScale;
  }

  // Pinch maps the gesture ratio straight onto the 0..1 zoom range so a QR on a
  // distant TV can be framed from the couch without leaving the scanner.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!controller.value.isRunning || details.scale == 1.0) {
      return;
    }
    final zoom = (_zoomOnScaleStart + details.scale - 1.0).clamp(0.0, 1.0);
    unawaited(controller.setZoomScale(zoom));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _listenBarcodes();
        unawaited(_startScanner());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sideLength = min(400, MediaQuery.sizeOf(context).width * 0.67);
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: sideLength,
      height: sideLength,
    );
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              // The camera Texture leaf never hit-tests, so a deferToChild detector gets no pointers; claim them here or pinch never fires.
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: MobileScanner(
                controller: controller,
                scanWindow: scanWindow,
                errorBuilder: _buildError,
              ),
            ),
          ),
          CustomPaint(painter: ScannerOverlay(scanWindow: scanWindow)),
          AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              tooltip: context.appLocalizations.close,
              style: IconButton.styleFrom(
                iconSize: 32,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const GlyphIcon(AppGlyphs.close),
            ),
            actions: [
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: controller,
                builder: (context, state, _) {
                  var icon = const GlyphIcon(AppGlyphs.torchOff);
                  var backgroundColor = Colors.black12;
                  switch (state.torchState) {
                    case TorchState.off:
                      icon = const GlyphIcon(AppGlyphs.torchOff);
                      backgroundColor = Colors.black12;
                    case TorchState.on:
                      icon = const GlyphIcon(AppGlyphs.bolt);
                      backgroundColor = Colors.orange;
                    case TorchState.unavailable:
                      icon = const GlyphIcon(AppGlyphs.torchOff);
                      backgroundColor = Colors.transparent;
                    case TorchState.auto:
                      icon = const GlyphIcon(AppGlyphs.torchAuto);
                      backgroundColor = Colors.orange;
                  }
                  final available = state.torchState != TorchState.unavailable;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ActivateBox(
                      active: available,
                      child: IconButton(
                        tooltip: context.appLocalizations.torch,
                        color: Colors.white,
                        icon: icon,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: backgroundColor,
                        ),
                        onPressed: available
                            ? () => controller.toggleTorch()
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            alignment: Alignment.bottomCenter,
            child: IconButton(
              tooltip: context.appLocalizations.pickFromAlbum,
              color: Colors.white,
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
              ),
              padding: AppInsets.lg,
              iconSize: 32.0,
              onPressed: () async {
                final result = await globalState.safeRun(
                  picker.pickerConfigQRCode,
                );
                if (result != null && context.mounted) {
                  Navigator.of(context).pop(result);
                }
              },
              icon: const GlyphIcon(AppGlyphs.camera),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, MobileScannerException error) {
    final l10n = context.appLocalizations;
    final String message;
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        message = l10n.cameraPermissionRequired;
      case MobileScannerErrorCode.unsupported:
        message = l10n.qrScanUnsupported;
      default:
        message = error.errorDetails?.message ?? error.errorCode.message;
    }
    final canOpenSettings =
        error.errorCode == MobileScannerErrorCode.permissionDenied &&
        app != null;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: AppInsets.xxxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GlyphIcon(
                AppGlyphs.brokenImage,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              if (canOpenSettings) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => unawaited(app!.openAppSettings()),
                  child: Text(l10n.setupPermissionOpenSettings),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // `StatefulElement.unmount` asserts that `super.dispose()` already ran by the
  // time `dispose()` returns, so nothing here may await first: the controller is
  // torn down in the background instead.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(controller.dispose());
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = AppCorner.md,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);

    final cutoutPath = Path()
      ..addRSuperellipse(
        RSuperellipse.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.opacity50
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final border = RSuperellipse.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRSuperellipse(border, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
