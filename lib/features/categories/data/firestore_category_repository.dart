// Firestore 카테고리 저장소(아이콘은 'ms:*' 문자열만 저장)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/category.dart';
import 'category_repository.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _parents =>
      _db.collection('categories_v2');
  CollectionReference<Map<String, dynamic>> get _subs =>
      _db.collection('categories');

  @override
  Stream<List<Category>> watchParents({bool activeOnly = true}) {
    Query<Map<String, dynamic>> q = _parents.orderBy('order');
    if (activeOnly) q = q.where('active', isEqualTo: true);
    return q
        .snapshots()
        .map((s) => s.docs.map(Category.fromFirestore).toList());
  }

  @override
  Stream<List<Category>> watchSubs(String parentId, {bool activeOnly = true}) {
    Query<Map<String, dynamic>> q =
        _subs.where('parentId', isEqualTo: parentId).orderBy('order');
    if (activeOnly) q = q.where('active', isEqualTo: true);
    return q
        .snapshots()
        .map((s) => s.docs.map(Category.fromFirestore).toList());
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
    await _subs.doc(model.id).set(model.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateParentFields(String id, Map<String, dynamic> fields) =>
      _parents.doc(id).update(fields);

  @override
  Future<void> updateSubFields(
          String parentId, String id, Map<String, dynamic> fields) =>
      _subs.doc(id).update(fields);

  @override
  Future<void> deleteSub(String parentId, String id) => _subs.doc(id).delete();

  @override
  Future<void> deleteParentWithSubs(String id) async {
    final batch = _db.batch();
    batch.delete(_parents.doc(id));
    final subs = await _subs.where('parentId', isEqualTo: id).get();
    for (final d in subs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
