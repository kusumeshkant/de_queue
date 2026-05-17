import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tc.bgGradient,
            ),
          ),
          child: child,
        ));
  }
}
