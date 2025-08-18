// lib/features/pom/data/short_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/short_model.dart';
import '../../../core/models/short_comment_model.dart';

class ShortRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _shortsCollection =>
      _firestore.collection('shorts');
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');


// V V V --- [추가] 특정 POM 영상 하나만 실시간으로 감시하는 함수 --- V V V
  Stream<ShortModel> getShortStream(String shortId) {
    return _shortsCollection.doc(shortId).snapshots()
        .map((snapshot) => ShortModel.fromFirestore(snapshot));
  }


  Stream<List<ShortModel>> fetchShorts() {
    return _shortsCollection
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ShortModel.fromFirestore(doc)).toList());
  }

// V V V --- [추가] POM 목록을 한 번만 가져오는 함수 --- V V V
  Future<List<ShortModel>> fetchShortsOnce() async {
    final snapshot = await _shortsCollection
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => ShortModel.fromFirestore(doc)).toList();
  }
  
  Future<String> createShort(ShortModel short) async {
    final docRef = await _shortsCollection.add(short.toJson());
    return docRef.id;
  }

  // V V V --- [추가] POM '좋아요' 토글 함수 --- V V V
  Future<void> toggleShortLike(String shortId, bool isLiked) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final shortRef = _shortsCollection.doc(shortId);
    final userRef = _usersCollection.doc(currentUserId);

    final batch = _firestore.batch();

    if (isLiked) {
      // 좋아요 취소
      batch.update(shortRef, {
        'likesCount': FieldValue.increment(-1),
        'likes': FieldValue.arrayRemove([currentUserId])
      });
      batch.update(userRef, {
        'likedShortIds': FieldValue.arrayRemove([shortId])
      });
    } else {
      // 좋아요 누르기
      batch.update(shortRef, {
        'likesCount': FieldValue.increment(1),
        'likes': FieldValue.arrayUnion([currentUserId])
      });
      batch.update(userRef, {
        'likedShortIds': FieldValue.arrayUnion([shortId])
      });
    }
    await batch.commit();
  }
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  Stream<List<ShortCommentModel>> getShortCommentsStream(String shortId) {
    return _shortsCollection
        .doc(shortId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShortCommentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addShortComment(String shortId, ShortCommentModel comment) async {
    final shortRef = _shortsCollection.doc(shortId);
    final commentRef = shortRef.collection('comments').doc();

    final batch = _firestore.batch();
    batch.set(commentRef, comment.toJson());
    batch.update(shortRef, {'commentsCount': FieldValue.increment(1)});
    await batch.commit();
  }
}