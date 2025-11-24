/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/providers/location_provider.dart
/// Purpose       : 앱 전역의 위치 필터 및 검색 모드를 관리하는 상태 관리자입니다.
/// User Impact   : 사용자가 설정한 지역/거리 조건이 모든 피드 화면에 일관되게 적용됩니다.
/// ============================================================================
library;

import 'package:bling_app/core/models/user_model.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// easy_localization compatibility removed; using Slang `t[...]`
import 'package:flutter/material.dart';

enum LocationSearchMode {
  administrative, // 행정구역 기반 (Prov, Kab, Kec, Kel)
  nearby, // 거리 기반 (GeoPoint 반경)
  national, // 전국 (필터 없음)
}

class LocationProvider extends ChangeNotifier {
  // 현재 검색 모드
  LocationSearchMode _mode = LocationSearchMode.national;

  // 행정구역 필터 상태
  Map<String, String?> _adminFilter = {
    'prov': null,
    'kab': null,
    'kec': null,
    'kel': null,
  };

  // 거리 기반 설정
  double _radiusKm = 5.0; // 기본 5km

  // 사용자 기본 정보 (로그인 시 설정)
  UserModel? _user;

  LocationSearchMode get mode => _mode;
  Map<String, String?> get adminFilter => _adminFilter;
  double get radiusKm => _radiusKm;
  UserModel? get user => _user;

  // 사용자 로그인/정보 업데이트 시 호출
  void setUser(UserModel? user) {
    _user = user;
    // 초기값: 사용자의 기본 위치가 있다면 행정구역 모드로 설정, 없으면 전국
    if (_mode == LocationSearchMode.national && user?.locationParts != null) {
      // 초기 진입 시 사용자 위치로 자동 설정 (보스 요청 반영)
      // 단, 사용자가 의도적으로 바꾼 상태를 덮어쓰지 않도록 체크 가능
      _mode = LocationSearchMode.administrative;
      _adminFilter = Map<String, String?>.from(user!.locationParts!);
    }
    notifyListeners();
  }

  // 모드 변경
  void setMode(LocationSearchMode mode) {
    _mode = mode;
    notifyListeners();
  }

  // 행정구역 필터 업데이트 (유연한 선택)
  void setAdminFilter({
    String? prov,
    String? kab,
    String? kec,
    String? kel,
  }) {
    _mode = LocationSearchMode.administrative;
    _adminFilter = {
      'prov': prov,
      'kab': kab,
      'kec': kec,
      'kel': kel,
    };
    notifyListeners();
  }

  // 거리 설정 업데이트
  void setNearbyRadius(double km) {
    _mode = LocationSearchMode.nearby;
    _radiusKm = km;
    notifyListeners();
  }

  // Firestore 쿼리용 활성 필터 키-값 쌍 반환
  // (가장 구체적인 행정구역 단위를 찾아 반환)
  MapEntry<String, String>? get activeQueryFilter {
    if (_mode != LocationSearchMode.administrative) return null;

    if (_adminFilter['kel'] != null && _adminFilter['kel']!.isNotEmpty) {
      return MapEntry('locationParts.kel', _adminFilter['kel']!);
    }
    if (_adminFilter['kec'] != null && _adminFilter['kec']!.isNotEmpty) {
      return MapEntry('locationParts.kec', _adminFilter['kec']!);
    }
    if (_adminFilter['kab'] != null && _adminFilter['kab']!.isNotEmpty) {
      return MapEntry('locationParts.kab', _adminFilter['kab']!);
    }
    if (_adminFilter['prov'] != null && _adminFilter['prov']!.isNotEmpty) {
      return MapEntry('locationParts.prov', _adminFilter['prov']!);
    }
    return null; // 전국
  }

  // UI 표시용 타이틀
  String get displayTitle {
    switch (_mode) {
      case LocationSearchMode.national:
        return t.locationfilter.national.title; // ✅ 다국어 키 적용
      case LocationSearchMode.nearby:
        // ✅ 다국어 키 적용 + 인자 전달
        return t.locationfilter.nearby.radius
            .replaceAll('{km}', _radiusKm.toInt().toString());
      case LocationSearchMode.administrative:
        // 가장 하위 행정구역 이름 표시
        if (_adminFilter['kel'] != null) return _adminFilter['kel']!;
        if (_adminFilter['kec'] != null) return _adminFilter['kec']!;
        if (_adminFilter['kab'] != null) return _adminFilter['kab']!;
        if (_adminFilter['prov'] != null) return _adminFilter['prov']!;
        return t.locationfilter.hint.selectParent; // 또는 적절한 기본 문구
    }
  }
}
