import 'package:flutter/material.dart';
import '../../../../../common/common.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/chart_data_point.dart';

/// Segmented Progress Distribution Bar Card
class ProgressBreakdownCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ChartDataPoint> data;

  const ProgressBreakdownCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final total = data.fold<double>(0.0, (sum, item) => sum + item.value);

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.captionSmall.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacing16),

          // Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: data.map((item) {
                  final flexVal = total > 0 ? ((item.value / total) * 1000).toInt() : 1;
                  return Expanded(
                    flex: flexVal > 0 ? flexVal : 1,
                    child: Container(
                      color: item.color ?? AppColors.primaryYellow,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Items Grid / List
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: data.map((item) {
              final pct = total > 0 ? ((item.value / total) * 100).toStringAsFixed(1) : '0';

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color ?? AppColors.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($pct%)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.color ?? AppColors.primaryYellow,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
