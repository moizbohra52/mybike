import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';

/// Responsive Layout Builder
///
/// Switches seamlessly between Mobile, Tablet, and Desktop layouts.
class AppResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AppResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppDimensions.breakpointTablet) {
          if (desktop != null) return desktop!;
          if (tablet != null) return tablet!;
          return mobile;
        }

        if (constraints.maxWidth >= AppDimensions.breakpointMobile) {
          if (tablet != null) return tablet!;
          return mobile;
        }

        return mobile;
      },
    );
  }
}
