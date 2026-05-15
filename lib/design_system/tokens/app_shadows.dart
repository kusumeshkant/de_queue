import 'package:flutter/material.dart';

/// Shadow and elevation tokens for DQ App.
///
/// DQ App uses glassmorphism — shadows are subtle and dark-aware.
/// Use [AppShadowsLight] for light (purple) theme, [AppShadowsDark] for green theme.
abstract class AppShadowsLight {
  // ── Auth card ─────────────────────────────────────────────
  static const List<BoxShadow> authCard = [
    BoxShadow(
      color: Color(0x14000000), // black 8%
      blurRadius: 36,
      offset: Offset(0, 12),
    ),
  ];

  // ── Glass card ────────────────────────────────────────────
  static const List<BoxShadow> glassCard = [
    BoxShadow(
      color: Color(0x0F000000), // black 6%
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ── Button ────────────────────────────────────────────────
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x4D6C63FF), // primary purple 30%
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  // ── Bottom nav ────────────────────────────────────────────
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x1F000000), // black 12%
      blurRadius: 12,
      offset: Offset(0, -3),
    ),
  ];
}

abstract class AppShadowsDark {
  // ── Auth card ─────────────────────────────────────────────
  static const List<BoxShadow> authCard = [
    BoxShadow(
      color: Color(0x73000000), // black 45%
      blurRadius: 36,
      offset: Offset(0, 12),
    ),
  ];

  // ── Glass card ────────────────────────────────────────────
  static const List<BoxShadow> glassCard = [
    BoxShadow(
      color: Color(0x4D000000), // black 30%
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ── Button (dark pill) ────────────────────────────────────
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x4D000000), // black 30%
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  // ── Bottom nav ────────────────────────────────────────────
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 12,
      offset: Offset(0, -3),
    ),
  ];

  // ── Scanner pulse ─────────────────────────────────────────
  static List<BoxShadow> scannerPulse(double intensity) => [
        BoxShadow(
          color: Color.fromRGBO(0, 230, 118, intensity * 0.25),
          blurRadius: 14,
          spreadRadius: 2,
        ),
      ];
}

/// Blur (backdrop filter) sigma values.
abstract class AppBlur {
  static const double light = 6;
  static const double storeCard = 6;
  static const double glassCard = 12;
  static const double scannerFeedback = 28;
  static const double input = 28;
  static const double authCard = 40;
}
