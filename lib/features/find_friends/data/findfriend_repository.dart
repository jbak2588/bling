// lib/features/find_friends/data/findfriend_repository.dart
// Repository implementation for FindFriend feature

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/findfriend_model.dart';

class FindFriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _profilesCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _requestsCollection =>
      _firestore.collection('match_requests');

  Future<void> saveProfile(FindFriend profile) async {
    await _profilesCollection.doc(profile.userId).set({
      'findfriend': profile.toJson(),
    }, SetOptions(merge: true));
  }

  Stream<List<FindFriend>> getNearbyFriends() {
    // For now just fetch all profiles where isDatingProfile is true
    return _profilesCollection
        .where('findfriend.isDatingProfile', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data()['findfriend'] as Map<String, dynamic>?;
              if (data == null) return null;
              return FindFriend.fromMap(data, doc.id);
            }).whereType<FindFriend>().toList());
  }

  Future<void> deleteProfile(String userId) async {
    await _profilesCollection.doc(userId).update({
      'findfriend.isDatingProfile': false,
    });
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    await _requestsCollection.add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _requestsCollection.doc(requestId).update({'status': 'accepted'});
  }

  Stream<List<FindFriend>> getLikedMe(String userId) {
    return _requestsCollection
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
      final profiles = <FindFriend>[];
      for (var doc in snapshot.docs) {
        final fromUserId = doc.data()['fromUserId'] as String?;
        if (fromUserId != null) {
          final profileDoc = await _profilesCollection.doc(fromUserId).get();
          final data = profileDoc.data()?['findfriend'];
          if (data != null) {
            profiles.add(FindFriend.fromMap(
                Map<String, dynamic>.from(data), fromUserId));
          }
        }
      }
      return profiles;
    });
  }

  Stream<List<FindFriend>> getILiked(String userId) {
    return _requestsCollection
        .where('fromUserId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final profiles = <FindFriend>[];
      for (var doc in snapshot.docs) {
        final toUserId = doc.data()['toUserId'] as String?;
        if (toUserId != null) {
          final profileDoc = await _profilesCollection.doc(toUserId).get();
          final data = profileDoc.data()?['findfriend'];
          if (data != null) {
            profiles.add(FindFriend.fromMap(
                Map<String, dynamic>.from(data), toUserId));
          }
        }
      }
      return profiles;
    });
  }

  Future<void> createChatRoom(String userId1, String userId2) async {
    final participants = [userId1, userId2]..sort();
    final chatId = participants.join('_');
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': participants,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
