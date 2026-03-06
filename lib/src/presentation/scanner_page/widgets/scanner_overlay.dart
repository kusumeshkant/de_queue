import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// SCAN LINE
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 260,
            height: 2,
            color: Colors.lightBlueAccent,
          ),
        ),
      ],
    );
  }
}
