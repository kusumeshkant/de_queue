import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppSystemUI {
  /// Makes status bar transparent with white icons
  static void setTransparentStatusBar({bool darkIcons = false}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
      statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
    ));
  }
}
