import 'package:flutter/material.dart';

/// MYBIKE Brand Color Palette
///
/// Yellow is the primary accent — used strategically for CTAs, highlights,
/// and brand identity. NOT used as a dominant background color.
abstract final class AppColors {
  // ─── Primary Brand ───
  static const Color primaryYellow = Color(0xFFF9C846);
  static const Color primaryYellowLight = Color(0xFFFBD76E);
  static const Color primaryYellowDark = Color(0xFFE5B52E);
  static const Color primaryYellowSubtle = Color(0xFFFFF8E7);

  static const Color primaryBlack = Color(0xFF171717);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Light Theme ───
  static const Color lightBackground = Color(0xFFF7F7F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E8E5);
  static const Color lightDivider = Color(0xFFF0F0ED);

  static const Color lightPrimaryText = Color(0xFF171717);
  static const Color lightSecondaryText = Color(0xFF6B6B6B);
  static const Color lightMutedText = Color(0xFF999999);
  static const Color lightHintText = Color(0xFFBBBBBB);

  // ─── Dark Theme ───
  static const Color darkBackground = Color(0xFF101010);
  static const Color darkSurface = Color(0xFF181818);
  static const Color darkCard = Color(0xFF202020);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF2A2A2A);

  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFB5B5B5);
  static const Color darkMutedText = Color(0xFF808080);
  static const Color darkHintText = Color(0xFF666666);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ─── Status Colors ───
  static const Color pending = Color(0xFFF59E0B);
  static const Color confirmed = Color(0xFF3B82F6);
  static const Color inProgress = Color(0xFF8B5CF6);
  static const Color completed = Color(0xFF22C55E);
  static const Color cancelled = Color(0xFFEF4444);
  static const Color delivered = Color(0xFF06B6D4);

  // ─── Chart Colors ───
  static const List<Color> chartColors = [
    Color(0xFFF9C846),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  // ─── Shimmer Colors ───
  static const Color shimmerBase = Color(0xFFE8E8E5);
  static const Color shimmerHighlight = Color(0xFFF5F5F2);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
}
