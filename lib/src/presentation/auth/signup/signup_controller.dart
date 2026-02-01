import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {

  LoginUseCase loginUseCase;

  SignupController({required this.loginUseCase});

  var isLoading = false.obs;
  var error = RxnString();
  Future<void> login() async {}

}