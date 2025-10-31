// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // optional: firstWhereOrNull
import 'package:easy_localization/easy_localization.dart';
// (선택) 앱 공용 태그 정의가 있다면 주입 대신 import 가능
// import 'package:bling_app/core/constants/app_tags.dart';

class CustomTagInputField extends StatefulWidget {
  final String hintText;
  final ValueChanged<List<String>> onTagsChanged;
  final List<String>? initialTags;
  final int maxTags;

  /// ✅ (옵션) 제목 컨트롤러를 넘기면, 제목을 실시간/저장 시 태그로 제안/생성할 수 있습니다.
  final TextEditingController? titleController;

  /// ✅ (옵션) 제목을 태그로 자동 생성(미선택 시 무시). 기본값: true
  final bool autoCreateTitleTag;

  /// ✅ (옵션) 사용자가 원치 않으면 태그 없이도 저장 가능. (상위에서 daily_life로 분류)
  final bool allowEmptyTags;

  /// ✅ (옵션) 추천 태그 칩을 외부에서 주입 (예: 실시간 추천 로직 결과)
  final List<String> suggestedTags;

  /// ✅ (옵션) 태그 화이트리스트(표시·자동완성·정규화에 쓰일 수 있음)
  final Set<String>? whitelist;

  const CustomTagInputField({
    super.key,
    required this.hintText,
    required this.onTagsChanged,
    this.initialTags,
    this.maxTags = 3,
    this.titleController,
    this.autoCreateTitleTag = true,
    this.allowEmptyTags = true,
    this.suggestedTags = const [],
    this.whitelist,
  });

  @override
  State<CustomTagInputField> createState() => _CustomTagInputFieldState();
}

class _CustomTagInputFieldState extends State<CustomTagInputField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _tags = [];
  List<String> _suggested = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialTags != null && widget.initialTags!.isNotEmpty) {
      _tags.addAll(widget.initialTags!);
    }
    _rebuildSuggestedFromWidget();
    widget.titleController?.addListener(_onTitleChanged);
    _textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CustomTagInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestedTags != widget.suggestedTags ||
        oldWidget.whitelist != widget.whitelist) {
      _rebuildSuggestedFromWidget();
    }
  }

  void _rebuildSuggestedFromWidget() {
    // Dedup while keeping order, filter by whitelist when provided, and cap
    const int maxSuggestions = 6;
    final seen = <String>{};
    final List<String> filtered = [];
    for (final s in widget.suggestedTags) {
      if (s.isEmpty) continue;
      if (seen.contains(s)) continue;
      if (widget.whitelist != null && widget.whitelist!.isNotEmpty) {
        if (!widget.whitelist!.contains(s)) continue;
      }
      seen.add(s);
      filtered.add(s);
      if (filtered.length >= maxSuggestions) break;
    }
    setState(() {
      _suggested = filtered;
    });
  }

  @override
  void dispose() {
    widget.titleController?.removeListener(_onTitleChanged);
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ====== 유틸: 태그 정규화(공백→-, 소문자, 앞뒤 트림) ======
  String _normalizeTag(String input) {
    var t = input.toLowerCase().trim();
    // 문장 기호 제거/치환 (필요 시 확장)
    t = t.replaceAll(RegExp(r'[^\p{L}\p{N}\s\-_/]', unicode: true), '');
    // 공백을 하이픈으로
    t = t.replaceAll(RegExp(r'\s+'), '-');
    // 길이 제한
    if (t.length > 30) t = t.substring(0, 30);
    return t;
  }

  // ====== 제목 변화 → 추천 소스 업데이트(옵션) ======
  void _onTitleChanged() {
    if (!widget.autoCreateTitleTag || widget.titleController == null) return;
    final raw = widget.titleController!.text;
    final candidate = _normalizeTag(raw);
    if (candidate.isEmpty) return;

    // 요구사항: "제목에 없는 추천 태그면, 제목 자체를 태그(선택적으로)"
    // 해석: 현재 추천(_suggested) 중 제목에 포함된 태그가 하나도 없으면, 제목 자체를 제안으로 올린다.
    final bool hasSuggestedInsideTitle = _suggested.any((s) {
      if (s.isEmpty) return false;
      return candidate.contains(s);
    });
    if (hasSuggestedInsideTitle) return; // 제목에 이미 추천 태그 패턴이 있으면 굳이 제목 태그 제안 안 함

    // 화이트리스트 고려: 화이트리스트가 있다면 포함될 때만 제안 우선
    if (widget.whitelist != null && widget.whitelist!.isNotEmpty) {
      if (!widget.whitelist!.contains(candidate)) {
        // 화이트리스트에 없으면 추천 목록에만 올리고 자동 추가는 하지 않음
        _pushSuggestion(candidate);
        return;
      }
    }
    // 화이트리스트가 없거나 포함되면 추천 목록 앞에 올림
    _pushSuggestion(candidate);
  }

  void _pushSuggestion(String tag) {
    setState(() {
      _suggested.remove(tag);
      _suggested.insert(0, tag);
      // 중복/길이 제한 정리
      if (_suggested.length > 6) _suggested = _suggested.sublist(0, 6);
    });
  }

  void _onTextChanged() {
    final text = _textController.text;
    if (text.isNotEmpty && text.endsWith(' ')) {
      _addTag(text.trim());
    }
  }

  void _addTag(String tag) {
    final norm = _normalizeTag(tag);
    if (norm.isEmpty) return;
    if (_tags.contains(norm)) {
      _textController.clear();
      return;
    }
    if (_tags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 ${widget.maxTags}개까지 선택할 수 있어요.')),
      );
      _textController.clear();
      return;
    }
    // 화이트리스트가 있다면, 없더라도 제목 태그 허용 요구사항에 따라 추가 허용
    if (widget.whitelist != null && widget.whitelist!.isNotEmpty) {
      // 권장: 화이트리스트에 없는 경우엔 "임시 태그" 배지로 보여줄 수도 있음(여기선 단순 추가)
    }
    setState(() {
      _tags.add(norm);
      _textController.clear();
      widget.onTagsChanged(List<String>.from(_tags));
    });
  }

  // 저장 전에 호출할 수 있는 헬퍼:
  //  - 태그가 비어 있고(autoCreateTitleTag && !allowEmptyTags)면 제목 태그 1개 생성
  //  - allowEmptyTags==true이면 그대로 비워둠(상위에서 daily_life로 분류)
  void ensureMinimumByTitleIfNeeded() {
    if (_tags.isNotEmpty) return;
    if (!widget.autoCreateTitleTag) return;
    if (widget.allowEmptyTags) return;
    if (widget.titleController == null) return;
    final candidate = _normalizeTag(widget.titleController!.text);
    if (candidate.isEmpty) return;
    _addTag(candidate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====== (옵션) 추천 태그 칩 ======
        if (_suggested.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in _suggested)
                ChoiceChip(
                  label: Text('#$id'),
                  selected: _tags.contains(id),
                  onSelected: (_) => _addTag(id),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            for (final tag in _tags)
              InputChip(
                label: Text('#$tag'),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                    widget.onTagsChanged(_tags);
                  });
                },
              ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'shared.tagInput.defaultHint'.tr(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                ),
                onSubmitted: (value) {
                  _addTag(value.trim());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
