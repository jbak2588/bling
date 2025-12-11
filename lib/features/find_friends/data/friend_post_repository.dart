// lib/features/find_friends/data/friend_post_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';

class FriendPostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();

  // 게시글 목록 가져오기 (최신순)
  // 실제 서비스 시에는 GeoFlutterFire 등을 이용해 주변 게시글만 쿼리해야 합니다.
  Stream<List<FriendPostModel>> getPostsStream(
      {Map<String, String?>? locationFilter}) {
    Query query = _firestore
        .collection('friend_posts')
        .orderBy('createdAt', descending: true);

    // Marketplace-style administrative filter: prefer most-specific part provided.
    // 우선순위: kel -> kec -> kab -> prov
    if (locationFilter != null) {
      if (locationFilter['kel'] != null) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec'] != null) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['prov'] != null) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
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

  // [작업 9] 게시글 수정
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _firestore.collection('friend_posts').doc(postId).update(data);
  }

  // [작업 9, 13, 14] 게시글 삭제
  Future<void> deletePost(String postId) async {
    // 1. 게시글 문서 삭제
    await _firestore.collection('friend_posts').doc(postId).delete();
    // [작업 14] 연결된 채팅방 참여자 초기화 (Admin 삭제 대기)
    try {
      final String chatId = 'post_$postId'; // 규칙: 'post_' + postId
      final chatRef = _firestore.collection('chats').doc(chatId);

      final chatDoc = await chatRef.get();
      if (chatDoc.exists) {
        // 채팅방을 직접 삭제하지 않고, 참여자를 비워
        // 1) 사용자 목록에서 즉시 숨김 처리
        // 2) 추후 Admin의 '참여자 0명 채팅방 정리' 로직에 의해 삭제되도록 유도
        await chatRef.update({
          'participants': [],
          'lastMessage': '게시글이 삭제되어 종료된 대화입니다.', // (선택) 관리자 확인용 마커
        });
      }
    } catch (e) {
      debugPrint("Failed to clear chat participants: $e");
    }
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
  // [작업 7] targetUserNickname 추가: 시스템 메시지용
  Future<void> acceptJoin(FriendPostModel post, String targetUserId,
      String targetUserNickname) async {
    final postRef = _firestore.collection('friend_posts').doc(post.id);

    // 1. Transaction: Post 문서 상태 변경 (원자적 처리)
    await _firestore.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(postRef);
      if (!freshSnapshot.exists) throw Exception("Post not found");

      final freshPost = FriendPostModel.fromFirestore(freshSnapshot);

      // 정원 초과 체크
      if (freshPost.currentParticipantIds.length >= freshPost.maxParticipants) {
        throw Exception("full"); // 정원 초과
      }

      // 대기 목록에서 제거 및 참여 목록에 추가
      transaction.update(postRef, {
        'waitingParticipantIds': FieldValue.arrayRemove([targetUserId]),
        'currentParticipantIds': FieldValue.arrayUnion([targetUserId]),
      });
    });

    // [작업 6] 리뷰 반영: Race Condition 방지 및 로직 위임
    // 2. 트랜잭션 완료 후 '최신' 문서 다시 조회 (Stale Data 방지)
    final finalPostSnap = await postRef.get();
    if (!finalPostSnap.exists) {
      return; // 방어 코드
    }
    final finalPost = FriendPostModel.fromFirestore(finalPostSnap);

    // 3. 최신 참여자 목록 구성
    List<String> allMembers = List.from(finalPost.currentParticipantIds);
    if (!allMembers.contains(finalPost.authorId)) {
      allMembers.add(finalPost.authorId);
    }

    // 4. ChatService에 채팅방 동기화 위임 (중복 로직 제거)
    await _chatService.getOrCreatePostGroupChat(
      postId: finalPost.id,
      postTitle: finalPost.content.length > 20
          ? '${finalPost.content.substring(0, 20)}...'
          : finalPost.content,
      participants: allMembers,
      joinedUserNames: [targetUserNickname], // [작업 7] 닉네임 전달
    );
  }

  // [New] 참여 거절 (Reject)
  Future<void> rejectJoin(String postId, String targetUserId) async {
    await _firestore.collection('friend_posts').doc(postId).update({
      'waitingParticipantIds': FieldValue.arrayRemove([targetUserId]),
    });
  }
}
