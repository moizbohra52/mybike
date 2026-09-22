import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Navigation Tab Item Model
class AppBottomNavItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppBottomNavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Mobile Bottom Navigation Bar for MYBIKE ERP
class AppBottomNavigation extends StatelessWidget {
  final String activeId;
  final ValueChanged<String> onTabSelected;

  const AppBottomNavigation({
    super.key,
    required this.activeId,
    required this.onTabSelected,
  });

  static const List<AppBottomNavItem> defaultItems = [
    AppBottomNavItem(
      id: 'dashboard',
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    AppBottomNavItem(
      id: 'inventory',
      label: 'Stock',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    ),
    AppBottomNavItem(
      id: 'sales',
      label: 'Sales',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    AppBottomNavItem(
      id: 'accounts',
      label: 'Accounts',
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
    ),
    AppBottomNavItem(
      id: 'more',
      label: 'More',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: AppDimensions.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: defaultItems.map((item) {
            final isActive = activeId == item.id;
            final color = isActive
                ? (isDark ? AppColors.primaryYellowLight : AppColors.primaryYellowDark)
                : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText);

            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(item.id),
                splashColor: AppColors.primaryYellow.withValues(alpha: 0.1),
                highlightColor: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: color,
                      size: AppDimensions.iconLg,
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      item.label,
                      style: AppTypography.captionSmall.copyWith(
                        color: color,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
}
