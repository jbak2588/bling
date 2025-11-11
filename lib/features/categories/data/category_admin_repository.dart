// lib/features/categories/data/category_admin_repository.dart
// 관리자 전용 저장소: Firestore에 카테고리/서브카테고리를 CRUD합니다.
// Publish 시 Cloud Functions(Export) 호출은 별도 service에서 담당합니다.

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryAdminRepository {
  final FirebaseFirestore _db;
  CategoryAdminRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('categories_v2');

  Future<List<Map<String, dynamic>>> fetchParents() async {
    final snap = await _col.orderBy('order').get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<List<Map<String, dynamic>>> fetchSubcategories(String parentId) async {
    final snap = await _col
        .doc(parentId)
        .collection('subCategories')
        .orderBy('order')
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> upsertParent({
    required String id, // 사용자가 지정한 slug 또는 자동 생성된 문서 id
    required String nameKo,
    required String nameId,
    required String nameEn,
    required int order,
    required bool active,
    String? icon,
    required String updatedBy,
  }) async {
    await _col.doc(id).set({
      'slug': id,
      'nameKo': nameKo,
      'nameId': nameId,
      'nameEn': nameEn,
      'order': order,
      'active': active,
      'icon': icon,
      'isParent': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
    }, SetOptions(merge: true));
  }

  Future<void> deleteParent(String id) async {
    // 주의: subCategories를 먼저 삭제해야 함
    final subs = await _col.doc(id).collection('subCategories').get();
    for (final d in subs.docs) {
      await d.reference.delete();
    }
    await _col.doc(id).delete();
  }

  Future<void> upsertSubcategory({
    required String parentId,
    required String id,
    required String nameKo,
    required String nameId,
    required String nameEn,
    required int order,
    required bool active,
    String? icon,
    required String updatedBy,
  }) async {
    await _col.doc(parentId).collection('subCategories').doc(id).set({
      'slug': id,
      'nameKo': nameKo,
      'nameId': nameId,
      'nameEn': nameEn,
      'order': order,
      'active': active,
      'icon': icon,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
    }, SetOptions(merge: true));
  }

  Future<void> deleteSubcategory(String parentId, String subId) async {
    await _col.doc(parentId).collection('subCategories').doc(subId).delete();
  }
}
