import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:dq_app/src/presentation/auth/signup/signup_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottomNavigation.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/widgets/dq_button.dart';
import 'package:dq_app/widgets/dq_container.dart';
import 'package:dq_app/widgets/dq_inputField.dart';
import 'package:flutter/material.dart';

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      GlassTextField(
                        label: 'Mobile Number',
                        hintText: '+91 000 000 0000',
                        controller: TextEditingController(),
                      ),
                      const SizedBox(height: 10),
                       GlassTextField(
                        label: 'OTP',
                        hintText: '0000',
                        controller: TextEditingController(),
                      ),
                      const SizedBox(height: 15),

                      /// Login → App
                      GlassButton(
                        text: "Get OTP",
                        onPressed: () {
                          debugPrint("Button pressed!");

                            Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Bottomnavigation()),
                    );

                          /// ✅ AutoRoute navigation
                          // context.router.replace(
                          //    BottomNavigationRoute(),
                          // );
                        },
                      ),
                    ],
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
