import 'package:flutter/material.dart';
import '../../local_news/screens/tag_search_result_screen.dart'; // 기본 네비(폴백)

class ClickableTagList extends StatelessWidget {
  final List<String> tags;

  /// ✅ (옵션) 태그 탭 시 커스텀 동작: null이면 기본 네비게이션
  final void Function(String tag)? onTapTag;

  const ClickableTagList({
    super.key,
    required this.tags,
    this.onTapTag,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        for (final tag in tags)
          ActionChip(
            label: Text('#$tag', style: const TextStyle(fontSize: 12)),
            onPressed: () {
              if (onTapTag != null) {
                onTapTag!(tag);
              } else {
                // 폴백: 로컬 뉴스 태그 검색 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TagSearchResultScreen(tags: [tag]),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
