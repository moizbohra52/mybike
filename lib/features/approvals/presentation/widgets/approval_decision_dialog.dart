import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/approval_request_entity.dart';

enum ApprovalDecisionType { approve, reject }

class ApprovalDecisionDialog extends StatefulWidget {
  final ApprovalRequestEntity request;
  final ApprovalDecisionType initialType;

  const ApprovalDecisionDialog({
    super.key,
    required this.request,
    this.initialType = ApprovalDecisionType.approve,
  });

  @override
  State<ApprovalDecisionDialog> createState() => _ApprovalDecisionDialogState();
}

class _ApprovalDecisionDialogState extends State<ApprovalDecisionDialog> {
  late ApprovalDecisionType _decisionType;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedPresetReason;

  static const List<String> _rejectionPresets = [
    'Policy threshold exceeded',
    'Discount margin too high',
    'Documentation / bill incomplete',
    'Duplicate transaction suspected',
    'Budget allocation depleted',
    'Stock reconciliation variance',
    'Requires GM authorization',
  ];

  @override
  void initState() {
    super.initState();
    _decisionType = widget.initialType;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _finalReason {
    final customNotes = _notesController.text.trim();
    if (_selectedPresetReason != null && customNotes.isNotEmpty) {
      return '$_selectedPresetReason - $customNotes';
    } else if (_selectedPresetReason != null) {
      return _selectedPresetReason!;
    } else {
      return customNotes;
    }
  }

  bool get _canSubmit {
    if (_decisionType == ApprovalDecisionType.approve) {
      return true;
    }
    // Rejection requires non-empty reason
    return _selectedPresetReason != null || _notesController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isApprove = _decisionType == ApprovalDecisionType.approve;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isApprove
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Icon(
                      isApprove ? Icons.verified_rounded : Icons.cancel_outlined,
                      color: isApprove ? AppColors.success : AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isApprove ? 'Authorize Transaction' : 'Reject Transaction',
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reference: ${widget.request.recordReference ?? widget.request.recordId}',
                          style: AppTypography.captionMedium.copyWith(
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
              const SizedBox(height: AppDimensions.spacingMd),

              // Transaction Summary Snippet
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.request.title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                          ),
                        ),
                        if (widget.request.amount != null)
                          Text(
                            '₹${widget.request.amount!.toStringAsFixed(2)}',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryYellowDark,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.request.requesterName} (${widget.request.requesterRole ?? "Staff"})',
                          style: AppTypography.captionMedium.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ),
                        if (widget.request.showroomName != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.store_outlined,
                            size: 14,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.request.showroomName!,
                            style: AppTypography.captionMedium.copyWith(
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // Action Switcher (Approve / Reject switch tab)
              SegmentedButton<ApprovalDecisionType>(
                segments: const [
                  ButtonSegment<ApprovalDecisionType>(
                    value: ApprovalDecisionType.approve,
                    icon: Icon(Icons.check_circle_outline, size: 16),
                    label: Text('Approve'),
                  ),
                  ButtonSegment<ApprovalDecisionType>(
                    value: ApprovalDecisionType.reject,
                    icon: Icon(Icons.block, size: 16),
                    label: Text('Reject'),
                  ),
                ],
                selected: {_decisionType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _decisionType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // Dynamic Form Body
              if (isApprove) ...[
                Text(
                  'Approval Notes (Optional)',
                  style: AppTypography.captionMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add optional conditions, references or manager comments...',
                    hintStyle: AppTypography.captionMedium.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Text(
                      'Rejection Reason',
                      style: AppTypography.captionMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    const Text(
                      ' * Mandatory',
                      style: TextStyle(color: AppColors.error, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _rejectionPresets.map((preset) {
                    final isSelected = _selectedPresetReason == preset;
                    return ChoiceChip(
                      label: Text(preset, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      selectedColor: AppColors.error.withValues(alpha: 0.2),
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.error
                            : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedPresetReason = selected ? preset : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Additional remarks or explanation to requester...',
                    hintStyle: AppTypography.captionMedium.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: AppDimensions.spacingXl),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApprove ? AppColors.success : AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _canSubmit
                        ? () {
                            Navigator.of(context).pop({
                              'decision': _decisionType,
                              'notes': isApprove ? _notesController.text.trim() : null,
                              'reason': isApprove ? null : _finalReason,
                            });
                          }
                        : null,
                    icon: Icon(
                      isApprove ? Icons.check_circle : Icons.block,
                      size: 16,
                    ),
                    label: Text(isApprove ? 'Confirm Approval' : 'Confirm Rejection'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
