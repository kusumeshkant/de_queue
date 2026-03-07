import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── iOS 26 Liquid Glass Card ─────────────────────────────────────────────────

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const LiquidGlassCard({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.44),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.90),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── iOS 26 Liquid Input Field ────────────────────────────────────────────────

class LiquidInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Color textColor;
  final Color hintColor;
  final bool isDark;

  const LiquidInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
    this.prefix,
    required this.textColor,
    required this.hintColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark
        ? Colors.black.withValues(alpha: 0.32)
        : Colors.white.withValues(alpha: 0.28);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.75);
    final focusBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.28);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
        const SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  enabled: enabled,
                  maxLength: maxLength,
                  inputFormatters: inputFormatters,
                  style: TextStyle(color: textColor, fontSize: 15),
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: hintColor, fontSize: 14),
                    prefixIcon: prefix != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 13),
                            child: prefix)
                        : null,
                    filled: true,
                    fillColor: fillColor,
                    counterText: '',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor, width: 0.8)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor, width: 0.8)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: focusBorderColor, width: 1.2)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: borderColor.withValues(alpha: 0.3),
                            width: 0.8)),
                  ),
                ),
              ),
            ),
            // Top specular sheen
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 22,
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.10 : 0.28),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── iOS 26 Glassy Sphere Button ───────────────────────────────────────────────

class LiquidButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const LiquidButton({
    super.key,
    required this.text,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              // Same radial-style depth as the sphere — off-center light from top-left
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC1A1A1A),
                  Color(0xE8000000),
                ],
              ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28), width: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.50),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── iOS 26 Glassy Sphere Icon ─────────────────────────────────────────────────

class LiquidGlassIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  const LiquidGlassIcon(
      {super.key, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        children: [
          // Sphere body — radial gradient gives depth
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.25),
                    radius: 0.90,
                    colors: isDark
                        ? [
                            color.withValues(alpha: 0.48),
                            color.withValues(alpha: 0.14),
                            Colors.black.withValues(alpha: 0.30),
                          ]
                        : [
                            color.withValues(alpha: 0.38),
                            color.withValues(alpha: 0.10),
                            Colors.black.withValues(alpha: 0.08),
                          ],
                    stops: const [0.0, 0.60, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.28 : 0.55),
                    width: 1.0,
                  ),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
            ),
          ),
          // Top-left specular highlight — the glassy sphere "shine"
          Positioned(
            top: 10,
            left: 14,
            child: Container(
              width: 24,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.72),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom rim light — adds sphere roundness
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: isDark ? 0.18 : 0.30),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
