// lib/features/categories/services/category_sync_service.dart
// Cloud Functions(httpsCallable)로 카테고리 디자인/AI 룰 JSON을 재생성합니다.
import 'package:cloud_functions/cloud_functions.dart';

class CategorySyncService {
  final FirebaseFunctions _functions;
  CategorySyncService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> publishDesignAndRules() async {
    final callable = _functions.httpsCallable('exportCategoriesDesign');
    await callable.call(<String, dynamic>{}); // 인증/권한은 Functions에서 검사
  }
}
