// lib/features/pom/data/pom_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pom_model.dart';
import '../models/pom_comment_model.dart';

class PomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // [V2 개선] 컬렉션 이름을 'shorts'에서 'pom'으로 변경
  CollectionReference<Map<String, dynamic>> get _pomCollection =>
      _firestore.collection('pom');
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

// V V V --- [V2 개선] PomModel 반환 --- V V V
  Stream<PomModel> getPomStream(String pomId) {
    return _pomCollection
        .doc(pomId)
        .snapshots()
        .map((snapshot) => PomModel.fromFirestore(snapshot));
  }

  Stream<List<PomModel>> fetchPoms({Map<String, String?>? locationFilter}) {
    Query<Map<String, dynamic>> query = _pomCollection;
    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }
    query = query.orderBy('createdAt', descending: true).limit(20);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        final fallbackSnapshot = await _pomCollection
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();
        return fallbackSnapshot.docs
            .map((doc) => PomModel.fromFirestore(doc))
            .toList();
      }
      return snapshot.docs.map((doc) => PomModel.fromFirestore(doc)).toList();
    });
  }

// V V V --- [V2 개선] PomModel 반환 --- V V V
  Future<List<PomModel>> fetchPomsOnce(
      {Map<String, String?>? locationFilter}) async {
    Query<Map<String, dynamic>> query =
        _pomCollection.orderBy('createdAt', descending: true);
    final String? kab = locationFilter?['kab'];

    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    if (locationFilter != null) {
      if (locationFilter['prov'] != null &&
          locationFilter['prov']!.isNotEmpty) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }

      if (locationFilter['kec'] != null && locationFilter['kec']!.isNotEmpty) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      }
      if (locationFilter['kel'] != null && locationFilter['kel']!.isNotEmpty) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      }
    }

    query = query.limit(20);
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
      final fallbackSnapshot = await _pomCollection
          .where('locationParts.kab', isEqualTo: 'Tangerang')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return fallbackSnapshot.docs
          .map((doc) => PomModel.fromFirestore(doc))
          .toList();
    }
    return snapshot.docs.map((doc) => PomModel.fromFirestore(doc)).toList();
  }

  Future<String> createPom(PomModel pom) async {
    final docRef = await _pomCollection.add(pom.toJson());
    return docRef.id;
  }

  // V V V --- [V2 개선] 'Short' -> 'Pom' --- V V V
  Future<void> togglePomLike(String pomId, bool isLiked) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final pomRef = _pomCollection.doc(pomId);
    final userRef = _usersCollection.doc(currentUserId);

    final batch = _firestore.batch();

    if (isLiked) {
      // 좋아요 취소
      batch.update(pomRef, {
        'likesCount': FieldValue.increment(-1),
        'likes': FieldValue.arrayRemove([currentUserId])
      });
      batch.update(userRef, {
        'likedPomIds': FieldValue.arrayRemove([pomId]) // [V2] 필드명 변경 제안
      });
    } else {
      // 좋아요 누르기
      batch.update(pomRef, {
        'likesCount': FieldValue.increment(1),
        'likes': FieldValue.arrayUnion([currentUserId])
      });
      batch.update(userRef, {
        'likedPomIds': FieldValue.arrayUnion([pomId]) // [V2] 필드명 변경 제안
      });
    }
    await batch.commit();
  }

  // V V V --- [V2 개선] 'Short' -> 'Pom' --- V V V
  Stream<List<PomCommentModel>> getPomCommentsStream(String pomId) {
    return _pomCollection
        .doc(pomId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PomCommentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addPomComment(String pomId, PomCommentModel comment) async {
    final pomRef = _pomCollection.doc(pomId);
    final commentRef = pomRef.collection('comments').doc();

    final batch = _firestore.batch();
    batch.set(commentRef, comment.toJson());
    batch.update(pomRef, {'commentsCount': FieldValue.increment(1)});
    await batch.commit();
  }
}
