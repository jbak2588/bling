// lib/features/lost_and_found/data/lost_and_found_repository.dart

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LostAndFoundRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // [수정] 컬렉션 참조를 위한 getter를 정의하여 코드 일관성을 유지합니다.
  CollectionReference<Map<String, dynamic>> get _lostAndFoundCollection =>
      _firestore.collection('lost_and_found');

  // [참고] 화면단(Screen)에서 직접 쿼리를 구성하므로 이 함수는 보조적으로 사용됩니다.
  Stream<List<LostItemModel>> fetchItems(
      {Map<String, String?>? locationFilter, String? itemType}) {
    // ✅ [작업 39] 'lost'/'found' 필터 파라미터 추가
    Query<Map<String, dynamic>> query = _firestore
        .collection('lost_and_found')
        .orderBy('createdAt', descending: true);

    if (locationFilter != null) {
      if (locationFilter['prov'] != null &&
          locationFilter['prov']!.isNotEmpty) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
      if (locationFilter['kab'] != null && locationFilter['kab']!.isNotEmpty) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
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

    // ✅ [작업 39] itemType이 null이 아니면(즉, 'all' 탭이 아니면) 'type' 필드 필터링
    if (itemType != null && itemType.isNotEmpty) {
      query = query.where('type', isEqualTo: itemType);
    }

    // ✅ [작업 6] 하드코딩된 'Tangerang' 폴백 제거.
    // 실제 위치 기반 필터링 결과만 반환하여 데이터 정확성 확보.
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LostItemModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 새로운 분실/습득물을 생성하는 함수입니다.
  Future<void> createItem(LostItemModel item) async {
    await _lostAndFoundCollection.add(item.toJson()); // [수정] getter 사용
  }

  /// 분실/습득물 정보를 수정하는 함수입니다.
  Future<void> updateItem(LostItemModel item) async {
    await _lostAndFoundCollection.doc(item.id).update(item.toJson());
  }

  /// 분실/습득물 정보를 삭제하는 함수입니다.
  Future<void> deleteItem(String itemId) async {
    // TODO: Storage에 업로드된 관련 이미지도 함께 삭제하는 로직 추가 필요
    await _lostAndFoundCollection.doc(itemId).delete();
  }

  // ✅ [작업 3 - 미담화] 해결 처리 및 미담 점수 부여 트랜잭션
  Future<void> resolveItemWithReview({
    required String itemId,
    required String? resolverId, // 도움을 준 유저 ID (없으면 null)
    required String? reviewText, // 후기 텍스트
  }) async {
    final itemRef = _lostAndFoundCollection.doc(itemId);

    await _firestore.runTransaction((transaction) async {
      // 1. 게시물 업데이트 준비
      final Map<String, dynamic> itemUpdateData = {
        'isResolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
      };

      if (resolverId != null) {
        itemUpdateData['resolverId'] = resolverId;
      }
      if (reviewText != null && reviewText.isNotEmpty) {
        itemUpdateData['reviewText'] = reviewText;
      }

      // 2. 만약 도움 준 이웃(Resolver)이 있다면 신뢰도 점수 업데이트
      if (resolverId != null) {
        final userRef = _firestore.collection('users').doc(resolverId);
        // 유저 문서 읽기 (트랜잭션 내 필수)
        final userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          // 점수 부여 정책: 미담 1회당 TrustScore +10, ThanksReceived +1
          final int currentTrust =
              (userSnapshot.data()?['trustScore'] ?? 0) as int;
          final int currentThanks =
              (userSnapshot.data()?['thanksReceived'] ?? 0) as int;

          transaction.update(userRef, {
            'trustScore': currentTrust + 10,
            'thanksReceived': currentThanks + 1,
          });
        }
      }

      // 3. 게시물 최종 업데이트
      transaction.update(itemRef, itemUpdateData);
    });
  }
}
