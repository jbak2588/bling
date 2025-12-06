/// ============================================================================
/// Bling DocHeader
/// Module        : Boards (동네 게시판)
/// File          : lib/features/boards/models/board_model.dart
/// Purpose       : 'boards/{kel_key}' 문서의 데이터 모델. Kelurahan 단위 게시판의
///                 통계(metrics) 및 활성화 기능(features)을 정의합니다.
///
/// Related Docs  : '하이브리드 방식 로컬 뉴스 게시글 개선 방안.md' (4. 동네 게시판)
///
/// 2025-10-30 (작업 8):
/// 2025-10-31 (작업 8):
///   - '하이브리드 기획안' 4)를 기반으로 BoardModel, BoardMetrics, BoardFeatures 신규 생성.
/// ============================================================================
library;
// (파일 내용...)

// lib/features/boards/models/board_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Kelurahan(동네) 단위 게시판 정보 모델
/// Firestore 'boards/{kel_key}' 컬렉션
/// (kel_key 예: "DKI|Jakarta Barat|Palmerah|Slipi")
class BoardModel {
  final String key; // Kelurahan 고유 키
  final Map<String, String> label; // 다국어 라벨 (en, id, ko)
  final BoardMetrics metrics; // 통계
  final BoardFeatures features; // 기능 활성화
  final Timestamp createdAt;
  final Timestamp updatedAt;

  BoardModel({
    required this.key,
    required this.label,
    required this.metrics,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BoardModel(
      key: doc.id,
      label: Map<String, String>.from(data['label'] ?? {}),
      metrics: BoardMetrics.fromMap(data['metrics'] ?? {}),
      features: BoardFeatures.fromMap(data['features'] ?? {}),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'metrics': metrics.toMap(),
      'features': features.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Compatibility getter: provide a readable label for components that
  /// expect `.title`. Prefer localized 'ko' label when present.
  String get title =>
      label['ko'] ?? (label.values.isNotEmpty ? label.values.first : key);
}

/// 게시판 통계 (metrics 필드)
class BoardMetrics {
  final int last30dPosts;
  final int last7dActiveUsers;

  BoardMetrics({
    this.last30dPosts = 0,
    this.last7dActiveUsers = 0,
  });

  factory BoardMetrics.fromMap(Map<String, dynamic> map) {
    return BoardMetrics(
      last30dPosts: map['last30dPosts'] ?? 0,
      last7dActiveUsers: map['last7dActiveUsers'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'last30dPosts': last30dPosts,
      'last7dActiveUsers': last7dActiveUsers,
    };
  }
}

/// 게시판 기능 (features 필드)
class BoardFeatures {
  final bool hasGroupChat;
  final List<String> verifiedInstitutions;

  BoardFeatures({
    this.hasGroupChat = false,
    this.verifiedInstitutions = const [],
  });

  factory BoardFeatures.fromMap(Map<String, dynamic> map) {
    return BoardFeatures(
      hasGroupChat: map['hasGroupChat'] ?? false,
      verifiedInstitutions: (map['verifiedInstitutions'] is List)
          ? List<String>.from(map['verifiedInstitutions'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasGroupChat': hasGroupChat,
      'verifiedInstitutions': verifiedInstitutions,
    };
  }
}
