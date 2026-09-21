import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/approval_rule_entity.dart';
import '../cubit/approval_rules_cubit.dart';
import '../cubit/approval_rules_state.dart';

class ApprovalRulesTable extends StatelessWidget {
  const ApprovalRulesTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocConsumer<ApprovalRulesCubit, ApprovalRulesState>(
      listener: (context, state) {
        if (state is ApprovalRulesLoaded && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ApprovalRulesCubit>().clearSuccessMessage();
        } else if (state is ApprovalRulesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ApprovalRulesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is ApprovalRulesLoaded) {
          final rules = state.rules;
          if (rules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No approval policies configured',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configured Approval Policies (${rules.length})',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      Text(
                        'Transactions meeting thresholds require sign-off',
                        style: AppTypography.captionSmall.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  itemCount: rules.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spacingSm),
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return _buildRuleCard(context, rule, isDark);
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRuleCard(BuildContext context, ApprovalRuleEntity rule, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: rule.isActive
              ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
              : (isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rule.isActive
                  ? AppColors.primaryYellow.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(
              _getTypeIcon(rule.transactionType),
              size: 20,
              color: rule.isActive ? AppColors.primaryYellowDark : Colors.grey,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),

          // Name & Type
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rule.isActive
                        ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                        : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  ),
                ),
                Text(
                  rule.transactionType.replaceAll('_', ' ').toUpperCase(),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Threshold
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Threshold',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
                Text(
                  rule.thresholdAmount == 0
                      ? 'All Transactions'
                      : '> ₹${rule.thresholdAmount.toStringAsFixed(0)}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellowDark,
                  ),
                ),
              ],
            ),
          ),

          // Required Role
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign-off By',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                  child: Text(
                    rule.requiredRole,
                    style: AppTypography.captionSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active switch
          Switch(
            value: rule.isActive,
            activeThumbColor: AppColors.primaryYellowDark,
            onChanged: (val) {
              final updated = rule.copyWith(
                isActive: val,
                updatedAt: DateTime.now(),
              );
              context.read<ApprovalRulesCubit>().updateRule(updated);
            },
          ),

          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => _showEditRuleDialog(context, rule),
          ),
        ],
      ),
    );
  }

  void _showEditRuleDialog(BuildContext context, ApprovalRuleEntity rule) {
    final thresholdCtrl = TextEditingController(text: rule.thresholdAmount.toStringAsFixed(0));
    final roleCtrl = TextEditingController(text: rule.requiredRole);
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Policy: ${rule.name}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Threshold Amount (₹, 0 = all require approval)',
                  style: AppTypography.captionMedium.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: thresholdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Required Approver Role',
                  style: AppTypography.captionMedium.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellowDark,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final newThreshold = double.tryParse(thresholdCtrl.text.trim()) ?? rule.thresholdAmount;
                        final newRole = roleCtrl.text.trim().isNotEmpty ? roleCtrl.text.trim() : rule.requiredRole;

                        final updated = rule.copyWith(
                          thresholdAmount: newThreshold,
                          requiredRole: newRole,
                          updatedAt: DateTime.now(),
                        );
                        context.read<ApprovalRulesCubit>().updateRule(updated);
                        Navigator.of(dialogCtx).pop();
                      },
                      child: const Text('Save Policy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'discount':
        return Icons.percent_rounded;
      case 'purchase':
        return Icons.shopping_bag_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'stock_adjustment':
        return Icons.tune_rounded;
      case 'stock_transfer':
        return Icons.local_shipping_outlined;
      default:
        return Icons.policy_outlined;
    }
  }
}
