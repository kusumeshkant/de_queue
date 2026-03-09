import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/domain/usecase/signup_usecase.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  final SignupUseCase signupUseCase;

  SignupController({required this.signupUseCase});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isLoading = false.obs;
  var otpSent = false.obs;
  var error = RxnString();

  String? _verificationId;

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Only digits allowed';
    if (value.length != 10) return 'Enter a valid 10-digit phone number';
    return null;
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

    // Auto-prepend country code for Firebase
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

    await signupUseCase.sendOtp(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        otpSent.value = true;
        isLoading.value = false;
      },
      onFailed: (message) {
        isLoading.value = false;
        error.value = message;
        onError(message);
      },
    );
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
      final auth = await signupUseCase.verifyOtp(
        verificationId: _verificationId!,
        otp: otp,
      );

      // Re-init GraphQL with real Firebase token
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
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
