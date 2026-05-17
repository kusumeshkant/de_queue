import 'package:flutter/material.dart';

// ── Breakpoints ────────────────────────────────────────────────────────────────
// 600 → tablet  |  1024 → desktop
// These match the three-tier system used across the DQ platform.

extension DqResponsive on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  bool get isTabletOrLarger => screenWidth >= 600;

  // ── Type-safe responsive value ─────────────────────────────────────────────
  T responsive<T>(T mobile, {T? tablet, T? desktop}) {
    if (screenWidth >= 1024) return desktop ?? tablet ?? mobile;
    if (screenWidth >= 600) return tablet ?? mobile;
    return mobile;
  }

  // ── Layout helpers ─────────────────────────────────────────────────────────
  double get pagePadding => responsive(16.0, tablet: 24.0, desktop: 32.0);

  double get maxContentWidth =>
      responsive(double.infinity, tablet: 760.0, desktop: 1040.0);

  int get gridColumns => responsive(2, tablet: 3, desktop: 4);

  int get statColumns => responsive(2, tablet: 3, desktop: 4);
}

// ── Static helper class (kept for backward compatibility) ──────────────────────

/// Breakpoints and responsive helpers for dq_app.
///
/// Usage:
///   Responsive.isMobile(context)   → true on phones
///   Responsive.isTablet(context)   → true on tablets
///   Responsive.isDesktop(context)  → true on wide screens / web desktop
///
///   Responsive.hPad(context)       → horizontal page padding
///   Responsive.formWidth(context)  → constrained width for auth/form content
class Responsive {
  Responsive._();

  static const double _mobile = 600;
  static const double _tablet = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= _mobile && w < _tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tablet;

  static double hPad(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= _tablet) return 32;
    if (w >= _mobile) return 24;
    return 16;
  }

  static double vSpace(BuildContext context, double mobile) {
    if (isDesktop(context)) return mobile * 0.75;
    if (isTablet(context)) return mobile * 0.85;
    return mobile;
  }

  static const double formMaxWidth = 480.0;
  static const double contentMaxWidth = 1040.0;

  static Widget formContainer({
    required BuildContext context,
    required Widget child,
    double maxWidth = formMaxWidth,
  }) {
    if (isMobile(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  static double fontSize(BuildContext context, double base) {
    if (isDesktop(context)) return base + 2;
    if (isTablet(context)) return base + 1;
    return base;
  }
}
