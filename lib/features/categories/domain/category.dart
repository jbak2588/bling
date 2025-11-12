// lib/features/categories/domain/category.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/category_icons.dart';

class Category {
  final String id; // Firestore 문서 ID
  final String? parentId; // 부모 문서 ID (부모는 null)
  final String slug; // 사람이 읽는 slug (kebab)
  final String nameKo;
  final String nameId;
  final String nameEn;
  final int order;
  final bool active;
  final bool isParent; // 부모 문서만 true
  final String? icon; // 파일명 또는 풀패스 (권장: 파일명)

  const Category({
    required this.id,
    required this.parentId,
    required this.slug,
    required this.nameKo,
    required this.nameId,
    required this.nameEn,
    required this.order,
    required this.active,
    required this.isParent,
    required this.icon,
  });

  /// 부모 문서에서 생성
  factory Category.fromParentDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Category(
      id: doc.id,
      parentId: null,
      slug: (d['slug'] ?? d['id'] ?? doc.id).toString(),
      nameKo: (d['nameKo'] ?? d['name_ko'] ?? '').toString(),
      nameId: (d['nameId'] ?? d['name_id'] ?? '').toString(),
      nameEn: (d['nameEn'] ?? d['name_en'] ?? '').toString(),
      order: d['order'] is int
          ? d['order'] as int
          : int.tryParse('${d['order'] ?? 1}') ?? 1,
      active: d['active'] == true,
      isParent: d['isParent'] == true,
      icon: (d['icon'] ?? d['iconAsset'])?.toString(),
    );
  }

  /// 서브 문서에서 생성
  factory Category.fromSubDoc(
      String parentId, DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Category(
      id: doc.id,
      parentId: parentId,
      slug: (d['slug'] ?? d['id'] ?? doc.id).toString(),
      nameKo: (d['nameKo'] ?? d['name_ko'] ?? '').toString(),
      nameId: (d['nameId'] ?? d['name_id'] ?? '').toString(),
      nameEn: (d['nameEn'] ?? d['name_en'] ?? '').toString(),
      order: d['order'] is int
          ? d['order'] as int
          : int.tryParse('${d['order'] ?? 1}') ?? 1,
      active: d['active'] == true,
      isParent: false,
      icon: (d['icon'] ?? d['iconAsset'])?.toString(),
    );
  }

  /// Backward-compat: 기존 코드의 `Category.fromFirestore(doc)` 호출을 지원합니다.
  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final collectionId = doc.reference.parent.id;
    if (collectionId == 'subCategories') {
      final parentRef = doc.reference.parent.parent;
      final parentId = parentRef?.id ?? '';
      return Category.fromSubDoc(parentId, doc);
    }
    return Category.fromParentDoc(doc);
  }

  /// 모델 -> Firestore(Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'slug': slug,
      'nameKo': nameKo,
      'nameId': nameId,
      'nameEn': nameEn,
      'order': order,
      'active': active,
      'isParent': isParent,
      'icon': icon,
    };
  }

  Map<String, dynamic> toParentMap() => {
        'slug': slug,
        'nameKo': nameKo,
        'nameId': nameId,
        'nameEn': nameEn,
        'order': order,
        'active': active,
        'isParent': true,
        if (icon != null && icon!.isNotEmpty)
          'icon':
              icon!.startsWith('ms:') ? icon : CategoryIcons.basename(icon!),
      };

  Map<String, dynamic> toSubMap() => {
        'slug': slug,
        'nameKo': nameKo,
        'nameId': nameId,
        'nameEn': nameEn,
        'order': order,
        'active': active,
        if (icon != null && icon!.isNotEmpty)
          'icon':
              icon!.startsWith('ms:') ? icon : CategoryIcons.basename(icon!),
      };

  String displayName(String lang) {
    switch (lang) {
      case 'ko':
        return nameKo.isNotEmpty
            ? nameKo
            : (nameId.isNotEmpty
                ? nameId
                : (nameEn.isNotEmpty ? nameEn : slug));
      case 'id':
        return nameId.isNotEmpty
            ? nameId
            : (nameKo.isNotEmpty
                ? nameKo
                : (nameEn.isNotEmpty ? nameEn : slug));
      default:
        return nameEn.isNotEmpty
            ? nameEn
            : (nameId.isNotEmpty
                ? nameId
                : (nameKo.isNotEmpty ? nameKo : slug));
    }
  }

  /// UI에서 바로 쓸 에셋 경로
  String get iconAssetPath =>
      CategoryIcons.resolve(icon: icon, slug: slug, isParent: isParent);

  /// 실제 사용할 아이콘 코드('ms:*').
  /// 비어있으면 nameEn/slug 기반 추천값을 돌려줌.
  String effectiveIcon({required bool forParent}) =>
      (icon != null && icon!.isNotEmpty)
          ? icon!
          : (forParent
              ? CategoryIcons.suggestForParent(nameEn: nameEn, slug: slug)
              : CategoryIcons.suggestForSub(nameEn: nameEn, slug: slug));

  Category copyWith({
    String? id,
    String? parentId,
    String? slug,
    String? nameKo,
    String? nameId,
    String? nameEn,
    int? order,
    bool? active,
    bool? isParent,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      slug: slug ?? this.slug,
      nameKo: nameKo ?? this.nameKo,
      nameId: nameId ?? this.nameId,
      nameEn: nameEn ?? this.nameEn,
      order: order ?? this.order,
      active: active ?? this.active,
      isParent: isParent ?? this.isParent,
      icon: icon ?? this.icon,
    );
  }
}
