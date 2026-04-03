import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/profile/profile_controller.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    final tc = Get.find<ThemeController>();

    return ThemedBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppKeys.profile.tr),
          centerTitle: false,
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: tc.primary));
          }

          final user = c.user.value;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),

              // Avatar
              Center(
                child: Obx(() => CircleAvatar(
                      radius: 48,
                      backgroundColor: tc.primary,
                      child: Text(
                        user?.initials ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 32),

              // Phone number (read-only)
              Obx(() => _SectionLabel(label: AppKeys.phoneNumberLabel.tr, tc: tc)),
              const SizedBox(height: 8),
              AppGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Obx(() => Icon(Icons.phone, color: tc.textSecondary, size: 20)),
                    const SizedBox(width: 12),
                    Obx(() => Text(
                          user?.phone ?? AppKeys.notAvailable.tr,
                          style: TextStyle(fontSize: 15, color: tc.textPrimary),
                        )),
                    const Spacer(),
                    Obx(() => Icon(Icons.lock_outline, color: tc.textSecondary, size: 16)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name (editable)
              Obx(() => _SectionLabel(label: AppKeys.displayName.tr, tc: tc)),
              const SizedBox(height: 8),
              AppGlassCard(
                padding: EdgeInsets.zero,
                child: Obx(() => TextField(
                      controller: c.nameController,
                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      style: TextStyle(color: tc.textPrimary),
                      cursorColor: tc.primary,
                      decoration: InputDecoration(
                        hintText: AppKeys.enterName.tr,
                        hintStyle: TextStyle(color: tc.textSecondary),
                        prefixIcon: Icon(Icons.person_outline, color: tc.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    )),
              ),

              const SizedBox(height: 32),

              // Save button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: c.isSaving.value
                          ? null
                          : () => c.saveProfile(
                                onSuccess: () {
                                  Get.snackbar(
                                    AppKeys.saved.tr,
                                    AppKeys.profileUpdated.tr,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                onError: (msg) {
                                  Get.snackbar(
                                    AppKeys.error.tr,
                                    msg,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: c.isSaving.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppKeys.saveChanges.tr,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  )),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeController tc;
  const _SectionLabel({required this.label, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: tc.textSecondary,
      ),
    );
  }
}
