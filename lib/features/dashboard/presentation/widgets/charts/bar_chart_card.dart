import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../common/common.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/chart_data_point.dart';

/// Interactive Custom-Painted Bar Chart Card
class BarChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ChartDataPoint> data;
  final double height;
  final Color? barColor;
  final Widget? trailing;

  const BarChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.height = 240,
    this.barColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = barColor ?? AppColors.primaryYellow;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                ],
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppDimensions.spacing20),
          SizedBox(
            height: height,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(
                data: data,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color primaryColor;
  final bool isDark;

  _BarChartPainter({
    required this.data,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.map((e) => e.value).reduce(math.max);
    final effectiveMax = maxVal == 0 ? 100.0 : maxVal * 1.15;

    const double bottomPadding = 28.0;
    const double topPadding = 18.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final slotWidth = size.width / data.length;
    final barWidth = math.min(36.0, slotWidth * 0.55);

    final linePaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.grey.shade200
      ..strokeWidth = 1.0;

    // Draw 3 horizontal guide lines
    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight * (i / 3.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final slotCenterX = (i * slotWidth) + (slotWidth / 2);
      final barHeight = (item.value / effectiveMax) * chartHeight;
      final topY = topPadding + chartHeight - barHeight;
      final bottomY = topPadding + chartHeight;

      final color = item.color ?? primaryColor;

      // Bar rect with rounded top corners
      final rect = Rect.fromLTRB(
        slotCenterX - (barWidth / 2),
        topY,
        slotCenterX + (barWidth / 2),
        bottomY,
      );

      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final barGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withValues(alpha: 0.65),
        ],
      );

      final barPaint = Paint()..shader = barGradient.createShader(rect);
      canvas.drawRRect(rrect, barPaint);

      // Value label on top of bar
      final valStr = item.displayValue ?? item.value.toStringAsFixed(0);
      textPainter.text = TextSpan(
        text: valStr,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(slotCenterX - (textPainter.width / 2), topY - 14),
      );

      // Category label under bar
      textPainter.text = TextSpan(
        text: item.label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(slotCenterX - (textPainter.width / 2), bottomY + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}
