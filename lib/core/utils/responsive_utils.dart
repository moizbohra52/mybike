import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

/// MYBIKE Responsive Utilities
///
/// Provides breakpoint detection and responsive layout helpers.
/// Breakpoints: Mobile (<600), Tablet (600-1024), Desktop (>1024)
enum DeviceType { mobile, tablet, desktop }

class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppDimensions.breakpointMobile) return DeviceType.mobile;
    if (width < AppDimensions.breakpointTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Boolean shortcuts
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Returns true for tablet and desktop
  static bool isTabletOrDesktop(BuildContext context) =>
      !isMobile(context);

  /// Get screen width
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Get screen height
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Get content padding based on device type
  static EdgeInsets contentPadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const EdgeInsets.all(AppDimensions.spacing16);
      case DeviceType.tablet:
        return const EdgeInsets.all(AppDimensions.spacing24);
      case DeviceType.desktop:
        return const EdgeInsets.all(AppDimensions.spacing32);
    }
  }

  /// Get grid cross-axis count based on device type
  static int gridCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Get a value based on the current device type
  static T valueForDevice<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

/// Responsive layout builder widget
///
/// Builds different layouts for mobile, tablet, and desktop.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppDimensions.breakpointMobile) {
          return mobile(context);
        }
        if (constraints.maxWidth < AppDimensions.breakpointTablet) {
          return (tablet ?? desktop).call(context);
        }
        return desktop(context);
      },
    );
  }
}
