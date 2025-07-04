// lib/features/chat/domain/chat_utils.dart

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
