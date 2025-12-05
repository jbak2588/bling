// SharedMapPostListBottomSheet
// 단일, 깨끗한 제네릭 구현입니다.
import 'package:flutter/material.dart';

class SharedMapPostListBottomSheet<T> extends StatelessWidget {
  final String headerTitle;
  final List<T> items;
  final String Function(T) titleBuilder;
  final String? Function(T)? subtitleBuilder;
  final String? Function(T)? locationLabelBuilder;
  final String? Function(T)? thumbnailUrlBuilder;
  final IconData? Function(T)? categoryIconBuilder;
  final void Function(T)? onItemTap;

  const SharedMapPostListBottomSheet({
    super.key,
    required this.headerTitle,
    required this.items,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.locationLabelBuilder,
    this.thumbnailUrlBuilder,
    this.categoryIconBuilder,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        headerTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${items.length}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _SharedMapListTile<T>(
                      item: item,
                      titleBuilder: titleBuilder,
                      subtitleBuilder: subtitleBuilder,
                      locationLabelBuilder: locationLabelBuilder,
                      thumbnailUrlBuilder: thumbnailUrlBuilder,
                      categoryIconBuilder: categoryIconBuilder,
                      onTap: () => onItemTap?.call(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharedMapListTile<T> extends StatelessWidget {
  final T item;
  final String Function(T) titleBuilder;
  final String? Function(T)? subtitleBuilder;
  final String? Function(T)? locationLabelBuilder;
  final String? Function(T)? thumbnailUrlBuilder;
  final IconData? Function(T)? categoryIconBuilder;
  final VoidCallback? onTap;

  const _SharedMapListTile({
    required this.item,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.locationLabelBuilder,
    this.thumbnailUrlBuilder,
    this.categoryIconBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = titleBuilder(item);
    final subtitle = subtitleBuilder?.call(item) ?? '';
    final loc = locationLabelBuilder?.call(item) ?? '';
    final thumbUrl = thumbnailUrlBuilder?.call(item);
    final categoryIcon = categoryIconBuilder?.call(item);

    Widget buildLeading() {
      const double size = 44;
      if (thumbUrl != null && thumbUrl.isNotEmpty) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    thumbUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (categoryIcon != null)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface
                          .withAlpha((0.9 * 255).round()),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.15 * 255).round()),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      categoryIcon,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
        ),
        alignment: Alignment.center,
        child: Icon(
          categoryIcon ?? Icons.location_on_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLeading(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                    ),
                  if (loc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              loc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
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
}
