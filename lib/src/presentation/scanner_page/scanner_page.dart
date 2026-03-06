import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/scanner_page/scanner_controller.dart';
import 'package:dq_app/src/presentation/scanner_page/widgets/scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ScannerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcode = capture.barcodes.first.rawValue;
              if (barcode != null) c.onBarcodeDetected(barcode);
            },
          ),

          ScannerOverlay(),

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

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppKeys.scanBarcode.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppKeys.scanHint.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
