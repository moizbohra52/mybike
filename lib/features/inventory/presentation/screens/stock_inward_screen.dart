import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/inventory_management_service.dart';
import '../cubit/stock_inward_cubit.dart';
import '../cubit/stock_inward_state.dart';

/// Stock Inward (Factory Goods Receipt Note) Screen
class StockInwardScreen extends StatefulWidget {
  const StockInwardScreen({super.key});

  @override
  State<StockInwardScreen> createState() => _StockInwardScreenState();
}

class _StockInwardScreenState extends State<StockInwardScreen> {
  late final StockInwardCubit _cubit;

  // Single unit entry controllers
  final _vinController = TextEditingController();
  final _engineController = TextEditingController();
  final _motorController = TextEditingController();
  final _batteryController = TextEditingController();
  final _keyController = TextEditingController();
  final _costController = TextEditingController();
  final _locationController = TextEditingController(text: 'Main Display Area');
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = StockInwardCubit()..init();
  }

  @override
  void dispose() {
    _cubit.close();
    _vinController.dispose();
    _engineController.dispose();
    _motorController.dispose();
    _batteryController.dispose();
    _keyController.dispose();
    _costController.dispose();
    _locationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _clearUnitInputs() {
    _vinController.clear();
    _engineController.clear();
    _motorController.clear();
    _batteryController.clear();
    _keyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AppScaffold(
        activeNavigationId: 'inventory',
        currentShowroomName: 'Stock Inwarding',
        title: 'Factory Inward (GRN)',
        body: BlocConsumer<StockInwardCubit, StockInwardState>(
          listener: (context, state) {
            if (state.status == StockInwardStatus.success) {
              context.showSuccessSnackBar('Successfully inwarded ${state.units.length} vehicle units into inventory');
              context.pop();
            } else if (state.status == StockInwardStatus.failure && state.errorMessage != null) {
              context.showErrorSnackBar(state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.status == StockInwardStatus.loading) {
              return const AppPageLoader(message: 'Initializing inwarding parameters...');
            }

            final isEv = state.isElectric;
            final catItem = state.currentCatalogItem;

            return SingleChildScrollView(
              padding: ResponsiveUtils.contentPadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionHeader(
                        title: 'Factory Inward & Serialized Unit Registration',
                        subtitle: 'Register newly received batches from factory/OEM by VIN, engine/motor numbers, and key tags',
                      ),
                      const SizedBox(height: AppDimensions.spacing20),

                      // ─── Section 1: Batch Configuration ───
                      AppCard(
                        padding: const EdgeInsets.all(AppDimensions.spacing20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Intake Batch Configuration',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppDimensions.spacing16),

                            ResponsiveFieldRow(
                              children: [
                                // Showroom
                                AppDropdown<String?>(
                                  label: 'Receiving Showroom Branch *',
                                  value: state.selectedShowroomId,
                                  items: state.showrooms.map((s) => s.showroom.id).toList(),
                                  itemLabel: (id) {
                                    final s = state.showrooms.where((sh) => sh.showroom.id == id).firstOrNull;
                                    return s != null ? '${s.showroom.name} (${s.showroom.code})' : 'Select Branch';
                                  },
                                  onChanged: (id) {
                                    if (id != null) _cubit.showroomChanged(id);
                                  },
                                ),
                                // Model
                                AppDropdown<String?>(
                                  label: 'Vehicle Model *',
                                  value: state.selectedModelId,
                                  items: state.catalog.map((c) => c.model.id).toList(),
                                  itemLabel: (id) {
                                    final c = state.catalog.where((cat) => cat.model.id == id).firstOrNull;
                                    return c != null ? '${c.model.name} (${c.model.type.toUpperCase()})' : 'Select Model';
                                  },
                                  onChanged: (id) {
                                    if (id != null) _cubit.modelChanged(id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacing16),

                            ResponsiveFieldRow(
                              children: [
                                // Variant
                                AppDropdown<String?>(
                                  label: 'Variant *',
                                  value: state.selectedVariantId,
                                  items: catItem != null ? catItem.variants.map((v) => v.id).toList() : [],
                                  itemLabel: (id) {
                                    final v = catItem?.variants.where((vr) => vr.id == id).firstOrNull;
                                    return v != null ? '${v.name} (${v.code})' : 'Select Variant';
                                  },
                                  onChanged: (id) {
                                    if (id != null) _cubit.variantChanged(id);
                                  },
                                ),
                                // Color
                                AppDropdown<String?>(
                                  label: 'Color Scheme *',
                                  value: state.selectedColorId,
                                  items: catItem != null ? catItem.colors.map((c) => c.id).toList() : [],
                                  itemLabel: (id) {
                                    final col = catItem?.colors.where((cl) => cl.id == id).firstOrNull;
                                    return col != null ? '${col.name} [${col.code}]' : 'Select Color';
                                  },
                                  onChanged: (id) {
                                    if (id != null) _cubit.colorChanged(id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacing16),

                            AppTextField(
                              label: 'Inward Notes / Supplier Invoice Ref',
                              hint: 'e.g. Received via OEM Factory Dispatch Challan #FC-2026-904',
                              controller: _remarksController,
                              onChanged: (val) => _cubit.remarksChanged(val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing20),

                      // ─── Section 2: Add Serialized Unit Form ───
                      AppCard(
                        padding: const EdgeInsets.all(AppDimensions.spacing20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Add Serialized Unit to Batch',
                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.spacing12),
                                AppStatusBadge(
                                  label: isEv ? 'ELECTRIC EV UNIT' : 'PETROL UNIT',
                                  color: isEv ? const Color(0xFF10B981) : const Color(0xFFF97316),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacing16),

                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: AppTextField(
                                    label: 'VIN / Chassis Number (17 chars) *',
                                    hint: 'e.g. ME4NC5800N8000999',
                                    controller: _vinController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Key Tag Number',
                                    hint: 'e.g. KEY-999',
                                    controller: _keyController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (isEv) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Motor Serial Number',
                                      hint: 'e.g. ATH-MTR-64-999',
                                      controller: _motorController,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Battery Serial Number',
                                      hint: 'e.g. ATH-BAT-37-9999',
                                      controller: _batteryController,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              AppTextField(
                                label: 'Engine Number *',
                                hint: 'e.g. NC58E-1009999',
                                controller: _engineController,
                              ),
                            ],
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Dealer Purchase Cost (INR)',
                                    hint: 'e.g. 175000',
                                    controller: _costController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Location in Showroom',
                                    hint: 'e.g. Display Bay 2, Basement Yard',
                                    controller: _locationController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerRight,
                              child: AppButton.secondary(
                                label: 'Add Unit to Batch',
                                leadingIcon: Icons.playlist_add_rounded,
                                onPressed: () {
                                  final vin = _vinController.text.trim();
                                  if (vin.length < 10) {
                                    context.showErrorSnackBar('Please enter a valid VIN (minimum 10 alphanumeric characters)');
                                    return;
                                  }

                                  final unit = InwardVehicleUnit(
                                    vin: vin,
                                    engineNumber: !isEv ? _engineController.text.trim() : null,
                                    motorNumber: isEv ? _motorController.text.trim() : null,
                                    batterySerialNumber: isEv ? _batteryController.text.trim() : null,
                                    keyNumber: _keyController.text.trim().isNotEmpty ? _keyController.text.trim() : null,
                                    purchaseCost: double.tryParse(_costController.text) ?? 0.0,
                                    locationInShowroom: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Main Display Area',
                                  );

                                  _cubit.addUnit(unit);
                                  _clearUnitInputs();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing20),

                      // ─── Section 3: Added Units Batch Preview ───
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Units in Current Inward Batch (${state.units.length})',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing12),

                      if (state.units.isEmpty)
                        const AppEmptyState(
                          icon: Icons.post_add_rounded,
                          title: 'No Units in Batch',
                          description: 'Fill in VIN details above and click "Add Unit to Batch" to build the inward receipt.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.units.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final u = state.units[index];
                            return AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryYellow.withValues(alpha: 0.2),
                                    child: Text('${index + 1}', style: AppTypography.captionLarge.copyWith(fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(u.vin, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                                        Text(
                                          isEv
                                              ? 'Motor: ${u.motorNumber ?? "N/A"} • Battery: ${u.batterySerialNumber ?? "N/A"}'
                                              : 'Engine: ${u.engineNumber ?? "N/A"}',
                                          style: AppTypography.captionSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${u.purchaseCost.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                    onPressed: () => _cubit.removeUnit(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: AppDimensions.spacing24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton.secondary(
                            label: 'Cancel',
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          AppButton.primary(
                            label: 'Submit Inward Batch (${state.units.length} Units)',
                            isLoading: state.status == StockInwardStatus.submitting,
                            leadingIcon: Icons.check_circle_outline_rounded,
                            onPressed: () => _cubit.submitInward(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
