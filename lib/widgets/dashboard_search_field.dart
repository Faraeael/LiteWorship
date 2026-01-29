import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/search_provider.dart';

// ============================================================================
// LITEWORSHIP — Dashboard Search Field
// Primary input for the Omni-Search feature
// ============================================================================

class DashboardSearchField extends ConsumerStatefulWidget {
  const DashboardSearchField({super.key});

  @override
  ConsumerState<DashboardSearchField> createState() => _DashboardSearchFieldState();
}

class _DashboardSearchFieldState extends ConsumerState<DashboardSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state
    _controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the debounce controller is alive
    ref.watch(searchControllerProvider);

    return TextField(
      controller: _controller,
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      style: const TextStyle(
        fontSize: 16,
        color: LWColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: LWColors.primary,
      decoration: InputDecoration(
        hintText: 'Search songs, lyrics, or sculpture...',
        hintStyle: TextStyle(
          color: LWColors.textMuted.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: LWColors.textSecondary,
        ),
        filled: true,
        fillColor: LWColors.surfaceElevated,
        // Default Border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LWRadius.md),
          borderSide: const BorderSide(
            color: LWColors.border,
            width: 1,
          ),
        ),
        // Focus Border (Amber/Gold)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LWRadius.md),
          borderSide: const BorderSide(
            color: LWColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LWSpacing.md,
          vertical: LWSpacing.buttonPadding,
        ),
        // Clear button
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                color: LWColors.textSecondary,
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  setState(() {}); // Rebuild to hide X
                },
              )
            : null,
      ),
    );
  }
}
