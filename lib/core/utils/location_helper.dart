// lib/core/utils/location_helper.dart

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

/// 두 GeoPoint 지점 간의 거리를 킬로미터(km) 단위로 계산합니다.
///
/// Haversine 공식을 사용하여 지구 표면의 곡률을 고려합니다.
double getDistanceBetween(GeoPoint point1, GeoPoint point2) {
  const double earthRadiusKm = 6371;

  final double lat1 = point1.latitude;
  final double lon1 = point1.longitude;
  final double lat2 = point2.latitude;
  final double lon2 = point2.longitude;

  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);

  final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
      (math.cos(_degreesToRadians(lat1)) *
          math.cos(_degreesToRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2));

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusKm * c;
}

/// 도(degree) 단위를 라디안(radian)으로 변환합니다.
double _degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
}

/// GeoPoint가 null인지 확인하고, 유효한 경우 거리를 계산하여 포맷팅된 문자열로 반환합니다.
/// (예: "1.2 km")
///
/// 두 GeoPoint 중 하나라도 null이면 빈 문자열을 반환합니다.
String? formatDistanceBetween(GeoPoint? userLocation, GeoPoint? itemLocation) {
  if (userLocation == null || itemLocation == null) {
    return null;
  }
  final double distance = getDistanceBetween(userLocation, itemLocation);
  // 0.1km 미만은 100m 등으로 표시할 수 있으나, 우선 km로 통일합니다.
  return '${distance.toStringAsFixed(1)} km';
}
