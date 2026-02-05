import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/routes/app_router.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/widgets/dq_button.dart';
import 'package:dq_app/widgets/dq_container.dart';
import 'package:dq_app/widgets/dq_inputField.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  void initState() {
    super.initState();
    AppSystemUI.setTransparentStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                    children:  [
                      SizedBox(height: 10),
                      GlassTextField(
                        label: 'Name',
                        hintText: 'User Name',
                        controller: TextEditingController(),
                      ),
                      SizedBox(height: 10),
                      GlassTextField(
                        label: 'Mobile Number',
                        hintText: '+91 000 000 0000',
                        controller: TextEditingController(),
                      ),
                      SizedBox(height: 10),
                      GlassTextField(
                        label: 'OTP',
                        hintText: '0000',
                        controller: TextEditingController(),
                      ),
                      SizedBox(height: 15),
                      GlassButton(
                        text: "Get OTP",
                        onPressed: (){},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Back Button
          Positioned(
            top: 40,
            left: 10,
            child: GlassButton(
              text: "Back",
              onPressed: () {
                context.router.pop();
              },
            ),
          ),

          /// Sign In Button
          Positioned(
            bottom: 40,
            right: 12,
            child: GlassButton(
              text: '   Sign In   ',
              onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                // context.router.replace(const LoginRoute());
              },
            ),
          ),
        ],
      ),
    );
  }
}
