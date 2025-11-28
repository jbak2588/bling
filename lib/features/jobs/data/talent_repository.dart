// lib/features/jobs/data/talent_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/talent_model.dart';

class TalentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'talents';

  /// 1. 재능 게시글 생성
  Future<void> createTalent(TalentModel talent) async {
    await _firestore.collection(_collection).add(talent.toJson());
  }

  /// 2. 재능 게시글 수정
  Future<void> updateTalent(String talentId, Map<String, dynamic> data) async {
    // 수정일 업데이트 자동 반영
    final updateData = Map<String, dynamic>.from(data);
    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection(_collection).doc(talentId).update(updateData);
  }

  /// 3. 재능 게시글 삭제
  Future<void> deleteTalent(String talentId) async {
    await _firestore.collection(_collection).doc(talentId).delete();
  }

  /// 4. 재능 목록 조회 (필터링 & 페이지네이션)
  /// - [category]: 특정 카테고리 필터 (없으면 전체)
  /// - [limit]: 한 번에 가져올 개수
  /// - [lastDoc]: 무한 스크롤용 마지막 문서 스냅샷
  Future<List<TalentModel>> fetchTalents({
    String? category,
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .where('isVisible', isEqualTo: true) // 판매 중인 것만 노출
        .orderBy('createdAt', descending: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TalentModel.fromFirestore(doc)).toList();
  }

  /// 5. 내가 등록한 재능 조회
  Stream<List<TalentModel>> fetchMyTalents(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TalentModel.fromFirestore(doc))
            .toList());
  }

  /// 6. 단일 재능 상세 조회
  Future<TalentModel?> getTalentById(String talentId) async {
    final doc = await _firestore.collection(_collection).doc(talentId).get();
    if (doc.exists) {
      return TalentModel.fromFirestore(doc);
    }
    return null;
  }
}
