import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/dealership_document_entity.dart';

class DocumentCard extends StatelessWidget {
  final DealershipDocumentEntity document;
  final VoidCallback onView;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onView,
    this.onVerify,
    this.onReject,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: document.isPending
              ? AppColors.primaryYellow.withValues(alpha: 0.4)
              : (document.isRejected
                  ? AppColors.error.withValues(alpha: 0.3)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
          width: document.isPending || document.isRejected ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Type Icon Box
                _buildFileIcon(context),
                const SizedBox(width: AppDimensions.spacing12),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              document.documentType,
                              style: AppTypography.titleMedium.copyWith(
                                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(context),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Document Number and Category
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withValues(alpha: isDark ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              border: Border.all(
                                color: AppColors.primaryYellow.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              document.categoryLabel,
                              style: AppTypography.captionMedium.copyWith(
                                color: isDark ? AppColors.primaryYellowDark : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (document.documentNumber != null && document.documentNumber!.isNotEmpty)
                            Text(
                              '# ${document.documentNumber}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              '${document.entityType.toUpperCase()}: ${document.entityId}',
                              style: AppTypography.captionMedium.copyWith(
                                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // File meta & Uploaded By
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file_outlined,
                            size: 13,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            document.fileName,
                            style: AppTypography.captionMedium.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            document.formattedFileSize,
                            style: AppTypography.captionMedium.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (document.expiryDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.event_outlined,
                              size: 13,
                              color: document.isExpired ? AppColors.error : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Exp: ${_formatDate(document.expiryDate!)}',
                              style: AppTypography.captionMedium.copyWith(
                                color: document.isExpired ? AppColors.error : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (document.notes != null && document.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          document.notes!,
                          style: AppTypography.captionMedium.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rejection reason alert banner
          if (document.isRejected && document.rejectionReason != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing8,
              ),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection Reason: ${document.rejectionReason}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Action Toolbar Footer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing8,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard.withValues(alpha: 0.4)
                  : AppColors.lightBackground.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.8,
                ),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppDimensions.radiusMd),
                bottomRight: Radius.circular(AppDimensions.radiusMd),
              ),
            ),
            child: Row(
              children: [
                if (document.verifiedBy != null && document.isVerified) ...[
                  const Icon(Icons.verified_outlined, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Verified by ${document.verifiedBy}',
                    style: AppTypography.captionMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),

                // Preview Button
                OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                // Pending actions (Verify / Reject)
                if (document.isPending && onVerify != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.check, size: 15, color: Colors.white),
                    label: const Text('Verify', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],

                if (document.isPending && onReject != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 15, color: AppColors.error),
                    label: const Text('Reject', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],

                if (onDelete != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                    tooltip: 'Delete Document',
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    final isDark = context.isDarkMode;
    IconData iconData;
    Color iconColor;
    Color bgColor;

    if (document.isPdf) {
      iconData = Icons.picture_as_pdf;
      iconColor = const Color(0xFFE53935);
      bgColor = iconColor.withValues(alpha: isDark ? 0.2 : 0.1);
    } else if (document.isImage) {
      iconData = Icons.image_outlined;
      iconColor = const Color(0xFF1E88E5);
      bgColor = iconColor.withValues(alpha: isDark ? 0.2 : 0.1);
    } else {
      iconData = Icons.description_outlined;
      iconColor = AppColors.primaryYellowDark;
      bgColor = iconColor.withValues(alpha: isDark ? 0.2 : 0.1);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = document.statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            document.isVerified
                ? Icons.check_circle
                : (document.isRejected
                    ? Icons.cancel
                    : (document.isExpired ? Icons.warning_amber_rounded : Icons.schedule)),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            document.statusLabel,
            style: AppTypography.captionMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
