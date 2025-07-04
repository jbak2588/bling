// lib/features/categories/domain/category.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String nameKo;
  final String nameEn;
  final String nameId;
  final String? parentId;
  final int order;

  Category({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.nameId,
    this.parentId,
    required this.order,
  });

  factory Category.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    // ▼▼▼▼▼ 여기가 핵심 수정 포인트입니다 ▼▼▼▼▼
    // order 필드의 타입을 확인하고, 문자열이면 숫자로 변환을 시도합니다.
    dynamic orderData = data['order'];
    int finalOrder = 99; // 기본값
    if (orderData is int) {
      finalOrder = orderData;
    } else if (orderData is String) {
      finalOrder = int.tryParse(orderData) ?? 99;
    }
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    return Category(
      id: snapshot.id,
      nameKo: data['name_ko'] ?? '',
      nameEn: data['name_en'] ?? '',
      nameId: data['name_id'] ?? '',
      parentId: data['parentId'],
      order: finalOrder, // 안전하게 처리된 값을 사용
    );
  }
}
