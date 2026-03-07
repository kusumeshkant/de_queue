import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/data/datasources/remote/profile_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_app/src/data/repo_impl/profile_repository_impl.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';
import 'package:dq_app/src/domain/repo/profile_repository.dart';
import 'package:dq_app/src/domain/usecase/signup_usecase.dart';
import 'package:dq_app/src/domain/usecase/update_profile_usecase.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_controller.dart';
import 'package:get/get.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthLocalDataSource());
    Get.lazyPut(() => AuthRemoteDataSource());
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(
          local: Get.find(),
          remote: Get.find(),
        ));
    Get.lazyPut(() => ProfileRemoteDataSource());
    Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(remote: Get.find()));
    Get.lazyPut(() => SignupUseCase(repository: Get.find()));
    Get.lazyPut(
        () => UpdateProfileUseCase(repository: Get.find<ProfileRepository>()));
    Get.lazyPut(() => SignupController(
          signupUseCase: Get.find(),
          updateProfileUseCase: Get.find(),
        ));
  }
}
