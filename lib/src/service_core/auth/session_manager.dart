import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/presentation/auth/login/login_binding.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionManager {
  /// Call this whenever the backend rejects the session (token expired / 401).
  /// Clears local auth state and navigates back to the login screen.
  static Future<void> expireSession() async {
    // Prevent multiple triggers in the same frame
    if (Get.isSnackbarOpen) return;

    // Clear stored auth so the app doesn't auto-login next launch
    await HiveManager.delete(DbTable.auth, 'current');

    // Dismiss any open dialogs / bottom sheets before navigating
    Get.closeAllSnackbars();
    if (Get.isDialogOpen ?? false) Get.back();
    if (Get.isBottomSheetOpen ?? false) Get.back();

    // Navigate to login, clearing the entire navigation stack
    Get.offAll(
      () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    );

    // Show session-expired message
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
    });
  }
}
