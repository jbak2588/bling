import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMapView extends StatelessWidget {
  final GeoPoint location;
  final String markerId;
  final double height;

  const MiniMapView({
    super.key,
    required this.location,
    required this.markerId,
    this.height = 180.0,
  });

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
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId(markerId),
              position: target,
            ),
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
        ),
      ),
    );
  }
}