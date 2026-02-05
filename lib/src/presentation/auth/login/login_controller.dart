import 'dart:developer';

import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {

   LoginUseCase loginUseCase = LoginUseCase();


  var isLoading = false.obs;
  var error = RxnString();
  var isButtonEnable = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();


bool isEnable() {
  final emailError = emailValidator(emailController.text);
  final passwordError = passwordCheck(passwordController.text);

  final isValid =
      emailError == null &&
      passwordError == null &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty;

  isButtonEnable.value = isValid;
  return isValid;
}


String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }

  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }

  return null;
}

String? passwordCheck(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }

  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).{8,}$',
  );

  if (!passwordRegex.hasMatch(value)) {
    return 'Password must contain uppercase, lowercase, number & special character';
  }

  return null;
}


Future<void> login({
  required void Function() onSuccess,
  required void Function(String message) onError,
}) async {
  try {
    isLoading.value = true;
    error.value = null;

    final response = await loginUseCase.login(
      emailController.text,
      passwordController.text,
    );

    isLoading.value = false;

    onSuccess();

  } catch (e) {
    isLoading.value = false;
    error.value = e.toString();

    onError(e.toString());
  }
}

}