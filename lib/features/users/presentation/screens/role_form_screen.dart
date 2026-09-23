import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/role_management_service.dart';
import '../../../roles/domain/entities/role_entity.dart';

/// Role Create / Edit Form with Permission Matrix Grid
class RoleFormScreen extends StatefulWidget {
  final String? editRoleId;

  const RoleFormScreen({super.key, this.editRoleId});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  List<ModulePermissions> _allPermissions = [];
  final Set<String> _selectedPermissionIds = {};
  final Set<String> _expandedGroups = {'Core', 'Operations', 'Transactions', 'Finance & Reports', 'System'};

  bool get isEditMode => widget.editRoleId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final permissions = await RoleManagementService.instance.fetchAllPermissions();
      _allPermissions = permissions;

      if (isEditMode) {
        final role = await RoleManagementService.instance.fetchRoleWithPermissions(widget.editRoleId!);
        if (role == null) {
          setState(() {
            _error = 'Role not found';
            _isLoading = false;
          });
          return;
        }
        _nameController.text = role.role.name;
        _displayNameController.text = role.role.displayName;
        _descriptionController.text = role.role.description ?? '';
        _selectedPermissionIds.addAll(role.role.permissions.map((p) => p.id));
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final service = RoleManagementService.instance;

      if (isEditMode) {
        await service.updateRole(
          widget.editRoleId!,
          displayName: _displayNameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        );
        await service.updateRolePermissions(widget.editRoleId!, _selectedPermissionIds.toList());
        if (mounted) {
          context.showSuccessSnackBar('Role updated successfully');
          context.pop();
        }
      } else {
        await service.createRole(
          name: _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
          displayName: _displayNameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          permissionIds: _selectedPermissionIds.toList(),
        );
        if (mounted) {
          context.showSuccessSnackBar('Role created successfully');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeNavigationId: 'users',
      currentShowroomName: 'Administration',
      title: isEditMode ? 'Edit Role' : 'Create Role',
      actions: [
        AppButton.ghost(
          label: 'Cancel',
          leadingIcon: Icons.close_rounded,
          onPressed: () => context.pop(),
        ),
      ],
      body: _isLoading
          ? const AppPageLoader(message: 'Loading permission data...')
          : _error != null
              ? AppErrorState(title: 'Error', message: _error!, onRetry: _loadData)
              : _isSaving
                  ? const AppPageLoader(message: 'Saving role...')
                  : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      padding: ResponsiveUtils.contentPadding(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Role Details Section ───
            AppFormSection(
              title: 'Role Details',
              subtitle: isEditMode
                  ? 'Update role configuration and description'
                  : 'Define the role identifier, display name, and description',
              children: [
                if (context.isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Role Slug',
                        hint: 'e.g. branch_auditor',
                        isRequired: true,
                        prefixIcon: Icons.key_rounded,
                        enabled: !isEditMode,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          if (val.contains(' ')) return 'Use underscores, no spaces';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      AppTextField(
                        controller: _displayNameController,
                        label: 'Display Name',
                        hint: 'e.g. Branch Auditor',
                        isRequired: true,
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _nameController,
                          label: 'Role Slug',
                          hint: 'e.g. branch_auditor',
                          isRequired: true,
                          prefixIcon: Icons.key_rounded,
                          enabled: !isEditMode,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            if (val.contains(' ')) return 'Use underscores, no spaces';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: AppTextField(
                          controller: _displayNameController,
                          label: 'Display Name',
                          hint: 'e.g. Branch Auditor',
                          isRequired: true,
                          prefixIcon: Icons.badge_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What does this role do?',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // ─── Permission Matrix Section ───
            AppFormSection(
              title: 'Permission Matrix',
              subtitle: '${_selectedPermissionIds.length} of ${_totalPermissions()} permissions selected',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPermissionIds.clear();
                        for (final mp in _allPermissions) {
                          for (final p in mp.permissions) {
                            _selectedPermissionIds.add(p.id);
                          }
                        }
                      });
                    },
                    child: Text(
                      'Select All',
                      style: AppTypography.captionLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() => _selectedPermissionIds.clear()),
                    child: Text(
                      'Clear All',
                      style: AppTypography.captionLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                if (ResponsiveUtils.isMobile(context)) ...[
                  Text(
                    'Swipe sideways to see every action column',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: constraints.maxWidth < 800 ? 800 : constraints.maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Action Column Headers ───
                            _buildActionHeaders(isDark),
                            const SizedBox(height: AppDimensions.spacing8),

                            // ─── Module Groups ───
                            ...RoleManagementService.moduleGroups.entries.map((group) {
                              return _buildModuleGroup(context, group.key, group.value, isDark);
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing32),

            // ─── Save Button ───
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppOutlinedButton(
                  label: 'Cancel',
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: AppDimensions.spacing16),
                AppButton.primary(
                  label: isEditMode ? 'Update Role' : 'Create Role',
                  leadingIcon: Icons.save_rounded,
                  onPressed: _save,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing40),
          ],
        ),
      ),
    );
  }

  int _totalPermissions() {
    int total = 0;
    for (final mp in _allPermissions) {
      total += mp.permissions.length;
    }
    return total;
  }

  Widget _buildActionHeaders(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 200),
      child: Row(
        children: RoleManagementService.allActions.map((action) {
          return Expanded(
            child: Center(
              child: Text(
                action.substring(0, 1).toUpperCase() + action.substring(1),
                style: AppTypography.captionMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModuleGroup(BuildContext context, String groupName, List<String> moduleNames, bool isDark) {
    final isExpanded = _expandedGroups.contains(groupName);

    // Count selected in this group
    int groupTotal = 0;
    int groupSelected = 0;
    for (final moduleName in moduleNames) {
      final mp = _allPermissions.where((m) => m.module == moduleName);
      for (final m in mp) {
        groupTotal += m.permissions.length;
        groupSelected += m.permissions.where((p) => _selectedPermissionIds.contains(p.id)).length;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedGroups.remove(groupName);
              } else {
                _expandedGroups.add(groupName);
              }
            });
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryYellow.withValues(alpha: 0.08)
                  : AppColors.primaryYellow.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_more_rounded : Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.primaryYellow,
                ),
                const SizedBox(width: 8),
                Text(
                  groupName,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.primaryYellowLight : AppColors.primaryYellowDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: groupSelected == groupTotal
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.primaryYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '$groupSelected/$groupTotal',
                    style: AppTypography.captionMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: groupSelected == groupTotal ? AppColors.success : AppColors.primaryYellowDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Select all in group
                InkWell(
                  onTap: () {
                    setState(() {
                      if (groupSelected == groupTotal) {
                        // Deselect all in group
                        for (final moduleName in moduleNames) {
                          for (final mp in _allPermissions.where((m) => m.module == moduleName)) {
                            for (final p in mp.permissions) {
                              _selectedPermissionIds.remove(p.id);
                            }
                          }
                        }
                      } else {
                        // Select all in group
                        for (final moduleName in moduleNames) {
                          for (final mp in _allPermissions.where((m) => m.module == moduleName)) {
                            for (final p in mp.permissions) {
                              _selectedPermissionIds.add(p.id);
                            }
                          }
                        }
                      }
                    });
                  },
                  child: Icon(
                    groupSelected == groupTotal ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    size: 20,
                    color: groupSelected == groupTotal ? AppColors.success : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Module Rows
        if (isExpanded)
          ...moduleNames.map((moduleName) {
            final mp = _allPermissions.where((m) => m.module == moduleName).toList();
            if (mp.isEmpty) return const SizedBox.shrink();
            return _buildModuleRow(mp.first, isDark);
          }),

        const SizedBox(height: AppDimensions.spacing8),
      ],
    );
  }

  Widget _buildModuleRow(ModulePermissions module, bool isDark) {
    final moduleSelected = module.permissions.where((p) => _selectedPermissionIds.contains(p.id)).length;
    final allSelected = moduleSelected == module.permissions.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Module name (fixed width)
          SizedBox(
            width: 200,
            child: Row(
              children: [
                const SizedBox(width: 24),
                // Select all for module
                InkWell(
                  onTap: () {
                    setState(() {
                      if (allSelected) {
                        for (final p in module.permissions) {
                          _selectedPermissionIds.remove(p.id);
                        }
                      } else {
                        for (final p in module.permissions) {
                          _selectedPermissionIds.add(p.id);
                        }
                      }
                    });
                  },
                  child: Icon(
                    allSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: allSelected ? AppColors.success : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    module.displayName,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Action checkboxes
          ...RoleManagementService.allActions.map((action) {
            final permission = module.permissions
                .cast<PermissionEntity?>()
                .firstWhere((p) => p?.action == action, orElse: () => null);

            if (permission == null) {
              return const Expanded(child: SizedBox.shrink());
            }

            final isChecked = _selectedPermissionIds.contains(permission.id);

            return Expanded(
              child: Center(
                child: Checkbox(
                  value: isChecked,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedPermissionIds.add(permission.id);
                      } else {
                        _selectedPermissionIds.remove(permission.id);
                      }
                    });
                  },
                  activeColor: AppColors.primaryYellow,
                  checkColor: AppColors.primaryBlack,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
