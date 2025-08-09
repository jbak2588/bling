// lib/features/clubs/data/club_repository.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/core/models/club_post_model.dart';
import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/core/models/club_comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


/// Handles CRUD operations for community clubs and their members.
class ClubRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _clubs =>
      _firestore.collection('clubs');
  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

 // [올바르게 수정된 새 코드]
 Future<String> createClub(ClubModel club) async {
    final batch = _firestore.batch();

    // 1. clubs 컬렉션에 대한 새로운 문서 참조를 미리 만듭니다. (ID를 먼저 알기 위해)
    final clubDocRef = _clubs.doc();
    final clubId = clubDocRef.id;

    final creatorAsMember = ClubMemberModel(
      id: club.ownerId,
      userId: club.ownerId,
      joinedAt: Timestamp.now()
    );

    // 2. 동호회 전용 그룹 채팅방을 먼저 생성합니다.
    final chatRoomRef = _chats.doc(clubId); // 채팅방 ID는 동호회 ID와 동일하게 설정
    final chatRoomData = {
      'isGroupChat': true,
      'groupName': club.title,
      'groupImage': null, // TODO: 동호회 대표 이미지 필드 추가 시 연동
      'participants': [club.ownerId], // 첫 참여자는 개설자
      'lastMessage': '동호회 채팅방이 개설되었습니다.', // TODO: 다국어
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'unreadCounts': {club.ownerId: 0},
    };
    batch.set(chatRoomRef, chatRoomData);
    
    // 3. 동호회 문서를 생성합니다.
    batch.set(clubDocRef, club.toJson());
    
    // 4. 개설자를 members 하위 컬렉션에 추가합니다.
    final memberRef = clubDocRef.collection('members').doc(club.ownerId);
    batch.set(memberRef, creatorAsMember.toJson());
    
    // 5. 개설자의 user 문서에 가입한 동호회 ID를 추가합니다.
    final userRef = _users.doc(club.ownerId);
    batch.update(userRef, {'clubs': FieldValue.arrayUnion([clubId])});
    
    // 6. 모든 작업을 한 번에 원자적으로 실행합니다.
    await batch.commit();
    
    debugPrint("동호회 및 그룹 채팅방 생성 완료: $clubId");
    return clubId;
  }

  Future<void> updateClub(ClubModel club) async {
    await _clubs.doc(club.id).update(club.toJson());
  }

  Future<void> deleteClub(String clubId) async {
    await _clubs.doc(clubId).delete();
  }

  Future<ClubModel> fetchClub(String clubId) async {
    final doc = await _clubs.doc(clubId).get();
    return ClubModel.fromFirestore(doc);
  }

  Stream<List<ClubModel>> fetchClubs() {
    return _clubs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClubModel.fromFirestore(doc)).toList());
  }
    
  // V V V --- [추가] 특정 동호회 정보를 실시간으로 가져오는 Stream 함수 --- V V V
  Stream<ClubModel> getClubStream(String clubId) {
    return _clubs
        .doc(clubId)
        .snapshots()
        .map((snapshot) => ClubModel.fromFirestore(snapshot));
  }
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  // V V V --- [수정] 가입 신청 시, 강퇴 이력을 확인하는 로직으로 변경 --- V V V
  Future<String> addMember(String clubId, ClubMemberModel member) async {
    final clubRef = _clubs.doc(clubId);
    final clubSnapshot = await clubRef.get();
    
    if (!clubSnapshot.exists) {
      throw Exception("동호회를 찾을 수 없습니다.");
    }

    final clubData = ClubModel.fromFirestore(clubSnapshot);
    final kickedMembers = clubData.kickedMembers ?? [];

    // 1. 강퇴 이력이 있는지 확인합니다.
    if (kickedMembers.contains(member.userId)) {
      // 2. 강퇴 이력이 있으면, '가입 대기' 목록에 추가하고 'pending' 상태를 반환합니다.
      await clubRef.update({
        'pendingMembers': FieldValue.arrayUnion([member.userId])
      });
      return 'pending'; // '가입 대기 중'임을 알리는 상태
    } else {
      // 3. 강퇴 이력이 없으면, 즉시 멤버로 추가하고 'joined' 상태를 반환합니다.
      final memberRef = clubRef.collection('members').doc(member.userId);
      final userRef = _users.doc(member.userId);
      final chatRoomRef = _chats.doc(clubId);
      final batch = _firestore.batch();

      batch.set(memberRef, member.toJson());
      batch.update(clubRef, {'membersCount': FieldValue.increment(1)});
      batch.update(userRef, {'clubs': FieldValue.arrayUnion([clubId])});
      batch.update(chatRoomRef, {
        'participants': FieldValue.arrayUnion([member.userId]),
        'unreadCounts.${member.userId}': 0,
      });

      await batch.commit();
      return 'joined'; // '가입 완료'임을 알리는 상태
    }
  }

  // V V V --- [수정] 멤버 강퇴 시, kickedMembers 목록에 기록하는 로직 추가 --- V V V
  Future<void> removeMember(String clubId, String memberId) async {
    final batch = _firestore.batch();
    final clubRef = _clubs.doc(clubId);
    final memberRef = clubRef.collection('members').doc(memberId);
    final userRef = _users.doc(memberId);
    final chatRoomRef = _chats.doc(clubId);

    // 1. members 하위 컬렉션에서 멤버 삭제
    batch.delete(memberRef);
    // 2. membersCount 1 감소
    batch.update(clubRef, {'membersCount': FieldValue.increment(-1)});
    // 3. 사용자의 clubs 필드에서 동호회 ID 제거
    batch.update(userRef, {'clubs': FieldValue.arrayRemove([clubId])});
    // 4. 채팅방 participants 목록에서 멤버 ID 제거
    batch.update(chatRoomRef, {'participants': FieldValue.arrayRemove([memberId])});
    // 5. [핵심] kickedMembers 목록에 강퇴된 멤버 ID 추가
    batch.update(clubRef, {'kickedMembers': FieldValue.arrayUnion([memberId])});

    await batch.commit();
  }

  Stream<List<ClubMemberModel>> fetchMembers(String clubId) {
    return _clubs
        .doc(clubId)
        .collection('members')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ClubMemberModel.fromFirestore).toList());
  }

