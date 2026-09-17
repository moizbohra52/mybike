import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

enum AppCurrencySize { small, medium, large }

/// Indian Rupee (₹) Formatted Currency Display
class AppCurrencyText extends StatelessWidget {
  final num amount;
  final AppCurrencySize size;
  final bool showSymbol;
  final bool compact;
  final int decimalDigits;
  final bool showColorIndicator;
  final Color? color;
  final TextStyle? customStyle;

  const AppCurrencyText({
    super.key,
    required this.amount,
    this.size = AppCurrencySize.medium,
    this.showSymbol = true,
    this.compact = false,
    this.decimalDigits = 2,
    this.showColorIndicator = false,
    this.color,
    this.customStyle,
  });

  const AppCurrencyText.compact({
    super.key,
    required this.amount,
    this.size = AppCurrencySize.medium,
    this.showSymbol = true,
    this.decimalDigits = 1,
    this.showColorIndicator = false,
    this.color,
    this.customStyle,
  }) : compact = true;

  String _formatValue() {
    final absAmount = amount.abs();

    if (compact) {
      if (absAmount >= 10000000) {
        final cr = absAmount / 10000000;
        return '${cr.toStringAsFixed(decimalDigits)} Cr';
      } else if (absAmount >= 100000) {
        final lakh = absAmount / 100000;
        return '${lakh.toStringAsFixed(decimalDigits)} L';
      } else if (absAmount >= 1000) {
        final k = absAmount / 1000;
        return '${k.toStringAsFixed(decimalDigits)} K';
      }
    }

    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(absAmount);
  }

  TextStyle _getBaseStyle() {
    switch (size) {
      case AppCurrencySize.small:
        return AppTypography.currencySmall;
      case AppCurrencySize.medium:
        return AppTypography.currencyMedium;
      case AppCurrencySize.large:
        return AppTypography.currencyLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final formattedNumber = _formatValue();
    final isNegative = amount < 0;

    Color effectiveColor;
    if (color != null) {
      effectiveColor = color!;
    } else if (showColorIndicator) {
      if (amount > 0) {
        effectiveColor = AppColors.success;
      } else if (amount < 0) {
        effectiveColor = AppColors.error;
      } else {
        effectiveColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
      }
    } else {
      effectiveColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    }

    final style = (customStyle ?? _getBaseStyle()).copyWith(color: effectiveColor);

    return Text(
      '${isNegative ? '-' : ''}${showSymbol ? '₹ ' : ''}$formattedNumber',
      style: style,
    );
  }
}
