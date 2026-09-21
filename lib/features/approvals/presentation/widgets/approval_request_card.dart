import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/approval_request_entity.dart';

class ApprovalRequestCard extends StatelessWidget {
  final ApprovalRequestEntity request;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApprovalRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: request.isPending && (request.urgency == 'critical' || request.urgency == 'high')
                ? AppColors.warning.withValues(alpha: 0.4)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Badges & Time
            Row(
              children: [
                _buildTransactionTypeChip(request.transactionType),
                const SizedBox(width: 8),
                _buildUrgencyChip(request.urgency),
                const Spacer(),
                _buildStatusBadge(request.status),
                const SizedBox(width: 8),
                Text(
                  _formatDate(request.createdAt),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),

            // Row 2: Title & Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      if (request.recordReference != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Ref: ${request.recordReference}',
                          style: AppTypography.captionMedium.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (request.amount != null)
                  Text(
                    '₹${request.amount!.toStringAsFixed(2)}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellowDark,
                    ),
                  ),
              ],
            ),

            if (request.description != null && request.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                request.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingSm),

            // Row 3: Requester & Showroom Info
            Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 14,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  '${request.requesterName} (${request.requesterRole ?? "Staff"})',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
                if (request.showroomName != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.business_outlined,
                    size: 14,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.showroomName!,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ],
            ),

            // If resolved, show resolution summary
            if (!request.isPending) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (request.isApproved ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  border: Border.all(
                    color: (request.isApproved ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      request.isApproved ? Icons.check_circle : Icons.block,
                      size: 14,
                      color: request.isApproved ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.isApproved
                            ? 'Approved by ${request.approverName ?? "Manager"}${request.approvalNotes != null ? " • \"${request.approvalNotes}\"" : ""}'
                            : 'Rejected by ${request.approverName ?? "Manager"}${request.rejectionReason != null ? " • \"${request.rejectionReason}\"" : ""}',
                        style: TextStyle(
                          fontSize: 12,
                          color: request.isApproved ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Row 4: Action Buttons
            if (request.isPending) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              const Divider(height: 1),
              const SizedBox(height: AppDimensions.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: onReject,
                    icon: const Icon(Icons.block, size: 14),
                    label: const Text('Reject', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text('Approve', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeChip(String type) {
    IconData icon;
    switch (type.toLowerCase()) {
      case 'expense':
        icon = Icons.receipt_long_outlined;
        break;
      case 'discount':
        icon = Icons.percent_rounded;
        break;
      case 'purchase':
        icon = Icons.shopping_bag_outlined;
        break;
      case 'payment':
        icon = Icons.payment_outlined;
        break;
      case 'stock_adjustment':
        icon = Icons.tune_rounded;
        break;
      case 'stock_transfer':
        icon = Icons.local_shipping_outlined;
        break;
      default:
        icon = Icons.assignment_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryYellowDark),
          const SizedBox(width: 4),
          Text(
            type.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryYellowDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(String urgency) {
    Color color;
    switch (urgency.toLowerCase()) {
      case 'critical':
        color = AppColors.error;
        break;
      case 'high':
        color = AppColors.warning;
        break;
      case 'low':
        color = Colors.blueGrey;
        break;
      case 'normal':
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        urgency.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'approved':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}
