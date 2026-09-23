import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/audit_log_entity.dart';

class AuditDiffModal extends StatelessWidget {
  final AuditLogEntity log;

  const AuditDiffModal({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final diffs = log.computeDiff();

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 720),
        child: Column(
          children: [
            // Top Header
            _buildHeader(context),
            const Divider(height: 1),

            // Content Area
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppColors.primaryYellowDark,
                      unselectedLabelColor: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      indicatorColor: AppColors.primaryYellow,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.difference_outlined, size: 16),
                          text: 'Changed Fields (${diffs.length})',
                        ),
                        const Tab(
                          icon: Icon(Icons.code_rounded, size: 16),
                          text: 'Raw JSON Snapshots',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildFieldDiffView(context, diffs),
                          _buildRawJsonView(context),
                        ],
                      ),
                    ),
                  ],
                ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.actionColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(log.actionIcon, color: log.actionColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: log.actionColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: log.actionColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        log.action,
                        style: AppTypography.captionSmall.copyWith(
                          color: log.actionColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      log.recordTitle ?? log.recordId,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.moduleLabel} • Operator: ${log.userName ?? "System"} (${log.userEmail ?? ""}) • ${log.formattedDate} at ${log.formattedTime}',
                  style: AppTypography.captionMedium.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldDiffView(BuildContext context, List<AuditFieldDiff> diffs) {
    final isDark = context.isDarkMode;

    if (diffs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              log.isCreate
                  ? Icons.fiber_new_rounded
                  : (log.isDelete ? Icons.delete_sweep_rounded : Icons.info_outline),
              size: 48,
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
            const SizedBox(height: 12),
            Text(
              log.isCreate
                  ? 'Record Initialized (All fields are new)'
                  : (log.isDelete
                      ? 'Record Deleted (All fields removed)'
                      : 'No state differences found in payload'),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: diffs.length,
      itemBuilder: (context, index) {
        final diff = diffs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diff.fieldName,
                style: AppTypography.captionMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Before Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BEFORE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diff.oldValue != null ? '${diff.oldValue}' : '<null>',
                            style: AppTypography.captionLarge.copyWith(
                              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 12),

                  // After Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AFTER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diff.newValue != null ? '${diff.newValue}' : '<null>',
                            style: AppTypography.captionLarge.copyWith(
                              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRawJsonView(BuildContext context) {
    final isDark = context.isDarkMode;
    const encoder = JsonEncoder.withIndent('  ');
    final beforeStr = log.beforeData != null ? encoder.convert(log.beforeData) : 'null (Created)';
    final afterStr = log.afterData != null ? encoder.convert(log.afterData) : 'null (Deleted)';

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Before JSON
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before Snapshot',
                  style: AppTypography.captionMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14171F) : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        beforeStr,
                        style: AppTypography.captionMedium.copyWith(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right: After JSON
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'After Snapshot',
                  style: AppTypography.captionMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14171F) : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        afterStr,
                        style: AppTypography.captionMedium.copyWith(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ],
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
              final payload = jsonEncode({
                'audit_id': log.id,
                'action': log.action,
                'module': log.module,
                'record_id': log.recordId,
                'before': log.beforeData,
                'after': log.afterData,
              });
              Clipboard.setData(ClipboardData(text: payload));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audit event JSON copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('Copy JSON Payload'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
