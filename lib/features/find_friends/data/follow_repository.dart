// lib/features/find_friends/data/follow_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/follow_model.dart';

/// Provides CRUD operations for [FollowModel] using Firestore.
class FollowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('follows');

  /// Creates a new follow document in Firestore.
  Future<void> createFollow(FollowModel follow) async {
    await _collection.add(follow.toJson());
  }

  /// Deletes a follow document by its Firestore document ID.
  Future<void> deleteFollow(String followId) async {
    await _collection.doc(followId).delete();
  }

  /// Fetches all followers of a user by [userId].
  Future<List<FollowModel>> fetchFollowers(String userId) async {
    final snapshot =
        await _collection.where('toUserId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => FollowModel.fromFirestore(doc))
        .toList();
  }
}
