// lib/features/feed/widgets/comment_input_field.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentInputField extends StatefulWidget {
  final String postId;
  final void Function(Map<String, dynamic> newComment)? onCommentAdded;

  const CommentInputField(
      {super.key, required this.postId, this.onCommentAdded});

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final _controller = TextEditingController();
  bool _isSending = false;
  bool _isSecret = false;

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);

    final commentData = {
      'userId': user.uid,
      'content': content,
      'createdAt': Timestamp.now(), // Firestore 서버 시간을 사용하도록 변경
      'likesCount': 0,
      'isSecret': _isSecret,
      'parentCommentId': null,
    };

    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      // [수정] Firestore 트랜잭션 로직을 올바른 문법으로 수정합니다.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. 새로운 댓글이 추가될 DocumentReference를 먼저 생성합니다.
        final newCommentRef = postRef.collection('comments').doc();

        // 2. 게시물의 commentCount를 1 증가시킵니다.
        transaction.update(postRef, {'commentsCount': FieldValue.increment(1)});

        // 3. 생성된 참조에 댓글 데이터를 set 합니다.
        transaction.set(newCommentRef, commentData);
      });

      _controller.clear();
      setState(() => _isSecret = false);
      if (widget.onCommentAdded != null) widget.onCommentAdded!(commentData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('댓글 등록 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // build 메소드는 기존과 동일하게 유지됩니다.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          8, 8, 8, MediaQuery.of(context).viewInsets.bottom + 8),
      child: Row(
        children: [
          // 비밀댓글 체크박스 (UI 예시)
          Checkbox(
            value: _isSecret,
            onChanged: (value) {
              setState(() {
                _isSecret = value ?? false;
              });
            },
            visualDensity: VisualDensity.compact,
          ),
          const Text('비밀댓글'),
          const Spacer(),
          Expanded(
            flex: 5,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                )
        ],
      ),
    );
  }
}
