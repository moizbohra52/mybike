import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class AppSearchBar extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;
  final Duration debounceDuration;
  final double? width;
  final VoidCallback? onCommandPaletteTap;

  const AppSearchBar({
    super.key,
    this.initialValue,
    this.hintText = 'Search by keyword, VIN, invoice, or phone...',
    required this.onChanged,
    this.onFilterTap,
    this.activeFilterCount = 0,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.width,
    this.onCommandPaletteTap,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChange(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged(value);
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _debounceTimer?.cancel();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget bar = SizedBox(
      height: 42,
      child: TextField(
        controller: _controller,
        onChanged: _onTextChange,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.captionMedium.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryYellowDark),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: _clear,
                  tooltip: 'Clear search',
                ),
              if (widget.onCommandPaletteTap != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: widget.onCommandPaletteTap,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        'Ctrl+K',
                        style: AppTypography.captionSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.onFilterTap != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Badge(
                      isLabelVisible: widget.activeFilterCount > 0,
                      label: Text('${widget.activeFilterCount}'),
                      child: const Icon(Icons.filter_list, size: 20),
                    ),
                    onPressed: widget.onFilterTap,
                    tooltip: 'Filters',
                  ),
                ),
            ],
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(
              color: AppColors.primaryYellowDark,
              width: 1.5,
            ),
          ),
        ),
      ),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: bar);
    }
    return bar;
  }
}
