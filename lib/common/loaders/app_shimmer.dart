import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/extensions/context_extensions.dart';

/// MYBIKE Zero-Dependency Shimmer Skeleton Component
///
/// Smooth, hardware-accelerated animated gradient sweep for loading placeholders.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Quick placeholder box with rounded corners
  static Widget box({
    Key? key,
    required double width,
    required double height,
    double borderRadius = AppDimensions.radiusSm,
  }) {
    return AppShimmer(
      key: key,
      child: AppShimmerBone(width: width, height: height, radius: borderRadius),
    );
  }

  /// Preset shimmer for ERP KPI stat cards.
  ///
  /// Mirrors `AppStatCard`'s own chrome — same card colour, border, shadow and
  /// padding — so the card does not resize when the value lands. The chrome is
  /// painted outside the [AppShimmer] on purpose: wrapping the whole card swept
  /// the border and background along with the bones, which read as a glowing
  /// tile rather than a placeholder.
  static Widget statCard({Key? key}) {
    return Builder(
      key: key,
      builder: (context) {
        final isDark = context.isDarkMode;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: AppDimensions.borderWidth,
            ),
            boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
          ),
          // One shimmer for the whole card: every bone sweeps in step, and the
          // card costs a single animation controller however many bones it has.
          child: const AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.55,
                        child: AppShimmerBone(height: 12),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing8),
                    AppShimmerBone(
                      width: 40,
                      height: 40,
                      radius: AppDimensions.radiusMd,
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing12),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: AppShimmerBone(height: 24),
                ),
                SizedBox(height: AppDimensions.spacing10),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.4,
                  child: AppShimmerBone(height: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Preset shimmer for table rows
  static Widget tableRow({Key? key, int columns = 5}) {
    return AppShimmer(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing12,
          horizontal: AppDimensions.spacing16,
        ),
        child: Row(
          children: [
            for (var index = 0; index < columns; index++)
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing8,
                  ),
                  child: AppShimmerBone(height: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Preset shimmer for a list item
  static Widget listItem({Key? key}) {
    return AppShimmer(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing12,
          horizontal: AppDimensions.spacing16,
        ),
        child: Row(
          children: [
            const AppShimmerBone(
              width: 44,
              height: 44,
              radius: AppDimensions.radiusMd,
            ),
            const SizedBox(width: AppDimensions.spacing16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBone(width: double.infinity, height: 14),
                  SizedBox(height: AppDimensions.spacing8),
                  AppShimmerBone(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

/// One placeholder bar inside an [AppShimmer].
///
/// Only meaningful as a descendant of an [AppShimmer]: the sweep paints over
/// this widget's colour, which is why the value here never reaches the screen.
/// It still has to be opaque — [ShaderMask] keeps the child's alpha, so a
/// transparent bone would leave nothing for the gradient to sit on and would
/// disappear entirely.
class AppShimmerBone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const AppShimmerBone({
    super.key,
    this.width,
    required this.height,
    this.radius = AppDimensions.radiusXs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final defaultBase = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;
    final defaultHighlight = isDark
        ? AppColors.shimmerHighlightDark
        : AppColors.shimmerHighlight;

    final base = widget.baseColor ?? defaultBase;
    final highlight = widget.highlightColor ?? defaultHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.0, 0.5, 1.0],
              colors: [base, highlight, base],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}
