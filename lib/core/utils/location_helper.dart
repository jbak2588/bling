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
  /// 현재 기기의 GPS 위치(위도, 경도)를 가져옵니다.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("위치 서비스(GPS)가 꺼져 있습니다. 켜주세요.");
    }

    // 2. 위치 권한 확인 및 요청
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

    // 3. 현재 위치 가져오기 (최신 API 적용)
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10), // 10초 타임아웃
      ),
    );
  }

  /// 좌표(Position)를 주소 문자열로 변환합니다 (Reverse Geocoding).
  static Future<String?> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // 주소 조합 로직
        List<String> parts = [
          place.street ?? '',
          place.subLocality ?? '', // Kelurahan
          place.locality ?? '', // Kecamatan
          place.subAdministrativeArea ?? '', // Kabupaten/Kota
          place.administrativeArea ?? '', // Province
          place.postalCode ?? ''
        ];
        return parts.where((s) => s.isNotEmpty).join(', ');
      }
    } catch (e) {
      throw Exception("주소 변환 실패: $e");
    }
    return null;
  }

  /// 주소 문자열을 분석하여 행정구역 맵으로 변환
  static Map<String, dynamic> parseAddress(String address) {
    final Map<String, dynamic> parts = {
      'prov': null,
      'kab': null,
      'kec': null,
      'kel': null,
    };

    final tokens = address.split(',').map((e) => e.trim()).toList();

    for (var token in tokens) {
      final lowerToken = token.toLowerCase();

      if (lowerToken.startsWith('provinsi') ||
          lowerToken.contains('jawa') ||
          lowerToken.contains('jakarta') ||
          lowerToken.contains('banten') ||
          lowerToken.contains('bali')) {
        parts['prov'] = token;
      } else if (lowerToken.startsWith('kabupaten') ||
          lowerToken.startsWith('kab.') ||
          lowerToken.startsWith('kota')) {
        parts['kab'] = token;
      } else if (lowerToken.startsWith('kecamatan') ||
          lowerToken.startsWith('kec.')) {
        parts['kec'] = token;
      } else if (lowerToken.startsWith('kelurahan') ||
          lowerToken.startsWith('kel.') ||
          lowerToken.startsWith('desa')) {
        parts['kel'] = token;
      }
    }
    return parts;
  }

  /// 거리 계산 (Haversine)
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
    if (userLocation == null || itemLocation == null) {
      return null;
    }
    final double distance = getDistanceBetween(userLocation, itemLocation);
    return '${distance.toStringAsFixed(1)} km';
  }
}

// ✅ [하위 호환성 유지] 기존 전역 함수 래퍼
double getDistanceBetween(GeoPoint point1, GeoPoint point2) =>
    LocationHelper.getDistanceBetween(point1, point2);

String? formatDistanceBetween(GeoPoint? userLocation, GeoPoint? itemLocation) =>
    LocationHelper.formatDistanceBetween(userLocation, itemLocation);
