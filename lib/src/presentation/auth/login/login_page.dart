import 'dart:ui';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/auth/login/login_binding.dart';
import 'package:dq_app/src/presentation/auth/login/login_controller.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/widgets/dq_button.dart';
import 'package:dq_app/widgets/dq_container.dart';
import 'package:dq_app/widgets/dq_input_field.dart';
import 'package:dq_app/widgets/themed_background.dart';
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

    return ThemedBackground(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: GlassContainer(
                    width: MediaQuery.of(context).size.width * .95,
                    padding: const EdgeInsets.all(20),
                    child: Obx(() => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            GlassTextField(
                              label: AppKeys.mobileNumber.tr,
                              hintText: AppKeys.mobileHint.tr,
                              controller: c.phoneController,
                              keyboardType: TextInputType.number,
                              enabled: !c.otpSent.value,
                              maxLength: 10,
                              validator: c.phoneValidator,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              prefixIcon: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                child: Text('+91',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            if (c.otpSent.value) ...[
                              const SizedBox(height: 10),
                              GlassTextField(
                                label: AppKeys.otp.tr,
                                hintText: AppKeys.otpHint.tr,
                                controller: c.otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                              ),
                            ],
                            const SizedBox(height: 15),
                            c.isLoading.value
                                ? const CircularProgressIndicator()
                                : GlassButton(
                                    text: c.otpSent.value
                                        ? AppKeys.verifyOtp.tr
                                        : AppKeys.getOtp.tr,
                                    onPressed: () {
                                      if (!c.otpSent.value) {
                                        c.sendOtp(
                                          onError: (msg) => Get.snackbar(
                                            AppKeys.error.tr,
                                            msg,
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
                                            AppKeys.error.tr,
                                            msg,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 12,
              child: GlassButton(
                text: '   ${AppKeys.signUp.tr}   ',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
