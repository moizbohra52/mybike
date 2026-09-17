import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Form Date Picker Input with Formatted Display
class AppDatePicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final bool enabled;
  final bool isClearable;
  final String dateFormat;

  const AppDatePicker({
    super.key,
    this.label,
    this.hint = 'Select date',
    this.errorText,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.enabled = true,
    this.isClearable = true,
    this.dateFormat = 'dd MMM yyyy',
  });

  Future<void> _pickDate(BuildContext context) async {
    if (!enabled) return;

    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? DateTime(2000);
    final effectiveLastDate = lastDate ?? DateTime(2100);
    final initialDate = value ?? (now.isAfter(effectiveFirstDate) && now.isBefore(effectiveLastDate) ? now : effectiveFirstDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      builder: (context, child) {
        final isDark = context.isDarkMode;
        return Theme(
          data: context.theme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primaryYellow,
                    onPrimary: AppColors.primaryBlack,
                    surface: AppColors.darkCard,
                    onSurface: AppColors.darkPrimaryText,
                  )
                : ColorScheme.light(
                    primary: AppColors.primaryYellowDark,
                    onPrimary: Colors.white,
                    surface: AppColors.lightCard,
                    onSurface: AppColors.lightPrimaryText,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final formattedValue = value != null ? DateFormat(dateFormat).format(value!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: AppDimensions.spacing4),
                Text(
                  '*',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        InkWell(
          onTap: enabled ? () => _pickDate(context) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              prefixIcon: Icon(
                Icons.calendar_today_outlined,
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                size: AppDimensions.iconSm,
              ),
              suffixIcon: (isClearable && value != null && enabled)
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: AppDimensions.iconSm),
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      onPressed: () => onChanged(null),
                      tooltip: 'Clear date',
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing12,
              ),
            ),
            child: Text(
              formattedValue ?? hint ?? '',
              style: AppTypography.bodyMedium.copyWith(
                color: formattedValue != null
                    ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                    : (isDark ? AppColors.darkHintText : AppColors.lightHintText),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
