import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Dashboard Screen — Placeholder
///
/// Displays a basic shell to verify:
/// - Theme (light/dark) switching works
/// - Responsive layout adapts to screen size
/// - Navigation and routing are functional
///
/// Full dashboard will be built in Phase 15.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(
                Icons.two_wheeler_rounded,
                size: 18,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            const Text('MYBIKE'),
          ],
        ),
        actions: [
          // ─── Theme Toggle ───
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.contentPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Welcome Header ───
              Text(
                'Welcome to MYBIKE',
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                'Dealership Management & Accounting ERP',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),

              // ─── Info Cards ───
              _buildInfoCard(
                context,
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                title: 'Phase 1 Complete',
                subtitle:
                    'Flutter project foundation, theme, routing, and responsive layout are set up.',
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // ─── Device Info ───
              _buildInfoCard(
                context,
                icon: Icons.devices_rounded,
                color: AppColors.info,
                title: 'Device Type: ${context.deviceType.name.toUpperCase()}',
                subtitle:
                    'Screen: ${context.screenWidth.toInt()}×${context.screenHeight.toInt()}px',
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // ─── Theme Info ───
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  return _buildInfoCard(
                    context,
                    icon: Icons.palette_rounded,
                    color: AppColors.primaryYellow,
                    title: 'Theme: ${state.themeMode.name.toUpperCase()}',
                    subtitle:
                        'Current brightness: ${context.isDarkMode ? "Dark" : "Light"}',
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spacing32),

              // ─── Placeholder Grid ───
              Text(
                'Dashboard Preview',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _buildStatGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconLg),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall),
                  const SizedBox(height: AppDimensions.spacing2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.gridCrossAxisCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    final stats = [
      _StatData('Total Sales', '₹0', Icons.trending_up_rounded, AppColors.success),
      _StatData('Stock', '0', Icons.inventory_2_rounded, AppColors.info),
      _StatData('Receivable', '₹0', Icons.account_balance_wallet_rounded, AppColors.warning),
      _StatData('Payable', '₹0', Icons.receipt_long_rounded, AppColors.error),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimensions.spacing12,
        mainAxisSpacing: AppDimensions.spacing12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stat.label,
                        style: AppTypography.labelMedium.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      stat.icon,
                      size: AppDimensions.iconMd,
                      color: stat.color,
                    ),
                  ],
                ),
                Text(
                  stat.value,
                  style: AppTypography.currencyMedium.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatData(this.label, this.value, this.icon, this.color);
}
