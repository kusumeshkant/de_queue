import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/domain/usecase/get_profile_usecase.dart';
import 'package:dq_app/src/domain/usecase/update_profile_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileController({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  });

  final Rx<UserEntity?> user = Rx(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final profile = await getProfileUseCase.execute();
      user.value = profile;
      nameController.text = profile.name ?? '';
    } catch (e) {
      debugPrint('loadProfile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      onError('Name cannot be empty');
      return;
    }

    isSaving.value = true;
    try {
      final updated = await updateProfileUseCase.execute(name: name);
      user.value = updated;
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
