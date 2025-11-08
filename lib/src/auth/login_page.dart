import 'dart:ui';

import 'package:dq_app/src/auth/signup_page.dart';
import 'package:dq_app/src/dashBoard/bottomNavigation.dart';
import 'package:dq_app/src/dashBoard/dashboard.dart';
import 'package:dq_app/src/utils/appsystem_ui.dart';
import 'package:dq_app/widgets/dq_button.dart';
import 'package:dq_app/widgets/dq_container.dart';
import 'package:dq_app/widgets/dq_inputField.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
   @override
  void initState() {
    super.initState();
    // Make notification icons white
     AppSystemUI.setTransparentStatusBar();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // put a nice background to appreciate the blur
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Semi-dark overlay so glass stands out
          Container(color: Colors.black.withValues(alpha: .7)),
          // Centered glass card
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
                      SizedBox(height: 10),
                      GlassTextField(
                        label: 'Mobile Number',
                        controller: TextEditingController(),
                        hintText: '+91 000 000 0000',
                      ),
                      SizedBox(height: 10),
                       Visibility(
                        visible: true,
                         child: GlassTextField(
                          label: 'OTP',
                          controller: TextEditingController(),
                          hintText: '0000',
                                               ),
                       ),
                      SizedBox(height: 15),
                      GlassButton(
                        text: "Get OTP",
                        onPressed: () {
                          debugPrint("Button pressed!");
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Bottomnavigation()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            // left: 0,
            right: 12,
            child: Column(
              children: [
                GlassButton(
                        text: '   Sign Up   ',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
