import 'package:dq_app/core/enums/data_source_type.dart';
import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:dq_app/src/presentation/auth/login/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // data source
    Get.lazyPut(() => AuthLocalDataSource());
    Get.lazyPut(() => AuthRemoteDataSource());

    // repos
    Get.lazyPut(
      () => AuthRepositoryImpl(
        local: Get.find(),
        remote: Get.find(),
        source: DataSourceType.local,
      ),
    );

    // usecase 
    // Get.lazyPut(()=> LoginUseCase(Get.find()));

    // controller
    // Get.lazyPut(()=> LoginController(loginUseCase: Get.find()));
  }
}
