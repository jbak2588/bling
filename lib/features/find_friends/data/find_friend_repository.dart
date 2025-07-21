// lib/features/find_friends/data/find_friend_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/friend_request_model.dart';
import '../../../core/models/user_model.dart';

/// Firestore helper for FindFriend features.
class FindFriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
