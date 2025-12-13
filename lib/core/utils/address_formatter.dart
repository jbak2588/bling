// lib/core/utils/address_formatter.dart

/// 주소 표시와 관련된 공통 함수들을 관리합니다.
class AddressFormatter {
  /// 전체 주소 문자열에서 국가명(기본: Indonesia)을 제거해 표시를 단순화합니다.
  /// Privacy 목적: street/rt/rw 등의 상세 주소는 여기서 제거하지 않습니다.
  /// (상세 주소 제거는 locationParts 기반 표시를 우선 권장)
  static String removeCountrySuffix(String? address,
      {String country = 'Indonesia'}) {
    if (address == null) return '';
    return address
        .replaceAll(
          RegExp(r',?\s*' + country + r'$', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r',?\s*' + country + r'\b', caseSensitive: false),
          '',
        )
        .trim();
  }

  /// LocationProvider.adminFilter(Prov/Kab/Kec/Kel 선택 깊이)에 따라
  /// 피드(카드/목록/상세 공통)에서 표시할 주소를 동적으로 구성합니다.
  /// - street/rt/rw는 포함하지 않습니다.
  /// - Prov+Kab+Kec가 선택된 경우: Kel만 표시(가능할 때)
  /// - 그 외: Kec/Kab/Prov를 상황에 따라 추가
  ///
  /// [fallbackFullAddress]는 locationParts가 없거나 표시 파츠가 비어 있을 때만 사용됩니다.
  static String dynamicAdministrativeAddress({
    required Map<String, dynamic>? locationParts,
    required Map<String, String?> adminFilter,
    String? fallbackFullAddress,
  }) {
    if (locationParts == null) return removeCountrySuffix(fallbackFullAddress);

    final kel = (locationParts['kel'] ?? '').toString().trim();
    final kec = (locationParts['kec'] ?? '').toString().trim();
    final kab =
        (locationParts['kab'] ?? locationParts['kota'] ?? '').toString().trim();
    final prov = (locationParts['prov'] ?? '').toString().trim();

    final hasProv = (adminFilter['prov'] ?? '').trim().isNotEmpty;
    final hasKab = (adminFilter['kab'] ?? '').trim().isNotEmpty;
    final hasKec = (adminFilter['kec'] ?? '').trim().isNotEmpty;

    final displayParts = <String>[];

    if (kel.isNotEmpty) displayParts.add('Kel. $kel');

    // Prov + Kab + Kec 선택됨 -> Kel 만 표시 (가능할 때)
    // 그 외의 경우 상위 주소를 단계적으로 추가
    if (!(hasProv && hasKab && hasKec)) {
      if (kec.isNotEmpty) displayParts.add('Kec. $kec');

      // Prov만 선택/전국 등 상위 필터일 때 Kab를 더 보여주어 맥락을 유지
      if (!hasKab && !hasKec) {
        if (kab.isNotEmpty) displayParts.add(kab);
      }

      // 전국(필터 없음)일 때 Prov까지 노출
      if (!hasProv && !hasKab && !hasKec) {
        if (prov.isNotEmpty) displayParts.add(prov);
      }
    }

    if (displayParts.isNotEmpty) return displayParts.join(', ');
    return removeCountrySuffix(fallbackFullAddress);
  }

  /// locationParts 맵(kel, kab 등)에서 kel/kab만 약어로 조합합니다.
  /// street/rt/rw는 포함하지 않아 개인정보를 보호합니다.
  static String formatKelKabFromParts(Map<String, dynamic>? parts) {
    if (parts == null) return '';

    final kel = (parts['kel'] ?? '').toString().trim();
    final kab = (parts['kab'] ?? parts['kota'] ?? '').toString().trim();

    final display = <String>[];
    if (kel.isNotEmpty) display.add('Kel. $kel');
    if (kab.isNotEmpty) display.add('Kab. $kab');

    return display.join(', ');
  }

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
