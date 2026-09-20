import 'package:flutter/material.dart';
import '../../../../../common/common.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/chart_data_point.dart';

/// Curvilinear Bézier Trend Chart Card
class LineTrendChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ChartDataPoint> data;
  final double height;
  final String? primarySeriesLabel;
  final String? secondarySeriesLabel;
  final Color? primaryColor;
  final Color? secondaryColor;

  const LineTrendChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.height = 240,
    this.primarySeriesLabel = 'Actual',
    this.secondarySeriesLabel,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final pColor = primaryColor ?? AppColors.primaryYellow;
    final sColor = secondaryColor ?? AppColors.info;

    final hasSecondary = data.any((d) => d.secondaryValue != null);

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
              // Series Legend
              Row(
                children: [
                  _legendDot(primarySeriesLabel ?? 'Actual', pColor, isDark),
                  if (hasSecondary && secondarySeriesLabel != null) ...[
                    const SizedBox(width: 16),
                    _legendDot(secondarySeriesLabel!, sColor, isDark),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing20),
          SizedBox(
            height: height,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineTrendPainter(
                data: data,
                primaryColor: pColor,
                secondaryColor: sColor,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LineTrendPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  _LineTrendPainter({
    required this.data,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double maxVal = 0.0;
    for (final d in data) {
      if (d.value > maxVal) maxVal = d.value;
      if (d.secondaryValue != null && d.secondaryValue! > maxVal) maxVal = d.secondaryValue!;
    }
    final effectiveMax = maxVal == 0 ? 100.0 : maxVal * 1.15;

    const double bottomPadding = 26.0;
    const double topPadding = 16.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final stepX = size.width / (data.length - 1);

    // Guide lines
    final linePaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight * (i / 3.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final hasSecondary = data.any((d) => d.secondaryValue != null);

    // Draw Secondary Line if present
    if (hasSecondary) {
      final secPoints = <Offset>[];
      for (int i = 0; i < data.length; i++) {
        final val = data[i].secondaryValue ?? 0.0;
        final x = i * stepX;
        final y = topPadding + chartHeight - ((val / effectiveMax) * chartHeight);
        secPoints.add(Offset(x, y));
      }
      _drawSmoothLine(canvas, secPoints, secondaryColor, drawArea: false);
    }

    // Draw Primary Line
    final primPoints = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final val = data[i].value;
      final x = i * stepX;
      final y = topPadding + chartHeight - ((val / effectiveMax) * chartHeight);
      primPoints.add(Offset(x, y));
    }

    _drawSmoothLine(canvas, primPoints, primaryColor, drawArea: true, size: size, topPadding: topPadding, chartHeight: chartHeight);

    // Draw Bottom Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), topPadding + chartHeight + 8),
      );
    }
  }

  void _drawSmoothLine(
    Canvas canvas,
    List<Offset> points,
    Color color, {
    required bool drawArea,
    Size? size,
    double topPadding = 0,
    double chartHeight = 0,
  }) {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    if (drawArea && size != null) {
      final areaPath = Path.from(path)
        ..lineTo(points.last.dx, topPadding + chartHeight)
        ..lineTo(points.first.dx, topPadding + chartHeight)
        ..close();

      final areaGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0.0),
        ],
      );

      canvas.drawPath(
        areaPath,
        Paint()..shader = areaGradient.createShader(Rect.fromLTRB(0, topPadding, size.width, topPadding + chartHeight)),
      );
    }

    // Stroke line
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Marker dots
    final dotPaint = Paint()..color = color;
    final dotHolePaint = Paint()..color = isDark ? const Color(0xFF202020) : Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 5.0, dotPaint);
      canvas.drawCircle(p, 2.5, dotHolePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineTrendPainter oldDelegate) => true;
}
