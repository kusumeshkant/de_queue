import 'package:auto_route/auto_route.dart';
import 'package:dq_app/src/presentation/scanner_page/widgets/scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';

// @RoutePage()
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  final Set<String> scannedBarcodes = {}; 

  bool _isScanningPaused = false;

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isScanningPaused) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    _isScanningPaused = true;

    if (scannedBarcodes.contains(barcode)) {
      Fluttertoast.showToast(
        msg: "Product already scanned and added to cart",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      scannedBarcodes.add(barcode);

      Fluttertoast.showToast(
        msg: "Product added to cart",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    _isScanningPaused = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA VIEW
          MobileScanner(controller: _controller, onDetect: _onBarcodeDetected),

          /// DARK OVERLAY
          ScannerOverlay(),

          /// TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          /// TEXT
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Scan QR Code of the device",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "The QR Code will be automatically detected\nwhen you position it between the guide lines",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
