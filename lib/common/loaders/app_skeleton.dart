import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';
import '../widgets/app_responsive_grid.dart';
import 'app_shimmer.dart';

/// Placeholder shapes for a screen whose data has not arrived yet.
///
/// The same moment used to be drawn three different ways — a bare
/// `CircularProgressIndicator` in some screens, an `AppLoading` spinner in
/// others, an `AppPageLoader` card in the rest. These builders replace all
/// three with one language: light bones sitting on real card chrome, swept by
/// a single [AppShimmer] per section.
///
/// Each composite already carries the page's own scroll view and padding, so a
/// call site is only `body: AppSkeleton.dashboard()`.
abstract final class AppSkeleton {
  /// A card-sized section: real chrome, shimmering bones inside.
  ///
  /// The chrome sits outside the [AppShimmer] so only the bones sweep, and so
  /// the section keeps the page's card colour instead of flashing a gradient
  /// across its whole surface.
  static Widget card(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppDimensions.borderWidth,
        ),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
      ),
      child: AppShimmer(child: child),
    );
  }

  /// A strip of KPI-card placeholders.
  ///
  /// Laid out on the same responsive grid the real cards use, so the strip
  /// keeps its column count when the values land instead of reflowing.
  static Widget kpiGrid({int count = 4, double minItemWidth = 210}) {
    return AppResponsiveGrid(
      minItemWidth: minItemWidth,
      children: [for (var i = 0; i < count; i++) AppShimmer.statCard()],
    );
  }

  /// KPI strip over a table — what most dashboard screens settle into.
  static Widget dashboard({int kpis = 4, int rows = 6, int columns = 5}) {
    return Builder(
      builder: (context) => _page(context, [
        if (kpis > 0) kpiGrid(count: kpis),
        _tableCard(context, rows: rows, columns: columns),
      ]),
    );
  }

  /// A stack of record placeholders, optionally under a KPI strip.
  static Widget list({int kpis = 0, int rows = 7}) {
    return Builder(
      builder: (context) => _page(context, [
        if (kpis > 0) kpiGrid(count: kpis),
        _listCard(context, rows: rows),
      ]),
    );
  }

  /// A table card, optionally under a KPI strip.
  static Widget table({int kpis = 0, int rows = 6, int columns = 5}) {
    return Builder(
      builder: (context) => _page(context, [
        if (kpis > 0) kpiGrid(count: kpis),
        _tableCard(context, rows: rows, columns: columns),
      ]),
    );
  }

  /// Input placeholders: [sections] cards of [fields] labelled rows each.
  static Widget form({int sections = 2, int fields = 4}) {
    return Builder(
      builder: (context) => _page(context, [
        for (var i = 0; i < sections; i++) _formCard(context, fields: fields),
      ]),
    );
  }

  /// A record header — avatar, title, chips — over its tabular details.
  static Widget detail({int kpis = 0, int rows = 5, int columns = 4}) {
    return Builder(
      builder: (context) => _page(context, [
        if (kpis > 0) kpiGrid(count: kpis),
        _headerCard(context),
        _tableCard(context, rows: rows, columns: columns),
      ]),
    );
  }

  /// The page's own scroll view and padding, so every skeleton fits a phone
  /// without overflowing its body.
  static Widget _page(BuildContext context, List<Widget> sections) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        context.isMobile ? AppDimensions.spacing16 : AppDimensions.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimensions.spacing20),
            sections[i],
          ],
        ],
      ),
    );
  }

  static Widget _tableCard(
    BuildContext context, {
    required int rows,
    required int columns,
  }) {
    Widget row(int index, {required bool isHeader}) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing14,
        ),
        child: Row(
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                // The first column stands in for a code or a name, which the
                // real tables give the most room.
                flex: c == 0 ? 3 : 2,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  // Ragged widths, so the placeholder reads as a table of
                  // differing values rather than a stack of identical bars.
                  widthFactor: isHeader ? 0.4 : 0.45 + ((index + c) % 3) * 0.18,
                  child: AppShimmerBone(height: isHeader ? 10 : 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return card(
      context,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          row(0, isHeader: true),
          for (var i = 0; i < rows; i++) row(i, isHeader: false),
        ],
      ),
    );
  }

  static Widget _listCard(BuildContext context, {required int rows}) {
    return card(
      context,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing12,
              ),
              child: Row(
                children: [
                  const AppShimmerBone(
                    width: AppDimensions.avatarMd,
                    height: AppDimensions.avatarMd,
                    radius: AppDimensions.radiusMd,
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.62 + (i % 3) * 0.12,
                          child: const AppShimmerBone(height: 13),
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.3 + (i % 2) * 0.14,
                          child: const AppShimmerBone(height: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  const AppShimmerBone(width: 64, height: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget _formCard(BuildContext context, {required int fields}) {
    return card(
      context,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < fields; i++) ...[
            if (i > 0) const SizedBox(height: AppDimensions.spacing20),
            const FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.22,
              child: AppShimmerBone(height: 10),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            const AppShimmerBone(
              height: AppDimensions.inputHeight,
              radius: AppDimensions.radiusMd,
            ),
          ],
        ],
      ),
    );
  }

  static Widget _headerCard(BuildContext context) {
    return card(
      context,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Row(
        children: [
          const AppShimmerBone(
            width: AppDimensions.avatarLg,
            height: AppDimensions.avatarLg,
            radius: AppDimensions.radiusFull,
          ),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.42,
                  child: AppShimmerBone(height: 18),
                ),
                const SizedBox(height: AppDimensions.spacing10),
                const FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.66,
                  child: AppShimmerBone(height: 12),
                ),
                const SizedBox(height: AppDimensions.spacing10),
                Row(
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      if (i > 0) const SizedBox(width: AppDimensions.spacing8),
                      const AppShimmerBone(
                        width: 72,
                        height: 20,
                        radius: AppDimensions.radiusFull,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
