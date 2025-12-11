import 'dart:math' as math;

// Payload: { 'userLat': double?, 'userLng': double?, 'points': List<Map<String,double>?> }
// Returns: List<double?> distances in same order (km), null if point missing or user missing
List<double?> computeDistancesIsolate(Map<String, dynamic> payload) {
  final userLat = payload['userLat'] as double?;
  final userLng = payload['userLng'] as double?;
  final points = payload['points'] as List<dynamic>?;

  if (userLat == null || userLng == null || points == null) {
    return List<double?>.filled(points?.length ?? 0, null);
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  final List<double?> results = List<double?>.filled(points.length, null);
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    if (p == null) {
      results[i] = null;
      continue;
    }
    final lat = (p['lat'] as num?)?.toDouble();
    final lng = (p['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      results[i] = null;
      continue;
    }
    results[i] = haversine(userLat, userLng, lat, lng);
  }

  return results;
}
