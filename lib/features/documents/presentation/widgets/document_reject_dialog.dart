import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/dealership_document_entity.dart';

class DocumentRejectDialog extends StatefulWidget {
  final DealershipDocumentEntity document;
  final Function(String reason) onConfirm;

  const DocumentRejectDialog({
    super.key,
    required this.document,
    required this.onConfirm,
  });

  @override
  State<DocumentRejectDialog> createState() => _DocumentRejectDialogState();
}

class _DocumentRejectDialogState extends State<DocumentRejectDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _quickReasons = [
    'Document copy is blurry or unreadable',
    'Customer name does not match KYC identity',
    'Document has expired or is invalid',
    'Incomplete signature or missing seal',
    'Incorrect document type uploaded',
    'Discrepancy in Chassis / Engine number',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reject Document',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.document.documentType,
                  style: AppTypography.captionMedium.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select or enter the reason for rejecting this document:',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
            const SizedBox(height: 12),

            // Quick Reasons Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickReasons.map((reason) {
                final isSelected = _reasonController.text == reason;
                return ChoiceChip(
                  label: Text(
                    reason,
                    style: AppTypography.captionMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.error,
                  backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _reasonController.text = reason;
                      } else {
                        _reasonController.clear();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Rejection reason input
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
              decoration: InputDecoration(
                labelText: 'Specific Rejection Reason *',
                hintText: 'Enter details so the team can re-upload the correct document...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _reasonController.text.trim().isEmpty
              ? null
              : () {
                  final reason = _reasonController.text.trim();
                  widget.onConfirm(reason);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Confirm Rejection'),
        ),
      ],
    );
  }
}
