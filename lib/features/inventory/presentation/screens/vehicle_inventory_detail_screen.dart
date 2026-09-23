import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../../domain/entities/vehicle_inventory_item.dart';
import '../cubit/vehicle_inventory_detail_cubit.dart';
import '../cubit/vehicle_inventory_detail_state.dart';

/// Detailed Vehicle Unit (VIN) Dossier Screen
class VehicleInventoryDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleInventoryDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleInventoryDetailScreen> createState() => _VehicleInventoryDetailScreenState();
}

class _VehicleInventoryDetailScreenState extends State<VehicleInventoryDetailScreen> {
  late final VehicleInventoryDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = VehicleInventoryDetailCubit(vehicleId: widget.vehicleId)..loadDetails();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatInr(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AppScaffold(
        activeNavigationId: 'inventory',
        currentShowroomName: 'VIN Dossier',
        title: 'Vehicle Unit Dossier',
        body: BlocConsumer<VehicleInventoryDetailCubit, VehicleInventoryDetailState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              context.showErrorSnackBar(state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.status == VehicleInventoryDetailStatus.loading && state.item == null) {
              return const AppPageLoader(message: 'Loading vehicle dossier & lifecycle history...');
            }

            if (state.status == VehicleInventoryDetailStatus.failure && state.item == null) {
              return AppErrorState(
                title: 'Vehicle Not Found',
                message: state.errorMessage ?? 'Unable to find vehicle unit in inventory',
                onRetry: () => _cubit.loadDetails(),
              );
            }

            final item = state.item;
            if (item == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: ResponsiveUtils.contentPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, item),
                  const SizedBox(height: AppDimensions.spacing20),

                  // Main Content Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Serialized Coordinates & Inspection
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildIdentifiersCard(context, item),
                            const SizedBox(height: AppDimensions.spacing16),
                            _buildPdiCard(context, item),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing16),

                      // Right Column: Showroom Location & Lifecycle Movement Timeline
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildLocationCard(context, item),
                            const SizedBox(height: AppDimensions.spacing16),
                            _buildTimelineCard(context, state.movements),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VehicleInventoryItem item) {
    final isDark = context.isDarkMode;
    final v = item.vehicle;
    final isEv = item.isElectric;

    Color statusColor;
    switch (v.status) {
      case 'in_stock':
        statusColor = const Color(0xFF10B981);
        break;
      case 'booked':
      case 'allocated':
        statusColor = const Color(0xFF3B82F6);
        break;
      case 'in_transit':
        statusColor = const Color(0xFFF59E0B);
        break;
      default:
        statusColor = Colors.grey;
    }

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Center(
              child: Icon(
                isEv ? Icons.electric_bolt_rounded : Icons.two_wheeler_rounded,
                size: 30,
                color: isEv ? const Color(0xFF10B981) : AppColors.primaryYellowDark,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      v.vin,
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      tooltip: 'Copy VIN',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: v.vin));
                        context.showSuccessSnackBar('VIN copied to clipboard');
                      },
                    ),
                    const SizedBox(width: 8),
                    AppStatusBadge(
                      label: v.status.replaceAll('_', ' ').toUpperCase(),
                      color: statusColor,
                    ),
                  ],
                ),
                Text(
                  '${item.displayName} • ${item.color?.name ?? "N/A"}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          AppButton.secondary(
            label: 'Back to Inventory',
            leadingIcon: Icons.arrow_back_rounded,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifiersCard(BuildContext context, VehicleInventoryItem item) {
    final v = item.vehicle;
    final isEv = item.isElectric;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fingerprint_rounded, size: 20, color: AppColors.primaryYellowDark),
              const SizedBox(width: 8),
              Text(
                'Serialized Asset Identification',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),

          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  'Chassis / VIN Number',
                  v.vin,
                  isMonospace: true,
                ),
              ),
              Expanded(
                child: _buildDetailRow(
                  'Physical Key Tag',
                  v.keyNumber ?? 'Not Assigned',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),

          if (isEv) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    'Electric Motor Serial',
                    v.motorNumber ?? 'N/A',
                    isMonospace: true,
                  ),
                ),
                Expanded(
                  child: _buildDetailRow(
                    'Battery Serial Number',
                    v.batterySerialNumber ?? 'N/A',
                    isMonospace: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    'Battery Health Status',
                    '${v.batteryHealthPercentage?.toStringAsFixed(1) ?? "100.0"}% Health',
                  ),
                ),
                Expanded(
                  child: _buildDetailRow(
                    'Odometer Reading',
                    '${v.odometerReadingKm} km',
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    'Engine Serial Number',
                    v.engineNumber ?? 'N/A',
                    isMonospace: true,
                  ),
                ),
                Expanded(
                  child: _buildDetailRow(
                    'Odometer Reading',
                    '${v.odometerReadingKm} km',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.spacing12),

          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  'Dealer Purchase Cost',
                  _formatInr(v.purchaseCost),
                ),
              ),
              Expanded(
                child: _buildDetailRow(
                  'Mfg Month / Year',
                  v.mfgYearMonth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdiCard(BuildContext context, VehicleInventoryItem item) {
    final isDark = context.isDarkMode;
    final v = item.vehicle;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.fact_check_outlined, size: 20, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    'Pre-Delivery Inspection (PDI)',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              AppStatusBadge(
                label: v.pdiStatus == 'passed' ? 'PDI PASSED' : (v.pdiStatus == 'failed' ? 'PDI FAILED' : 'PDI PENDING'),
                color: v.pdiStatus == 'passed' ? const Color(0xFF10B981) : (v.pdiStatus == 'failed' ? AppColors.error : const Color(0xFFF59E0B)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),

          Text(
            v.pdiNotes ?? 'No technician notes recorded for this unit.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          Align(
            alignment: Alignment.centerRight,
            child: AppButton.secondary(
              label: 'Update PDI Status',
              leadingIcon: Icons.edit_note_rounded,
              onPressed: () => _showPdiModal(context, v.pdiStatus, v.pdiNotes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, VehicleInventoryItem item) {
    final v = item.vehicle;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 20, color: AppColors.primaryYellowDark),
                  const SizedBox(width: 8),
                  Text(
                    'Showroom & Storage Bay',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_location_alt_outlined, size: 20),
                tooltip: 'Relocate Bay',
                onPressed: () => _showRelocateModal(context, v.locationInShowroom),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),

          _buildDetailRow('Assigned Showroom', item.showroom?.name ?? 'Branch N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Physical Bay / Position', v.locationInShowroom),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, List<StockMovementEntity> movements) {
    final isDark = context.isDarkMode;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Lifecycle & Movement Audit Log',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),

          if (movements.isEmpty)
            const Text('No movement logs recorded yet.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movements.length,
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final m = movements[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_checked_rounded, size: 14, color: AppColors.primaryYellowDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.displayTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          if (m.remarks != null) ...[
                            const SizedBox(height: 2),
                            Text(m.remarks!, style: AppTypography.captionSmall.copyWith(color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText)),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false}) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontFamily: isMonospace ? 'monospace' : null,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
          ),
        ),
      ],
    );
  }

  void _showPdiModal(BuildContext context, String currentStatus, String? currentNotes) {
    String selectedStatus = currentStatus;
    final notesController = TextEditingController(text: currentNotes ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return AlertDialog(
            title: const Text('Update Pre-Delivery Inspection (PDI)'),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDropdown<String>(
                    label: 'PDI Inspection Status',
                    value: selectedStatus,
                    items: const ['passed', 'pending', 'failed'],
                    itemLabel: (s) => s.toUpperCase(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Technician Inspection Notes',
                    hint: 'Details of battery charge, brake checks, fluids, tyre pressure...',
                    controller: notesController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
              AppButton.primary(
                label: 'Save Inspection',
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  await _cubit.updatePdi(selectedStatus, notes: notesController.text.trim());
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRelocateModal(BuildContext context, String currentLocation) {
    final locationController = TextEditingController(text: currentLocation);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Relocate Showroom Bay'),
        content: SizedBox(
          width: 400,
          child: AppTextField(
            label: 'New Bay Location',
            hint: 'e.g. Display Floor Bay A1, Stockyard Bay 4',
            controller: locationController,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          AppButton.primary(
            label: 'Save Location',
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await _cubit.updateLocation(locationController.text.trim());
            },
          ),
        ],
      ),
    );
  }
}
