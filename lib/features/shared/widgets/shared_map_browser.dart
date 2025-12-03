import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

/// [공용 위젯] 데이터 스트림을 받아 지도 위에 마커를 표시하고,
/// 클릭 시 상세 정보를 BottomSheet로 보여주는 지도 브라우저입니다.
class SharedMapBrowser<T> extends StatefulWidget {
  /// 표시할 데이터 리스트 스트림 (예: 상점 목록, 매물 목록)
  final Stream<List<T>> dataStream;

  /// 각 아이템(T)에서 좌표(GeoPoint)를 추출하는 함수
  final GeoPoint? Function(T) locationExtractor;

  /// 각 아이템(T)의 고유 ID를 추출하는 함수 (마커 ID용)
  final String Function(T) idExtractor;

  /// 마커 클릭 시 보여줄 상세 정보 카드 빌더
  final Widget Function(BuildContext, T) cardBuilder;

  /// (선택) 초기 카메라 위치 (없으면 기본값 사용)
  final CameraPosition? initialCameraPosition;

  /// (선택) 커스텀 마커 아이콘 (없으면 기본 핀 사용)
  final BitmapDescriptor? customMarkerIcon;

  const SharedMapBrowser({
    super.key,
    required this.dataStream,
    required this.locationExtractor,
    required this.idExtractor,
    required this.cardBuilder,
    this.initialCameraPosition,
    this.customMarkerIcon,
  });

  @override
  State<SharedMapBrowser> createState() => _SharedMapBrowserState<T>();
}

class _SharedMapBrowserState<T> extends State<SharedMapBrowser<T>> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: widget.dataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('common.error'.tr()));
        }

        final items = snapshot.data ?? [];
        // Debug: log how many items arrived and first few geoPoints to help
        // diagnose maps-without-pins issues (non-invasive, no behavior change).
        if (kDebugMode) {
          debugPrint('[SharedMapBrowser] received ${items.length} items');
          for (var i = 0; i < items.length && i < 5; i++) {
            final gp = widget.locationExtractor(items[i]);
            debugPrint('[SharedMapBrowser] item[$i] geoPoint=$gp');
          }
        }

        if (items.isEmpty) {
          // 데이터가 없을 때도 지도는 보여주되 마커만 없음
          // (혹은 빈 화면 메시지를 보여줄 수도 있음)
        }

        // 마커 생성
        _markers = items
            .map((item) {
              final geoPoint = widget.locationExtractor(item);
              if (geoPoint == null) return null;

              final markerId = widget.idExtractor(item);

              return Marker(
                markerId: MarkerId(markerId),
                position: LatLng(geoPoint.latitude, geoPoint.longitude),
                icon: widget.customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                onTap: () {
                  // 마커 클릭 시 BottomSheet 표시
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      minChildSize: 0.2,
                      maxChildSize: 0.8,
                      builder: (_, controller) => SingleChildScrollView(
                        controller: controller,
                        child: widget.cardBuilder(context, item),
                      ),
                    ),
                  );
                },
              );
            })
            .whereType<Marker>()
            .toSet();

        return GoogleMap(
          initialCameraPosition: widget.initialCameraPosition ??
              const CameraPosition(
                target: LatLng(-6.2088, 106.8456), // 자카르타 기본값
                zoom: 13,
              ),
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        );
      },
    );
  }
}
