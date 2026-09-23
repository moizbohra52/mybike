import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_dimensions.dart';

/// Lays form fields out side by side on tablet/desktop and stacks them
/// vertically on mobile.
///
/// Two half-width fields on a phone end up around 150px each — too narrow for
/// dropdowns, dates and currency inputs to be readable. Stacking them keeps
/// every field full width without touching the wide-screen layout.
class ResponsiveFieldRow extends StatelessWidget {
  final List<Widget> children;

  /// Relative widths used only on the wide layout. Defaults to equal widths.
  final List<int>? flexes;
  final double spacing;

  const ResponsiveFieldRow({
    super.key,
    required this.children,
    this.flexes,
    this.spacing = AppDimensions.spacing16,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            children[i],
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            flex: flexes != null && i < flexes!.length ? flexes![i] : 1,
            child: children[i],
          ),
        ],
      ],
    );
  }
}
