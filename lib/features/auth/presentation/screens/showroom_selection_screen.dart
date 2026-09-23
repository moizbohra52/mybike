import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../showroom/domain/entities/showroom_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../common/common.dart';

/// Screen for selecting active branch when user is assigned to multiple showrooms
class ShowroomSelectionScreen extends StatelessWidget {
  const ShowroomSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  List<ShowroomEntity> showrooms = [];
                  String userName = 'Team Member';

                  if (state is AuthShowroomSelectionRequired) {
                    showrooms = state.authorizedShowrooms;
                    userName = state.profile.fullName ?? state.profile.email;
                  } else if (state is Authenticated) {
                    showrooms = state.authorizedShowrooms;
                    userName = state.profile.fullName ?? state.profile.email;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Badge
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.two_wheeler_rounded,
                            size: 32,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing20),
                      Text(
                        'Welcome, $userName',
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        'Select the dealership showroom branch you want to manage',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing32),

                      // Showrooms Grid / List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: showrooms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spacing16),
                        itemBuilder: (context, index) {
                          final showroom = showrooms[index];

                          return AppCard(
                            padding: const EdgeInsets.all(AppDimensions.spacing20),
                            enableHover: true,
                            onTap: () {
                              context.read<AuthCubit>().selectShowroom(showroom);
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 24,
                                      color: AppColors.primaryYellow,
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
                                          Flexible(
                                            child: Text(
                                              showroom.name,
                                              style: AppTypography.titleMedium.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? AppColors.darkPrimaryText
                                                    : AppColors.lightPrimaryText,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppDimensions.spacing8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.darkSurface
                                                  : AppColors.lightBackground,
                                              borderRadius: BorderRadius.circular(
                                                AppDimensions.radiusXs,
                                              ),
                                              border: Border.all(
                                                color: isDark
                                                    ? AppColors.darkBorder
                                                    : AppColors.lightBorder,
                                              ),
                                            ),
                                            child: Text(
                                              showroom.code,
                                              style: AppTypography.captionMedium.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.primaryYellowLight
                                                    : AppColors.primaryYellowDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppDimensions.spacing4),
                                      Text(
                                        showroom.fullAddress,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.captionLarge.copyWith(
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.lightSecondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.spacing12),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.primaryYellow,
                                  size: 24,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacing24),
                      TextButton.icon(
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text('Sign out to different account'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
