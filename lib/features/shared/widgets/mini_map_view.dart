import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMapView extends StatelessWidget {
  final GeoPoint location;
  final String markerId;
  // [Fix] 작업 28의 myLocationEnabled 파라미터를 받도록 추가
  final bool myLocationEnabled;
  final double height;

  MiniMapView({
    super.key,
    GeoPoint? geoPoint,
    GeoPoint? location,
    required this.markerId,
    this.height = 180.0,
    this.myLocationEnabled = false, // 기본값은 false
  })  : assert(geoPoint != null || location != null),
        location = geoPoint ?? location!;

  @override
  Widget build(BuildContext context) {
    final target = LatLng(location.latitude, location.longitude);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: 16.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId(markerId),
              position: target,
            ),
          },
          myLocationEnabled: myLocationEnabled, // [Fix] 전달받은 값 적용
          myLocationButtonEnabled: false, // 사용 안 함
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
        ),
      ),
    );
  }
}
