// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 9-2) 기획서 6.1 '모임 제안' 로직 구현 (V2.0).
// 2. '_clubProposals' 컬렉션 참조 추가.
// 3. 'createClubProposal': '모임 제안' 생성 함수 추가.
// 4. 'joinClubProposal': '제안 참여' 및 '목표 인원 도달 시 자동 생성' 로직 추가 (트랜잭션).
// 5. '_convertProposalToClub': '제안'을 '정식 클럽'으로 전환하는 내부 함수 (클럽 생성, 채팅방 생성, 멤버 자동 등록, 제안 삭제).
// 6. 'getClubProposalsStream': '모임 제안' 탭 목록 스트림 추가.
// 7. 'getClubsStream': '스폰서' 클럽 우선 정렬 로직 추가.
// 8. (Task 12) 'getMyClubsStream': '내가 가입한 모임' 카로셀을 위한 스트림 추가.
// 9. (Task 10) 'deletePost': [버그 수정] 게시글 삭제 시 하위 'comments' 컬렉션을 일괄 삭제(batch delete)하도록 수정.
// =====================================================
// [v2.1 리팩토링 이력: Job 32, 38-45]
// - (Job 32) 'getClubsByLocationStream' (위치 기반 'Active Clubs') 스트림 추가.
// - (Job 39) 'getClubProposalsByLocationStream' (위치 기반 'Proposals') 스트림 추가.
// - (Job 38-44) 'getClubsByLocationStream'의 Firestore 복합 인덱스 문제 디버깅.
// - (Job 43) 쿼리 단순화를 위해 위치 필터 시 'orderBy' 제거 (클라이언트 정렬 활용).
// - (Job 45) 'Expected to find }' 컴파일 에러 수정 (괄호 누락) 및 'unused_element' 경고 수정.
// lib/features/clubs/data/club_repository.dart

import 'package:bling_app/features/clubs/models/club_member_model.dart';
import 'package:bling_app/features/clubs/models/club_proposal_model.dart'; // new
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/models/club_comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

