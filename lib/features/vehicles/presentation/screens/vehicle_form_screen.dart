import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/vehicle_form_cubit.dart';
import '../cubit/vehicle_form_state.dart';

/// Vehicle Model Add / Edit Form Screen
class VehicleFormScreen extends StatefulWidget {
  final String? modelId;

  const VehicleFormScreen({super.key, this.modelId});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  late final VehicleFormCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  static const List<String> bodyTypes = [
    'commuter',
    'cruiser',
    'sports',
    'scooter',
    'adventure',
    'moped',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = VehicleFormCubit()..init(modelId: widget.modelId);
  }

  @override
  void dispose() {
    _cubit.close();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AppScaffold(
        activeNavigationId: 'vehicles',
        currentShowroomName: 'Vehicle Master',
        title: widget.modelId != null ? 'Edit Vehicle Model' : 'Add Vehicle Model',
        body: BlocConsumer<VehicleFormCubit, VehicleFormState>(
          listener: (context, state) {
            if (state.status == VehicleFormStatus.success) {
              context.showSuccessSnackBar(
                widget.modelId != null
                    ? 'Vehicle model updated successfully'
                    : 'Vehicle model created successfully',
              );
              context.pop();
            } else if (state.status == VehicleFormStatus.failure && state.errorMessage != null) {
              context.showErrorSnackBar(state.errorMessage!);
            }

            // Sync controllers if model loaded
            if (state.initialModel != null && _nameController.text.isEmpty) {
              _nameController.text = state.initialModel!.name;
              _descController.text = state.initialModel!.description ?? '';
            }
          },
          builder: (context, state) {
            if (state.status == VehicleFormStatus.loading) {
              return const AppPageLoader(message: 'Loading vehicle details...');
            }

            return SingleChildScrollView(
              padding: ResponsiveUtils.contentPadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSectionHeader(
                          title: widget.modelId != null
                              ? 'Edit Vehicle Model: ${state.name}'
                              : 'Create New Vehicle Model',
                          subtitle: 'Configure manufacturer brand, powertrain category, body type, and model description',
                        ),
                        const SizedBox(height: AppDimensions.spacing24),

                        AppCard(
                          padding: const EdgeInsets.all(AppDimensions.spacing24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Model Information',
                                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Brand Selection
                              AppDropdown<String?>(
                                label: 'Manufacturer Brand *',
                                value: state.brandId,
                                items: state.brands.map((b) => b.id).toList(),
                                itemLabel: (id) {
                                  final brand = state.brands.where((b) => b.id == id).firstOrNull;
                                  return brand != null ? '${brand.name} (${brand.code})' : 'Select Brand';
                                },
                                onChanged: (id) {
                                  if (id != null) _cubit.brandChanged(id);
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Model Name
                              AppTextField(
                                label: 'Model Name *',
                                hint: "e.g. CB350 H'ness, 450X Gen 3, Apache RTR 310",
                                controller: _nameController,
                                onChanged: (val) => _cubit.nameChanged(val),
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Powertrain Segment
                              Text(
                                'Powertrain Category *',
                                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppDimensions.spacing8),
                              if (context.isMobile)
                                Column(
                                  children: [
                                    _buildPowertrainOption(
                                      label: 'Petrol / Internal Combustion',
                                      value: 'petrol',
                                      icon: Icons.local_gas_station_rounded,
                                      isSelected: state.type == 'petrol',
                                      onTap: () => _cubit.typeChanged('petrol'),
                                    ),
                                    const SizedBox(height: AppDimensions.spacing16),
                                    _buildPowertrainOption(
                                      label: 'Electric Vehicle (EV)',
                                      value: 'electric',
                                      icon: Icons.electric_bolt_rounded,
                                      isSelected: state.type == 'electric',
                                      onTap: () => _cubit.typeChanged('electric'),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPowertrainOption(
                                        label: 'Petrol / Internal Combustion',
                                        value: 'petrol',
                                        icon: Icons.local_gas_station_rounded,
                                        isSelected: state.type == 'petrol',
                                        onTap: () => _cubit.typeChanged('petrol'),
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.spacing16),
                                    Expanded(
                                      child: _buildPowertrainOption(
                                        label: 'Electric Vehicle (EV)',
                                        value: 'electric',
                                        icon: Icons.electric_bolt_rounded,
                                        isSelected: state.type == 'electric',
                                        onTap: () => _cubit.typeChanged('electric'),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Body Type
                              AppDropdown<String>(
                                label: 'Body Style / Category *',
                                value: state.bodyType,
                                items: bodyTypes,
                                itemLabel: (type) => type[0].toUpperCase() + type.substring(1),
                                onChanged: (val) {
                                  if (val != null) _cubit.bodyTypeChanged(val);
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Description
                              AppTextField(
                                label: 'Description / Highlights',
                                hint: 'Key engineering highlights, design philosophy, or target audience...',
                                controller: _descController,
                                maxLines: 3,
                                onChanged: (val) => _cubit.descriptionChanged(val),
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Is Active Switch
                              SwitchListTile(
                                title: const Text('Model Active for Dealership Catalog'),
                                subtitle: const Text('Inactive models will be hidden from new customer sales and quotes'),
                                value: state.isActive,
                                activeThumbColor: AppColors.primaryYellowDark,
                                onChanged: (val) => _cubit.isActiveChanged(val),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing24),

                        // Form Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton.secondary(
                              label: 'Cancel',
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: AppDimensions.spacing12),
                            AppButton.primary(
                              label: widget.modelId != null ? 'Update Model' : 'Save Model',
                              isLoading: state.status == VehicleFormStatus.submitting,
                              leadingIcon: Icons.save_rounded,
                              onPressed: () => _cubit.saveModel(),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacing40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPowertrainOption({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryYellow.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryYellow
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (value == 'electric' ? const Color(0xFF10B981) : const Color(0xFFF97316))
                  : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.captionMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
