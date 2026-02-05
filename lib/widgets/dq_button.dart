import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;

  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color textColor;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = enabled ? 1.0 : 0.5;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: enabled ? onPressed : null,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),

              // 🎨 Background
              color: Colors.white.withOpacity(
                enabled ? 0.12 : 0.06,
              ),

              // 🧊 Border
              border: Border.all(
                color: Colors.white.withOpacity(
                  enabled ? 0.2 : 0.1,
                ),
                width: 1.2,
              ),

              // 🌈 Gradient
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(
                    enabled ? 0.08 : 0.03,
                  ),
                  Colors.white.withOpacity(
                    enabled ? 0.03 : 0.015,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              // 🌑 Shadow
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Opacity(
                opacity: opacity,
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
