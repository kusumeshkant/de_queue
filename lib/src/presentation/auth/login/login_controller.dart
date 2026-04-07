import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;
  LoginController({required this.loginUseCase});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var validationError = ''.obs;

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> signIn({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    validationError.value = '';
    final emailError = emailValidator(emailController.text.trim());
    if (emailError != null) { validationError.value = emailError; return; }

    final passwordError = passwordValidator(passwordController.text);
    if (passwordError != null) { validationError.value = passwordError; return; }

    isLoading.value = true;
    try {
      await loginUseCase.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await GraphQLClientProvider.init(baseUrl: AppConfig.graphqlEndpoint);
      _clearFields();
      isLoading.value = false;
      onSuccess();
    } catch (e) {
      isLoading.value = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signInWithGoogle({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    isLoading.value = true;
    try {
      await loginUseCase.signInWithGoogle();
      await GraphQLClientProvider.init(baseUrl: AppConfig.graphqlEndpoint);
      _clearFields();
      isLoading.value = false;
      onSuccess();
    } catch (e) {
      isLoading.value = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    obscurePassword.value = true;
    validationError.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
