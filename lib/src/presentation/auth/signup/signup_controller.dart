import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/domain/usecase/signup_usecase.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  final SignupUseCase signupUseCase;
  SignupController({required this.signupUseCase});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var validationError = ''.obs;

  String? nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    return null;
  }

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

  Future<void> signUp({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    validationError.value = '';
    final nameError = nameValidator(nameController.text);
    if (nameError != null) { validationError.value = nameError; return; }

    final emailError = emailValidator(emailController.text.trim());
    if (emailError != null) { validationError.value = emailError; return; }

    final passwordError = passwordValidator(passwordController.text);
    if (passwordError != null) { validationError.value = passwordError; return; }

    isLoading.value = true;
    try {
      final auth = await signupUseCase.signUpWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await GraphQLClientProvider.init(
        baseUrl: AppConfig.graphqlEndpoint,
        token: auth.token,
      );
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
      final auth = await signupUseCase.signInWithGoogle();
      await GraphQLClientProvider.init(
        baseUrl: AppConfig.graphqlEndpoint,
        token: auth.token,
      );
      _clearFields();
      isLoading.value = false;
      onSuccess();
    } catch (e) {
      isLoading.value = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    obscurePassword.value = true;
    validationError.value = '';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
