// lib/features/shared/widgets/shared_map_post_list_bottom_sheet.dart
//
// [기획 요약]
// - 지도에서 특정 위치(툴팁 그룹)를 탭하면 해당 위치에 모여 있는
//   포스트 리스트를 바텀시트로 표시합니다.
// - Local News / Marketplace / Lost&Found 등 모든 모듈에서 재사용 가능.
//
// [구현 요약]
// - showModalBottomSheet 로 열리며 스크롤 가능
// - 각 포스트는 제목, 요약, 위치 라벨 등을 표시
// - onPostTap 콜백으로 상세 화면 이동을 외부에 위임

import 'package:flutter/material.dart';

class SharedMapPostSummary {
  final String id;
  final String title;
  final String subtitle;
  final String locationLabel;
  final int replyCount;
  final DateTime createdAt;

  const SharedMapPostSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.locationLabel,
    required this.replyCount,
    required this.createdAt,
  });
}

class SharedMapPostListBottomSheet extends StatelessWidget {
  final String headerTitle;
  final List<SharedMapPostSummary> posts;
  final void Function(SharedMapPostSummary summary)? onPostTap;

  const SharedMapPostListBottomSheet({
    super.key,
    required this.headerTitle,
    required this.posts,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    Text(
                      '${sorted.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final post = sorted[index];
                    return _SharedMapListTile(
                      summary: post,
                      onTap: () => onPostTap?.call(post),
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

class _SharedMapListTile extends StatelessWidget {
  final SharedMapPostSummary summary;
  final VoidCallback? onTap;

  const _SharedMapListTile({
    required this.summary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.location_on_outlined,
                  color: theme.colorScheme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: .75),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          summary.locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.forum_outlined,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Text(
                        '${summary.replyCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
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
