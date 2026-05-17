import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay with cutout for the scan box
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              // Full-screen dark overlay
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              // Transparent cutout — 270x270, centered
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner brackets drawn over the scan box area
        CustomPaint(
          painter: _CornerBracketPainter(),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  static const double _boxSize = 270.0;
  static const double _bracketLen = 28.0;
  static const double _bracketWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = _bracketWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Center the 270x270 scan box
    final double left = (size.width - _boxSize) / 2;
    final double top = (size.height - _boxSize) / 2;
    final double right = left + _boxSize;
    final double bottom = top + _boxSize;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + _bracketLen),
      Offset(left, top),
      paint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + _bracketLen, top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right - _bracketLen, top),
      Offset(right, top),
      paint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + _bracketLen),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom - _bracketLen),
      Offset(left, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + _bracketLen, bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right - _bracketLen, bottom),
      Offset(right, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - _bracketLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
