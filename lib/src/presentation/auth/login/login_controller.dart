import 'dart:async';

import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isLoading = false.obs;
  var otpSent = false.obs;
  var error = RxnString();
  var resendCountdown = 0.obs;

  String? _verificationId;
  Timer? _countdownTimer;

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Only digits allowed';
    if (value.length != 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    resendCountdown.value = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCountdown.value <= 1) {
        resendCountdown.value = 0;
        t.cancel();
      } else {
        resendCountdown.value--;
      }
    });
  }

  Future<void> sendOtp({
    required void Function(String message) onError,
  }) async {
    final raw = phoneController.text.trim();
    final validationError = phoneValidator(raw);
    if (validationError != null) {
      onError(validationError);
      return;
    }

    final phone = '+91$raw';

    isLoading.value = true;
    error.value = null;

    // Timeout in case Firebase never fires any callback
    Future.delayed(const Duration(seconds: 30), () {
      if (isLoading.value) {
        isLoading.value = false;
        onError('OTP request timed out. Please try again.');
      }
    });

    await loginUseCase.sendOtp(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        otpSent.value = true;
        isLoading.value = false;
        _startCountdown();
      },
      onFailed: (message) {
        isLoading.value = false;
        error.value = message;
        onError(message);
      },
    );
  }

  Future<void> resendOtp({
    required void Function(String message) onError,
  }) async {
    if (resendCountdown.value > 0) return;
    otpController.clear();
    await sendOtp(onError: onError);
  }

  void resetOtp() {
    _countdownTimer?.cancel();
    resendCountdown.value = 0;
    otpSent.value = false;
    _verificationId = null;
    otpController.clear();
    error.value = null;
  }

  Future<void> verifyOtp({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    if (_verificationId == null) {
      onError('Please request an OTP first');
      return;
    }

    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      onError('Please enter the OTP');
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final auth = await loginUseCase.verifyOtp(
        verificationId: _verificationId!,
        otp: otp,
      );

      await GraphQLClientProvider.init(
        baseUrl: AppConfig.graphqlEndpoint,
        token: auth.token,
      );

      isLoading.value = false;
      onSuccess();
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      onError(e.toString());
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
