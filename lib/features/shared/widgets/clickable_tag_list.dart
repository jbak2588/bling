import 'package:flutter/material.dart';
import '../../local_news/screens/tag_search_result_screen.dart'; // local_news에 있지만 공용으로 사용

class ClickableTagList extends StatelessWidget {
  final List<String> tags;

  const ClickableTagList({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) {
        return InkWell(
          onTap: () {
            // 현재는 local_news 하위의 화면을 사용하지만, 추후 공용 검색 화면으로 대체 가능
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TagSearchResultScreen(tag: tag),
            ));
          },
          borderRadius: BorderRadius.circular(16),
          child: Chip(
            label: Text('#$tag', style: const TextStyle(fontSize: 12)),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.grey[200],
          ),
        );
      }).toList(),
    );
  }
}