import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MYBIKE Shadow Definitions
///
/// Subtle, premium shadows for cards, dropdowns, modals, and floating elements.
abstract final class AppShadows {
  // ─── Light Theme Shadows ───

  /// Subtle card shadow (default for cards)
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Medium elevation (dropdowns, popovers)
  static const List<BoxShadow> dropdownLight = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// High elevation (modals, dialogs)
  static const List<BoxShadow> modalLight = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  /// Floating action button / sticky header
  static const List<BoxShadow> floatingLight = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  // ─── Dark Theme Shadows ───
  // Shadows are more subtle in dark mode

  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> dropdownDark = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> modalDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> floatingDark = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  // ─── Yellow Glow (for CTAs) ───
  static List<BoxShadow> yellowGlow = [
    BoxShadow(
      color: AppColors.primaryYellow.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
}
