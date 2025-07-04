// lib/features/feed/widgets/reply_list_view.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// v0.9 모델 import
import '../../../core/models/reply_model.dart';
import '../../../core/models/user_model.dart';

class ReplyListView extends StatelessWidget {
  final String postId;
  final String commentId;

  const ReplyListView({
    super.key,
    required this.postId,
    required this.commentId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final replies = snapshot.data!.docs
            .map((doc) => ReplyModel.fromDocument(doc))
            .toList();

        return Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: replies.map((reply) {
              // [수정] 대댓글 작성자의 실시간 정보를 가져오기 위해 StreamBuilder 추가
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(reply.userId)
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox.shrink();
                    final user = UserModel.fromFirestore(userSnapshot.data!);

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('└', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${user.nickname}: ', // [수정] 실시간 닉네임 사용
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: reply.content),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }).toList(),
          ),
        );
      },
    );
  }
}
