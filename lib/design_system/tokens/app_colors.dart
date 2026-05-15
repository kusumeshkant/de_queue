import 'package:flutter/material.dart';

/// Color tokens for DQ App — single source of truth.
///
/// DQ App supports two themes: light (purple) and green (dark).
/// Use [AppColorsLight] or [AppColorsDark] for theme-specific tokens.
/// Use [AppColors] for semantic tokens that are theme-independent.
abstract class AppColors {
  // ── Semantic — Success (theme-independent) ────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successSubtle = Color(0x1A4CAF50);
  static const Color successBorder = Color(0x334CAF50);
  static const Color successDark = Color(0xFF22C55E); // brighter for dark bg

  // ── Semantic — Warning ────────────────────────────────────
  static const Color warning = Color(0xFFFF9800);
  static const Color warningSubtle = Color(0x1AFF9800);
  static const Color warningBorder = Color(0x33FF9800);

  // ── Semantic — Error ──────────────────────────────────────
  static const Color error = Color(0xFFFF5252);
  static const Color errorSubtle = Color(0x1AFF5252);
  static const Color errorBorder = Color(0x33FF5252);

  // ── Semantic — Info ───────────────────────────────────────
  static const Color info = Color(0xFF4285F4);
  static const Color infoSubtle = Color(0x1A4285F4);
  static const Color infoBorder = Color(0x334285F4);

  // ── Semantic — Neutral ────────────────────────────────────
  static const Color neutral = Color(0xFF9E9E9E);
  static const Color neutralSubtle = Color(0x1A9E9E9E);
  static const Color neutralBorder = Color(0x339E9E9E);

  // ── Google ────────────────────────────────────────────────
  static const Color googleBlue = Color(0xFF4285F4);

  // ── Order / Payment status convenience ────────────────────
  static Color statusColor(String status) => switch (status.toLowerCase()) {
        'pending' => neutral,
        'preparing' => warning,
        'ready' => info,
        'completed' || 'paid' => success,
        'cancelled' || 'failed' => error,
        _ => neutral,
      };

  static Color statusSubtle(String status) => switch (status.toLowerCase()) {
        'pending' => neutralSubtle,
        'preparing' => warningSubtle,
        'ready' => infoSubtle,
        'completed' || 'paid' => successSubtle,
        'cancelled' || 'failed' => errorSubtle,
        _ => neutralSubtle,
      };

  static Color statusBorder(String status) => switch (status.toLowerCase()) {
        'pending' => neutralBorder,
        'preparing' => warningBorder,
        'ready' => infoBorder,
        'completed' || 'paid' => successBorder,
        'cancelled' || 'failed' => errorBorder,
        _ => neutralBorder,
      };
}

/// Light theme color tokens (purple / white glass).
abstract class AppColorsLight {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF757575); // grey.shade600 approx
  static const Color bgGradientStart = Color(0xFFEEF2FF);
  static const Color bgGradientEnd = Color(0xFFE8F5E9);

  // Glass surfaces
  static const Color cardSurface = Color(0xBFFFFFFF); // white 75%
  static const Color cardBorder = Color(0xD9FFFFFF); // white 85%
  static const Color inputFill = Color(0x47FFFFFF); // white 28%
  static const Color inputBorder = Color(0xBFFFFFFF); // white 75%
  static const Color inputFocusBorder = Color(0x47000000); // black 28%

  // Button
  static const Color buttonGradientStart = Color(0xB36C63FF);
  static const Color buttonGradientEnd = Color(0xE16C63FF);
}

/// Dark/Green theme color tokens (green / dark navy glass).
abstract class AppColorsDark {
  static const Color primary = Color(0xFF00E676);
  static const Color primaryMuted = Color(0xFF00C853);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF); // white60
  static const Color bgGradientStart = Color(0xFF0A1628);
  static const Color bgGradientEnd = Color(0xFF0D3B2E);

  // Glass surfaces
  static const Color cardSurface = Color(0x12FFFFFF); // white 7%
  static const Color cardBorder = Color(0x26FFFFFF); // white 15%
  static const Color inputFill = Color(0x52000000); // black 32%
  static const Color inputBorder = Color(0x2EFFFFFF); // white 18%
  static const Color inputFocusBorder = Color(0x6BFFFFFF); // white 42%

  // Button (dark pill)
  static const Color buttonGradientStart = Color(0xCC1A1A1A);
  static const Color buttonGradientEnd = Color(0xE8000000);
}

/// Glass opacity constants — shared across both themes.
abstract class AppGlassOpacity {
  static const double blur04 = 0.04;
  static const double blur07 = 0.07;
  static const double blur10 = 0.10;
  static const double blur15 = 0.15;
  static const double blur18 = 0.18;
  static const double blur20 = 0.20;
  static const double blur25 = 0.25;
  static const double blur30 = 0.30;
  static const double blur45 = 0.45;
  static const double blur55 = 0.55;
  static const double blur75 = 0.75;
  static const double blur85 = 0.85;
}
