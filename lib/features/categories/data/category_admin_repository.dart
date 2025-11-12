import '../../categories/domain/category.dart';

abstract class CategoryRepository {
  // Read
  Stream<List<Category>> watchParents({bool activeOnly = false});
  Stream<List<Category>> watchSubs(String parentDocId,
      {bool activeOnly = false});

  // Write (Admin)
  Future<void> upsertParent(Category parent); // 새로 만들거나 수정
  Future<void> updateParentFields(
      String parentDocId, Map<String, dynamic> patch);
  Future<void> deleteParentWithSubs(String parentDocId);

  Future<void> upsertSub(String parentDocId, Category sub);
  Future<void> updateSubFields(
      String parentDocId, String subId, Map<String, dynamic> patch);
  Future<void> deleteSub(String parentDocId, String subId);
}
