// lib/features/find_friends/data/friend_post_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';

class FriendPostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 게시글 목록 가져오기 (최신순)
  // 실제 서비스 시에는 GeoFlutterFire 등을 이용해 주변 게시글만 쿼리해야 합니다.
  Stream<List<FriendPostModel>> getPostsStream(
      {Map<String, String?>? locationFilter}) {
    Query query = _firestore
        .collection('friend_posts')
        .orderBy('createdAt', descending: true);

    // 간단한 위치 필터링 (동 단위)
    if (locationFilter != null && locationFilter['kel'] != null) {
      query =
          query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendPostModel.fromFirestore(doc))
          .toList();
    });
  }

  // 게시글 작성
  Future<void> createPost(FriendPostModel post) async {
    await _firestore.collection('friend_posts').add(post.toJson());
  }

  // (추후 구현) 게시글 삭제, 신고, 참여 요청 등
  // [New] 참여 요청 (Request Join)
  Future<void> requestToJoin(String postId, String userId) async {
    await _firestore.collection('friend_posts').doc(postId).update({
      'waitingParticipantIds': FieldValue.arrayUnion([userId]),
    });
  }

  // [New] 참여 요청 취소 (Cancel Request)
  Future<void> cancelRequest(String postId, String userId) async {
    await _firestore.collection('friend_posts').doc(postId).update({
      'waitingParticipantIds': FieldValue.arrayRemove([userId]),
    });
  }

  // [New] 참여 승인 (Approve) -> DB 트랜잭션으로 대기자 -> 참여자로 이동
  // 승인 후에는 게시글 기반 그룹 채팅을 생성하거나 기존 채팅에 참여자를 추가합니다.
  Future<void> acceptJoin(FriendPostModel post, String targetUserId) async {
    final postRef = _firestore.collection('friend_posts').doc(post.id);

    await _firestore.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(postRef);
      if (!freshSnapshot.exists) throw Exception('Post not found');

      final freshPost = FriendPostModel.fromFirestore(freshSnapshot);

      // 정원 초과 체크
      if (freshPost.currentParticipantIds.length >= freshPost.maxParticipants) {
        throw Exception('full');
      }

      // 대기자에서 제거하고 참여자에 추가
      transaction.update(postRef, {
        'waitingParticipantIds': FieldValue.arrayRemove([targetUserId]),
        'currentParticipantIds': FieldValue.arrayUnion([targetUserId]),
      });
    });

    // 채팅방 생성/업데이트 (트랜잭션 바깥에서 처리)
    // 모든 참여자 목록을 조합
    final updatedMembers = List<String>.from(post.currentParticipantIds);
    if (!updatedMembers.contains(targetUserId)) {
      updatedMembers.add(targetUserId);
    }
    if (!updatedMembers.contains(post.authorId)) {
      updatedMembers.add(post.authorId);
    }

    // 채팅방 ID: post_{postId}
    final chatDocRef = _firestore.collection('chats').doc('post_${post.id}');
    final chatDoc = await chatDocRef.get();

    final now = FieldValue.serverTimestamp();

    if (!chatDoc.exists) {
      // 새 그룹 채팅방 생성
      final participants = updatedMembers;
      final unreadCounts = <String, int>{for (var uid in participants) uid: 0};

      final chatData = {
        'participants': participants,
        'lastMessage': '${post.authorNickname}의 게시글 채팅',
        'lastTimestamp': now,
        'unreadCounts': unreadCounts,
        'contextType': 'post',
        'isGroupChat': true,
        'roomId': post.id,
        'roomTitle': post.content.length > 40
            ? post.content.substring(0, 40)
            : post.content,
      };

      final batch = _firestore.batch();
      batch.set(chatDocRef, chatData);
      final messageRef = chatDocRef.collection('messages').doc();
      batch.set(messageRef, {
        'senderId': 'system',
        'text': '채팅이 생성되었습니다.',
        'timestamp': now,
        'readBy': participants,
        'type': 'system',
      });
      await batch.commit();
    } else {
      // 기존 채팅방이 있으면 participants에 추가
      await chatDocRef.update({
        'participants': FieldValue.arrayUnion(updatedMembers),
        for (var uid in updatedMembers) 'unreadCounts.$uid': 0,
      });
    }
  }

  // [New] 참여 거절 (Reject)
  Future<void> rejectJoin(String postId, String targetUserId) async {
    await _firestore.collection('friend_posts').doc(postId).update({
      'waitingParticipantIds': FieldValue.arrayRemove([targetUserId]),
    });
  }
}
