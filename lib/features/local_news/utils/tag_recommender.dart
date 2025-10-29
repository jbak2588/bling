// lib/features/local_news/utils/tag_recommender.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_tags.dart';

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[_\\-.,:;!?()"\'[]{}]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

List<String> recommendTagsFromText({
  required String title,
  required String content,
  int topN = 6,
  Set<String> exclude = const {},
}) {
  final text = _normalize('$title $content');
  if (text.isEmpty) return const [];

  final scores = <String, double>{};

  for (final tag in AppTags.localNewsTags) {
    final tagId = tag.tagId;
    if (exclude.contains(tagId)) continue;

    double score = 0.0;
    final keywords = <String>{tagId, ...tag.synonyms};
    for (final raw in keywords) {
      final q = _normalize(raw);
      if (q.isEmpty) continue;
      if (text.contains(q)) {
        // 약어 과적합 방지: 길수록 가중 ↑
        final base = q.length >= 6 ? 1.0 : (q.length >= 3 ? 0.7 : 0.5);
        score += base;
      }
    }

    if (score > 0) {
      const urgent = {
        'power_outage',
        'water_outage',
        'traffic_diversion',
        'flood_alert',
        'weather_warning',
        'disease_alert',
      };
      if (urgent.contains(tagId)) score *= 1.1;
      scores[tagId] = (scores[tagId] ?? 0) + score;
    }
  }

  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(topN).map((e) => e.key).toList();
}

class TagRecommenderController {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final void Function(List<String> tags) onRecommend;
  final Duration debounce;
  // 선택적으로 현재 선택된 태그를 제외하기 위한 공급자
  final Set<String> Function()? excludeProvider;
  Timer? _timer;

  TagRecommenderController({
    required this.titleController,
    required this.contentController,
    required this.onRecommend,
    this.debounce = const Duration(milliseconds: 300),
    this.excludeProvider,
  }) {
    titleController.addListener(_schedule);
    contentController.addListener(_schedule);
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, () {
      final rec = recommendTagsFromText(
        title: titleController.text,
        content: contentController.text,
        exclude: excludeProvider?.call() ?? const {},
      );
      onRecommend(rec);
    });
  }

  void dispose() {
    _timer?.cancel();
    titleController.removeListener(_schedule);
    contentController.removeListener(_schedule);
  }
}
