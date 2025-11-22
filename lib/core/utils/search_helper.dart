// lib/core/utils/search_helper.dart

class SearchHelper {
  /// 검색용 키워드 배열 생성 (띄어쓰기 단위 분리 + 소문자 변환)
  /// [title]: 제목/이름 (필수)
  /// [tags]: 태그 목록 (선택)
  /// [description]: 설명/내용 (선택, 너무 긴 내용은 제외 권장)
  static List<String> generateSearchIndex({
    String? title,
    List<String> tags = const [],
    String? description,
  }) {
    final Set<String> keywords = {};

    // 텍스트 전처리 및 토큰화 함수
    List<String> tokenize(String? text) {
      if (text == null || text.isEmpty) return [];
      return text
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s가-힣]'), '') // 특수문자 제거 (선택 사항)
          .split(RegExp(r'\s+')) // 공백으로 분리
          .where((w) => w.length >= 1) // 1글자 이상만 포함
          .toList();
    }

    // 1. 제목 키워드 추가
    keywords.addAll(tokenize(title));

    // 2. 태그 키워드 추가 (원본 + 토큰)
    for (var tag in tags) {
      keywords.add(tag.toLowerCase()); // 태그 원본 (띄어쓰기 포함)
      keywords.addAll(tokenize(tag)); // 태그 내 단어 분리
    }

    // 3. 설명 키워드 추가 (필요 시 주석 해제, 인덱스 용량 고려)
    // keywords.addAll(tokenize(description));

    return keywords.toList();
  }
}
