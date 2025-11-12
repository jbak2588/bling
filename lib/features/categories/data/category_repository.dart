// lib/features/categories/data/category_repository.dart
//
// Bling - Category Repository Interface
// Purpose : UI/BLoC에서 Firestore 접근을 분리하여, 부모/서브 카테고리의
//           읽기/쓰기/삭제를 일관된 API로 제공합니다.

import '../domain/category.dart';

abstract class CategoryRepository {
  // ---------------- READ ----------------

  /// 부모 카테고리 스트림.
  /// [activeOnly]가 true면 active == true인 문서만 반환합니다.
  Stream<List<Category>> watchParents({bool activeOnly = false});

  /// 선택된 부모의 서브 카테고리 스트림.
  /// [parentDocId]는 'categories_v2'의 문서 ID입니다.
  /// [activeOnly]가 true면 active == true인 문서만 반환합니다.
  Stream<List<Category>> watchSubs(String parentDocId,
      {bool activeOnly = false});

  // ---------------- WRITE (ADMIN) ----------------

  /// 부모 카테고리 신규/수정 저장.
  /// [Category.id]가 비어있으면 구현체에서 새 문서를 생성할 수 있습니다.
  Future<void> upsertParent(Category parent);

  /// 부모 카테고리 일부 필드만 패치.
  Future<void> updateParentFields(
      String parentDocId, Map<String, dynamic> patch);

  /// 부모와 그 하위 서브 카테고리를 모두 삭제.
  Future<void> deleteParentWithSubs(String parentDocId);

  /// 서브 카테고리 신규/수정 저장.
  /// [Category.id]가 비어있으면 구현체에서 slug를 문서 ID로 사용할 수 있습니다.
  Future<void> upsertSub(String parentDocId, Category sub);

  /// 서브 카테고리 일부 필드만 패치.
  Future<void> updateSubFields(
      String parentDocId, String subId, Map<String, dynamic> patch);

  /// 서브 카테고리 삭제.
  Future<void> deleteSub(String parentDocId, String subId);
}
