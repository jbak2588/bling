// Firestore 카테고리 저장소(아이콘은 'ms:*' 문자열만 저장)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/category.dart';
import 'category_repository.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _parents =>
      _db.collection('categories_v2');
  // v2: subCategories는 각 부모 도큐먼트 하위 서브컬렉션으로 존재
  CollectionReference<Map<String, dynamic>> _subsOf(String parentId) =>
      _db.collection('categories_v2').doc(parentId).collection('subCategories');

  @override
  Stream<List<Category>> watchParents({bool activeOnly = true}) {
    Query<Map<String, dynamic>> q = _parents.where('isParent', isEqualTo: true);
    if (activeOnly) q = q.where('active', isEqualTo: true);
    q = q.orderBy('order');
    return q.snapshots().map(
          (s) => s.docs.map((d) => Category.fromFirestore(d)).toList(),
        );
  }

  @override
  Stream<List<Category>> watchSubs(String parentId, {bool activeOnly = true}) {
    final col = _subsOf(parentId);
    final q = activeOnly ? col.where('active', isEqualTo: true) : col;
    return q.orderBy('order').snapshots().map(
          (s) => s.docs.map((d) => Category.fromFirestore(d)).toList(),
        );
  }

  @override
  Future<void> upsertParent(Category model) async {
    if (model.id.isEmpty) {
      final ref = await _parents.add(model.toMap());
      await ref.update({'id': ref.id});
    } else {
      await _parents.doc(model.id).set(model.toMap(), SetOptions(merge: true));
    }
  }

  @override
  Future<void> upsertSub(String parentId, Category model) async {
    await _subsOf(parentId).doc(model.id).set(
          model.toSubMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> updateParentFields(String id, Map<String, dynamic> fields) =>
      _parents.doc(id).update(fields);

  @override
  Future<void> updateSubFields(
      String parentId, String id, Map<String, dynamic> data) async {
    await _subsOf(parentId).doc(id).update(data);
  }

  @override
  Future<void> deleteSub(String parentId, String id) async {
    await _subsOf(parentId).doc(id).delete();
  }

  @override
  Future<void> deleteParentWithSubs(String parentId) async {
    final parentRef = _parents.doc(parentId);
    final subsSnap = await _subsOf(parentId).get();
    final batch = _db.batch();
    for (final d in subsSnap.docs) {
      batch.delete(d.reference);
    }
    batch.delete(parentRef);
    await batch.commit();
  }
}
