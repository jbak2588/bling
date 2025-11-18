import 'package:flutter/material.dart';
import 'package:bling_app/core/theme/bling_theme.dart';

/// Gemini Style Gradient Header
class BlingHeader extends StatelessWidget {
  // Global notifier: toggle this to show the search bar across the app.
  // Example: To enable the header search from anywhere, call
  // `BlingHeader.setGlobalSearchEnabled(true);`
  // To revert: `BlingHeader.setGlobalSearchEnabled(false);`
  // This keeps the search bar off by default while allowing opt-in activation.
  static final ValueNotifier<bool> searchEnabled = ValueNotifier<bool>(false);

  /// Helper to toggle the global search activation signal.
  static void setGlobalSearchEnabled(bool enabled) =>
      searchEnabled.value = enabled;

  final String? title;
  final bool showTitleRow;
  final VoidCallback? onChange;
  final String searchHint;
  final VoidCallback? onSearchTap;
  final Widget? leading;
  final Widget? trailing;
  final bool showSearchBar;

  const BlingHeader({
    super.key,
    this.title,
    this.showTitleRow = false,
    this.onChange,
    this.searchHint = 'Search neighbors, news, items...',
    this.onSearchTap,
    this.leading,
    this.trailing,
    // Default to false to avoid overflow on smaller screens. Use the
    // constructor `showSearchBar: true` to enable per-instance, or call
    // `BlingHeader.setGlobalSearchEnabled(true)` to enable globally.
    this.showSearchBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: BlingColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitleRow) ...[
            Row(
              children: [
                if (leading != null) leading!,
                Expanded(
                  child: GestureDetector(
                    onTap: onChange,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (onChange != null)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.keyboard_arrow_down,
                                color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
          ],
          // The search bar visibility can be controlled locally with
          // the `showSearchBar` property or globally via
          // `BlingHeader.setGlobalSearchEnabled(true)`.
          ValueListenableBuilder<bool>(
            valueListenable: BlingHeader.searchEnabled,
            builder: (context, globalEnabled, _) {
              final visible = showSearchBar || globalEnabled;
              if (!visible) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: BlingColors.geminiBlue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          searchHint,
                          style: TextStyle(
                            color: BlingColors.subtext,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Common Search Field (Reuse styles)
class BlingSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;

  const BlingSearchField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BlingColors.divider),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(color: BlingColors.geminiDeep),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: BlingColors.subtext),
          prefixIcon: const Icon(Icons.search, color: BlingColors.subtext),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
