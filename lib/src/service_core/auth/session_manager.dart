import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/presentation/auth/login/login_binding.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionManager {
  // Prevents multiple concurrent 401 responses from each triggering their own
  // navigation to the login screen, which would stack multiple LoginPage routes.
  static bool _isExpiring = false;

  /// Terminates the current session completely and navigates to the login screen.
  ///
  /// Called when:
  ///   - The backend returns UNAUTHENTICATED and the token refresh retry fails.
  ///   - The Firebase token force-refresh itself fails (account disabled/deleted).
  ///
  /// Clears both the Hive auth cache AND the Firebase session so the next cold
  /// start does not silently re-authenticate with a stale Firebase credential.
  static Future<void> expireSession() async {
    if (_isExpiring) return;
    _isExpiring = true;

    // Sign out from Firebase FIRST so FirebaseAuth.instance.currentUser becomes
    // null immediately. Without this, a cold start after session expiry would
    // find a live Firebase credential and silently re-enter the app.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // signOut() rarely fails, but never block navigation if it does.
    }

    // Clear the local Hive cache so the app cannot restore a stale session.
    await HiveManager.delete(DbTable.auth, 'current');

    Get.closeAllSnackbars();
    if (Get.isDialogOpen ?? false) Get.back();
    if (Get.isBottomSheetOpen ?? false) Get.back();

    // Deferred to avoid "setState() called after dispose()" when a dialog
    // is still animating closed when Get.offAll fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(
        () => const LoginPage(),
        binding: LoginBinding(),
        transition: Transition.fadeIn,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Session Expired',
          'Please sign in again to continue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.lock_outline, color: Colors.white),
        );
        // Reset guard AFTER navigation completes so a re-login can expire
        // again if needed.
        _isExpiring = false;
      });
    });
  }
}
