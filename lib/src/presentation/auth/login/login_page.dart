import 'dart:developer';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/presentation/auth/login/login_controller.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottomNavigation.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/widgets/dq_button.dart';
import 'package:dq_app/widgets/dq_container.dart';
import 'package:dq_app/widgets/dq_inputField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    AppSystemUI.setTransparentStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    var loginController = Get.put<LoginController>(LoginController());
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Dark overlay
          Container(color: Colors.black.withValues(alpha: .7)),

          /// Glass Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: GlassContainer(
                  width: MediaQuery.of(context).size.width * .95,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: loginController.loginFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        GlassTextField(
                          label: 'Email',
                          hintText: 'example@ybl.com',
                          controller: loginController.emailController,
                          onChanged: (v) {
                            loginController.isEnable();
                          },
                          validator: loginController.emailValidator,
                        ),
                        const SizedBox(height: 10),
                        GlassTextField(
                          label: 'Password',
                          hintText: '*******',
                          controller: loginController.passwordController,
                          obscureText: true,
                          onChanged: (v) {
                            loginController.isEnable();
                          },
                          validator: loginController.passwordCheck,
                        ),
                        const SizedBox(height: 15),

                        /// Login → App
                        Obx(
                          () => GlassButton(
                            text: "SignIn",
                            enabled: loginController.isButtonEnable.value,
                            onPressed: loginController.isButtonEnable.value
                                ? () async {
                                  HiveManager.delete(DbTable.users, 'Users');
                                    final existingAuth = HiveManager.get(
                                      DbTable.users,
                                      'Users',
                                    );

                                    if (existingAuth == null) {
                                        await HiveManager.put(
                                        DbTable.users,
                                        'Users',
                                        {
                                          'id': 'demo_001',
                                          'email': 'demo@test.com',
                                          'password': '123456',
                                        },
                                      );

                                    await  HiveManager.put(DbTable.auth, 'current', {
                                        'token': 'abcd',
                                        'isLoggedIn': true,
                                      });
                                    
                                    }
                                    if (loginController
                                        .loginFormKey
                                        .currentState!
                                        .validate()) {
                                      loginController.login(
                                        onError: (v){},
                                        onSuccess: (){
                                          Get.offAll(Bottomnavigation());
                                        }
                                      );
                                    }
                                  }
                                : () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Sign Up
          Positioned(
            bottom: 40,
            right: 12,
            child: GlassButton(
              text: '   Sign Up   ',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );

                /// ✅ AutoRoute navigation
                // context.router.push(const SignUpRoute());
              },
            ),
          ),
        ],
      ),
    );
  }
}
