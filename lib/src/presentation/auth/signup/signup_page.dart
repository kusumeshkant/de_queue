import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_binding.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/widgets/liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SignupBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupController>();
    final tc = Get.find<ThemeController>();

    return Obx(() {
      final isDark = tc.isGreenTheme.value;
      final primary =
          isDark ? const Color(0xFF00E676) : const Color(0xFF6C63FF);
      final textPrimary =
          isDark ? const Color(0xFFF2F2F7) : const Color(0xFF1C1C1E);
      final textSecondary =
          isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70);
      final bgColors = isDark
          ? [const Color(0xFF080612), const Color(0xFF0E0820)]
          : [const Color(0xFFF0EEFF), const Color(0xFFF8F0FF)];

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
                      const SizedBox(height: 52),

                      LiquidGlassIcon(
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

                      LiquidGlassCard(
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

                            LiquidInputField(
                              label: 'Full Name',
                              hint: 'Your name',
                              controller: c.nameController,
                              enabled: !c.otpSent.value,
                              textColor: textPrimary,
                              hintColor: textSecondary,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),

                            LiquidInputField(
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
                              LiquidInputField(
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
                                : LiquidButton(
                                    text: c.otpSent.value
                                        ? 'Verify OTP'
                                        : 'Get OTP',
                                    color: primary,
                                    textColor:
                                        isDark ? Colors.black : Colors.white,
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
                                          onSuccess: () => Get.offAll(
                                              () => const Bottomnavigation()),
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
      );
    });
  }
}
