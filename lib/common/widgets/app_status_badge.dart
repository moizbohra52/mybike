import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

enum AppBadgeVariant { solid, soft, outline }

/// Status Pill Badge for Dealership ERP
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final AppBadgeVariant variant;
  final bool showDot;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.variant = AppBadgeVariant.soft,
    this.showDot = true,
    this.icon,
  });

  /// Factory helper for status strings (e.g. "in_stock", "pending", "active")
  factory AppStatusBadge.fromStatus(
    String status, {
    Key? key,
    AppBadgeVariant variant = AppBadgeVariant.soft,
    bool showDot = true,
  }) {
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    Color statusColor;
    String displayLabel;

    switch (normalized) {
      // Vehicle Statuses
      case 'in_stock':
      case 'available':
        statusColor = AppColors.success;
        displayLabel = 'In Stock';
        break;
      case 'reserved':
      case 'booked':
        statusColor = AppColors.primaryYellow;
        displayLabel = 'Reserved';
        break;
      case 'sold':
        statusColor = AppColors.info;
        displayLabel = 'Sold';
        break;
      case 'in_transit':
      case 'transferring':
        statusColor = const Color(0xFF8B5CF6);
        displayLabel = 'In Transit';
        break;
      case 'damaged':
        statusColor = AppColors.error;
        displayLabel = 'Damaged';
        break;

      // Transaction Statuses
      case 'approved':
      case 'completed':
      case 'paid':
      case 'active':
        statusColor = AppColors.success;
        displayLabel = normalized[0].toUpperCase() + normalized.substring(1);
        break;
      case 'pending':
      case 'partial':
        statusColor = AppColors.warning;
        displayLabel = normalized[0].toUpperCase() + normalized.substring(1);
        break;
      case 'rejected':
      case 'cancelled':
      case 'unpaid':
      case 'inactive':
        statusColor = AppColors.error;
        displayLabel = normalized[0].toUpperCase() + normalized.substring(1);
        break;
      case 'draft':
        statusColor = const Color(0xFF6B7280);
        displayLabel = 'Draft';
        break;

      default:
        statusColor = AppColors.info;
        displayLabel = status;
        break;
    }

    return AppStatusBadge(
      key: key,
      label: displayLabel,
      color: statusColor,
      variant: variant,
      showDot: showDot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveColor = color ?? AppColors.primaryYellow;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppBadgeVariant.soft:
        bg = effectiveColor.withValues(alpha: isDark ? 0.18 : 0.12);
        fg = isDark ? (effectiveColor == AppColors.primaryYellow ? AppColors.primaryYellowLight : effectiveColor) : (effectiveColor == AppColors.primaryYellow ? const Color(0xFFB48500) : effectiveColor);
        border = Border.all(
          color: effectiveColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: AppDimensions.borderWidthThin,
        );
        break;
      case AppBadgeVariant.solid:
        bg = effectiveColor;
        fg = effectiveColor == AppColors.primaryYellow ? AppColors.primaryBlack : Colors.white;
        break;
      case AppBadgeVariant.outline:
        bg = Colors.transparent;
        fg = effectiveColor;
        border = Border.all(color: effectiveColor, width: AppDimensions.borderWidth);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppDimensions.spacing4),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing6),
          ],
          Text(
            label,
            style: AppTypography.captionMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
