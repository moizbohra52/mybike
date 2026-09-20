import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/common.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/report_filter_criteria.dart';
import '../cubit/reports_hub_cubit.dart';
import '../cubit/reports_hub_state.dart';

/// Central Enterprise Reports Navigation Hub
class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsHubCubit()..init(),
      child: const _ReportsHubContent(),
    );
  }
}

class _ReportsHubContent extends StatelessWidget {
  const _ReportsHubContent();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppScaffold(
      title: 'Reports & Export Hub',
      activeNavigationId: 'reports',
      body: BlocBuilder<ReportsHubCubit, ReportsHubState>(
        builder: (context, state) {
          final cubit = context.read<ReportsHubCubit>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header & Search ───
                _buildHeader(context, state, cubit, isDark),
                const SizedBox(height: AppDimensions.spacing20),

                // ─── Filter Pills Bar (Categories) ───
                _buildCategoryFilters(state, cubit, isDark),
                const SizedBox(height: AppDimensions.spacing24),

                // ─── Report Catalog Grid ───
                _buildReportGrid(context, state, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ReportsHubState state,
    ReportsHubCubit cubit,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial & Operational Registers',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                '14 statutory, treasury, tax, and inventory statements with multi-branch reconciliation.',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        // Search Input
        SizedBox(
          width: 280,
          child: AppTextField(
            hint: 'Search registers & ledgers...',
            prefixIcon: Icons.search_rounded,
            onChanged: (val) => cubit.searchReports(val),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(
    ReportsHubState state,
    ReportsHubCubit cubit,
    bool isDark,
  ) {
    final categories = [
      {'id': 'all', 'label': 'All Statements (14)'},
      {'id': 'financial', 'label': 'Financial Statements (3)'},
      {'id': 'books', 'label': 'Books & Ledgers (3)'},
      {'id': 'registers', 'label': 'Operational Registers (3)'},
      {'id': 'working_capital', 'label': 'Statutory & Tax (5)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = state.selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                cat['label']!,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryYellow
                      : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                ),
              ),
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              selectedColor: AppColors.primaryYellow.withAlpha(40),
              checkmarkColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryYellow
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              onSelected: (_) => cubit.filterByCategory(cat['id']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportGrid(
    BuildContext context,
    ReportsHubState state,
    bool isDark,
  ) {
    final reports = state.filteredReports;

    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
              const SizedBox(height: 12),
              Text('No reports match "${state.searchQuery}"', style: AppTypography.titleMedium),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimensions.spacing16,
            mainAxisSpacing: AppDimensions.spacing16,
            mainAxisExtent: 160,
          ),
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(context, report, state.criteria, isDark);
          },
        );
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    ReportMetadata report,
    ReportFilterCriteria criteria,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'report-viewer',
          pathParameters: {'reportType': report.id},
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: AppCard(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: report.iconColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(report.icon, color: report.iconColor, size: 22),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.category.toUpperCase().replaceAll('_', ' '),
                        style: AppTypography.captionSmall.copyWith(
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Expanded(
              child: Text(
                report.description,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View Statement',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.table_chart_outlined, size: 14, color: AppColors.primaryYellow),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
