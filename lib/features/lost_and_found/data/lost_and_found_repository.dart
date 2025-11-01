// lib/features/lost_and_found/data/lost_and_found_repository.dart

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LostAndFoundRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // [수정] 컬렉션 참조를 위한 getter를 정의하여 코드 일관성을 유지합니다.
  CollectionReference<Map<String, dynamic>> get _lostAndFoundCollection =>
      _firestore.collection('lost_and_found');

  // V V V --- [수정] fetchItems 함수에 locationFilter를 적용합니다 --- V V V
  Stream<List<LostItemModel>> fetchItems(
      {Map<String, String?>? locationFilter, String? itemType}) {
    // ✅ [작업 39] 'lost'/'found' 필터 파라미터 추가
    Query<Map<String, dynamic>> query = _firestore
        .collection('lost_and_found')
        .orderBy('createdAt', descending: true);
    final String? kab = locationFilter?['kab'];

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

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        final fallbackSnapshot = await _firestore
            .collection('lost_and_found')
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('createdAt', descending: true)
            .get();
        return fallbackSnapshot.docs
            .map((doc) => LostItemModel.fromFirestore(doc))
            .toList();
      }
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
}
