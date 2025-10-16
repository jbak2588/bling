import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';

/// 메인피드 가로 캐러셀에서 쓰는 '로컬 뉴스' 전용 썸네일 카드
/// - 크기 고정: 220 x 240
/// - 이미지형: 상단 16:9 이미지 + 하단 메타
/// - 텍스트형: 상단 텍스트(최대 3줄) + 하단 메타
class PostThumbCard extends StatelessWidget {
  static const double width = 220;
  static const double height = 240;

  final PostModel post;
  final VoidCallback onTap;
  const PostThumbCard({super.key, required this.post, required this.onTap});

  bool get _hasImage {
    try {
      final imgs = post.mediaUrl;
      return imgs != null && imgs.isNotEmpty && imgs.first.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String _titleOrSnippet() {
    final t = (post.title ?? '').trim();
    final b = post.body.trim();
    if (t.isNotEmpty) return t;
    if (b.isNotEmpty) {
      // 본문 앞 60자
      return b.length > 60 ? '${b.substring(0, 60)}…' : b;
    }
    return '…';
  }

  String _kabKotaShort() {
    // 모델에선 locationName / locationParts(Map) 제공
    final ln = (post.locationName ?? '').trim();
    if (ln.isNotEmpty) return ln;
    final parts = post.locationParts;
    if (parts != null) {
      // 우선순위 키 후보들을 순회하며 첫 번째 값 반환
      const keys = [
        'kabupaten', 'kota', 'kab', 'city', 'kec', 'kel', 'district', 'village'
      ];
      for (final k in keys) {
        final v = parts[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return '';
  }

  String _categoryName() {
    return (post.category).toString();
  }

  String _relativeTime() {
    try {
      final dt = post.createdAt.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return '방금';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      if (diff.inDays < 7) return '${diff.inDays}일 전';
      return DateFormat('MM/dd').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _titleOrSnippet();
    final cat = _categoryName();
    final kabKota = _kabKotaShort();
    final rel = _relativeTime();

    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 영역
              if (_hasImage)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    post.mediaUrl!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFECEFF3)),
                  ),
                )
              else
                // 텍스트형 — 넉넉한 공간에서 3줄까지 보여줌
                Container(
                  height: 120, // 16:9(≈124) 대신 텍스트형은 120으로 균형
                  color: const Color(0xFFF5F6F9),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 8),

              // 제목(이미지형일 때만 1~2줄로 추가 노출)
              if (_hasImage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),

              const Spacer(),

              // 하단 메타: 카테고리 • kab/kota • 시간
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.black.withOpacity(0.7)),
                  child: Row(
                    children: [
                      if (cat.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(cat, overflow: TextOverflow.ellipsis),
                        ),
                      if (cat.isNotEmpty && (kabKota.isNotEmpty || rel.isNotEmpty))
                        const SizedBox(width: 8),
                      if (kabKota.isNotEmpty) Flexible(child: Text(kabKota, overflow: TextOverflow.ellipsis)),
                      if (kabKota.isNotEmpty && rel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('•', style: TextStyle(color: Colors.black.withOpacity(0.45))),
                        ),
                      if (rel.isNotEmpty) Text(rel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
