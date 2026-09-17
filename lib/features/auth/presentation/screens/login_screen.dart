import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Login Screen — Placeholder
///
/// Full authentication will be implemented in Phase 5.
/// This is a visual placeholder to verify theme, responsive layout,
/// and routing are working correctly.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxFormWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Logo ───
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        size: 40,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Center(
                    child: Text(
                      'MYBIKE',
                      style: AppTypography.headlineLarge.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Center(
                    child: Text(
                      'Sign in to your account',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing40),

                  // ─── Email ───
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // ─── Password ───
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),

                  // ─── Forgot Password ───
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                        ),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // ─── Sign In Button ───
                  SizedBox(
                    height: AppDimensions.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: () {
                        // Placeholder — navigate to dashboard
                        context.goNamed(RouteNames.dashboard);
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // ─── Footer ───
                  Center(
                    child: Text(
                      'Powered by MYBIKE ERP',
                      style: AppTypography.captionMedium.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
