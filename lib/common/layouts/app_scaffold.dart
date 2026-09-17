import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_app_bar.dart';
import 'app_sidebar.dart';
import 'app_bottom_navigation.dart';

/// Master Responsive Scaffold for MYBIKE ERP
class AppScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final String activeNavigationId;
  final ValueChanged<String>? onNavigationChanged;
  final Widget? floatingActionButton;
  final bool showBottomNavOnMobile;
  final bool showSidebarOnDesktop;
  final String currentShowroomName;
  final VoidCallback? onShowroomSwitchTap;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.activeNavigationId = 'dashboard',
    this.onNavigationChanged,
    this.floatingActionButton,
    this.showBottomNavOnMobile = true,
    this.showSidebarOnDesktop = true,
    this.currentShowroomName = 'Central Showroom',
    this.onShowroomSwitchTap,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _currentNavId;

  @override
  void initState() {
    super.initState();
    _currentNavId = widget.activeNavigationId;
  }

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeNavigationId != oldWidget.activeNavigationId) {
      _currentNavId = widget.activeNavigationId;
    }
  }

  void _handleNavigation(String id) {
    setState(() {
      _currentNavId = id;
    });
    widget.onNavigationChanged?.call(id);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final isDark = context.isDarkMode;

    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final appBar = AppAppBar(
      title: widget.title,
      titleWidget: widget.titleWidget,
      actions: widget.actions,
      currentShowroomName: widget.currentShowroomName,
      onShowroomSwitchTap: widget.onShowroomSwitchTap,
      onMenuTap: !isDesktop ? () => _scaffoldKey.currentState?.openDrawer() : null,
    );

    // Desktop Layout (Sidebar + Top App Bar + Main Content)
    if (isDesktop && widget.showSidebarOnDesktop) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            AppSidebar(
              activeItemId: _currentNavId,
              onItemTap: _handleNavigation,
            ),
            Expanded(
              child: Column(
                children: [
                  appBar,
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      );
    }

    // Tablet Layout (Collapsible sidebar or drawer)
    if (isTablet && widget.showSidebarOnDesktop) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            AppSidebar(
              activeItemId: _currentNavId,
              onItemTap: _handleNavigation,
              initialCollapsed: true,
            ),
            Expanded(
              child: Column(
                children: [
                  appBar,
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      );
    }

    // Mobile Layout (Drawer + Top App Bar + Body + Bottom Nav)
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: Drawer(
        child: AppSidebar(
          activeItemId: _currentNavId,
          onItemTap: _handleNavigation,
        ),
      ),
      body: widget.body,
      bottomNavigationBar: widget.showBottomNavOnMobile
          ? AppBottomNavigation(
              activeId: _currentNavId,
              onTabSelected: _handleNavigation,
            )
          : null,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
