// lib/features/feed/widgets/reply_input_field.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyInputField extends StatefulWidget {
  final String postId;
  final String commentId;
  final VoidCallback onReplyAdded;

  const ReplyInputField({
    super.key,
    required this.postId,
    required this.commentId,
    required this.onReplyAdded,
  });

  @override
  State<ReplyInputField> createState() => _ReplyInputFieldState();
}

class _ReplyInputFieldState extends State<ReplyInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _submitReply() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다.');

      // [수정] userName 저장 로직 제거
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('replies')
          .add({
        'content': content,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _controller.clear();
      if (!mounted) return;
      widget.onReplyAdded();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('답글 등록 실패: $e')));
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ... (build 메소드는 기존과 동일하게 유지)
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '답글을 입력하세요',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            enabled: !_isSubmitting,
            onSubmitted: (_) => _submitReply(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          color: Theme.of(context).primaryColor,
          onPressed: _isSubmitting ? null : _submitReply,
        ),
      ],
    );
  }
}
