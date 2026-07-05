import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'scan_result_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  bool _isCameraFront = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        HapticFeedback.heavyImpact();
        
        // Show flash overlay momentarily
        showGeneralDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, anim1, anim2) {
            return FadeTransition(
              opacity: anim1,
              child: Container(color: AppTheme.accentColor.withValues(alpha: 0.5)),
            );
          },
        );
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          if (context.mounted) {
            Navigator.pop(context); // Remove flash
            _showResultSheet(barcode);
          }
        });
      }
    }
  }

  void _showResultSheet(Barcode barcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultSheet(
        capture: barcode,
        onRescan: () {
          setState(() {
            _isProcessing = false;
          });
        },
      ),
    ).whenComplete(() {
      setState(() {
        _isProcessing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanAreaSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Scan Code',
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            color: _isFlashOn ? AppTheme.accentColor : Colors.white,
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () {
              _scannerController.switchCamera();
              setState(() {
                _isCameraFront = !_isCameraFront;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            scanWindow: Rect.fromCenter(
              center: MediaQuery.of(context).size.center(Offset.zero),
              width: scanAreaSize,
              height: scanAreaSize,
            ),
          ),
          // Custom Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(scanAreaSize: scanAreaSize),
            child: Container(),
          ),
          // Animated Laser
          Center(
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: scanAreaSize * _animation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  _ScannerOverlayPainter({required this.scanAreaSize});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);
    final scanRect = Rect.fromCenter(center: center, width: scanAreaSize, height: scanAreaSize);
    final scanPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(24)));

    // Subtract scan path from background
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, scanPath);
    canvas.drawPath(finalPath, backgroundPaint);

    // Draw frame corners
    final cornerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final length = scanAreaSize * 0.15;
    final radius = 24.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + length)
        ..lineTo(scanRect.left, scanRect.top + radius)
        ..arcToPoint(Offset(scanRect.left + radius, scanRect.top),
            radius: Radius.circular(radius))
        ..lineTo(scanRect.left + length, scanRect.top),
      cornerPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right, scanRect.top + length)
        ..lineTo(scanRect.right, scanRect.top + radius)
        ..arcToPoint(Offset(scanRect.right - radius, scanRect.top),
            radius: Radius.circular(radius), clockwise: false)
        ..lineTo(scanRect.right - length, scanRect.top),
      cornerPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - length)
        ..lineTo(scanRect.left, scanRect.bottom - radius)
        ..arcToPoint(Offset(scanRect.left + radius, scanRect.bottom),
            radius: Radius.circular(radius), clockwise: false)
        ..lineTo(scanRect.left + length, scanRect.bottom),
      cornerPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right, scanRect.bottom - length)
        ..lineTo(scanRect.right, scanRect.bottom - radius)
        ..arcToPoint(Offset(scanRect.right - radius, scanRect.bottom),
            radius: Radius.circular(radius))
        ..lineTo(scanRect.right - length, scanRect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
