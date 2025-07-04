// lib/core/utils/address_formatter.dart

/// 주소 표시와 관련된 공통 함수들을 관리합니다.
class AddressFormatter {
  /// 전체 주소 문자열을 받아, 'Kecamatan, Kabupaten' 형태의 약어로 변환합니다.
  /// 예: "Kelurahan Panunggangan Barat, Kecamatan Cibodas, Kabupaten Tangerang"
  /// -> "Kec. Cibodas, Kab. Tangerang"
  static String toSingkatan(String fullAddress) {
    if (fullAddress.isEmpty) return '';

    // 쉼표로 주소 단위를 분리합니다.
    final parts = fullAddress.split(',');

    String kecamatan = '';
    String kabupaten = '';

    for (var part in parts) {
      final trimmedPart = part.trim();
      if (trimmedPart.toLowerCase().startsWith('kecamatan')) {
        kecamatan = trimmedPart.replaceFirst('Kecamatan', 'Kec.');
      } else if (trimmedPart.toLowerCase().startsWith('kabupaten')) {
        kabupaten = trimmedPart.replaceFirst('Kabupaten', 'Kab.');
      } else if (trimmedPart.toLowerCase().startsWith('kota')) {
        // 'Kota'는 보통 약어 없이 사용되지만, 필요시 규칙 추가 가능
        kabupaten = trimmedPart;
      }
    }

    if (kecamatan.isNotEmpty && kabupaten.isNotEmpty) {
      return '$kecamatan, $kabupaten';
    } else if (kecamatan.isNotEmpty) {
      return kecamatan;
    } else if (kabupaten.isNotEmpty) {
      return kabupaten;
    }

    // 적절한 단위를 찾지 못하면 원본의 첫 부분을 반환
    return parts.first.trim();
  }
}
