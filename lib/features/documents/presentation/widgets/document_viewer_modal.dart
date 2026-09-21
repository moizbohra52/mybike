import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/dealership_document_entity.dart';

class DocumentViewerModal extends StatelessWidget {
  final DealershipDocumentEntity document;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;

  const DocumentViewerModal({
    super.key,
    required this.document,
    this.onVerify,
    this.onReject,
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
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
        child: Column(
          children: [
            // Top Header
            _buildHeader(context),
            const Divider(height: 1),

            // Content Viewer
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Document Visual Preview Container
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: isDark ? const Color(0xFF14171F) : const Color(0xFFF1F3F5),
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Center(
                        child: _buildDocumentPreview(context),
                      ),
                    ),
                  ),

                  // Metadata & Verification Details Sidebar
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                      border: Border(
                        left: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    child: _buildMetadataSidebar(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            // Footer Controls
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(
            document.isPdf
                ? Icons.picture_as_pdf
                : (document.isImage ? Icons.image : Icons.description),
            color: document.isPdf ? const Color(0xFFE53935) : AppColors.primaryYellowDark,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.documentType,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${document.categoryLabel} • ${document.fileName}',
                  style: AppTypography.captionMedium.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(context),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    return Container(
      width: 480,
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Stack(
        children: [
          // Simulated Document Layout
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Top Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellowDark.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler, size: 20, color: AppColors.primaryYellowDark),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MYBIKE ENTERPRISE DMS',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'STATUTORY ARCHIVE RECORD',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 28, color: Color(0xFF334155)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1.2, height: 24),

              // Title in Document
              Text(
                document.documentType.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              if (document.documentNumber != null)
                Text(
                  'Record No: ${document.documentNumber}',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 16),

              // Simulated Field Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    _buildPreviewRow('Linked Entity', '${document.entityType.toUpperCase()} (#${document.entityId})'),
                    _buildPreviewRow('Category', document.categoryLabel),
                    _buildPreviewRow('File Name', document.fileName),
                    _buildPreviewRow('File Size', document.formattedFileSize),
                    _buildPreviewRow('MIME Type', document.mimeType),
                    _buildPreviewRow('Created Date', _formatDate(document.createdAt)),
                    if (document.expiryDate != null)
                      _buildPreviewRow('Valid Until', _formatDate(document.expiryDate!)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              if (document.notes != null && document.notes!.isNotEmpty) ...[
                const Text(
                  'Attached Notes:',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    document.notes!,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Seal and Security Signature Stamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DIGITALLY ENCRYPTED ARCHIVE',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'DOC-HASH: ${document.id.toUpperCase()}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: document.statusColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      document.statusLabel,
                      style: TextStyle(
                        color: document.statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Watermark Stamp in Background
          Center(
            child: Transform.rotate(
              angle: -0.4,
              child: Opacity(
                opacity: 0.08,
                child: Text(
                  document.statusLabel,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: document.statusColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSidebar(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Properties',
            style: AppTypography.captionMedium.copyWith(
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          _buildSidebarMetaItem(context, 'Document ID', document.id),
          _buildSidebarMetaItem(context, 'Category', document.categoryLabel),
          _buildSidebarMetaItem(context, 'Entity Type', document.entityType.toUpperCase()),
          _buildSidebarMetaItem(context, 'Entity ID', document.entityId),
          if (document.documentNumber != null)
            _buildSidebarMetaItem(context, 'Doc Number', document.documentNumber!),
          _buildSidebarMetaItem(context, 'File Size', document.formattedFileSize),
          _buildSidebarMetaItem(context, 'MIME Type', document.mimeType),
          _buildSidebarMetaItem(context, 'Uploaded By', document.uploadedBy ?? 'Staff'),
          _buildSidebarMetaItem(context, 'Uploaded On', _formatDate(document.createdAt)),
          if (document.expiryDate != null)
            _buildSidebarMetaItem(
              context,
              'Expiry Date',
              _formatDate(document.expiryDate!),
              textColor: document.isExpired ? AppColors.error : null,
            ),

          const Divider(height: 24),

          // Verification Section
          Text(
            'Verification Status',
            style: AppTypography.captionMedium.copyWith(
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacing10),
            decoration: BoxDecoration(
              color: document.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(color: document.statusColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      document.isVerified
                          ? Icons.verified
                          : (document.isRejected ? Icons.cancel : Icons.schedule),
                      size: 14,
                      color: document.statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      document.statusLabel,
                      style: TextStyle(
                        color: document.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (document.verifiedBy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Verifier: ${document.verifiedBy}',
                    style: AppTypography.captionMedium.copyWith(
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
                if (document.verifiedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Timestamp: ${_formatDate(document.verifiedAt!)}',
                    style: AppTypography.captionMedium.copyWith(
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
                if (document.isRejected && document.rejectionReason != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reason: ${document.rejectionReason}',
                    style: AppTypography.captionMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMetaItem(BuildContext context, String title, String val, {Color? textColor}) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              fontSize: 10,
            ),
          ),
          Text(
            val,
            style: AppTypography.bodySmall.copyWith(
              color: textColor ?? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${document.fileName}...')),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download File'),
          ),
          const Spacer(),
          if (document.isPending && onReject != null) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onReject!();
              },
              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
              label: const Text('Reject Document', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (document.isPending && onVerify != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onVerify!();
              },
              icon: const Icon(Icons.verified, size: 16, color: Colors.white),
              label: const Text('Verify Document', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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
      child: Text(
        document.statusLabel,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
