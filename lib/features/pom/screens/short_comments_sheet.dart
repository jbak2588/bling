// lib/features/pom/widgets/short_comments_sheet.dart

import 'package:bling_app/core/models/short_comment_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // [삭제] 불필요한 import
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ShortCommentsSheet extends StatefulWidget {
  final String shortId;
  const ShortCommentsSheet({super.key, required this.shortId});

  @override
  State<ShortCommentsSheet> createState() => _ShortCommentsSheetState();
}

class _ShortCommentsSheetState extends State<ShortCommentsSheet> {
  final ShortRepository _repository = ShortRepository();
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // V V V --- [수정] ShortCommentModel 객체를 생성하여 전달하도록 변경 --- V V V
  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      // Repository의 addShortComment 함수는 이제 commentBody(String)를 직접 받습니다.
      // (short_repository.dart 파일도 함께 수정되었습니다.)
      await _repository.addShortComment(widget.shortId, body);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('pom.comments.fail'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('pom.comments.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<ShortCommentModel>>(
              stream: _repository.getShortCommentsStream(widget.shortId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty) return Center(child: Text('pom.comments.empty'.tr()));

                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) => _buildCommentItem(comments[index]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'pom.comments.placeholder'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                IconButton(
                  icon: _isSending ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                  onPressed: _isSending ? null : _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ShortCommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(comment.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Row(children: [CircleAvatar(radius: 18), SizedBox(width: 12), Text('...')]);
          }
          final user = UserModel.fromFirestore(snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
                child: (user.photoUrl == null || user.photoUrl!.isEmpty) ? const Icon(Icons.person, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(comment.body),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}