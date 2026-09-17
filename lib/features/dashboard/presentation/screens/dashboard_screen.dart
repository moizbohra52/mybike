import 'package:flutter/material.dart';
import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Sample Vehicle Model for DataTable Showcase
class _VehicleItem {
  final String vin;
  final String model;
  final String type;
  final String showroom;
  final num price;
  final String status;

  const _VehicleItem({
    required this.vin,
    required this.model,
    required this.type,
    required this.showroom,
    required this.price,
    required this.status,
  });
}

/// MYBIKE Dashboard & Design System Interactive Showcase
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  int _currentPage = 1;
  int _pageSize = 10;
  DateTime? _selectedDate = DateTime.now();
  String? _selectedShowroom = 'Central Showroom';

  final List<_VehicleItem> _allVehicles = const [
    _VehicleItem(
      vin: 'MB-2026-00192',
      model: 'Honda CB350 H\'ness',
      type: 'Petrol',
      showroom: 'Central Showroom',
      price: 215000,
      status: 'in_stock',
    ),
    _VehicleItem(
      vin: 'MB-2026-00244',
      model: 'Ather 450X Gen 3',
      type: 'EV',
      showroom: 'Central Showroom',
      price: 155000,
      status: 'reserved',
    ),
    _VehicleItem(
      vin: 'MB-2026-00301',
      model: 'TVS Apache RTR 310',
      type: 'Petrol',
      showroom: 'West Showroom',
      price: 242000,
      status: 'sold',
    ),
    _VehicleItem(
      vin: 'MB-2026-00412',
      model: 'Ola S1 Pro Gen 2',
      type: 'EV',
      showroom: 'Central Showroom',
      price: 147500,
      status: 'in_transit',
    ),
    _VehicleItem(
      vin: 'MB-2026-00588',
      model: 'Royal Enfield Hunter 350',
      type: 'Petrol',
      showroom: 'North Showroom',
      price: 173000,
      status: 'in_stock',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppScaffold(
      activeNavigationId: 'dashboard',
      currentShowroomName: _selectedShowroom ?? 'Central Showroom',
      titleWidget: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryYellow,
        indicatorWeight: 3,
        labelColor: isDark ? AppColors.primaryYellowLight : AppColors.primaryBlack,
        unselectedLabelColor: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        labelStyle: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'Dealership Overview'),
          Tab(text: 'Design System Gallery'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context),
          _buildDesignSystemGalleryTab(context),
        ],
      ),
    );
  }

  // ─── TAB 1: DEALERSHIP OVERVIEW ───
  Widget _buildOverviewTab(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.gridCrossAxisCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 4,
    );

    final filteredVehicles = _allVehicles.where((v) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesVin = v.vin.toLowerCase().contains(q);
        final matchesModel = v.model.toLowerCase().contains(q);
        if (!matchesVin && !matchesModel) return false;
      }
      if (_selectedCategory == 'petrol' && v.type != 'Petrol') return false;
      if (_selectedCategory == 'ev' && v.type != 'EV') return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: ResponsiveUtils.contentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          AppSectionHeader(
            title: 'Showroom Performance',
            subtitle: 'Real-time overview of current showroom sales, stock, and bookings',
            trailing: AppButton.primary(
              label: 'New Booking',
              leadingIcon: Icons.add_rounded,
              onPressed: () {
                AppInfoDialog.show(
                  context,
                  title: 'New Booking Flow',
                  message: 'Booking wizard will be integrated in Phase 11.',
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),

          // Stat Cards Grid
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimensions.spacing16,
            mainAxisSpacing: AppDimensions.spacing16,
            childAspectRatio: context.isDesktop ? 1.8 : (context.isTablet ? 1.7 : 2.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              AppStatCard(
                title: 'Total Monthly Sales',
                value: '₹ 24.85 L',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.success,
                changePercentage: '+18.4%',
                isPositiveChange: true,
              ),
              AppStatCard(
                title: 'Vehicles In Stock',
                value: '52 Units',
                icon: Icons.two_wheeler_rounded,
                iconColor: AppColors.primaryYellow,
                changePercentage: '-4 units',
                isPositiveChange: false,
                comparisonPeriod: 'vs last week',
              ),
              AppStatCard(
                title: 'Active Bookings',
                value: '14 Orders',
                icon: Icons.bookmark_added_rounded,
                iconColor: AppColors.info,
                changePercentage: '+5 today',
                isPositiveChange: true,
              ),
              AppStatCard(
                title: 'Receivables Due',
                value: '₹ 3.40 L',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.warning,
                changePercentage: '7 overdue',
                isPositiveChange: false,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing32),

          // Filter and Search Toolbar
          AppDashboardCard(
            title: 'Live Inventory Tracking',
            subtitle: 'VIN/Chassis level vehicle stock status in this showroom',
            headerAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSearchField(
                  hint: 'Search VIN or Model...',
                  width: context.isMobile ? 160 : 260,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFilter<String>(
                  selectedValue: _selectedCategory,
                  options: const [
                    AppFilterOption(label: 'All Vehicles', value: 'all', count: 5),
                    AppFilterOption(label: 'Petrol Bikes', value: 'petrol', count: 3, icon: Icons.local_gas_station_rounded),
                    AppFilterOption(label: 'Electric Scooters', value: 'ev', count: 2, icon: Icons.electric_bolt_rounded),
                  ],
                  onSelected: (val) => setState(() => _selectedCategory = val),
                  onClear: () => setState(() => _selectedCategory = 'all'),
                ),
                const SizedBox(height: AppDimensions.spacing16),

                // Responsive Table
                AppDataTable<_VehicleItem>(
                  minWidth: 700,
                  columns: [
                    AppDataColumn<_VehicleItem>(
                      title: 'VIN / Chassis',
                      flex: 2,
                      cellBuilder: (context, item) => Text(
                        item.vin,
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    AppDataColumn<_VehicleItem>(
                      title: 'Brand & Model',
                      flex: 3,
                      cellBuilder: (context, item) => Row(
                        children: [
                          Icon(
                            item.type == 'EV' ? Icons.electric_bolt_rounded : Icons.two_wheeler_rounded,
                            size: 16,
                            color: item.type == 'EV' ? const Color(0xFF06B6D4) : AppColors.primaryYellow,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Expanded(
                            child: Text(
                              item.model,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppDataColumn<_VehicleItem>(
                      title: 'Ex-Showroom',
                      flex: 2,
                      cellBuilder: (context, item) => AppCurrencyText(
                        amount: item.price,
                        size: AppCurrencySize.small,
                      ),
                    ),
                    AppDataColumn<_VehicleItem>(
                      title: 'Status',
                      flex: 2,
                      cellBuilder: (context, item) => AppStatusBadge.fromStatus(item.status),
                    ),
                    AppDataColumn<_VehicleItem>(
                      title: 'Action',
                      flex: 1,
                      cellBuilder: (context, item) => IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: AppDimensions.iconSm),
                        tooltip: 'Options',
                        onPressed: () {
                          context.showSnackBar('Viewing details for ${item.model} (${item.vin})');
                        },
                      ),
                    ),
                  ],
                  items: filteredVehicles,
                ),

                const SizedBox(height: AppDimensions.spacing16),
                AppPagination(
                  currentPage: _currentPage,
                  totalPages: 1,
                  totalRecords: filteredVehicles.length,
                  pageSize: _pageSize,
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  onPageSizeChanged: (s) => setState(() => _pageSize = s),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing40),
        ],
      ),
    );
  }

  // ─── TAB 2: DESIGN SYSTEM GALLERY ───
  Widget _buildDesignSystemGalleryTab(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.contentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'MYBIKE Component Library',
            subtitle: 'Comprehensive gallery of all Phase 2 widgets, buttons, inputs, dialogs, and states',
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // 1. Buttons Showcase
          AppCard(
            title: 'Buttons & Actions',
            subtitle: 'Primary, Secondary, Danger, Ghost, Outlined, and Loading States',
            child: Wrap(
              spacing: AppDimensions.spacing16,
              runSpacing: AppDimensions.spacing16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton.primary(
                  label: 'Primary Button',
                  leadingIcon: Icons.check_rounded,
                  onPressed: () => context.showSuccessSnackBar('Primary action triggered!'),
                ),
                AppButton.secondary(
                  label: 'Secondary Button',
                  leadingIcon: Icons.folder_open_rounded,
                  onPressed: () => context.showSnackBar('Secondary action clicked'),
                ),
                AppButton.danger(
                  label: 'Danger Action',
                  leadingIcon: Icons.delete_outline_rounded,
                  onPressed: () => context.showErrorSnackBar('Destructive action triggered'),
                ),
                AppButton.ghost(
                  label: 'Ghost Button',
                  leadingIcon: Icons.arrow_forward_rounded,
                  onPressed: () {},
                ),
                const AppOutlinedButton(
                  label: 'Outlined Button',
                  leadingIcon: Icons.filter_list_rounded,
                ),
                const AppButton.primary(
                  label: 'Loading State',
                  isLoading: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // 2. Form Inputs Showcase
          AppCard(
            title: 'Form Inputs & Selectors',
            subtitle: 'Text fields, password visibility, dropdowns, and date pickers',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Customer Name',
                        hint: 'e.g. Rajesh Kumar',
                        isRequired: true,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(
                      child: AppTextField(
                        label: 'Master Security PIN / Password',
                        hint: 'Enter password',
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Showroom Assignment',
                        isRequired: true,
                        value: _selectedShowroom,
                        items: const ['Central Showroom', 'West Showroom', 'North Showroom'],
                        onChanged: (val) => setState(() => _selectedShowroom = val),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(
                      child: AppDatePicker(
                        label: 'Invoice Date',
                        value: _selectedDate,
                        onChanged: (d) => setState(() => _selectedDate = d),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // 3. Status Badges & Currency
          AppCard(
            title: 'Status Badges & Currency Tokens',
            subtitle: 'Color-coded semantic statuses and Indian Rupee ₹ formatters',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimensions.spacing12,
                  runSpacing: AppDimensions.spacing12,
                  children: [
                    AppStatusBadge.fromStatus('in_stock'),
                    AppStatusBadge.fromStatus('reserved'),
                    AppStatusBadge.fromStatus('sold'),
                    AppStatusBadge.fromStatus('in_transit'),
                    AppStatusBadge.fromStatus('damaged'),
                    AppStatusBadge.fromStatus('approved'),
                    AppStatusBadge.fromStatus('pending'),
                    AppStatusBadge.fromStatus('cancelled'),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing20),
                const Divider(),
                const SizedBox(height: AppDimensions.spacing12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Column(
                      children: [
                        Text('Standard Currency', style: AppTypography.captionMedium),
                        SizedBox(height: 4),
                        AppCurrencyText(amount: 145000, size: AppCurrencySize.large),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Compact Lakhs (L)', style: AppTypography.captionMedium),
                        SizedBox(height: 4),
                        AppCurrencyText.compact(amount: 1250000, size: AppCurrencySize.large),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Compact Crores (Cr)', style: AppTypography.captionMedium),
                        SizedBox(height: 4),
                        AppCurrencyText.compact(amount: 45000000, size: AppCurrencySize.large),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // 4. Dialog Triggers Showcase
          AppCard(
            title: 'Dialogs & Modals',
            subtitle: 'Interactive trigger for Confirmation and Information modals',
            child: Wrap(
              spacing: AppDimensions.spacing16,
              runSpacing: AppDimensions.spacing16,
              children: [
                AppButton.secondary(
                  label: 'Launch Info Dialog',
                  leadingIcon: Icons.info_outline_rounded,
                  onPressed: () {
                    AppInfoDialog.show(
                      context,
                      title: 'Showroom Synchronization',
                      message: 'All inventory changes are synced in real-time across all dealerships.',
                    );
                  },
                ),
                AppButton.danger(
                  label: 'Launch Destructive Confirm',
                  leadingIcon: Icons.warning_amber_rounded,
                  onPressed: () async {
                    final confirmed = await AppConfirmDialog.show(
                      context,
                      title: 'Cancel Vehicle Booking?',
                      message: 'Are you sure you want to cancel booking #BK-9021? This will release the bike back to available inventory.',
                      isDestructive: true,
                      confirmText: 'Yes, Cancel Booking',
                    );
                    if (context.mounted && (confirmed ?? false)) {
                      context.showErrorSnackBar('Booking #BK-9021 cancelled.');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // 5. Loaders & Shimmer
          const AppCard(
            title: 'Loaders & Shimmer Skeletons',
            subtitle: 'Smooth 60fps hardware-accelerated animated gradient sweep',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppLoading.small(message: 'Loading records...'),
                    AppLoading(message: 'Synchronizing...'),
                    AppLoading.large(message: 'Processing invoice...'),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing24),
                Divider(),
                SizedBox(height: AppDimensions.spacing16),
                AppShimmer(
                  child: Row(
                    children: [
                      Expanded(child: AppShimmer(child: SizedBox(height: 50))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing40),
        ],
      ),
    );
  }
}
