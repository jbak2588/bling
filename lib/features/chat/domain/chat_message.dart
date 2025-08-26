/// ============================================================================
/// Bling DocHeader
/// Module        : Chat
/// File          : lib/features/chat/domain/chat_message.dart
/// Purpose       : 단일 채팅 메시지를 표현하는 데이터 모델입니다.
/// User Impact   : 모듈 전반에서 메시지 구조를 표준화합니다.
/// Feature Links : lib/features/chat/data/chat_service.dart; lib/features/chat/screens/chat_room_screen.dart
/// Data Model    : Firestore `messages` 필드 `senderId`, `text`, `timestamp`, `readBy`.
/// Location Scope: 없음.
/// Trust Policy  : 메시지는 신고될 수 있으며 발신자의 신뢰 등급에 영향을 줍니다.
/// Monetization  : 없음.
/// KPIs          : `send_message`, `read_message` 이벤트 추적을 가능하게 합니다.
/// Analytics     : `readBy`에 읽음 확인을 저장합니다.
/// I18N          : 없음.
/// Dependencies  : cloud_firestore
/// Security/Auth : 발신자 ID를 인증된 사용자와 비교하여 검증합니다.
/// Edge Cases    : 텍스트나 타임스탬프가 없으면 `Timestamp.now()`로 대체합니다.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/07 Chat 모듈 Core.md; docs/team/teamC_Chat & Notification 모듈_통합 작업문서.md
/// ============================================================================
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 메시지 데이터 모델(senderId, text, timestamp, readBy 등), KPI/Analytics, 신뢰등급, Edge case 처리
///
/// 2. 실제 코드 분석
///   - 메시지 데이터 모델, KPI/Analytics(메시지 전송/읽음), 신뢰등급, Edge case 처리
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 신뢰등급·Edge case·KPI/Analytics 등 품질·운영 기능 강화
///   - 기획에 못 미친 점: 활동 히스토리, 광고 슬롯 등 일부 기능 미구현, 신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - 데이터 모델 확장(활동 히스토리, KPI/Analytics 필드 추가), 에러 핸들링 강화, 광고/추천글 연계
library;
// 아래부터 실제 코드

// lib/features/chat/domain/chat_message.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  // 'isRead' -> 'readBy'로 변경. 여러 참여자의 읽음 상태를 기록할 수 있음.
  final List<String> readBy;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: (data['text'] ?? '').toString(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      // Firestore에서 List<String> 타입으로 데이터를 가져옴
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  // ⭐️ [추가] 이 toJson() 함수를 클래스 내부에 추가해주세요.
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }
}
