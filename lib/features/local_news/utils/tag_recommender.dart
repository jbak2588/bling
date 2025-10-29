// lib/features/local_news/utils/tag_recommender.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_tags.dart';

/// Normalize for matching: lowercase, strip punctuation, collapse spaces.
String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp("[_\\-\\.,:;!\\?\\(\\)\\\"'\\[\\]\\{\\}]"), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Quick tokenization for boundary-sensitive checks.
List<String> _tokens(String s) =>
    _normalize(s).split(' ').where((w) => w.isNotEmpty).toList();

/// Very small Indonesian/EN/KR stopwords to avoid over-matching generic words.
const Set<String> _stop = {
  // ID
  'dan', 'atau', 'yang', 'di', 'ke', 'dari', 'ini', 'itu', 'ada', 'tidak',
  'bukan', 'harap', 'info',
  'jalan', 'lokasi', 'wilayah', 'rt', 'rw', 'kelurahan', 'kecamatan',
  'kabupaten', 'kota',
  // EN
  'and', 'or', 'the', 'of', 'in', 'to', 'from', 'is', 'are', 'at', 'on',
  // KO
  '및', '그리고', '에서', '으로', '입니다', '예정', '안내',
};

/// Tags that should get mild priority boost.
const Set<String> _urgent = {
  'power_outage',
  'water_outage',
  'traffic_control',
  'weather_warning',
  'flood_alert',
  'air_quality',
  'disease_alert',
};

class _Weights {
  static const double title = 1.4; // title hit multiplier
  static const double content = 1.0; // content hit multiplier

  /// length-based base weight
  static double len(String q) {
    final n = q.length;
    if (n >= 10) return 1.2;
    if (n >= 6) return 1.0;
    if (n >= 3) return 0.7;
    return 0.4; // acronyms/very short
  }

  /// boundary match bonus if appears as a whole token/phrase
  static const double boundaryBonus = 0.5;

  /// urgent tag multiplier
  static const double urgent = 1.1;
}

/// Recommend tagIds based on title & content.
/// - [exclude]: tagIds to exclude (e.g., already selected)
/// - [whitelist]: if provided, only return tagIds contained in this set
/// - [topN]: number of tags to return (default 6)
List<String> recommendTagsFromText({
  required String title,
  required String content,
  int topN = 6,
  Set<String> exclude = const {},
  Set<String>? whitelist,
}) {
  final normTitle = _normalize(title);
  final normContent = _normalize(content);
  final titleTokens = _tokens(title);
  final contentTokens = _tokens(content);

  final Map<String, double> scores = {};
  final Set<String> candidateTagIds = {
    for (final t in AppTags.localNewsTags) t.tagId
  };

  for (final tag in AppTags.localNewsTags) {
    final tagId = tag.tagId;
    if (exclude.contains(tagId)) continue;
    if (whitelist != null &&
        whitelist.isNotEmpty &&
        !whitelist.contains(tagId)) {
      continue;
    }

    double score = 0.0;

    // Build search terms = tagId + synonyms (normalized & filtered)
    final terms = <String>{
      tagId,
      ...tag.synonyms.map(_normalize),
    }.where((q) => q.isNotEmpty && !_stop.contains(q)).toSet();

    for (final q in terms) {
      // Count occurrences in title/content using token hits + substring fallback
      int titleCount = 0;
      int contentCount = 0;

      // Token boundary matches
      titleCount += titleTokens.where((t) => t == q).length;
      contentCount += contentTokens.where((t) => t == q).length;

      // Substring fallback for multi-word phrases not captured as single tokens
      if (q.contains(' ')) {
        if (normTitle.contains(q)) titleCount = math.max(titleCount, 1);
        if (normContent.contains(q)) contentCount = math.max(contentCount, 1);
      }

      if (titleCount == 0 && contentCount == 0) continue;

      // Frequency with sqrt scaling to avoid dominance
      final freq = math.sqrt((titleCount + contentCount).toDouble());

      // Length weight to de-emphasize short acronyms/noise
      final lenW = _Weights.len(q);

      // Boundary bonus if appeared exactly as a token anywhere
      final boundaryHit = titleTokens.contains(q) || contentTokens.contains(q)
          ? _Weights.boundaryBonus
          : 0.0;

      final partScore =
          (titleCount * _Weights.title + contentCount * _Weights.content) *
                  lenW *
                  freq +
              boundaryHit;

      score += partScore;
    }

    if (score > 0.0) {
      // Slight boost for urgent public-safety-related tags
      if (_urgent.contains(tagId)) {
        score *= _Weights.urgent;
      }
      scores[tagId] = (scores[tagId] ?? 0) + score;
    }
  }

  // Sort by score desc and take topN
  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final picked = <String>[];
  for (final e in sorted) {
    if (picked.length >= topN) break;
    // extra guard (exclude/whitelist checked earlier, but double-check)
    if (exclude.contains(e.key)) continue;
    if (whitelist != null && whitelist.isNotEmpty && !whitelist.contains(e.key))
      continue;
    picked.add(e.key);
  }

  // Fallback: if nothing recommended, propose normalized title as a tag
  if (picked.isEmpty) {
    final titleAsTag = normTitle.replaceAll(RegExp(r'\s+'), '-');
    if (titleAsTag.isNotEmpty &&
        !exclude.contains(titleAsTag) &&
        (whitelist == null ||
            whitelist.isEmpty ||
            whitelist.contains(titleAsTag) ||
            !candidateTagIds.contains(titleAsTag))) {
      picked.add(titleAsTag);
    }
  }

  return picked;
}

/// Controller that listens to title/content edits and emits recommended tags.
/// - [debounce]: if provided, fixed debounce; otherwise adaptive (250–500ms).
/// - [adaptiveDebounce]: if true, use adaptive debounce (overrides [debounce] when null)
/// - [excludeProvider]: to exclude currently selected tags from recommendations
class TagRecommenderController {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final void Function(List<String> tags) onRecommend;

  /// Fixed debounce. If null and [adaptiveDebounce]=true, we use adaptive.
  final Duration? debounce;

  /// When true and [debounce]==null, apply 250–500ms based on input length.
  final bool adaptiveDebounce;

  /// Optionally exclude currently selected tags.
  final Set<String> Function()? excludeProvider;

  /// Optional whitelist for tagIds.
  final Set<String>? whitelist;

  Timer? _timer;

  TagRecommenderController({
    required this.titleController,
    required this.contentController,
    required this.onRecommend,
    this.debounce = const Duration(milliseconds: 300),
    this.adaptiveDebounce = true,
    this.excludeProvider,
    this.whitelist,
  }) {
    titleController.addListener(_schedule);
    contentController.addListener(_schedule);
  }

  Duration _computeAdaptiveDebounce() {
    final len = titleController.text.length + contentController.text.length;
    if (len < 40) return const Duration(milliseconds: 250);
    if (len < 140) return const Duration(milliseconds: 350);
    return const Duration(milliseconds: 500);
  }

  void _schedule() {
    _timer?.cancel();
    final d = (adaptiveDebounce && (debounce == null))
        ? _computeAdaptiveDebounce()
        : (debounce ?? const Duration(milliseconds: 300));

    _timer = Timer(d, () {
      final rec = recommendTagsFromText(
        title: titleController.text,
        content: contentController.text,
        exclude: excludeProvider?.call() ?? const {},
        whitelist: whitelist,
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
