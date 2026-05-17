import 'dart:ui';
import 'package:flutter/material.dart';

/// iOS 26 Liquid Glass button.
/// [backgroundColor] = solid accent → primary action.
/// No [backgroundColor] → pure glass → secondary action.
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color textColor;
  final Color? backgroundColor;
  final bool isDark;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.borderRadius = 50,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.textColor = Colors.white,
    this.backgroundColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSolid = backgroundColor != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                // Solid accent OR glass
                color: isSolid ? backgroundColor : null,
                gradient: isSolid
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0.07),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.72),
                                Colors.white.withValues(alpha: 0.42),
                              ],
                      ),
                border: Border.all(
                  color: isSolid
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.20)
                          : Colors.white.withValues(alpha: 0.90)),
                  width: 0.8,
                ),
                boxShadow: isSolid
                    ? [
                        BoxShadow(
                          color: backgroundColor!.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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
