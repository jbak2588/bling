// ===================== DocHeader =====================
// [기획 요약]
// - 'pom' 컬렉션에 대한 Firestore CRUD 로직.
// [V2 - 2025-11-03]
// - 'ShortRepository'에서 'PomRepository'로 리네이밍.
// - 탭 기능 지원 (fetchPomsOnce, fetchPopularPoms, fetchMyPoms).
// - 'addPomReport' (게시물 신고) 기능 추가.
// [V3 - 2025-11-04]
// - 'searchPomsByKeyword': 'searchIndex' 필드 기반 서버사이드 검색 기능 추가.
// - 페이지네이션(lastDoc) 지원 로직 추가.
// =====================================================

// lib/features/pom/data/pom_repository.dart

// ignore_for_file: file_names

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

  /// 3. [V2] 인기 뽐 (좋아요 순 정렬)
  Future<List<PomModel>> fetchPopularPoms(
      {Map<String, String?>? locationFilter, DocumentSnapshot? lastDoc}) async {
    Query<Map<String, dynamic>> query =
        _pomCollection.orderBy('likesCount', descending: true);

    // 위치 필터 (선택적)
    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    query = query.limit(20);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => PomModel.fromFirestore(doc)).toList();
  }

  /// 4. [V2] 내 뽐 (내 아이디 + 최신순)
  Future<List<PomModel>> fetchMyPoms({DocumentSnapshot? lastDoc}) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    Query<Map<String, dynamic>> query = _pomCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    query = query.limit(20);
    final snapshot = await query.get();
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

  /// [V2] Pom 게시물 신고
  Future<void> addPomReport({
    required String reportedPomId,
    required String reportedUserId,
    required String reasonKey,
  }) async {
    final reporterId = _auth.currentUser?.uid;
    if (reporterId == null) {
      throw Exception('User not logged in');
    }

    if (reportedUserId == reporterId) {
      throw Exception('reportDialog.cannotReportSelf');
    }

    final reportData = {
      'reportedContentId': reportedPomId,
      'reportedContentType': 'pom', // [V2]
      'reportedUserId': reportedUserId,
      'reporterUserId': reporterId,
      'reason': reasonKey,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('reports').add(reportData);
  }

  // [V2] 서버측 키워드 검색 (searchIndex 배열 기반)
  Future<List<PomModel>> searchPomsByKeyword({
    required String keyword,
    Map<String, String?>? locationFilter,
    int limit = 20,
  }) async {
    var kw = keyword.trim().toLowerCase();
    if (kw.isEmpty) return [];

    Query<Map<String, dynamic>> query =
        _pomCollection.where('searchIndex', arrayContains: kw);

    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    // 최신순 정렬 (필요 시 인덱스 추가 필요)
    try {
      query = query.orderBy('createdAt', descending: true);
    } catch (_) {
      // 인덱스 문제 시 정렬 없이 진행
    }
    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => PomModel.fromFirestore(doc)).toList();
  }
}
