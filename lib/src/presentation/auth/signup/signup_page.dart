import 'dart:ui';
import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_binding.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/src/utils/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  void initState() {
    super.initState();
    AppSystemUI.setTransparentStatusBar();
    if (!Get.isRegistered<SignupController>()) {
      SignupBinding().dependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupController>();
    final tc = Get.find<ThemeController>();

    return Obx(() {
      final isDark = tc.isGreenTheme.value;
      final primary = tc.primary;
      final textPrimary = tc.textPrimary;
      final textSecondary = tc.textSecondary;
      final bgColors = tc.bgGradient;

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
            child: LayoutBuilder(
              builder: (_, lc) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.hPad(context)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: lc.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: Responsive.formMaxWidth),
                      child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 24),

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

                      const SizedBox(height: 40),

                      _LiquidGlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create Account',
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Join DQ to shop smarter',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 13)),
                            const SizedBox(height: 24),

                            // ── Full Name ─────────────────────────────────
                            _LiquidInputField(
                              label: 'Full Name',
                              hint: 'Your name',
                              controller: c.nameController,
                              prefix: Icon(Icons.person_outline,
                                  size: 18, color: textSecondary),
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              isDark: isDark,
                              semanticsIdentifier: 'signup_name_field',
                            ),
                            const SizedBox(height: 14),

                            // ── Email ─────────────────────────────────────
                            _LiquidInputField(
                              label: 'Email',
                              hint: 'you@example.com',
                              controller: c.emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefix: Icon(Icons.email_outlined,
                                  size: 18, color: textSecondary),
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              isDark: isDark,
                              semanticsIdentifier: 'signup_email_field',
                            ),
                            const SizedBox(height: 14),

                            // ── Password ──────────────────────────────────
                            _LiquidInputField(
                              label: 'Password',
                              hint: 'Min. 8 characters',
                              controller: c.passwordController,
                              obscureText: c.obscurePassword.value,
                              semanticsIdentifier: 'signup_password_field',
                              prefix: Icon(Icons.lock_outline,
                                  size: 18, color: textSecondary),
                              suffix: IconButton(
                                icon: Icon(
                                  c.obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: textSecondary,
                                ),
                                onPressed: () => c.obscurePassword.toggle(),
                              ),
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),

                            // ── Inline validation error ───────────────────
                            Obx(() => c.validationError.isNotEmpty
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      c.validationError.value,
                                      style: AppTypography.bodySmall
                                          .copyWith(color: AppColors.error),
                                    ),
                                  )
                                : const SizedBox.shrink()),

                            // ── Sign Up button ────────────────────────────
                            c.isLoading.value
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: primary, strokeWidth: 2))
                                : _LiquidButton(
                                    text: 'Sign Up',
                                    color: primary,
                                    textColor: Colors.white,
                                    isDark: isDark,
                                    onTap: () => c.signUp(
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
                                        backgroundColor: AppColors.error,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 20),

                            // ── OR divider ────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: textSecondary.withValues(
                                            alpha: 0.35),
                                        thickness: 0.8)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text('OR',
                                      style: TextStyle(
                                          color: textSecondary, fontSize: 12)),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: textSecondary.withValues(
                                            alpha: 0.35),
                                        thickness: 0.8)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── Google button ─────────────────────────────
                            GestureDetector(
                              onTap: c.isLoading.value
                                  ? null
                                  : () => c.signInWithGoogle(
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
                                          backgroundColor: AppColors.error,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.BOTTOM,
                                        ),
                                      ),
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.22)
                                        : Colors.black.withValues(alpha: 0.15),
                                    width: 1.0,
                                  ),
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.white.withValues(alpha: 0.70),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('G',
                                        style: TextStyle(
                                            color: AppColors.googleBlue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 10),
                                    Text('Continue with Google',
                                        style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?  ',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage())),
                            child: Text('Sign In',
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
              ),
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
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final Color textColor;
  final Color hintColor;
  final bool isDark;
  final String? semanticsIdentifier;

  const _LiquidInputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    required this.textColor,
    required this.hintColor,
    required this.isDark,
    this.semanticsIdentifier,
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
                child: Semantics(
                  identifier: semanticsIdentifier,
                  child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  autocorrect: false,
                  enableSuggestions: false,
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
                    suffixIcon: suffix,
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
                      colors: [
                        AppColorsDark.buttonGradientStart,
                        AppColorsDark.buttonGradientEnd,
                      ],
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
              child: Text(text, style: AppTypography.button),
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
