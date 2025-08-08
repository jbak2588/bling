// lib/features/clubs/data/club_repository.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/core/models/club_model.dart';
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

  Future<void> addMember(String clubId, ClubMemberModel member) async {
    final clubRef = _clubs.doc(clubId);
    final memberRef = clubRef.collection('members').doc(member.userId);
    final userRef = _users.doc(member.userId);
    final chatRoomRef = _chats.doc(clubId);

    final batch = _firestore.batch();

    batch.set(memberRef, member.toJson());
    batch.update(clubRef, {'membersCount': FieldValue.increment(1)});
    batch.update(userRef, {
      'clubs': FieldValue.arrayUnion([clubId])
    });
    batch.update(chatRoomRef, {
      'participants': FieldValue.arrayUnion([member.userId]),
      'unreadCounts.${member.userId}': 0,
    });

    await batch.commit();
  }

  Future<void> removeMember(String clubId, String memberId) async {
    // TODO: 멤버 제거 시 membersCount 감소, users/{uid}/clubs 및 chats participants 필드에서 제거하는 로직 추가 필요
    await _clubs
        .doc(clubId)
        .collection('members')
        .doc(memberId)
        .delete();
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
}