// V V V --- [추가] 가입 대기중인 멤버 목록을 불러오는 함수 --- V V V
  Stream<List<UserModel>> fetchPendingMembers(List<String> pendingMemberIds) {
    if (pendingMemberIds.isEmpty) {
      return Stream.value([]);
    }
    return _users
        .where(FieldPath.documentId, whereIn: pendingMemberIds)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  // V V V --- [추가] 가입 대기 멤버를 거절(목록에서 삭제)하는 함수 --- V V V
  Future<void> rejectPendingMember(String clubId, String memberId) async {
    await _clubs.doc(clubId).update({
      'pendingMembers': FieldValue.arrayRemove([memberId])
    });
  }


  Stream<bool> isCurrentUserMember(String clubId) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value(false);
    }
    return _clubs
        .doc(clubId)
        .collection('members')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// 특정 동호회에 새로운 게시글을 작성합니다.
  Future<void> createClubPost(String clubId, ClubPostModel post) async {
    await _clubs
        .doc(clubId)
        .collection('posts')
        .add(post.toJson());
  }

  /// 특정 동호회의 모든 게시글 목록을 실시간으로 가져옵니다.
  Stream<List<ClubPostModel>> getClubPostsStream(String clubId) {
    return _clubs
        .doc(clubId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClubPostModel.fromFirestore(doc))
          .toList();
    });
  }
  
  // V V V --- [추가] 방장이 게시글을 삭제하는 함수 --- V V V
  Future<void> deleteClubPost(String clubId, String postId) async {
    final postRef = _clubs.doc(clubId).collection('posts').doc(postId);
    // TODO: 게시글에 달린 댓글, 좋아요 등도 함께 삭제하는 로직 추가 필요
    await postRef.delete();
  }

   /// 특정 게시글에 새로운 댓글을 작성하고, 게시글의 댓글 수를 1 증가시킵니다.
  Future<void> addClubPostComment(String clubId, String postId, ClubCommentModel comment) async {
    final batch = _firestore.batch();

    // 1. posts 하위 컬렉션에 새로운 댓글 문서 추가
    final commentRef = _clubs.doc(clubId).collection('posts').doc(postId).collection('comments').doc();
    batch.set(commentRef, comment.toJson());

    // 2. 해당 post 문서의 commentsCount 필드를 1 증가
    final postRef = _clubs.doc(clubId).collection('posts').doc(postId);
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();
  }

  /// 특정 게시글의 모든 댓글 목록을 실시간으로 가져옵니다.
  Stream<List<ClubCommentModel>> getClubPostCommentsStream(String clubId, String postId) {
    return _clubs
        .doc(clubId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // 오래된 댓글부터 보이도록
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClubCommentModel.fromFirestore(doc))
          .toList();
    });
  }

// V V V --- [추가] 가입 대기 멤버를 승인하는 함수 --- V V V
  Future<void> approvePendingMember(String clubId, String memberId) async {
    final batch = _firestore.batch();
    final clubRef = _clubs.doc(clubId);
    
    // 1. 가입 대기 목록(pendingMembers)과 강퇴 목록(kickedMembers)에서 해당 멤버를 제거합니다.
    batch.update(clubRef, {
      'pendingMembers': FieldValue.arrayRemove([memberId]),
      'kickedMembers': FieldValue.arrayRemove([memberId]),
    });
    
    // 2. 새로운 멤버로 추가하는 작업을 수행합니다.
    final newMember = ClubMemberModel(id: memberId, userId: memberId, joinedAt: Timestamp.now());
    final memberRef = clubRef.collection('members').doc(memberId);
    final userRef = _users.doc(memberId);
    final chatRoomRef = _chats.doc(clubId);
    
    batch.set(memberRef, newMember.toJson());
    batch.update(clubRef, {'membersCount': FieldValue.increment(1)});
    batch.update(userRef, {'clubs': FieldValue.arrayUnion([clubId])});
    batch.update(chatRoomRef, {
      'participants': FieldValue.arrayUnion([memberId]),
      'unreadCounts.$memberId': 0,
    });

    await batch.commit();
  }

}