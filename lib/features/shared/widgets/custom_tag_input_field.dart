import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomTagInputField extends StatefulWidget {
  final String hintText;
  final ValueChanged<List<String>> onTagsChanged;
  final List<String>? initialTags;
  final int maxTags;

  // [복구] 제목 기반 태그 추천/생성 기능
  final TextEditingController? titleController;
  final bool autoCreateTitleTag;

  // (옵션) 외부 추천 태그
  final List<String> suggestedTags;

  const CustomTagInputField({
    super.key,
    required this.hintText,
    required this.onTagsChanged,
    this.initialTags,
    this.maxTags = 10,
    this.titleController,
    this.autoCreateTitleTag = true,
    this.suggestedTags = const [],
  });

  @override
  State<CustomTagInputField> createState() => _CustomTagInputFieldState();
}

class _CustomTagInputFieldState extends State<CustomTagInputField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _tags;

  // 제목 기반 추천 태그 목록
  List<String> _titleSuggestions = [];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags ?? []);

    // 제목 변경 감지 리스너 등록
    if (widget.titleController != null) {
      widget.titleController!.addListener(_onTitleChanged);
      // 초기 제목이 있다면 바로 분석
      _onTitleChanged();
    }
  }

  @override
  void dispose() {
    if (widget.titleController != null) {
      widget.titleController!.removeListener(_onTitleChanged);
    }
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // [복구] 제목에서 명사/키워드 추출 (간이 로직)
  void _onTitleChanged() {
    if (!widget.autoCreateTitleTag) return;

    final title = widget.titleController?.text.trim() ?? '';
    if (title.isEmpty) {
      if (_titleSuggestions.isNotEmpty) {
        setState(() => _titleSuggestions.clear());
      }
      return;
    }

    // 간단히 띄어쓰기 단위로 분리하여 2글자 이상인 단어를 추천
    // (실제 서비스에서는 형태소 분석기가 없으므로 이 정도가 최선입니다)
    final potentialTags = title
        .split(' ')
        .where((word) => word.length >= 2) // 너무 짧은 조사 등 제외 시도
        .where((word) => !_tags.contains(word)) // 이미 등록된 태그 제외
        .take(3) // 최대 3개까지만 추천
        .toList();

    // 상태 갱신이 필요할 때만 setState
    if (potentialTags.toString() != _titleSuggestions.toString()) {
      setState(() {
        _titleSuggestions = potentialTags;
      });
    }
  }

  void _addTag(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    if (!_tags.contains(trimmed) && _tags.length < widget.maxTags) {
      setState(() {
        _tags.add(trimmed);
        // 태그 추가 시 추천 목록에서 해당 단어 제거 (UX 향상)
        _titleSuggestions.remove(trimmed);
        widget.onTagsChanged(_tags);
      });
    }
    _textController.clear();
    _focusNode.requestFocus();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      widget.onTagsChanged(_tags);
      // 삭제하면 다시 제목 추천에 뜰 수 있도록 _onTitleChanged 재호출 가능
      _onTitleChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 외부 추천 + 제목 기반 추천 합치기 (중복 제거)
    final allSuggestions = <String>{
      ...widget.suggestedTags,
      ..._titleSuggestions,
    }.where((t) => !_tags.contains(t)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 추천 태그 영역 (제목 기반 포함)
        if (allSuggestions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allSuggestions.map((tag) {
              // 제목에서 온 태그인지 확인 (스타일 구분 가능)
              final isFromTitle = _titleSuggestions.contains(tag);

              return ActionChip(
                label: Text(isFromTitle
                    ? '$tag ${'tag_input.fromTitleSuffix'.tr()}'
                    : '#$tag'),
                avatar: isFromTitle
                    ? const Icon(Icons.auto_awesome, size: 14)
                    : null,
                onPressed: () => _addTag(tag),
                backgroundColor: isFromTitle
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : null,
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // 2. 입력 영역
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 등록된 태그 칩
              ..._tags.map((tag) => Chip(
                    label: Text('#$tag'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )),

              // 텍스트 입력 필드
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: _tags.isEmpty
                        ? widget.hintText
                        : 'tag_input.addHint'.tr(),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  // [유지] 엔터 입력 시 태그 생성
                  onSubmitted: (value) {
                    _addTag(value);
                  },
                  // [유지] 콤마(,) 입력 시 태그 생성
                  onChanged: (value) {
                    if (value.contains(',')) {
                      final parts = value.split(',');
                      if (parts.first.trim().isNotEmpty) {
                        _addTag(parts.first);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'tag_input.help'.tr(),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
