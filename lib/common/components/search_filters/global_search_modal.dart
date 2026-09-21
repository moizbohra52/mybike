import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/global_search_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class GlobalSearchModal extends StatefulWidget {
  const GlobalSearchModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const GlobalSearchModal(),
    );
  }

  @override
  State<GlobalSearchModal> createState() => _GlobalSearchModalState();
}

class _GlobalSearchModalState extends State<GlobalSearchModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<GlobalSearchResultItem> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      final res = await GlobalSearchService.instance.search(query);
      if (mounted) {
        setState(() {
          _results = res;
          _isLoading = false;
        });
      }
    });
  }

  void _selectResult(GlobalSearchResultItem item) {
    GlobalSearchService.instance.addRecentSearch(_controller.text);
    Navigator.of(context).pop();
    if (item.routeName != null) {
      context.goNamed(item.routeName!);
    } else {
      context.go(item.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final recent = GlobalSearchService.instance.recentSearches;

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 24, right: 24),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primaryYellowDark, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search anything (Vehicles, Customers, Invoices, Approvals)...',
                        hintStyle: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: const Text('ESC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Area
            Expanded(
              child: _controller.text.trim().isEmpty
                  ? _buildEmptyOrRecentView(context, recent, isDark)
                  : _buildResultsList(context, isDark),
            ),

            // Footer hint
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick jump across all dealership modules',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                  Text(
                    'Powered by MYBIKE Universal Engine',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrRecentView(BuildContext context, List<String> recent, bool isDark) {
    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_command_key, size: 48, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            const SizedBox(height: 12),
            Text(
              'Type to search vehicles, customers, inventory, invoices...',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.captionMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
              TextButton(
                onPressed: () {
                  GlobalSearchService.instance.clearRecentSearches();
                  setState(() {});
                },
                child: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((r) {
              return ActionChip(
                label: Text(r, style: const TextStyle(fontSize: 12)),
                avatar: const Icon(Icons.history, size: 14),
                onPressed: () {
                  _controller.text = r;
                  _onSearchChanged(r);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, bool isDark) {
    if (_results.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            const SizedBox(height: 12),
            Text(
              'No records found for "${_controller.text}"',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
          ],
        ),
      );
    }

    // Group by category
    final Map<SearchCategory, List<GlobalSearchResultItem>> grouped = {};
    for (final item in _results) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: grouped.entries.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(group.key.icon, size: 14, color: AppColors.primaryYellowDark),
                  const SizedBox(width: 6),
                  Text(
                    group.key.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                ],
              ),
            ),
            ...group.value.map((item) => _buildResultTile(context, item, isDark)),
            const Divider(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildResultTile(BuildContext context, GlobalSearchResultItem item, bool isDark) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (item.badgeColor ?? AppColors.primaryYellowDark).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(
          item.category.icon,
          size: 16,
          color: item.badgeColor ?? AppColors.primaryYellowDark,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
          ),
          if (item.badgeText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (item.badgeColor ?? Colors.grey).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
              child: Text(
                item.badgeText!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: item.badgeColor ?? Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        item.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.captionSmall.copyWith(
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: () => _selectResult(item),
    );
  }
}
