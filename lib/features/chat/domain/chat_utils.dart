/// ============================================================================
/// Bling DocHeader
/// Module        : Chat
/// File          : lib/features/chat/domain/chat_utils.dart
/// Purpose       : 일관된 채팅방 식별자를 생성합니다.
/// User Impact   : 사용자 간 또는 상품 중심 대화가 고유하게 유지됩니다.
/// Feature Links : lib/features/chat/data/chat_service.dart
/// Data Model    : `chatRooms`와 상품 채팅방을 위한 ID를 구성합니다.
/// Location Scope: 없음.
/// Trust Policy  : 인증된 UID 입력에 의존합니다.
/// Monetization  : 없음.
/// KPIs          : `start_chat` 이벤트 로깅을 지원합니다.
/// Analytics     : ID 구조가 메시지 추적을 돕습니다.
/// I18N          : 없음.
/// Dependencies  : 없음
/// Security/Auth : 사용자 ID에서 파생된 ID로, 패턴 노출을 피해야 합니다.
/// Edge Cases    : UID가 동일하거나 누락되면 중복 ID가 발생합니다.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/07 Chat 모듈 Core.md; docs/team/teamC_Chat & Notification 모듈_통합 작업문서.md
/// ============================================================================
library;
// 아래부터 실제 코드

String makeChatId(String uid1, String uid2) {
  // 상품 ID가 아닌, 두 사용자 ID만으로 고유 ID를 생성합니다.
  // 이래야 두 사람 사이의 대화는 항상 하나로 유지됩니다.
  // 상품 정보는 채팅방 데이터 안에 저장하여 구분합니다.
  List<String> uids = [uid1, uid2];
  uids.sort();
  return uids.join('_');
}

// 상품 문의를 위한 별도의 채팅방 ID 생성 규칙
String makeProductChatId(String productId, String uid1, String uid2) {
  List<String> uids = [uid1, uid2];
  uids.sort();
  return '${productId}_${uids.join('_')}';
}
