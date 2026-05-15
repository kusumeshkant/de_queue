import 'package:flutter/material.dart';

/// Typography tokens for DQ App — single source of truth.
///
/// DQ App supports dual themes (light/dark). Typography shapes are theme-agnostic;
/// colors are omitted here — apply them via ThemeController at the call-site,
/// or use [AppTypographyLight] / [AppTypographyDark] convenience variants.
///
/// All TextStyles are const.
abstract class AppTypography {
  // ── Display ───────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // ── Title ─────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  // ── Body ──────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // ── Label ─────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.3,
  );

  // ── Caption ───────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ── Button ────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ── Logo ──────────────────────────────────────────────────
  static const TextStyle logoTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: 5,
  );

  static const TextStyle logoTagline = TextStyle(
    fontSize: 13,
    letterSpacing: 0.4,
  );

  // ── App bar ───────────────────────────────────────────────
  static const TextStyle appBar = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ── Badge / tag ───────────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // ── Price / numeric ───────────────────────────────────────
  static const TextStyle priceLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle priceStrikethrough = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
  );

  // ── Quantity ──────────────────────────────────────────────
  static const TextStyle quantity = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}
