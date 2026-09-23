import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';

/// Lays equally-weighted cards out in a grid whose column count follows the
/// available width.
///
/// KPI strips are the main use: five cards in one `Row` look right on a
/// desktop but leave each card around 60px wide on a phone, where the label
/// wraps one character per line and the value clips. This grid drops columns
/// instead — down to a single full-width column — and never overflows.
class AppResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  /// Narrowest a card may get before the grid drops a column.
  final double minItemWidth;
  final double spacing;

  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 200,
    this.spacing = AppDimensions.spacing12,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final columns = available.isFinite
            ? ((available + spacing) ~/ (minItemWidth + spacing))
                .clamp(1, children.length)
                .toInt()
            : 1;

        // Each run is intrinsically sized so cards sharing a row match heights
        // even when one of their titles wraps onto a second line.
        final runs = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final end = (start + columns).clamp(0, children.length).toInt();
          runs.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = start; i < end; i++) ...[
                    if (i > start) SizedBox(width: spacing),
                    Expanded(child: children[i]),
                  ],
                  // Blank cells keep a short final run at grid width instead of
                  // stretching its cards across the whole row.
                  for (var i = end; i < start + columns; i++) ...[
                    SizedBox(width: spacing),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < runs.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              runs[i],
            ],
          ],
        );
      },
    );
  }
}
