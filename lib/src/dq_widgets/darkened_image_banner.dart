import 'package:flutter/material.dart';

class DarkenedImageBanner extends StatelessWidget {
  final String imagePath;
  final double height;
  final BorderRadius? borderRadius;
  final double darkness; // 0.0 → no dark, 1.0 → fully dark

  const DarkenedImageBanner({
    Key? key,
    required this.imagePath,
    required this.height,
    this.borderRadius,
    this.darkness = 0.35, // ✅ default brightness reduction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(darkness),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }
}
