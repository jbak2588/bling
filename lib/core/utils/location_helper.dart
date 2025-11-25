/// ============================================================================
/// Bling DocHeader
/// Module        : Core Utils
/// File          : lib/core/utils/location_helper.dart
/// Purpose       : GPS 위치 확인, 좌표-주소 변환(Geocoding), 주소 파싱, 거리 계산 유틸리티
/// Dependencies  : geolocator, geocoding (pubspec.yaml 확인 필요), cloud_firestore
/// ============================================================================
library;

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스를 켤 수 있도록 설정창으로 유도하거나 에러 처리
      // await Geolocator.openLocationSettings(); // 선택 사항
      throw Exception("위치 서비스(GPS)가 꺼져 있습니다.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("위치 권한이 거부되었습니다.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  static Future<String?> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // 주소 조합: 도로명(street)이 가장 정확한 상세 주소임
        List<String> parts = [
          place.street ?? '', // 상세 주소 (예: Jl. Gn. Mahkota No.12)
          place.subLocality ?? '', // Kelurahan
          place.locality ?? '', // Kecamatan
          place.subAdministrativeArea ?? '', // Kabupaten/Kota
          place.administrativeArea ?? '', // Province
          place.postalCode ?? ''
        ];
        // 중복 제거 및 빈 값 제거
        return parts.where((s) => s.isNotEmpty).toSet().join(', ');
      }
    } catch (e) {
      throw Exception("주소 변환 실패: $e");
    }
    return null;
  }

  /// 행정구역 명칭 정규화
  static String cleanName(String name) {
    String cleaned = name.trim();
    final prefixes = [
      'Provinsi ',
      'Prov. ',
      'Kabupaten ',
      'Kab. ',
      'Kota ',
      'Kecamatan ',
      'Kec. ',
      'Kelurahan ',
      'Kel. ',
      'Desa '
    ];
    for (var prefix in prefixes) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleaned = cleaned.substring(prefix.length).trim();
      }
    }
    if (cleaned.toLowerCase().endsWith(' city')) {
      cleaned = cleaned.substring(0, cleaned.length - 5).trim();
    }
    return cleaned;
  }

  /// Placemark 객체로부터 정교한 파싱 (추천)
  static Map<String, dynamic> parsePlacemark(Placemark place) {
    return {
      'prov': place.administrativeArea != null
          ? cleanName(place.administrativeArea!)
          : null,
      'kab': place.subAdministrativeArea != null
          ? cleanName(place.subAdministrativeArea!)
          : null,
      'kec': place.locality != null ? cleanName(place.locality!) : null,
      'kel': place.subLocality != null ? cleanName(place.subLocality!) : null,
      'street': place.street, // ✅ 상세 주소 추가
      'postalCode': place.postalCode,
      'country': place.country,
    };
  }

  /// 문자열 기반 파싱 (Fallback)
  static Map<String, dynamic> parseAddress(String address) {
    final Map<String, dynamic> parts = {
      'prov': null,
      'kab': null,
      'kec': null,
      'kel': null,
      'street': null, // 상세 주소 필드 추가
    };

    // 상세 주소 추출 시도: 보통 맨 앞부분이 도로명 주소임
    final tokens = address.split(',').map((e) => e.trim()).toList();
    if (tokens.isNotEmpty) {
      parts['street'] = tokens.first;
    }

    for (var token in tokens) {
      final lowerToken = token.toLowerCase();
      if (lowerToken.startsWith('prov') ||
          lowerToken.contains('jawa') ||
          lowerToken.contains('banten')) {
        parts['prov'] = cleanName(token);
      } else if (lowerToken.startsWith('kab') ||
          lowerToken.startsWith('kota')) {
        parts['kab'] = cleanName(token);
      } else if (lowerToken.startsWith('kec')) {
        parts['kec'] = cleanName(token);
      } else if (lowerToken.startsWith('kel') ||
          lowerToken.startsWith('desa')) {
        parts['kel'] = cleanName(token);
      }
    }
    return parts;
  }

  static double getDistanceBetween(GeoPoint point1, GeoPoint point2) {
    const double earthRadiusKm = 6371;
    final double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final double dLon = _degreesToRadians(point2.longitude - point1.longitude);
    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(point1.latitude)) *
            math.cos(_degreesToRadians(point2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static String? formatDistanceBetween(
      GeoPoint? userLocation, GeoPoint? itemLocation) {
    if (userLocation == null || itemLocation == null) return null;
    final double distance = getDistanceBetween(userLocation, itemLocation);
    return '${distance.toStringAsFixed(1)} km';
  }
}

// 하위 호환성 래퍼
double getDistanceBetween(GeoPoint point1, GeoPoint point2) =>
    LocationHelper.getDistanceBetween(point1, point2);
String? formatDistanceBetween(GeoPoint? userLocation, GeoPoint? itemLocation) =>
    LocationHelper.formatDistanceBetween(userLocation, itemLocation);
