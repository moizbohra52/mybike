import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/approval_request_entity.dart';
import 'approval_decision_dialog.dart';

class ApprovalDetailModal extends StatelessWidget {
  final ApprovalRequestEntity request;
  final void Function(ApprovalDecisionType decision, String? notes, String? reason)? onDecision;

  const ApprovalDetailModal({
    super.key,
    required this.request,
    this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, isDark),
            const Divider(height: 1),

            // Body (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Banner
                    if (request.amount != null) _buildAmountBanner(context, isDark),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // Key Metadata Grid
                    _buildMetaGrid(context, isDark),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // Description
                    if (request.description != null && request.description!.isNotEmpty) ...[
                      Text(
                        'Details / Justification',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          request.description!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],

                    // Decision Outcome Card (if resolved)
                    if (!request.isPending) ...[
                      _buildDecisionOutcomeCard(context, isDark),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],

                    // Payload Inspection
                    if (request.payload != null && request.payload!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Transaction Snapshot Payload',
                              style: AppTypography.titleMedium.copyWith(
                                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          TextButton.icon(
                            icon: const Icon(Icons.copy, size: AppDimensions.iconXs),
                            label: Text('Copy JSON', style: AppTypography.captionLarge),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text: const JsonEncoder.withIndent('  ').convert(request.payload),
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Payload copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildPayloadViewer(context, isDark),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            // Footer
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          _buildUrgencyPill(request.urgency),
          const SizedBox(width: AppDimensions.spacingSm),
          _buildStatusBadge(request.status),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${request.id} • ${request.transactionType.toUpperCase()}',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBanner(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: AppColors.primaryYellowDark.withValues(alpha: 0.3),
        ),
      ),
      child: Builder(
        builder: (context) {
          final amountInfo = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requested Authorization Amount',
                style: AppTypography.captionMedium.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${request.amount!.toStringAsFixed(2)}',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellowDark,
                ),
              ),
            ],
          );
          final referenceChip = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
            child: Text(
              'Ref: ${request.recordReference ?? request.recordId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
          );

          return context.isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    amountInfo,
                    const SizedBox(height: AppDimensions.spacing8),
                    referenceChip,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: amountInfo),
                    const SizedBox(width: AppDimensions.spacing8),
                    Flexible(child: referenceChip),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildMetaGrid(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetaItem(
                  icon: Icons.person_outline,
                  label: 'Requested By',
                  value: request.requesterName ?? 'Staff Member',
                  subvalue: request.requesterRole,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetaItem(
                  icon: Icons.store_outlined,
                  label: 'Showroom / Branch',
                  value: request.showroomName ?? 'All Showrooms',
                  subvalue: request.showroomId,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildMetaItem(
                  icon: Icons.access_time,
                  label: 'Submitted Date',
                  value: _formatDate(request.createdAt),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetaItem(
                  icon: Icons.link,
                  label: 'Linked Record',
                  value: request.recordId,
                  subvalue: request.recordReference,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
    required String value,
    String? subvalue,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),
              if (subvalue != null && subvalue.isNotEmpty)
                Text(
                  subvalue,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionOutcomeCard(BuildContext context, bool isDark) {
    final isApproved = request.isApproved;
    final color = isApproved ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApproved ? Icons.verified : Icons.cancel,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isApproved ? 'Approved by ${request.approverName ?? "Manager"}' : 'Rejected by ${request.approverName ?? "Manager"}',
                style: AppTypography.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (request.approvedAt != null)
                Text(
                  _formatDate(request.approvedAt!),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (isApproved && request.approvalNotes != null && request.approvalNotes!.isNotEmpty) ...[
            Text(
              'Approver Notes:',
              style: AppTypography.captionSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              request.approvalNotes!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
          ] else if (!isApproved && request.rejectionReason != null && request.rejectionReason!.isNotEmpty) ...[
            Text(
              'Rejection Reason:',
              style: AppTypography.captionSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              request.rejectionReason!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayloadViewer(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: SelectableText(
        const JsonEncoder.withIndent('  ').convert(request.payload),
        style: AppTypography.captionLarge.copyWith(
          fontFamily: 'monospace',
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (request.isPending && onDecision != null) ...[
            const SizedBox(width: AppDimensions.spacingMd),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final res = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (_) => ApprovalDecisionDialog(
                    request: request,
                    initialType: ApprovalDecisionType.reject,
                  ),
                );
                if (res != null && context.mounted) {
                  Navigator.of(context).pop();
                  onDecision!(
                    res['decision'] as ApprovalDecisionType,
                    res['notes'] as String?,
                    res['reason'] as String?,
                  );
                }
              },
              icon: const Icon(Icons.block, size: 16),
              label: const Text('Reject'),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final res = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (_) => ApprovalDecisionDialog(
                    request: request,
                    initialType: ApprovalDecisionType.approve,
                  ),
                );
                if (res != null && context.mounted) {
                  Navigator.of(context).pop();
                  onDecision!(
                    res['decision'] as ApprovalDecisionType,
                    res['notes'] as String?,
                    res['reason'] as String?,
                  );
                }
              },
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('Approve'),
            ),
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppTypography.captionMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyPill(String urgency) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        urgency.toUpperCase(),
        style: AppTypography.captionSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
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
