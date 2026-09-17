import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../common/common.dart';

/// Production-Ready Dealership Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@mybike.com');
  final _passwordController = TextEditingController(text: 'admin123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _fillDemo(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          context.showErrorSnackBar(state.message);
        } else if (state is AuthShowroomSelectionRequired) {
          context.goNamed(RouteNames.showroomSelection);
        } else if (state is Authenticated) {
          context.goNamed(RouteNames.dashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppDimensions.spacing32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ─── Brand Header ───
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryYellow.withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.two_wheeler_rounded,
                                  size: 36,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing16),
                          Text(
                            'MYBIKE',
                            textAlign: TextAlign.center,
                            style: AppTypography.displaySmall.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing4),
                          Text(
                            'Dealership Management & Accounting ERP',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing32),

                          // ─── Email ───
                          AppTextField(
                            label: 'Staff Email',
                            hint: 'name@mybike.com',
                            isRequired: true,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!val.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // ─── Password ───
                          AppTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            isRequired: true,
                            isPassword: true,
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppDimensions.spacing8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                AppInfoDialog.show(
                                  context,
                                  title: 'Password Reset',
                                  message: 'Please contact your Super Admin to reset your dealership account password.',
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: AppTypography.captionMedium.copyWith(
                                  color: isDark ? AppColors.primaryYellowLight : AppColors.primaryYellowDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // ─── Sign In Button ───
                          AppButton.primary(
                            label: 'Sign In to Dealership',
                            isFullWidth: true,
                            size: AppButtonSize.large,
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: AppDimensions.spacing24),

                          // ─── Quick Demo Access Chips ───
                          Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                          const SizedBox(height: AppDimensions.spacing12),
                          Text(
                            'Quick Demo Profiles (Dev Mode):',
                            textAlign: TextAlign.center,
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppDimensions.spacing8,
                            runSpacing: AppDimensions.spacing8,
                            children: [
                              ActionChip(
                                label: const Text('Super Admin'),
                                avatar: const Icon(Icons.admin_panel_settings_rounded, size: 14),
                                onPressed: () => _fillDemo('admin@mybike.com', 'admin123'),
                              ),
                              ActionChip(
                                label: const Text('Showroom Mgr'),
                                avatar: const Icon(Icons.storefront_rounded, size: 14),
                                onPressed: () => _fillDemo('manager@mybike.com', 'mgr123'),
                              ),
                              ActionChip(
                                label: const Text('Sales Exec'),
                                avatar: const Icon(Icons.two_wheeler_rounded, size: 14),
                                onPressed: () => _fillDemo('sales@mybike.com', 'sales123'),
                              ),
                              ActionChip(
                                label: const Text('Accountant'),
                                avatar: const Icon(Icons.account_balance_rounded, size: 14),
                                onPressed: () => _fillDemo('accountant@mybike.com', 'acc123'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
