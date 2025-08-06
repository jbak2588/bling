// lib/features/find_friends/data/find_friend_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/friend_request_model.dart';
import '../../../core/models/user_model.dart';

// import 'package:firebase_auth/firebase_auth.dart';

/// Firestore helper for FindFriend features.
class FindFriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('friend_requests');

  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<List<UserModel>> getNearbyFriends(String kab) {
    return _users
        .where('isDatingProfile', isEqualTo: true)
        .where('isVisibleInList', isEqualTo: true)
        .where('neighborhoodVerified', isEqualTo: true)
        .where('locationParts.kab', isEqualTo: kab)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  // V V V --- [수정] 누락되었던 친구 추가 로직을 복원한 최종 버전 --- V V V
  Future<void> acceptFriendRequest(
      String requestId, String fromUserId, String toUserId) async {
    try {
      debugPrint("--- 친구 요청 수락 시작 ---");
      final batch = _firestore.batch();

      // 1. friend_requests 컬렉션에서 해당 요청 문서의 status를 'accepted'로 변경
      final requestRef = _requests.doc(requestId);
      batch.update(requestRef, {'status': 'accepted'});

      // 2. [복원] 요청을 보낸 사람(fromUser)의 friends 목록에 받는 사람(toUser)의 ID를 추가
      final fromUserRef = _users.doc(fromUserId);
      batch.update(fromUserRef, {
        'friends': FieldValue.arrayUnion([toUserId])
      });

      // 3. [복원] 요청을 받은 사람(toUser)의 friends 목록에 보낸 사람(fromUser)의 ID를 추가
      final toUserRef = _users.doc(toUserId);
      batch.update(toUserRef, {
        'friends': FieldValue.arrayUnion([fromUserId])
      });

      // 4. 새로운 1:1 채팅방 생성 로직
      List<String> ids = [fromUserId, toUserId];
      ids.sort();
      String chatRoomId = ids.join('_');
      final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);
      final chatRoomData = {
        'participants': [fromUserId, toUserId],
        'lastMessage': 'friendRequests.defaultChatMessage'.tr(),
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {fromUserId: 0, toUserId: 0},
      };
      batch.set(chatRoomRef, chatRoomData, SetOptions(merge: true));

      // 5. 모든 작업을 한 번에 실행
      await batch.commit();
      debugPrint("--- 친구 요청 수락 성공 (Batch Commit 완료) ---");
    } catch (e) {
      debugPrint("!!! 친구 요청 수락 중 에러 발생: $e !!!");
      rethrow;
    }
  }

  // V V V --- [수정] 친구 요청 거절 시, 거절당한 사람을 목록에 추가하는 로직 --- V V V
  Future<void> rejectFriendRequest(
      String requestId, String fromUserId, String toUserId) async {
    final batch = _firestore.batch();

    // 1. 요청 문서의 status를 'rejected'로 변경
    final requestRef = _requests.doc(requestId);
    batch.update(requestRef, {'status': 'rejected'});

    // 2. 요청을 받은 사람(toUser, 거절한 사람)의 rejectedUsers 목록에 요청 보낸 사람(fromUser)의 ID를 추가
    final toUserRef = _users.doc(toUserId);
    batch.update(toUserRef, {
      'rejectedUsers': FieldValue.arrayUnion([fromUserId])
    });

    await batch.commit();
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
   Future<void> unrejectUser(String currentUserId, String rejectedUserId) async {
    await _users.doc(currentUserId).update({
      'rejectedUsers': FieldValue.arrayRemove([rejectedUserId])
    });
  }

   // V V V --- [추가] 사용자 차단 해제 함수 --- V V V
  Future<void> unblockUser(String currentUserId, String blockedUserId) async {
    await _users.doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId])
    });
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    final existing = await _requests
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .get();
    if (existing.docs.isNotEmpty) return;
    await _requests.add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  // V V V --- [수정] 친구 목록을 불러올 때, 거절/차단한 사용자를 제외하는 로직 --- V V V
  Stream<List<UserModel>> getUsersForFindFriends(UserModel currentUser) {
    Query query = _firestore
        .collection('users')
        .where('isDatingProfile', isEqualTo: true)
        .where('isVisibleInList', isEqualTo: true);

    final rejectedUids = currentUser.rejectedUsers ?? [];
    final blockedUids = currentUser.blockedUsers ?? [];
    final excludedUids =
        {...rejectedUids, ...blockedUids, currentUser.uid}.toList();

    if (excludedUids.isNotEmpty) {
      query = query.where(FieldPath.documentId,
          whereNotIn: excludedUids.take(10).toList());
    }

    final genderPreference = currentUser.privacySettings?['genderPreference'];
    if (genderPreference == 'male') {
      query = query.where('gender', isEqualTo: 'male');
    } else if (genderPreference == 'female') {
      query = query.where('gender', isEqualTo: 'female');
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(
              doc as QueryDocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  Stream<QuerySnapshot> getRequestStatus(String fromUserId, String toUserId) {
    return _requests
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1) // 요청은 하나만 존재할 것이므로
        .snapshots();
  }

  Future<void> respondRequest(String requestId, String status) async {
    await _requests.doc(requestId).update({'status': status});
  }

  Stream<List<FriendRequestModel>> getReceivedRequests(String userId) {
    return _requests
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending') // 이 조건이 핵심입니다.
        .snapshots()
        .map((s) => s.docs.map(FriendRequestModel.fromFirestore).toList());
  }

  Stream<List<FriendRequestModel>> getSentRequests(String userId) {
    return _requests
        .where('fromUserId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map(FriendRequestModel.fromFirestore).toList());
  }
}
