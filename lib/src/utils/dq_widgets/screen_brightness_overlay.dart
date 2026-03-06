import 'package:flutter/material.dart';

class ScreenBrightnessOverlay extends StatelessWidget {
  final Widget child;
  final double darkness; // 0.0 = normal, 1.0 = fully black
  final bool enabled;

  const ScreenBrightnessOverlay({
    super.key,
    required this.child,
    this.darkness = 0.15,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      children: [
        child,

        /// 🔹 Global dim layer
        IgnorePointer(
          ignoring: true, // allows touches to pass through
          child: Container(
            color: Colors.black.withValues(alpha: darkness),
          ),
        ),
      ],
    );
  }
}
