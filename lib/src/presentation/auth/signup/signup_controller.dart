import 'package:dq_app/src/domain/usecase/signup_usecase.dart';
import 'package:dq_app/src/service_core/auth/customer_auth_service.dart';
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

  /// Email + password signup.
  ///
  /// After Firebase account creation, calls [CustomerAuthService.validateCustomerAccess]
  /// to confirm the user document is created in MongoDB. For a brand-new Firebase
  /// account this always succeeds (backend auto-creates as customer).
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
      await signupUseCase.signUpWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await GraphQLClientProvider.reinitWithToken();
      // Confirm backend session — creates the MongoDB user doc as customer.
      await CustomerAuthService.validateCustomerAccess();
      _clearFields();
      isLoading.value = false;
      onSuccess();
    } on AccessDeniedException catch (e) {
      // A brand-new Firebase account should never hit FORBIDDEN, but handle
      // it defensively. The service already signed out Firebase.
      isLoading.value = false;
      onError(e.userMessage);
    } catch (e) {
      isLoading.value = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Google sign-up / sign-in — handles all three account states automatically:
  ///
  /// 1. **New account** → backend auto-creates as customer → home
  /// 2. **Existing customer account** → validated → home
  /// 3. **Staff or admin account** → [registerAsCustomer] adds customer role → home
  ///
  /// Case 3 is the key fix: a staff member who taps "Continue with Google" on
  /// the signup page gets their customer role added silently, with no extra
  /// steps. They can now use both the DQ Staff app and the DQ customer app
  /// with the same Google account.
  Future<void> signInWithGoogle({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    isLoading.value = true;
    try {
      await signupUseCase.signInWithGoogle();
      await GraphQLClientProvider.reinitWithToken();

      try {
        await CustomerAuthService.validateCustomerAccess();
      } on AccessDeniedException catch (e) {
        if (e.hint == AuthAccessHint.staffNoCustomer ||
            e.hint == AuthAccessHint.adminNoCustomer) {
          // Account exists but has no customer role yet — add it.
          // Firebase is still signed in at this point (signOut not called for
          // FORBIDDEN on validateCustomerAccess before registerAsCustomer).
          await CustomerAuthService.registerAsCustomer();
          // Fall through to onSuccess below
        } else {
          // Network error or truly unknown denial — propagate as plain error
          rethrow;
        }
      }

      _clearFields();
      isLoading.value = false;
      onSuccess();
    } on AccessDeniedException catch (e) {
      isLoading.value = false;
      onError(e.userMessage);
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
