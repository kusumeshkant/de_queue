import 'package:dq_app/src/data/datasources/remote/profile_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/profile_repository_impl.dart';
import 'package:dq_app/src/domain/repo/profile_repository.dart';
import 'package:dq_app/src/domain/usecase/get_profile_usecase.dart';
import 'package:dq_app/src/domain/usecase/update_profile_usecase.dart';
import 'package:dq_app/src/presentation/profile/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRemoteDataSource());
    Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(remote: Get.find()));
    Get.lazyPut(() => GetProfileUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateProfileUseCase(repository: Get.find()));
    Get.lazyPut(() => ProfileController(
          getProfileUseCase: Get.find(),
          updateProfileUseCase: Get.find(),
        ));
  }
}
