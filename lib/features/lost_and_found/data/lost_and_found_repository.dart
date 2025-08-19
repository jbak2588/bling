// lib/features/lost_and_found/data/lost_and_found_repository.dart

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LostAndFoundRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // [수정] 컬렉션 참조를 위한 getter를 정의하여 코드 일관성을 유지합니다.
  CollectionReference<Map<String, dynamic>> get _lostAndFoundCollection =>
      _firestore.collection('lost_and_found');

  /// 'lost_and_found' 컬렉션의 모든 게시글 목록을 실시간으로 가져옵니다.
  Stream<List<LostItemModel>> fetchItems() {
    return _lostAndFoundCollection // [수정] getter 사용
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
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