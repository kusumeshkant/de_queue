import 'dart:ui';
import 'package:dq_app/src/presentation/auth/login/login_binding.dart';
import 'package:dq_app/src/presentation/auth/login/login_controller.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    AppSystemUI.setTransparentStatusBar();
    if (!Get.isRegistered<LoginController>()) {
      LoginBinding().dependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();
    final tc = Get.find<ThemeController>();

    return Obx(() {
      final isDark = tc.isGreenTheme.value;

      // ── Colours ───────────────────────────────────────────────────────────
      final primary =
          isDark ? const Color(0xFF00E676) : const Color(0xFF00C853);
      final textPrimary =
          isDark ? const Color(0xFFF2F2F7) : const Color(0xFF0D0D0D);
      final textSecondary =
          isDark ? const Color(0xFF8E8E93) : const Color(0xFF555555);

      // Background gradient
      final bgColors = isDark
          ? [const Color(0xFF080612), const Color(0xFF0E0820)]
          : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)];

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 64),

                      // ── Logo ──────────────────────────────────────────────
                      _LiquidGlassIcon(
                          icon: Icons.shopping_bag_rounded,
                          color: primary,
                          isDark: isDark),
                      const SizedBox(height: 16),
                      Text('DQ',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 5)),
                      const SizedBox(height: 4),
                      Text('Smart Shopping, Simplified',
                          style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              letterSpacing: 0.4)),

                      const SizedBox(height: 48),

                      // ── Glass card ────────────────────────────────────────
                      _LiquidGlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sign In',
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Enter your mobile number to continue',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 13)),
                            const SizedBox(height: 24),

                            _LiquidInputField(
                              label: 'Mobile Number',
                              hint: '10-digit number',
                              controller: c.phoneController,
                              keyboardType: TextInputType.number,
                              enabled: !c.otpSent.value,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              prefix: Text('+91',
                                  style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              isDark: isDark,
                            ),

                            if (c.otpSent.value) ...[
                              const SizedBox(height: 14),
                              _LiquidInputField(
                                label: 'OTP',
                                hint: '6-digit OTP',
                                controller: c.otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                textColor: textPrimary,
                                hintColor: textSecondary,
                                isDark: isDark,
                              ),
                            ],

                            const SizedBox(height: 24),

                            c.isLoading.value
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: primary, strokeWidth: 2))
                                : _LiquidButton(
                                    text: c.otpSent.value
                                        ? 'Verify OTP'
                                        : 'Get OTP',
                                    color: primary,
                                    textColor: Colors.white,
                                    isDark: isDark,
                                    onTap: () {
                                      if (!c.otpSent.value) {
                                        c.sendOtp(
                                          onError: (msg) => Get.snackbar(
                                            'Error', msg,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ),
                                        );
                                      } else {
                                        c.verifyOtp(
                                          onSuccess: () {
                                            try {
                                              Get.find<NavigationController>()
                                                  .goToHome();
                                            } catch (_) {}
                                            Get.offAll(
                                                () => const Bottomnavigation());
                                          },
                                          onError: (msg) => Get.snackbar(
                                            'Error', msg,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Sign up link ──────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("New here?  ",
                              style: TextStyle(
                                  color: textSecondary, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpPage()),
                            ),
                            child: Text('Create Account',
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  )),
            ),
          ),
        ),
      );
    });
  }
}

// ── iOS 26 Liquid Glass Card ─────────────────────────────────────────────────

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _LiquidGlassCard({required this.child, required this.isDark});

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

class _LiquidInputField extends StatelessWidget {
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

  const _LiquidInputField({
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

class _LiquidButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool isDark;
  final VoidCallback onTap;

  const _LiquidButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.isDark,
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
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xCC1A1A1A), Color(0xE8000000)],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.70),
                        color.withValues(alpha: 0.88),
                      ],
                    ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.40),
                  width: 0.9),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : color)
                      .withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
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

class _LiquidGlassIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  const _LiquidGlassIcon(
      {required this.icon, required this.color, required this.isDark});

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
          // Bottom rim light
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