/// Handles CRUD operations for community clubs and their members.
class ClubRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _clubProposals =>
      _firestore.collection('club_proposals'); // 제안(프로포절) 컬렉션
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
        id: club.ownerId, userId: club.ownerId, joinedAt: Timestamp.now());

    // 2. 동호회 전용 그룹 채팅방을 먼저 생성합니다.
    final chatRoomRef = _chats.doc(clubId); // 채팅방 ID는 동호회 ID와 동일하게 설정
    final chatRoomData = {
      'isGroupChat': true,
      'groupName': club.title,
      'groupImage': club.imageUrl ?? '', // [수정] club.imageUrl 연동
      'participants': [club.ownerId], // 첫 참여자는 개설자
      'lastMessage': 'clubs.repository.chatCreated'.tr(),
      // [FIX] 표준 스키마 준수: lastMessageTimestamp -> lastTimestamp
      'lastTimestamp': FieldValue.serverTimestamp(),
      // [FIX] 표준 스키마 준수: contextType 추가
      'contextType': 'club',
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
    batch.update(userRef, {
      'clubs': FieldValue.arrayUnion([clubId])
    });

    // 6. 모든 작업을 한 번에 원자적으로 실행합니다.
    await batch.commit();

    debugPrint("동호회 및 그룹 채팅방 생성 완료: $clubId");
    return clubId;
  }

  /// Create a club proposal document (club_proposals) for proposals that
  /// will be converted to ClubModel when target is met.
  Future<String> createClubProposal(ClubProposalModel proposal) async {
    final doc = await _clubProposals.add(proposal.toJson());
    return doc.id;
  }

  /// Join a club proposal: add user to memberIds and increment currentMemberCount.
  /// If the target is reached, convert the proposal to an official club.
  Future<void> joinClubProposal(String proposalId, String userId) async {
    final proposalRef = _clubProposals.doc(proposalId);

    ClubProposalModel? proposal;

    // Transaction 1: add participant and increment count
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(proposalRef);
      if (!snapshot.exists) {
        throw Exception("Proposal does not exist!");
      }

      proposal = ClubProposalModel.fromFirestore(snapshot);

      if (proposal!.memberIds.contains(userId)) {
        // already joined
        return;
      }

      transaction.update(proposalRef, {
        'memberIds': FieldValue.arrayUnion([userId]),
        'currentMemberCount': FieldValue.increment(1),
      });
    });

    if (proposal == null) return;

    // After transaction: check if target reached (proposal count is from before +1)
    if ((proposal!.currentMemberCount + 1) >= proposal!.targetMemberCount) {
      await _convertProposalToClub(proposalRef.id, proposal!);
    }
  }

  /// Convert a proposal to an official club. This should ideally be done in Cloud Functions,
  /// but provided here for client-side flow.
  Future<void> _convertProposalToClub(
      String proposalId, ClubProposalModel proposal) async {
    final clubRef = _clubs.doc();
    final proposalRef = _clubProposals.doc(proposalId);
    final chatRoomRef = _chats.doc(clubRef.id);

    // Build new ClubModel from proposal
    final newClub = ClubModel(
      id: clubRef.id,
      title: proposal.title,
      description: proposal.description,
      ownerId: proposal.ownerId,
      location: proposal.location,
      locationParts: proposal.locationParts,
      geoPoint: proposal.geoPoint,
      mainCategory: proposal.mainCategory,
      interestTags: proposal.interestTags,
      membersCount: proposal.currentMemberCount + 1,
      isPrivate: proposal.isPrivate, // [수정] 제안의 공개/비공개 설정을 그대로 승계
      trustLevelRequired: 'normal',
      createdAt: Timestamp.now(),
      kickedMembers: const [],
      pendingMembers: const [],
      imageUrl: proposal.imageUrl,
    );

    final batch = _firestore.batch();

    // Create club document
    batch.set(clubRef, newClub.toJson());

    // Participants: ensure uniqueness and include the current user if present
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final allMemberIdsSet = <String>{...proposal.memberIds};
    if (currentUid != null) {
      allMemberIdsSet.add(currentUid);
    }
    final allMemberIds = allMemberIdsSet.toList();

    // Create group chat document (use existing schema)
    final unreadCounts = {for (var id in allMemberIds) id: 0};
    batch.set(chatRoomRef, {
      'isGroupChat': true,
      'groupName': newClub.title,
      'groupImage': newClub.imageUrl ?? '',
      'participants': allMemberIds,
      'lastMessage': 'clubs.repository.chatCreated'.tr(),
      // [FIX] 표준 스키마 준수: lastMessageTimestamp -> lastTimestamp
      'lastTimestamp': FieldValue.serverTimestamp(),
      // [FIX] 표준 스키마 준수: contextType 추가
      'contextType': 'club',
      'unreadCounts': unreadCounts,
    });

    // Add members subcollection and update users' clubs
    for (final memberId in allMemberIds) {
      final memberRef = clubRef.collection('members').doc(memberId);
      final newMember = ClubMemberModel(
        id: memberId,
        userId: memberId,
        joinedAt: Timestamp.now(),
      );
      batch.set(memberRef, newMember.toJson());

      final userRef = _users.doc(memberId);
      batch.update(userRef, {
        'clubs': FieldValue.arrayUnion([clubRef.id])
      });
    }

    // Delete proposal after conversion
    batch.delete(proposalRef);

    await batch.commit();
  }

  /// [v2.1] '동네 친구'의 '모임' 탭을 위한 하이퍼로컬 필터 스트림
  Stream<List<ClubModel>> getClubsByLocationStream({
    required Map<String, String?> locationFilter,
  }) {
    Query query = _clubs; // Initialize query

    // 'find_friend_repository.dart'와 동일한 동적 위치 필터 적용
    // [작업 41] 필터가 비어 있지 않은지 확인 ({} != null은 true가 아님)
    if (locationFilter.isNotEmpty && locationFilter['prov'] != null) {
      // --- 1. 'where' (필터) 절을 모두 적용 ---
      query =
          query.where('locationParts.prov', isEqualTo: locationFilter['prov']);

      if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);

        if (locationFilter['kec'] != null) {
          query = query.where('locationParts.kec',
              isEqualTo: locationFilter['kec']);
        }
        if (locationFilter['kel'] != null) {
          query = query.where('locationParts.kel',
              isEqualTo: locationFilter['kel']);
        }
      }

      // --- 2. 'orderBy' (정렬) 절 ---
      // [작업 43] 'where' 필터와 'orderBy' 필드가 다르므로, 복합 인덱스가 필요함.
      query = query
          .orderBy('isSponsored', descending: true)
          .orderBy('createdAt', descending: true);
    } else {
      // [작업 41] 위치 필터가 없는 경우 (locationFilter: {})
      // 'Test' 탭과 동일한 쿼리를 실행하여 'Active Clubs' 3개가 보이도록 함
      query = query
          .orderBy('isSponsored', descending: true)
          .orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ClubModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  /// Stream proposals (optionally add location filtering later)
  Stream<List<ClubProposalModel>> getClubProposalsStream() {
    Query<Map<String, dynamic>> query = _clubProposals;
    query = query.orderBy('createdAt', descending: true);
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map(ClubProposalModel.fromFirestore).toList());
  }

  /// [v2.1] '동네 친구'의 '모임' 탭을 위한 하이퍼로컬 '제안' 필터 스트림
  Stream<List<ClubProposalModel>> getClubProposalsByLocationStream({
    required Map<String, String?> locationFilter,
  }) {
    // '제안'은 'clubProposals' 컬렉션에서 가져옴
    Query<Map<String, dynamic>> query = _clubProposals;

    // 'find_friend_repository.dart'와 동일한 동적 위치 필터 적용
    // [작업 41] 필터가 비어 있지 않은지 확인
    if (locationFilter.isNotEmpty && locationFilter['prov'] != null) {
      // --- 1. 'where' (필터) 절 ---
      query =
          query.where('locationParts.prov', isEqualTo: locationFilter['prov']);

      if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);

        if (locationFilter['kec'] != null) {
          query = query.where('locationParts.kec',
              isEqualTo: locationFilter['kec']);
        }
        if (locationFilter['kel'] != null) {
          query = query.where('locationParts.kel',
              isEqualTo: locationFilter['kel']);
        }
      }

      // --- 2. 'orderBy' (정렬) 절 ---
      // [작업 43] 'where' 필터와 'orderBy' 필드가 다르므로, 복합 인덱스가 필요함.
      query = query.orderBy('createdAt', descending: true);
    } else {
      // [작업 41] 위치 필터가 없는 경우, 'createdAt'으로만 정렬 (Proposals가 1개 보였던 이유)
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ClubProposalModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  /// Leave a club proposal (decrement count and remove from memberIds)
  Future<void> leaveClubProposal(String proposalId, String userId) async {
    final proposalRef = _clubProposals.doc(proposalId);
    await _firestore.runTransaction((transaction) async {
      transaction.update(proposalRef, {
        'memberIds': FieldValue.arrayRemove([userId]),
        'currentMemberCount': FieldValue.increment(-1),
      });
    });
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

  Stream<List<ClubModel>> fetchClubs({Map<String, String?>? locationFilter}) {
    Query<Map<String, dynamic>> query = _clubs;
    final filter = locationFilter;

    final String? kab = filter?['kab'];
    if (filter != null) {
      if (filter['kel'] != null) {
        query = query.where('locationParts.kel', isEqualTo: filter['kel']);
      } else if (filter['kec'] != null) {
        query = query.where('locationParts.kec', isEqualTo: filter['kec']);
      } else if (filter['kab'] != null) {
        query = query.where('locationParts.kab', isEqualTo: filter['kab']);
      } else if (filter['kota'] != null) {
        query = query.where('locationParts.kota', isEqualTo: filter['kota']);
      } else if (filter['prov'] != null) {
        query = query.where('locationParts.prov', isEqualTo: filter['prov']);
      }
    }
    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        final fallbackSnapshot = await _clubs
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('createdAt', descending: true)
            .get();
        return fallbackSnapshot.docs
            .map((doc) => ClubModel.fromFirestore(doc))
            .toList();
      }
      return snapshot.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
    });
  }

  // [신규] 기존 fetchClubs와 동일한 동작을 하는 별칭 스트림 함수
  Stream<List<ClubModel>> getClubsStream(
      {Map<String, String?>? locationFilter}) {
    return fetchClubs(locationFilter: locationFilter);
  }

  // V V V --- [추가] 특정 동호회 정보를 실시간으로 가져오는 Stream 함수 --- V V V
  Stream<ClubModel> getClubStream(String clubId) {
    return _clubs
        .doc(clubId)
        .snapshots()
        .map((snapshot) => ClubModel.fromFirestore(snapshot));
  }

  // [신규] '내가 가입한 모임' 목록을 가져오는 스트림 (하이브리드 UI용)
  Stream<List<ClubModel>> getMyClubsStream(String userId) {
    return _users.doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) {
        return [];
      }
      final userData = userDoc.data() ?? {};
      final List<String> myClubIds = List<String>.from(userData['clubs'] ?? []);

      if (myClubIds.isEmpty) {
        return [];
      }

      // [Fix] Firestore 'whereIn' 제한(10개)에 맞춰 쿼리를 분할 실행합니다.
      // 사용자가 가입한 모든 클럽을 안전하게 가져옵니다.
      final queryBatches = <List<String>>[];
      for (var i = 0; i < myClubIds.length; i += 10) {
        queryBatches.add(myClubIds.sublist(
            i, i + 10 > myClubIds.length ? myClubIds.length : i + 10));
      }

      final allClubs = <ClubModel>[];
      for (final batchIds in queryBatches) {
        final snapshot =
            await _clubs.where(FieldPath.documentId, whereIn: batchIds).get();
        allClubs.addAll(snapshot.docs.map(ClubModel.fromFirestore));
      }
      return allClubs;
    });
  }
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  // V V V --- [수정] 가입 신청 시, 강퇴 이력 및 비공개 여부를 확인하는 로직으로 변경 --- V V V
  Future<String> addMember(String clubId, ClubMemberModel member) async {
    final clubRef = _clubs.doc(clubId);
    final clubSnapshot = await clubRef.get();

    if (!clubSnapshot.exists) {
      throw Exception("동호회를 찾을 수 없습니다.");
    }

    final clubData = ClubModel.fromFirestore(clubSnapshot);
    final kickedMembers = clubData.kickedMembers ?? [];

    // [수정] 비공개 모임이거나, 강퇴 이력이 있는 경우 '가입 대기'로 처리
    bool requireApproval =
        clubData.isPrivate || kickedMembers.contains(member.userId);

    // 1. 승인 필요 여부 확인 (비공개 모임 OR 강퇴자)
    if (requireApproval) {
      // 2. 가입 대기 목록에 추가하고 'pending' 상태를 반환합니다.
      await clubRef.update({
        'pendingMembers': FieldValue.arrayUnion([member.userId])
      });
      return 'pending'; // '가입 대기 중'임을 알리는 상태
    } else {
      // 3. 공개 모임이고 강퇴자가 아니면, 즉시 멤버로 추가하고 'joined' 상태를 반환합니다.
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
    batch.update(userRef, {
      'clubs': FieldValue.arrayRemove([clubId])
    });
    // 4. 채팅방 participants 목록에서 멤버 ID 제거
    batch.update(chatRoomRef, {
      'participants': FieldValue.arrayRemove([memberId])
    });
    // 5. [핵심] kickedMembers 목록에 강퇴된 멤버 ID 추가
    batch.update(clubRef, {
      'kickedMembers': FieldValue.arrayUnion([memberId])
    });

    await batch.commit();
  }

  // V V V --- [추가] 멤버가 스스로 동호회를 탈퇴하는 함수 --- V V V
  Future<void> leaveClub(String clubId, String memberId) async {
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
    batch.update(userRef, {
      'clubs': FieldValue.arrayRemove([clubId])
    });
    // 4. 채팅방 participants 목록에서 멤버 ID 제거
    batch.update(chatRoomRef, {
      'participants': FieldValue.arrayRemove([memberId])
    });

    // '강퇴'와 달리 kickedMembers 목록에는 추가하지 않습니다.

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
    await _clubs.doc(clubId).collection('posts').add(post.toJson());
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

  Stream<DocumentSnapshot> getClubPostStream(String clubId, String postId) {
    return _clubs.doc(clubId).collection('posts').doc(postId).snapshots();
  }

  // V V V --- [수정] 방장이 게시글을 삭제하는 함수: 하위 댓글까지 일괄 삭제 --- V V V
  Future<void> deleteClubPost(String clubId, String postId) async {
    final postRef = _clubs.doc(clubId).collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    // [수정] 게시글 삭제 시 하위 댓글(comments)을 먼저 배치 삭제한 뒤, 원본 게시글 삭제
    final batch = _firestore.batch();

    // 1) 모든 댓글 문서 읽어서 배치 삭제에 추가
    final commentsSnapshot = await commentsRef.get();
    for (final doc in commentsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 2) 원본 게시글 삭제
    batch.delete(postRef);

    await batch.commit();
  }

  /// 특정 게시글에 새로운 댓글을 작성하고, 게시글의 댓글 수를 1 증가시킵니다.
  Future<void> addClubPostComment(
      String clubId, String postId, ClubCommentModel comment) async {
    final batch = _firestore.batch();

    // 1. posts 하위 컬렉션에 새로운 댓글 문서 추가
    final commentRef = _clubs
        .doc(clubId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();
    batch.set(commentRef, comment.toJson());

    // 2. 해당 post 문서의 commentsCount 필드를 1 증가
    final postRef = _clubs.doc(clubId).collection('posts').doc(postId);
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();
  }

  /// 특정 게시글의 모든 댓글 목록을 실시간으로 가져옵니다.
  Stream<List<ClubCommentModel>> getClubPostCommentsStream(
      String clubId, String postId) {
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
    final newMember = ClubMemberModel(
        id: memberId, userId: memberId, joinedAt: Timestamp.now());
    final memberRef = clubRef.collection('members').doc(memberId);
    final userRef = _users.doc(memberId);
    final chatRoomRef = _chats.doc(clubId);

    batch.set(memberRef, newMember.toJson());
    batch.update(clubRef, {'membersCount': FieldValue.increment(1)});
    batch.update(userRef, {
      'clubs': FieldValue.arrayUnion([clubId])
    });
    batch.update(chatRoomRef, {
      'participants': FieldValue.arrayUnion([memberId]),
      'unreadCounts.$memberId': 0,
    });

    await batch.commit();
  }

  // V V V --- [추가] 동호회 게시글 '좋아요' 토글 함수 --- V V V
  Future<void> toggleClubPostLike(
      String clubId, String postId, bool isLiked) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final batch = _firestore.batch();
    final postRef = _clubs.doc(clubId).collection('posts').doc(postId);
    final userRef = _users.doc(currentUserId);

    if (isLiked) {
      // 좋아요 취소
      batch.update(postRef, {'likesCount': FieldValue.increment(-1)});
      batch.update(userRef, {
        'bookmarkedClubPostIds': FieldValue.arrayRemove([postId])
      });
    } else {
      // 좋아요 누르기
      batch.update(postRef, {'likesCount': FieldValue.increment(1)});
      batch.update(userRef, {
        'bookmarkedClubPostIds': FieldValue.arrayUnion([postId])
      });
    }

    await batch.commit();
  }

  // V V V --- [추가] 모임 제안 정보 수정 --- V V V
  Future<void> updateClubProposal(ClubProposalModel proposal) async {
    await _clubProposals.doc(proposal.id).update(proposal.toJson());
  }

  // V V V --- [추가] 모임 제안 삭제 --- V V V
  Future<void> deleteClubProposal(String proposalId) async {
    await _clubProposals.doc(proposalId).delete();
  }
}
