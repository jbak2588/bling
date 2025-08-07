// lib/features/clubs/data/club_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/club_member_model.dart';
import '../../../core/models/club_model.dart';

/// Handles CRUD operations for community clubs and their members.
class ClubRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _clubs =>
      _firestore.collection('clubs');
  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  Future<String> createClub(ClubModel club) async {
    // 1. clubs 컬렉션에 새로운 동호회 문서를 먼저 생성합니다.
    final docRef = await _clubs.add(club.toJson());
    final clubId = docRef.id;

    // 2. 동호회 개설자를 첫 멤버로 추가하는 MemberModel을 만듭니다.
    final creatorAsMember = ClubMemberModel(
      id: club.ownerId, 
      userId: club.ownerId, 
      joinedAt: Timestamp.now()
    );
    // 3. addMember 함수를 호출하여 멤버 추가 및 사용자 프로필 업데이트를 처리합니다.
    await addMember(clubId, creatorAsMember);

    // 4. 동호회 전용 그룹 채팅방을 생성합니다.
    final chatRoomRef = _chats.doc(clubId); // 채팅방 ID는 동호회 ID와 동일하게 설정
    final chatRoomData = {
      'isGroupChat': true, // 그룹 채팅방임을 명시
      'groupName': club.title,
      'groupImage': null, // TODO: 동호회 대표 이미지 필드 추가 시 연동
      'participants': [club.ownerId], // 첫 참여자는 개설자
      'lastMessage': '동호회 채팅방이 개설되었습니다.', // TODO: 다국어
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'unreadCounts': {club.ownerId: 0},
    };
    await chatRoomRef.set(chatRoomData);

    return docRef.id;
  }

  Future<void> updateClub(ClubModel club) async {
    await _firestore.collection('clubs').doc(club.id).update(club.toJson());
  }

  Future<void> deleteClub(String clubId) async {
    await _firestore.collection('clubs').doc(clubId).delete();
  }

  Future<ClubModel> fetchClub(String clubId) async {
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    return ClubModel.fromFirestore(doc);
  }

  Stream<List<ClubModel>> fetchClubs() {
    return _firestore
        .collection('clubs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
    });
  }

 Future<void> addMember(String clubId, ClubMemberModel member) async {
    final clubRef = _clubs.doc(clubId);
    final memberRef = clubRef.collection('members').doc(member.userId);
    final userRef = _users.doc(member.userId);
    // [추가] 동호회 채팅방 문서 참조
    final chatRoomRef = _chats.doc(clubId);

    final batch = _firestore.batch();
    
    // 작업 1: clubs/{clubId}/members에 멤버 추가
    batch.set(memberRef, member.toJson());
    // 작업 2: clubs/{clubId}의 membersCount 1 증가
    batch.update(clubRef, {'membersCount': FieldValue.increment(1)});
    // 작업 3: users/{uid}의 clubs 필드에 clubId 추가
    batch.update(userRef, {'clubs': FieldValue.arrayUnion([clubId])});
    // 작업 4: chats/{clubId}의 participants 목록에 멤버 ID 추가
    batch.update(chatRoomRef, {
      'participants': FieldValue.arrayUnion([member.userId]),
      'unreadCounts.${member.userId}': 0, // 새로운 멤버의 안 읽은 메시지 수 초기화
    });

    await batch.commit();
  }

  Future<void> removeMember(String clubId, String memberId) async {
    // TODO: 멤버 제거 시 membersCount를 1 감소시키는 로직 추가 필요
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('members')
        .doc(memberId)
        .delete();
  }

  Stream<List<ClubMemberModel>> fetchMembers(String clubId) {
    return _firestore
        .collection('clubs')
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
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('members')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.exists); // 문서가 존재하면 true(멤버임), 아니면 false
  }
}
