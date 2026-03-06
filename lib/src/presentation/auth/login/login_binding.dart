import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';
import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:dq_app/src/presentation/auth/login/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthLocalDataSource());
    Get.lazyPut(() => AuthRemoteDataSource());
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(
          local: Get.find(),
          remote: Get.find(),
        ));
    Get.lazyPut(() => LoginUseCase(repository: Get.find()));
    Get.lazyPut(() => LoginController(loginUseCase: Get.find()));
  }
}
