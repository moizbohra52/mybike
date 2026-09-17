import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Navigation Item Model
class AppSidebarItem {
  final String id;
  final String title;
  final IconData icon;
  final String? badge;

  const AppSidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    this.badge,
  });
}

/// Navigation Group Model
class AppSidebarGroup {
  final String? groupTitle;
  final List<AppSidebarItem> items;

  const AppSidebarGroup({
    this.groupTitle,
    required this.items,
  });
}

/// Collapsible ERP Navigation Sidebar
class AppSidebar extends StatefulWidget {
  final String activeItemId;
  final ValueChanged<String> onItemTap;
  final bool initialCollapsed;
  final ValueChanged<bool>? onCollapseChanged;

  const AppSidebar({
    super.key,
    required this.activeItemId,
    required this.onItemTap,
    this.initialCollapsed = false,
    this.onCollapseChanged,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initialCollapsed;
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    widget.onCollapseChanged?.call(_isCollapsed);
  }

  List<AppSidebarGroup> _getNavigationGroups() {
    return const [
      AppSidebarGroup(
        items: [
          AppSidebarItem(id: 'dashboard', title: 'Dashboard', icon: Icons.dashboard_outlined),
        ],
      ),
      AppSidebarGroup(
        groupTitle: 'MASTER DATA',
        items: [
          AppSidebarItem(id: 'showrooms', title: 'Showrooms', icon: Icons.storefront_outlined),
          AppSidebarItem(id: 'vehicles', title: 'Vehicles', icon: Icons.two_wheeler_outlined),
          AppSidebarItem(id: 'customers', title: 'Customers', icon: Icons.people_outline_rounded),
          AppSidebarItem(id: 'suppliers', title: 'Suppliers', icon: Icons.local_shipping_outlined),
        ],
      ),
      AppSidebarGroup(
        groupTitle: 'OPERATIONS',
        items: [
          AppSidebarItem(id: 'inventory', title: 'Inventory & Stock', icon: Icons.inventory_2_outlined),
          AppSidebarItem(id: 'purchases', title: 'Purchases', icon: Icons.shopping_bag_outlined),
          AppSidebarItem(id: 'sales', title: 'Sales & Invoices', icon: Icons.receipt_long_outlined),
          AppSidebarItem(id: 'bookings', title: 'Bookings', icon: Icons.bookmark_border_rounded, badge: 'NEW'),
        ],
      ),
      AppSidebarGroup(
        groupTitle: 'ACCOUNTING & FINANCE',
        items: [
          AppSidebarItem(id: 'accounts', title: 'Chart of Accounts', icon: Icons.account_balance_outlined),
          AppSidebarItem(id: 'expenses', title: 'Expenses', icon: Icons.payments_outlined),
          AppSidebarItem(id: 'gst', title: 'GST & Tax', icon: Icons.calculate_outlined),
        ],
      ),
      AppSidebarGroup(
        groupTitle: 'ANALYTICS',
        items: [
          AppSidebarItem(id: 'reports', title: 'Reports & Export', icon: Icons.bar_chart_rounded),
        ],
      ),
      AppSidebarGroup(
        groupTitle: 'SYSTEM',
        items: [
          AppSidebarItem(id: 'users', title: 'Users & Roles', icon: Icons.admin_panel_settings_outlined),
          AppSidebarItem(id: 'settings', title: 'Settings', icon: Icons.settings_outlined),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final groups = _getNavigationGroups();

    final width = _isCollapsed
        ? AppDimensions.sidebarWidthCollapsed
        : AppDimensions.sidebarWidthExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: AppDimensions.borderWidth,
          ),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header (Logo)
          Container(
            height: AppDimensions.appBarHeight,
            padding: EdgeInsets.symmetric(
              horizontal: _isCollapsed ? AppDimensions.spacing16 : AppDimensions.spacing20,
            ),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: AppDimensions.borderWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.two_wheeler_rounded,
                      color: AppColors.primaryBlack,
                      size: 22,
                    ),
                  ),
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: AppDimensions.spacing12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MYBIKE',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      Text(
                        'DEALERSHIP ERP',
                        style: AppTypography.overline.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryYellowLight : AppColors.primaryYellowDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Sidebar Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing12),
              itemCount: groups.length,
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isCollapsed && group.groupTitle != null) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.spacing20,
                          AppDimensions.spacing16,
                          AppDimensions.spacing16,
                          AppDimensions.spacing6,
                        ),
                        child: Text(
                          group.groupTitle!,
                          style: AppTypography.overline.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ] else if (_isCollapsed && group.groupTitle != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
                        child: Divider(
                          height: 1,
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                      ),
                    ],
                    ...group.items.map((item) {
                      final isActive = widget.activeItemId == item.id;

                      return Tooltip(
                        message: _isCollapsed ? item.title : '',
                        preferBelow: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing10,
                            vertical: AppDimensions.spacing2,
                          ),
                          child: InkWell(
                            onTap: () => widget.onItemTap(item.id),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(
                                horizontal: _isCollapsed ? AppDimensions.spacing14 : AppDimensions.spacing14,
                                vertical: AppDimensions.spacing10,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? (isDark
                                        ? AppColors.primaryYellow.withValues(alpha: 0.15)
                                        : AppColors.primaryYellow.withValues(alpha: 0.2))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                border: Border(
                                  left: isActive
                                      ? BorderSide(
                                          color: AppColors.primaryYellow,
                                          width: 3,
                                        )
                                      : BorderSide.none,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: AppDimensions.iconMd,
                                    color: isActive
                                        ? (isDark ? AppColors.primaryYellowLight : AppColors.primaryYellowDark)
                                        : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                                  ),
                                  if (!_isCollapsed) ...[
                                    const SizedBox(width: AppDimensions.spacing12),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                          color: isActive
                                              ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                                              : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                                        ),
                                      ),
                                    ),
                                    if (item.badge != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryYellow,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                        ),
                                        child: Text(
                                          item.badge!,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryBlack,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          // Sidebar Footer: Collapse Toggle
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing12),
            child: InkWell(
              onTap: _toggleCollapse,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing8,
                  vertical: AppDimensions.spacing8,
                ),
                child: Row(
                  mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Icon(
                      _isCollapsed ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded,
                      size: AppDimensions.iconMd,
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                    if (!_isCollapsed) ...[
                      const SizedBox(width: AppDimensions.spacing12),
                      Text(
                        'Collapse Menu',
                        style: AppTypography.captionLarge.copyWith(
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
