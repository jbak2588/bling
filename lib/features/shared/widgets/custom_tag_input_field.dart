import 'package:flutter/material.dart';

class CustomTagInputField extends StatefulWidget {
  final Function(List<String>) onTagsChanged;
  final List<String>? initialTags;
  final String hintText;

  const CustomTagInputField({
    super.key,
    required this.onTagsChanged,
    this.initialTags,
    this.hintText = '태그를 입력하세요 (스페이스바로 추가)',   // TODO : 다국어 작업
  });

  @override
  State<CustomTagInputField> createState() => _CustomTagInputFieldState();
}

class _CustomTagInputFieldState extends State<CustomTagInputField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = widget.initialTags ?? [];
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    if (text.isNotEmpty && text.endsWith(' ')) {
      _addTag(text.trim());
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _textController.clear();
      });
      widget.onTagsChanged(_tags);
    } else {
       _textController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ..._tags.map(
              (tag) => Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
            ),
            SizedBox(
              width: 150, // TextField의 최소 너비 확보
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: _tags.isEmpty ? widget.hintText : '',
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
      ),
    );
  }
}