import 'package:dq_app/src/domain/entity/auth_exception.dart';
import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:dq_app/src/service_core/auth/customer_auth_service.dart';
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

  /// Email + password login.
  ///
  /// [onAccessDenied] fires when the backend returns FORBIDDEN — the UI should
  /// show a role-specific dialog, not a generic snackbar.
  /// [onError] fires for Firebase auth failures and network errors.
  Future<void> signIn({
    required void Function() onSuccess,
    required void Function(AccessDeniedException error) onAccessDenied,
    required void Function(String message) onError,
  }) async {
    validationError.value = '';
    final emailError = emailValidator(emailController.text.trim());
    if (emailError != null) { validationError.value = emailError; return; }

    final passwordError = passwordValidator(passwordController.text);
    if (passwordError != null) { validationError.value = passwordError; return; }

    isLoading.value = true;
    try {
      debugPrint('[AUTH] signIn: Firebase email/password start');
      await loginUseCase.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      debugPrint('[AUTH] signIn: Firebase OK → reinitWithToken');
      await GraphQLClientProvider.reinitWithToken();
      debugPrint('[AUTH] signIn: reinitWithToken OK → validateCustomerAccess');
      await CustomerAuthService.validateCustomerAccess();
      debugPrint('[AUTH] signIn: validateCustomerAccess OK → success');
      _clearFields();
      isLoading.value = false;
      onSuccess();
    } on AccessDeniedException catch (e) {
      debugPrint('[AUTH] signIn: AccessDeniedException — ${e.userMessage}');
      isLoading.value = false;
      onAccessDenied(e);
    } catch (e, stack) {
      debugPrint('[AUTH] signIn: ERROR — $e\n$stack');
      isLoading.value = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Google login.
  ///
  /// [onAccessDenied] fires when the account exists as staff/admin only.
  /// The UI should offer a "Go to Sign Up" action — the signup page's Google
  /// button will automatically add the customer role to their account.
  Future<void> signInWithGoogle({
    required void Function() onSuccess,
    required void Function(AccessDeniedException error) onAccessDenied,
    required void Function(String message) onError,
  }) async {
    isLoading.value = true;
    try {
      debugPrint('[AUTH] signInWithGoogle: start');
      await loginUseCase.signInWithGoogle();
      debugPrint('[AUTH] signInWithGoogle: Firebase OK → reinitWithToken');
      await GraphQLClientProvider.reinitWithToken();
      debugPrint('[AUTH] signInWithGoogle: reinitWithToken OK → validateCustomerAccess');
      await CustomerAuthService.validateCustomerAccess();
      debugPrint('[AUTH] signInWithGoogle: validateCustomerAccess OK → success');
      _clearFields();
      isLoading.value = false;
      onSuccess();
    } on GoogleSignInRedirectStarted {
      // Browser is navigating away for the OAuth redirect flow.
      // Keep isLoading = true so the spinner remains visible.
      // Auth completes when the app restarts after the OAuth redirect.
      debugPrint('[AUTH] signInWithGoogle: redirect started — keeping spinner');
    } on AccessDeniedException catch (e) {
      debugPrint('[AUTH] signInWithGoogle: AccessDeniedException — ${e.userMessage}');
      isLoading.value = false;
      onAccessDenied(e);
    } catch (e, stack) {
      debugPrint('[AUTH] signInWithGoogle: ERROR — $e\n$stack');
      isLoading.value = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Adds the 'customer' role to the currently signed-in Firebase account.
  ///
  /// Called directly from the admin/staff detection dialog — skips the signup
  /// page entirely so the user stays in the login flow. Firebase must be
  /// signed in when this is called (validateCustomerAccess preserves the
  /// session for ADMIN_NO_CUSTOMER / STAFF_NO_CUSTOMER).
  Future<void> addCustomerRole({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    isLoading.value = true;
    try {
      debugPrint('[AUTH] addCustomerRole: calling registerAsCustomer');
      try {
        await CustomerAuthService.registerAsCustomer();
      } on AccessDeniedException catch (e) {
        if (e.hint != AuthAccessHint.network) rethrow;
        // Network/timeout — wait and retry once with a fresh token.
        debugPrint('[AUTH] addCustomerRole: timeout on attempt 1 — retrying');
        await Future.delayed(const Duration(seconds: 5));
        await GraphQLClientProvider.reinitWithToken();
        await CustomerAuthService.registerAsCustomer();
      }
      debugPrint('[AUTH] addCustomerRole: customer role added → success');
      isLoading.value = false;
      onSuccess();
    } on AccessDeniedException catch (e) {
      debugPrint('[AUTH] addCustomerRole: AccessDeniedException — ${e.userMessage}');
      isLoading.value = false;
      onError(e.userMessage);
    } catch (e) {
      debugPrint('[AUTH] addCustomerRole: ERROR — $e');
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
