import 'package:flutter/material.dart';

class TitleSubheading extends StatelessWidget {
  final String titleLabel;
  final TextStyle? style;
  const TitleSubheading({super.key, required this.titleLabel, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(titleLabel, style: style ?? TextStyle(fontSize: 20));
  }
}
