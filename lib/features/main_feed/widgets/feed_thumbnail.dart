import 'package:flutter/material.dart';

// 각 타입 공통 썸네일용 데이터 (main_feed 내부에서만 사용)
class FeedThumb {
  final String title;
  final String? subtitle;         // 위치/작성자 등 한 줄
  final String? imageUrl;         // 없으면 플레이스홀더
  final String? badge;            // 가격/라벨 등 한 단어
  final VoidCallback onTap;       // 상세/목록 화면으로 이동
  const FeedThumb({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.imageUrl,
    this.badge,
  });
}

/// 표준 썸네일 카드 (고정 크기: 200 x 240)
class FeedThumbnailCard extends StatelessWidget {
  static const double cardWidth = 200;
  static const double cardHeight = 240;
  final FeedThumb data;
  const FeedThumbnailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일: 1:1 사각형, 없으면 플레이스홀더
              AspectRatio(
                aspectRatio: 1, // 1:1
                child: data.imageUrl == null || data.imageUrl!.isEmpty
                    ? const ColoredBox(color: Color(0xFFECEFF3))
                    : Image.network(data.imageUrl!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (data.subtitle != null && data.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    data.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const Spacer(),
              if (data.badge != null && data.badge!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data.badge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
