import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitleSubheading extends StatelessWidget {
  final String titleLabel;
  final TextStyle? style;
  const TitleSubheading({super.key, required this.titleLabel, this.style});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => Text(
          titleLabel,
          style: style ??
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
        ));
  }
}
