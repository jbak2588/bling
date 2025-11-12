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
    try {
      await callable.call(<String, dynamic>{}); // 인증/권한은 Functions에서 검사
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        // Cloud Functions에서 관리자만 허용할 때
        throw NotAdminException('관리자만 가능합니다.');
      }
      rethrow;
    }
  }
}

/// 관리자 권한 부족 시 UI에서 캐치하기 위한 명확한 예외 타입
class NotAdminException implements Exception {
  final String message;
  NotAdminException(this.message);
  @override
  String toString() => message;
}
