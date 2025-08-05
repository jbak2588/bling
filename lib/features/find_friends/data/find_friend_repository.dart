// lib/features/find_friends/data/find_friend_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/friend_request_model.dart';
import '../../../core/models/user_model.dart';

// import 'package:firebase_auth/firebase_auth.dart';

/// Firestore helper for FindFriend features.
class FindFriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
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

  Future<void> acceptFriendRequest(String requestId, String fromUserId, String toUserId) async {
    // WriteBatch를 사용하면 여러 작업을 하나의 원자적 단위로 처리하여 안정성을 높입니다.
    final batch = _firestore.batch();

    // 1. friend_requests 컬렉션에서 해당 요청 문서의 status를 'accepted'로 변경
    final requestRef = _requests.doc(requestId);
    batch.update(requestRef, {'status': 'accepted'});

   // --- 2. [추가] 새로운 1:1 채팅방 생성 로직 ---
   // 기존 ChatService의 getChatRoomId 로직을 활용하여 고유한 채팅방 ID 생성
   List<String> ids = [fromUserId, toUserId];
   ids.sort();
   String chatRoomId = ids.join('_');
   
   final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);
 
   // 생성할 채팅방의 초기 데이터 설정
   final chatRoomData = {
     'participants': [fromUserId, toUserId],
     'lastMessage': '이제 친구가 되었습니다! 대화를 시작해보세요.', // TODO: 다국어
     'lastMessageTimestamp': FieldValue.serverTimestamp(),
     'unreadCounts': {
       fromUserId: 0,
       toUserId: 0,
     },
   };
   
   // batch에 채팅방 생성 작업을 추가 (set.merge를 사용하여, 혹시 방이 있어도 덮어쓰지 않음)
   batch.set(chatRoomRef, chatRoomData, SetOptions(merge: true));

    // 4. 모든 작업을 한 번에 실행
    await batch.commit();
  }

  Future<void> rejectFriendRequest(String requestId) async {
    // 요청 문서의 status를 'rejected'로 변경
    await _requests.doc(requestId).update({'status': 'rejected'});
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

  // V V V --- [수정] 성별 필터링 기능이 추가된 함수 --- V V V
 Stream<List<UserModel>> getUsersForFindFriends(UserModel currentUser) {
   // 1. Firestore 쿼리를 시작합니다.
   Query query = _firestore
       .collection('users')
       .where('isDatingProfile', isEqualTo: true)
       .where('isVisibleInList', isEqualTo: true)
       .where('uid', isNotEqualTo: currentUser.uid);
 
   // 2. 현재 사용자의 '찾고 싶은 성별' 설정을 가져옵니다.
   final genderPreference = currentUser.privacySettings?['genderPreference'];
 
   // 3. '상관없음(all)'이 아닐 경우에만, 성별 필터링 쿼리를 추가합니다.
   if (genderPreference == 'male') {
     query = query.where('gender', isEqualTo: 'male');
   } else if (genderPreference == 'female') {
     query = query.where('gender', isEqualTo: 'female');
   }
 
   // 4. 최종 쿼리를 실행하고 결과를 반환합니다.
   return query.snapshots().map((snapshot) {
     return snapshot.docs.map((doc) {
       return UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
     }).toList();
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
        .snapshots()
        .map((s) =>
            s.docs.map(FriendRequestModel.fromFirestore).toList());
  }

  Stream<List<FriendRequestModel>> getSentRequests(String userId) {
    return _requests
        .where('fromUserId', isEqualTo: userId)
        .snapshots()
        .map((s) =>
            s.docs.map(FriendRequestModel.fromFirestore).toList());
  }
}
