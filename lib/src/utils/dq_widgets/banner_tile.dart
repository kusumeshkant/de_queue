import 'package:flutter/material.dart';

class BannerTile extends StatelessWidget {
  final String imagePath;
   const BannerTile({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Image.asset(imagePath),
    );
  }
}