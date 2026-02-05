import 'dart:developer';

import 'package:dq_app/src/domain/usecase/login_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {

  LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  var isLoading = false.obs;
  var error = RxnString();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();




  Future<void> login () async{
    
    isLoading.value = true;
    error.value = null;

    final response = loginUseCase(emailController.text, passwordController.text);

    log('response: ${response}');
    
  
  }
  

}