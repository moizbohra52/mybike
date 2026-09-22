import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/user_form_cubit.dart';
import '../cubit/user_form_state.dart';

/// User Create / Edit Form Screen
class UserFormScreen extends StatefulWidget {
  final String? editUserId;

  const UserFormScreen({super.key, this.editUserId});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  late final UserFormCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool get isEditMode => widget.editUserId != null;

  @override
  void initState() {
    super.initState();
    _cubit = UserFormCubit();

    if (isEditMode) {
      _cubit.loadUserForEdit(widget.editUserId!);
    } else {
      _cubit.initNewUser();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AppScaffold(
        activeNavigationId: 'users',
        currentShowroomName: 'User Management',
        title: isEditMode ? 'Edit User' : 'Create User',
        actions: [
          AppButton.ghost(
            label: 'Cancel',
            leadingIcon: Icons.close_rounded,
            onPressed: () => context.pop(),
          ),
        ],
        body: BlocConsumer<UserFormCubit, UserFormState>(
          listener: (context, state) {
            if (state is UserFormSuccess) {
              context.showSuccessSnackBar(state.message);
              context.pop();
            }
            if (state is UserFormError) {
              context.showErrorSnackBar(state.message);
            }
            if (state is UserFormReady && state.existingUser != null) {
              // Populate controllers with existing data
              final user = state.existingUser!;
              if (_fullNameController.text.isEmpty) {
                _emailController.text = user.profile.email;
                _fullNameController.text = user.profile.fullName ?? '';
                _phoneController.text = user.profile.phone ?? '';
              }
            }
          },
          builder: (context, state) {
            if (state is UserFormLoading) {
              return const AppPageLoader(message: 'Loading form data...');
            }
            if (state is UserFormSaving) {
              return const AppPageLoader(message: 'Saving user...');
            }
            if (state is UserFormError && state is! UserFormReady) {
              return AppErrorState(
                title: 'Error',
                message: state.message,
                onRetry: () {
                  if (isEditMode) {
                    _cubit.loadUserForEdit(widget.editUserId!);
                  } else {
                    _cubit.initNewUser();
                  }
                },
              );
            }
            if (state is UserFormReady) {
              return _buildForm(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserFormReady state) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.contentPadding(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Section 1: Account Details ───
            AppFormSection(
              title: 'Account Details',
              subtitle: isEditMode
                  ? 'Update user profile information'
                  : 'Enter new staff member credentials and profile',
              children: [
                if (context.isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'e.g. john.doe@mybike.com',
                        isRequired: true,
                        prefixIcon: Icons.email_outlined,
                        enabled: !isEditMode,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email is required';
                          if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      if (!isEditMode) ...[
                        const SizedBox(height: AppDimensions.spacing16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Min 6 characters',
                          isRequired: true,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Password is required';
                            if (val.length < 6) return 'Must be at least 6 characters';
                            return null;
                          },
                        ),
                      ],
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'e.g. john.doe@mybike.com',
                          isRequired: true,
                          prefixIcon: Icons.email_outlined,
                          enabled: !isEditMode,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Email is required';
                            if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                      ),
                      if (!isEditMode) ...[
                        const SizedBox(width: AppDimensions.spacing16),
                        Expanded(
                          child: AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Min 6 characters',
                            isRequired: true,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Password is required';
                              if (val.length < 6) return 'Must be at least 6 characters';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                if (context.isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'e.g. Rajesh Kumar',
                        isRequired: true,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+91 XXXXX XXXXX',
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hint: 'e.g. Rajesh Kumar',
                          isRequired: true,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Name is required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+91 XXXXX XXXXX',
                          prefixIcon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // ─── Section 2: Role Assignment ───
            AppFormSection(
              title: 'Role Assignment',
              subtitle: 'Select one or more roles for this user',
              children: [
                Wrap(
                  spacing: AppDimensions.spacing10,
                  runSpacing: AppDimensions.spacing10,
                  children: state.availableRoles.map((role) {
                    final isSelected = state.selectedRoleIds.contains(role.id);
                    return _RoleChip(
                      role: role,
                      isSelected: isSelected,
                      onTap: () {
                        final current = List<String>.from(state.selectedRoleIds);
                        if (isSelected) {
                          current.remove(role.id);
                        } else {
                          current.add(role.id);
                        }
                        _cubit.updateRoleSelection(current);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // ─── Section 3: Showroom Assignment ───
            AppFormSection(
              title: 'Showroom Access',
              subtitle: 'Assign showrooms this user can operate in',
              children: [
                ...state.availableShowrooms.map((showroom) {
                  final isSelected = state.selectedShowroomIds.contains(showroom.id);
                  final isDefault = showroom.id == state.defaultShowroomId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spacing10),
                    child: _ShowroomAssignCard(
                      showroom: showroom,
                      isSelected: isSelected,
                      isDefault: isDefault,
                      onToggle: () {
                        final current = List<String>.from(state.selectedShowroomIds);
                        if (isSelected) {
                          current.remove(showroom.id);
                        } else {
                          current.add(showroom.id);
                        }
                        _cubit.updateShowroomSelection(current);
                      },
                      onSetDefault: isSelected
                          ? () => _cubit.setDefaultShowroom(showroom.id)
                          : null,
                    ),
                  );
                }),
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
                  label: isEditMode ? 'Update User' : 'Create User',
                  leadingIcon: isEditMode ? Icons.save_rounded : Icons.person_add_outlined,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _cubit.saveUser(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        fullName: _fullNameController.text.trim(),
                        phone: _phoneController.text.trim().isEmpty
                            ? null
                            : _phoneController.text.trim(),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing40),
          ],
        ),
      ),
    );
  }
}

// ─── Role Chip Widget ───

class _RoleChip extends StatelessWidget {
  final dynamic role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({required this.role, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = _roleColor(role.name);

    return Material(
      color: isSelected
          ? color.withValues(alpha: isDark ? 0.25 : 0.15)
          : (isDark ? AppColors.darkCard : AppColors.lightBackground),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.6) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 20,
                color: isSelected ? color : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        role.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                        ),
                      ),
                      if (role.isSystemRole) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('SYSTEM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.warning)),
                        ),
                      ],
                    ],
                  ),
                  if (role.description != null)
                    Text(
                      role.description!,
                      style: AppTypography.captionMedium.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(String roleName) {
    switch (roleName) {
      case 'super_admin':
        return const Color(0xFFEF4444);
      case 'admin':
        return const Color(0xFFF59E0B);
      case 'showroom_manager':
        return const Color(0xFF3B82F6);
      case 'sales_executive':
      case 'sales_manager':
        return const Color(0xFF10B981);
      case 'accountant':
      case 'cashier':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

// ─── Showroom Assignment Card ───

class _ShowroomAssignCard extends StatelessWidget {
  final dynamic showroom;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onToggle;
  final VoidCallback? onSetDefault;

  const _ShowroomAssignCard({
    required this.showroom,
    required this.isSelected,
    required this.isDefault,
    required this.onToggle,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Material(
      color: isSelected
          ? AppColors.primaryYellow.withValues(alpha: isDark ? 0.12 : 0.08)
          : (isDark ? AppColors.darkCard : AppColors.lightBackground),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryYellow.withValues(alpha: 0.5)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                size: 22,
                color: isSelected ? AppColors.primaryYellow : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  showroom.code,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryYellowDark),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showroom.name,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${showroom.city}, ${showroom.state}',
                      style: AppTypography.captionMedium.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected && onSetDefault != null)
                TextButton.icon(
                  onPressed: isDefault ? null : onSetDefault,
                  icon: Icon(
                    isDefault ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: isDefault ? AppColors.primaryYellow : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  ),
                  label: Text(
                    isDefault ? 'Default' : 'Set Default',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDefault ? AppColors.primaryYellow : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
