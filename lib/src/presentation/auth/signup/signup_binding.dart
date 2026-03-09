import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';
import 'package:dq_app/src/domain/usecase/signup_usecase.dart';
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
    Get.lazyPut(() => SignupUseCase(repository: Get.find()));
    Get.lazyPut(() => SignupController(signupUseCase: Get.find()));
  }
}
