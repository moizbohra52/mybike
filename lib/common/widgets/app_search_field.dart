import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Instant Search Field with Debounce & Clear Action
class AppSearchField extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final String? initialValue;
  final double? width;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.controller,
    this.initialValue,
    this.width,
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasTextNow = _controller.text.isNotEmpty;
    if (hasTextNow != _hasText) {
      setState(() {
        _hasText = hasTextNow;
      });
    }

    if (widget.onChanged != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onChanged!(_controller.text);
      });
    }
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget field = TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      style: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkHintText : AppColors.lightHintText,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
          size: AppDimensions.iconSm,
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: AppDimensions.iconSm),
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                onPressed: _clear,
                tooltip: 'Clear',
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        ),
      ),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: field);
    }

    return field;
  }
}
