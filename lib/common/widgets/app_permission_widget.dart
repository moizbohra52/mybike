import 'package:flutter/material.dart';

/// Conditional Permission Gate Widget
///
/// Shows or hides UI elements based on user role and permissions.
class AppPermissionWidget extends StatelessWidget {
  final bool hasPermission;
  final Widget child;
  final Widget? fallback;
  final bool showDisabledInsteadOfHiding;
  final String? tooltipWhenDisabled;

  const AppPermissionWidget({
    super.key,
    required this.hasPermission,
    required this.child,
    this.fallback,
    this.showDisabledInsteadOfHiding = false,
    this.tooltipWhenDisabled,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPermission) {
      return child;
    }

    if (showDisabledInsteadOfHiding) {
      Widget disabledChild = IgnorePointer(
        child: Opacity(
          opacity: 0.45,
          child: child,
        ),
      );

      if (tooltipWhenDisabled != null && tooltipWhenDisabled!.isNotEmpty) {
        return Tooltip(
          message: tooltipWhenDisabled!,
          child: disabledChild,
        );
      }

      return disabledChild;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
